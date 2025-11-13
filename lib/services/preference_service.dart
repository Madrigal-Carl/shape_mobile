import 'package:shared_preferences/shared_preferences.dart';
import 'package:shape_mobile/models/LessonModel.dart';
import 'dart:convert';
import 'dart:io';

class PreferenceService {
  // 🔹 Cached values
  static bool isLoggedIn = false;
  static int? studentId;
  static String? token;
  static int? latestSchoolYearId;
  static String? fullname;
  static String? lrn;
  static String? avatarPath;
  static String? status;
  static int? latestLessonId;
  static String? latestLessonTitle;
  static String? lastSyncTime;

  /// Load saved preferences on app startup
  static Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    studentId = prefs.getInt('student_id');
    latestSchoolYearId = prefs.getInt('latest_school_year_id');
    token = prefs.getString('token');
    fullname = prefs.getString('fullname');
    lrn = prefs.getString('lrn');
    avatarPath = prefs.getString('avatarPath');
    status = prefs.getString('status');
    latestLessonId = prefs.getInt('latest_lesson_id');
    latestLessonTitle = prefs.getString('latest_lesson_title');
    lastSyncTime = prefs.getString('last_sync_time');
  }

  /// Save login data and cache them
  Future<void> saveLoginData({
    required int latestSchoolYearId,
    required String token,
    required int studentId,
    required String fullname,
    required String lrn,
    required String? avatarPath,
    required String status,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", true);
    await prefs.setInt("latest_school_year_id", latestSchoolYearId);
    await prefs.setInt("student_id", studentId);
    await prefs.setString("token", token);
    await prefs.setString("fullname", fullname);
    await prefs.setString("lrn", lrn);
    await prefs.setString("status", status);

    if (avatarPath != null) {
      await prefs.setString("avatarPath", avatarPath);
    }

    // 🔹 Update cache immediately
    PreferenceService.isLoggedIn = true;
    PreferenceService.studentId = studentId;
    PreferenceService.latestSchoolYearId = latestSchoolYearId;
    PreferenceService.token = token;
    PreferenceService.fullname = fullname;
    PreferenceService.lrn = lrn;
    PreferenceService.avatarPath = avatarPath;
    PreferenceService.status = status;
  }

  /// Load values from SharedPreferences into cache
  Future<void> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    PreferenceService.isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    PreferenceService.studentId = prefs.getInt("student_id");
    PreferenceService.latestSchoolYearId = prefs.getInt(
      "latest_school_year_id",
    );
    PreferenceService.token = prefs.getString("token");
    PreferenceService.fullname = prefs.getString("fullname");
    PreferenceService.lrn = prefs.getString("lrn");
    PreferenceService.avatarPath = prefs.getString("avatarPath");
  }

  /// Save the current time as last sync
  static Future<void> saveLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    final formatted = time.toUtc().toIso8601String();

    await prefs.setString('last_sync_time', formatted);
    lastSyncTime = formatted;
  }

  /// Load last sync time (on app start)
  static Future<void> loadLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    lastSyncTime = prefs.getString('last_sync_time');
  }

  /// Clear preferences and reset cache
  Future<void> clearPreferences({bool keepLastSync = false}) async {
    final prefs = await SharedPreferences.getInstance();
    if (keepLastSync) {
      final lastSync = prefs.getString('last_sync_time');
      await prefs.clear();
      if (lastSync != null) {
        await prefs.setString('last_sync_time', lastSync);
      }
    } else {
      await prefs.clear();
    }

    // Reset cache
    PreferenceService.isLoggedIn = false;
    PreferenceService.studentId = null;
    PreferenceService.latestSchoolYearId = null;
    PreferenceService.token = null;
    PreferenceService.fullname = null;
    PreferenceService.lrn = null;
    PreferenceService.avatarPath = null;
    PreferenceService.status = null;
  }

  static Future<void> saveLatestLesson(Lesson lesson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('latest_lesson_id', lesson.id);
    await prefs.setString('latest_lesson_title', lesson.title);

    latestLessonId = lesson.id;
    latestLessonTitle = lesson.title;
  }

  static const _downloadedFilesKey = 'downloaded_files';

  /// Save a downloaded file path for a given URL
  static Future<void> saveDownloadedFile(String url, String localPath) async {
    final prefs = await SharedPreferences.getInstance();
    final map = _getDownloadedFilesMap(prefs);
    map[url] = localPath;
    await prefs.setString(_downloadedFilesKey, jsonEncode(map));
  }

  /// Get the local file path for a given URL
  static Future<String?> getDownloadedFile(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final map = _getDownloadedFilesMap(prefs);
    final path = map[url];
    if (path != null && await File(path).exists()) {
      return path;
    }
    return null;
  }

  /// Load the map of downloaded files
  static Map<String, String> _getDownloadedFilesMap(SharedPreferences prefs) {
    final jsonString = prefs.getString(_downloadedFilesKey);
    if (jsonString == null) return {};
    try {
      final decoded = jsonDecode(jsonString);
      return Map<String, String>.from(decoded);
    } catch (_) {
      return {};
    }
  }

  /// Remove a file record (optional: after deletion)
  static Future<void> removeDownloadedFile(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final map = _getDownloadedFilesMap(prefs);
    map.remove(url);
    await prefs.setString(_downloadedFilesKey, jsonEncode(map));
  }
}
