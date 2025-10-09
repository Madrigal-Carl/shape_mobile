import 'dart:convert';
import 'package:http/http.dart' as http;
import 'preference_service.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final String baseUrl =
      "http://10.0.2.2:8000/api"; // replace with Laragon host (see note below)
  final PreferenceService _prefs = PreferenceService();

  Future<void> loginStudent(String username, String password) async {
    final url = Uri.parse("$baseUrl/student/login");
    final response = await http.post(
      url,
      body: {"username": username, "password": password},
    );
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final student = data['student'];

      // Save in SharedPreferences
      await _prefs.saveLoginData(
        token: data['token'],
        fullname: student['fullname'],
        lrn: student['lrn'],
      );
    } else {
      throw ApiException(data['message'] ?? "Login failed");
    }
  }

  Future<void> logout() async {
    final token = PreferenceService.token;

    if (token != null) {
      final url = Uri.parse("$baseUrl/student/logout");
      await http.post(url, headers: {"Authorization": "Bearer $token"});
    }

    await _prefs.clearPreferences();
  }
}
