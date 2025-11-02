import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'preference_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shape_mobile/db/app_database.dart';
import 'package:shape_mobile/models/StudentModel.dart';
import 'package:shape_mobile/models/LessonModel.dart';
import 'package:shape_mobile/models/VideoModel.dart';
import 'package:shape_mobile/models/GameActivityModel.dart';
import 'package:shape_mobile/models/GameActivityLessonModel.dart';
import 'package:shape_mobile/models/StudentActivityModel.dart';
import 'package:shape_mobile/models/FeedModel.dart';
import 'package:shape_mobile/models/AwardModel.dart';
import 'package:shape_mobile/models/StudentAwardModel.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  final String baseUrl = "http://10.0.2.2:8000/api";
  final PreferenceService _prefs = PreferenceService();

  Future<bool> loginStudent(
    String username,
    String password, {
    void Function(String)? onProgress,
  }) async {
    onProgress?.call("Sending login request...");

    final url = Uri.parse("$baseUrl/student/login");
    final response = await http.post(
      url,
      body: {"username": username, "password": password},
    );

    onProgress?.call("Processing...");
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final dataWrapper = data['data'];
      final studentJson = dataWrapper['student'];
      final lessonsJson = dataWrapper['lessons'] ?? [];
      final videosJson = dataWrapper['videos'] ?? [];
      final gameActivitiesJson = dataWrapper['game_activities'] ?? [];
      final gameActivityLessonsJson =
          dataWrapper['game_activity_lessons'] ?? [];
      final studentActivitiesJson = dataWrapper['student_activities'] ?? [];
      final feedsJson = dataWrapper['feeds'] ?? [];
      final awardsJson = dataWrapper['awards'] ?? [];
      final studentAwardsJson = dataWrapper['student_awards'] ?? [];

      // ✅ Download media (image/video) and replace path with local file path
      onProgress?.call("Downloading...");
      try {
        // ✅ Step 1: Download Student Profile
        String? mediaUrl = studentJson['path'];
        String? localMediaPath;

        if (mediaUrl != null && mediaUrl.isNotEmpty) {
          localMediaPath = await downloadFileToLocal(mediaUrl);
          if (localMediaPath == null) {
            throw ApiException("Failed to download student profile image");
          }
          studentJson['path'] = localMediaPath;
        }

        // ✅ Step 2: Download All Video Thumbnails (fail-fast)
        int totalVideos = videosJson.length;
        for (int i = 0; i < totalVideos; i++) {
          final videoJson = videosJson[i];
          final thumbnailUrl = videoJson['thumbnail'];

          if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
            final localThumbPath = await downloadFileToLocal(thumbnailUrl);

            if (localThumbPath == null) {
              return false;
            }

            videoJson['thumbnail'] = localThumbPath;
          }
        }

        for (final awardJson in awardsJson) {
          final pathUrl = awardJson['path'];
          if (pathUrl != null && pathUrl.isNotEmpty) {
            final localAwardPath = await downloadFileToLocal(pathUrl);
            if (localAwardPath == null) {
              return false;
            }
            awardJson['path'] = localAwardPath;
          }
        }
      } catch (e) {
        onProgress?.call("Download failed");
        print("❌ Stopping due to failure: $e");
        rethrow;
      }

      // ✅ Save in SharedPreferences
      onProgress?.call("Saving data locally...");
      await _prefs.saveLoginData(
        token: data['token'],
        studentId: studentJson['id'],
        fullname: studentJson['fullname'],
        lrn: studentJson['lrn'],
        avatarPath: studentJson['path'],
        status: studentJson['status'],
      );

      final student = Student.fromJson(studentJson);
      await AppDatabase.instance.insertStudent(student);

      for (var lessonJson in lessonsJson) {
        final lesson = Lesson.fromJson(lessonJson);
        await AppDatabase.instance.insertLesson(lesson);
      }

      for (var videoJson in videosJson) {
        final video = Video.fromJson(videoJson);
        await AppDatabase.instance.insertVideo(video);
      }

      for (final gameJson in gameActivitiesJson) {
        final game = GameActivity.fromJson(gameJson);
        await AppDatabase.instance.insertGameActivity(game);
      }

      for (final galJson in gameActivityLessonsJson) {
        final gal = GameActivityLesson.fromJson(galJson);
        await AppDatabase.instance.insertGameActivityLesson(gal);
      }

      for (final saJson in studentActivitiesJson) {
        final sa = StudentActivity.fromJson(saJson);
        await AppDatabase.instance.insertStudentActivity(sa);
      }

      for (final feedJson in feedsJson) {
        await AppDatabase.instance.insertFeed(Feed.fromJson(feedJson));
      }

      for (final awardJson in awardsJson) {
        await AppDatabase.instance.insertAward(Award.fromJson(awardJson));
      }

      for (final saJson in studentAwardsJson) {
        await AppDatabase.instance.insertStudentAward(
          StudentAward.fromJson(saJson),
        );
      }

      onProgress?.call("Success!");
      await PreferenceService.saveLastSyncTime(DateTime.now());
      return true;
    } else {
      throw ApiException(data['message'] ?? "Login failed");
    }
  }

  /// Downloads a file (image or video) and stores it locally with streaming
  Future<String?> downloadFileToLocal(
    String fileUrl, {
    void Function(double progress)? onProgress,
    int retryCount = 0,
  }) async {
    const int maxRetries = 10;
    final uri = Uri.parse(fileUrl);
    final fileName = uri.pathSegments.last;
    final directory = await getApplicationDocumentsDirectory();
    final localPath = "${directory.path}/$fileName";

    try {
      final client = HttpClient();
      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode == 200) {
        final file = File(localPath);
        if (await file.exists()) await file.delete();
        final raf = await file.open(mode: FileMode.write);

        final contentLength = response.contentLength;
        int received = 0;

        await for (var chunk in response) {
          raf.writeFromSync(chunk);
          received += chunk.length;
          if (onProgress != null && contentLength > 0) {
            onProgress(received / contentLength);
          }
        }

        await raf.close();
        client.close(force: true);

        print("✅ File successfully saved to: $localPath");
        return localPath;
      } else {
        throw Exception("Failed to download: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ File download error: $e");
      if (retryCount < maxRetries) {
        final nextTry = retryCount + 1;
        print("🔁 Retrying download... Attempt $nextTry/$maxRetries");
        await Future.delayed(Duration(seconds: 1));
        return downloadFileToLocal(
          fileUrl,
          onProgress: onProgress,
          retryCount: nextTry,
        );
      }
    }

    print("🚫 Download failed after $retryCount retries.");
    return null;
  }

  Future<bool> logout() async {
    final token = PreferenceService.token;
    if (token == null) return false;

    final url = Uri.parse("$baseUrl/student/logout");

    try {
      final response = await http
          .post(url, headers: {"Authorization": "Bearer $token"})
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        await _prefs.clearPreferences();
        await AppDatabase.instance.clearAllTables();
        await AppDatabase.instance.close();
        await _clearLocalFiles();
        print("✅ Logged out and cleared all local data.");
        return true;
      } else {
        throw Exception("server_error");
      }
    } catch (e) {
      print("❌ Logout failed: $e");
      return false;
    }
  }

  Future<void> _clearLocalFiles() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      if (await dir.exists()) {
        final entities = dir.listSync();
        for (var entity in entities) {
          if (entity is File) {
            await entity.delete();
          } else if (entity is Directory) {
            await entity.delete(recursive: true);
          }
        }
        print("🧹 All local files cleared from ${dir.path}");
      }
    } catch (e) {
      print("⚠️ Error clearing local files: $e");
    }
  }

  /// Syncs all unsynced student activities (is_synced = 0) with the server
  Future<bool> syncStudentActivities({
    void Function(String)? onProgress,
  }) async {
    final db = await AppDatabase.instance.database;
    onProgress?.call("Checking unsynced activities...");
    final unsyncedActivities = await db.query(
      'student_activities',
      where: 'is_synced = ?',
      whereArgs: [0],
    );

    if (unsyncedActivities.isEmpty) {
      onProgress?.call("No unsynced activities found.");
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }

    final activities = unsyncedActivities.map((activity) {
      return {
        'student_id': activity['student_id'],
        'activity_lesson_id': activity['activity_lesson_id'],
        'activity_lesson_type': activity['activity_lesson_type'],
        'status': activity['status'],
        'created_at': activity['created_at'],
        'updated_at': activity['updated_at'],
      };
    }).toList();

    final url = Uri.parse('$baseUrl/student/sync-activity');
    final token = PreferenceService.token;

    try {
      onProgress?.call("Uploading ${activities.length} activities...");

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'activities': activities}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw ApiException("connection_timeout"),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        onProgress?.call("Updating local data...");

        for (final row in unsyncedActivities) {
          await db.update(
            'student_activities',
            {'is_synced': 1},
            where: 'id = ?',
            whereArgs: [row['id']],
          );
        }

        onProgress?.call("Sync complete!");
        print('✅ Synced successfully: ${data['synced_ids']}');
        return true;
      } else {
        onProgress?.call("Failed to sync activities.");
        print('❌ Sync failed: ${response.body}');
        throw ApiException('Failed to sync activities: ${response.body}');
      }
    } on ApiException catch (e) {
      onProgress?.call(
        e.message == "connection_timeout"
            ? "Connection timed out. Please check your internet."
            : e.message,
      );
      throw e;
    } catch (e) {
      onProgress?.call("Connection error.");
      print('⚠️ Error syncing student activities: $e');
      throw ApiException(e.toString());
    }
  }
}
