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
      } catch (e) {
        onProgress?.call("Download failed");
        print("❌ Stopping due to failure: $e");
        rethrow;
      }

      // ✅ Save in SharedPreferences
      onProgress?.call("Saving data locally...");
      await _prefs.saveLoginData(
        token: data['token'],
        fullname: studentJson['fullname'],
        lrn: studentJson['lrn'],
        avatarPath: studentJson['path'],
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

      onProgress?.call("Success!");
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
}
