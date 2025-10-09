import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  // 🔹 Cached values
  static bool isLoggedIn = false;
  static String? token;
  static String? fullname;
  static String? lrn;

  /// Save login data and cache them
  Future<void> saveLoginData({
    required String token,
    required String fullname,
    required String lrn,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", true);
    await prefs.setString("token", token);
    await prefs.setString("fullname", fullname);
    await prefs.setString("lrn", lrn);

    // 🔹 Update cache immediately
    PreferenceService.isLoggedIn = true;
    PreferenceService.token = token;
    PreferenceService.fullname = fullname;
    PreferenceService.lrn = lrn;
  }

  /// Load values from SharedPreferences into cache
  Future<void> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    PreferenceService.isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    PreferenceService.token = prefs.getString("token");
    PreferenceService.fullname = prefs.getString("fullname");
    PreferenceService.lrn = prefs.getString("lrn");
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
  }
}
