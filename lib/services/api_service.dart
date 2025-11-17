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
  final String baseUrl = "https://shape-dlhms.site/api";
  final PreferenceService _prefs = PreferenceService();

  Future<bool> loginStudent(
    String username,
    String password, {
    void Function(String)? onProgress,
  }) async {
    onProgress?.call("Sending login request...");

    // final url = Uri.parse("$baseUrl/student/login");
    final url = Uri.https("shape-dlhms.site", "/api/student/login");
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
          await PreferenceService.saveDownloadedFile(mediaUrl, localMediaPath);
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
            await PreferenceService.saveDownloadedFile(
              thumbnailUrl,
              localThumbPath,
            );
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
            await PreferenceService.saveDownloadedFile(pathUrl, localAwardPath);
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
        latestSchoolYearId: data['current_school_year_id'],
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

  Future<bool> fetchAndSyncStudentData({
    void Function(String)? onProgress,
  }) async {
    final studentId = PreferenceService.studentId;
    if (studentId == null) return false;

    final db = AppDatabase.instance;
    // final url = Uri.parse("$baseUrl/student/sync-all");
    final url = Uri.https("shape-dlhms.site", "/api/student/sync-all");
    final token = PreferenceService.token;

    // 1️⃣ Sync local activities first
    onProgress?.call("Syncing local activities...");
    final activitiesSynced = await updateStudentActivities(
      onProgress: onProgress,
    );
    if (!activitiesSynced) return false;

    // 2️⃣ Fetch data from server
    onProgress?.call("Fetching updated student data...");
    print("Sending sync request...");
    print("student_id: $studentId");
    print("last_sync_time: ${PreferenceService.lastSyncTime}");
    print("last_school_year_id: ${PreferenceService.latestSchoolYearId}");
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'student_id': studentId,
              'last_sync_time': PreferenceService.lastSyncTime,
              'last_school_year_id': PreferenceService.latestSchoolYearId,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw ApiException("connection_timeout"),
          );
      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');
      final data = jsonDecode(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        throw ApiException(data['message'] ?? "Failed to fetch student data");
      }

      // ✅ NEW: Handle new school year reset
      if (data['new_school_year'] == true) {
        onProgress?.call("New school year detected. Logging out...");

        final logoutSuccess = await logout();

        if (logoutSuccess) {
          print("🧹 Logged out due to new school year.");
          await _prefs.clearPreferences();
          await AppDatabase.instance.clearAllTables();
          await AppDatabase.instance.close();
          await _clearLocalFiles();
          throw ApiException("New School Year");
        }
      }

      // 3️⃣ Extract JSON
      final studentJson = data['student'];
      final lessonsJson = data['lessons'] ?? [];
      final videosJson = data['videos'] ?? [];
      final gameActivitiesJson = data['game_activities'] ?? [];
      final gameActivityLessonsJson = data['game_activity_lessons'] ?? [];
      final studentActivitiesJson = data['student_activities'] ?? [];
      final feedsJson = data['feeds'] ?? [];
      final awardsJson = data['awards'] ?? [];
      final studentAwardsJson = data['student_awards'] ?? [];

      final reset = data['reset'] == true;

      if (reset) {
        onProgress?.call("Reset detected. Clearing selected local tables...");

        // Clear only specific tables
        await db.deleteGameActivityLessonTable();
        await db.deleteGameActivityTable();
        await db.deleteVideoTable();
        await db.deleteLessonTable();
        await db.deleteStudentActivityTable();
      }

      // -----------------------
      // 4️⃣ Helper: Check or download file
      // -----------------------
      Future<String?> getOrDownloadFile(String? remoteUrl) async {
        if (remoteUrl == null || remoteUrl.isEmpty) return null;

        String? cachedPath = await PreferenceService.getDownloadedFile(
          remoteUrl,
        );
        if (cachedPath != null && await File(cachedPath).exists()) {
          return cachedPath;
        }

        final localPath = await downloadFileToLocal(remoteUrl);
        if (localPath != null) {
          await PreferenceService.saveDownloadedFile(remoteUrl, localPath);
        }
        return localPath;
      }

      // -----------------------
      // 5️⃣ Pre-download media
      // -----------------------
      onProgress?.call("Downloading media...");

      // Student avatar
      if (studentJson['path'] != null) {
        studentJson['path'] =
            await getOrDownloadFile(studentJson['path']) ?? studentJson['path'];
      }

      // Video thumbnails
      for (final video in videosJson) {
        if (video['thumbnail'] != null) {
          video['thumbnail'] =
              await getOrDownloadFile(video['thumbnail']) ?? video['thumbnail'];
        }
      }

      // Award images
      for (final award in awardsJson) {
        if (award['path'] != null) {
          award['path'] =
              await getOrDownloadFile(award['path']) ?? award['path'];
        }
      }

      // -----------------------
      // 6️⃣ Upsert/Delete helper with media cleanup
      // -----------------------
      Future<void> upsertOrDeleteWithMedia(
        Map<String, dynamic> json,
        Future<void> Function(Map<String, dynamic>) insert,
        Future<void> Function(int) delete, {
        List<String> mediaKeys = const [],
      }) async {
        if (json['deleted_at'] != null) {
          // Delete local files first
          for (final key in mediaKeys) {
            final path = json[key] as String?;
            if (path != null && path.isNotEmpty) {
              final file = File(path);
              if (await file.exists()) await file.delete();
            }
          }
          await delete(json['id']);
        } else {
          await insert(json);
        }
      }
      // -----------------------
      // 7️⃣ Insert or delete all data
      // -----------------------

      onProgress?.call("Updating local preferences...");

      // Update last sync time **before database** so cache is fresh
      await PreferenceService.saveLastSyncTime(DateTime.now());

      // Update student-specific cache immediately
      if (studentJson['id'] != null) {
        PreferenceService.studentId = studentJson['id'];
      }
      if (studentJson['fullname'] != null) {
        PreferenceService.fullname = studentJson['fullname'];
      }
      if (studentJson['lrn'] != null) {
        PreferenceService.lrn = studentJson['lrn'];
      }
      if (studentJson['status'] != null) {
        PreferenceService.status = studentJson['status'];
      }
      if (studentJson['path'] != null) {
        PreferenceService.avatarPath = studentJson['path'];
      }
      // -----------------------
      // 8️⃣ Insert or delete all data
      // -----------------------

      onProgress?.call("Updating local database...");

      // Student
      await upsertOrDeleteWithMedia(
        studentJson,
        (json) => db.insertStudent(Student.fromJson(json)),
        (id) => db.deleteStudent(id),
        mediaKeys: ['path'],
      );

      // Lessons
      for (final json in lessonsJson) {
        await upsertOrDeleteWithMedia(
          json,
          (json) => db.insertLesson(Lesson.fromJson(json)),
          (id) => db.deleteLesson(id),
        );
      }

      // Videos
      for (final json in videosJson) {
        await upsertOrDeleteWithMedia(
          json,
          (json) => db.insertVideo(Video.fromJson(json)),
          (id) => db.deleteVideo(id),
          mediaKeys: ['thumbnail', 'url'],
        );
      }

      // Game Activities
      for (final json in gameActivitiesJson) {
        await upsertOrDeleteWithMedia(
          json,
          (json) => db.insertGameActivity(GameActivity.fromJson(json)),
          (id) => db.deleteGameActivity(id),
        );
      }

      // Game Activity Lessons
      for (final json in gameActivityLessonsJson) {
        await upsertOrDeleteWithMedia(
          json,
          (json) =>
              db.insertGameActivityLesson(GameActivityLesson.fromJson(json)),
          (id) => db.deleteGameActivityLesson(id),
        );
      }

      // Student Activities
      for (final json in studentActivitiesJson) {
        await upsertOrDeleteWithMedia(
          json,
          (json) => db.insertStudentActivity(StudentActivity.fromJson(json)),
          (id) => db.deleteStudentActivity(id),
        );
      }

      // Feeds
      for (final json in feedsJson) {
        await upsertOrDeleteWithMedia(
          json,
          (json) => db.insertFeed(Feed.fromJson(json)),
          (id) => db.deleteFeed(id),
        );
      }

      // Awards
      for (final json in awardsJson) {
        await upsertOrDeleteWithMedia(
          json,
          (json) => db.insertAward(Award.fromJson(json)),
          (id) => db.deleteAward(id),
          mediaKeys: ['path'],
        );
      }

      // Student Awards
      for (final json in studentAwardsJson) {
        await upsertOrDeleteWithMedia(
          json,
          (json) => db.insertStudentAward(StudentAward.fromJson(json)),
          (id) => db.deleteStudentAward(id),
        );
      }

      // 8️⃣ Finalize
      onProgress?.call("Sync complete!");
      await PreferenceService.saveLastSyncTime(DateTime.now());
      return true;
    } on ApiException catch (e) {
      onProgress?.call(
        e.message == "connection_timeout"
            ? "Connection timed out. Check your internet."
            : e.message,
      );
      rethrow;
    } catch (e) {
      onProgress?.call("Error fetching student data");
      print('⚠️ Error: $e');
      throw ApiException(e.toString());
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

    // final url = Uri.parse("$baseUrl/student/logout");
    final url = Uri.https("shape-dlhms.site", "/api/student/logout");

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
  Future<bool> updateStudentActivities({
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
      onProgress?.call("No unsynced data found.");
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }

    // final url = Uri.parse('$baseUrl/student/sync-activity');
    final url = Uri.https("shape-dlhms.site", "/api/student/sync-activity");

    final token = PreferenceService.token;

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

    try {
      onProgress?.call("Uploading ${activities.length} activities...");

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'student_id': PreferenceService.studentId,
              'activities': activities,
            }),
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
