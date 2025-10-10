import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'preference_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shape_mobile/db/app_database.dart';
import 'package:shape_mobile/models/StudentModel.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  final String baseUrl = "http://10.0.2.2:8000/api";
  final PreferenceService _prefs = PreferenceService();

  Future<bool> loginStudent(String username, String password) async {
    final url = Uri.parse("$baseUrl/student/login");
    final response = await http.post(
      url,
      body: {"username": username, "password": password},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final studentJson = data['student'];

      String? imageUrl = studentJson['path'];
      String? localImagePath;

      // ✅ Download image and replace path with local file path
      if (imageUrl != null && imageUrl.isNotEmpty) {
        print("📥 Downloading image from: $imageUrl");
        localImagePath = await downloadImageToLocal(imageUrl);

        // ❌ If still null after retries, stop login and throw
        if (localImagePath == null) {
          throw ApiException("connection_timeout");
        }

        print("✅ Image saved locally: $localImagePath");
        studentJson['path'] = localImagePath;
      }

      // ✅ Save in SharedPreferences
      await _prefs.saveLoginData(
        token: data['token'],
        fullname: studentJson['fullname'],
        lrn: studentJson['lrn'],
        avatarPath: localImagePath,
      );

      // ✅ Insert or update student in local SQLite
      final student = Student.fromJson(studentJson);
      await AppDatabase.instance.insertStudent(student);

      return true;
    } else {
      throw ApiException(data['message'] ?? "Login failed");
    }
  }

  /// Downloads an image and stores it locally, returns the full local path
  Future<String?> downloadImageToLocal(
    String imageUrl, {
    int retryCount = 0,
  }) async {
    const int maxRetries = 10;
    final uri = Uri.parse(imageUrl);
    final fileName = uri.pathSegments.last;

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final localPath = "${directory.path}/$fileName";
        final file = File(localPath);

        if (await file.exists()) await file.delete();

        final raf = await file.open(mode: FileMode.write);
        await raf.writeFrom(response.bodyBytes);
        await raf.flush();
        await raf.close();

        print("✅ Image successfully saved to: $localPath");
        return localPath;
      } else {
        print("⚠️ Image download failed. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Image download error: $e");

      // 🌀 Retry only if connection closed and retryCount < maxRetries
      if (e.toString().contains('Connection closed') &&
          retryCount < maxRetries) {
        final nextTry = retryCount + 1;
        print("🔁 Retrying download... Attempt $nextTry/$maxRetries");
        await Future.delayed(Duration(milliseconds: 500 * nextTry));
        return downloadImageToLocal(imageUrl, retryCount: nextTry);
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
        // ✅ Clear preferences
        await _prefs.clearPreferences();

        // ✅ Clear local database
        await AppDatabase.instance.clearAllTables();
        await AppDatabase.instance.close();

        // ✅ Clear downloaded image files
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

  /// Delete all files inside app documents directory
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
