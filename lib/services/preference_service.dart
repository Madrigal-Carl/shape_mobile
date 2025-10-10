import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  // 🔹 Cached values
  static bool isLoggedIn = false;
  static String? token;
  static String? fullname;
  static String? lrn;
  static String? avatarPath;

  /// Load saved preferences on app startup
  static Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    token = prefs.getString('token');
    fullname = prefs.getString('fullname');
    lrn = prefs.getString('lrn');
    avatarPath = prefs.getString('avatarPath');
  }

  /// Save login data and cache them
  Future<void> saveLoginData({
    required String token,
    required String fullname,
    required String lrn,
    required String? avatarPath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", true);
    await prefs.setString("token", token);
    await prefs.setString("fullname", fullname);
    await prefs.setString("lrn", lrn);

    if (avatarPath != null) {
      await prefs.setString("avatarPath", avatarPath);
    }

    // 🔹 Update cache immediately
    PreferenceService.isLoggedIn = true;
    PreferenceService.token = token;
    PreferenceService.fullname = fullname;
    PreferenceService.lrn = lrn;
    PreferenceService.avatarPath = avatarPath;
  }

  /// Load values from SharedPreferences into cache
  Future<void> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    PreferenceService.isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    PreferenceService.token = prefs.getString("token");
    PreferenceService.fullname = prefs.getString("fullname");
    PreferenceService.lrn = prefs.getString("lrn");
    PreferenceService.avatarPath = prefs.getString("avatarPath");
  }

  /// Clear preferences and reset cache
  Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // 🔹 Reset cache
    PreferenceService.isLoggedIn = false;
    PreferenceService.token = null;
    PreferenceService.fullname = null;
    PreferenceService.lrn = null;
    PreferenceService.avatarPath = null;
  }
}
