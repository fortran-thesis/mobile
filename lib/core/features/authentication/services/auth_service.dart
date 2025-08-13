import 'dart:convert';

import 'package:moldify/services/api_service.dart';
import '../../../constants/api_url.dart';


class AuthService {
  final ApiService _apiService = ApiService(baseUrl: ApiUrl.auth);

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _apiService.post(
      '/login',
      headers: {'Content-Type': 'application/json'},
      body: {
        'username': username,
        'password': password,
      },
    );

    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    final bool success = jsonResponse['success'] ?? false;
    final dynamic data = jsonResponse['data'];
    final dynamic error = jsonResponse['error'];
    final String? cookie = response.headers['set-cookie'];

    return {
      'success': success,
      'data': data,
      'error': error,
      'cookie': cookie,
    };
  }

  // Add more methods like signup, logout, etc.
}
