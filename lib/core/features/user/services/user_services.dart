import 'dart:convert';

import 'package:moldify/core/constants/api_url.dart';
import 'package:moldify/services/api_service.dart';

class UserService {
  final ApiService _apiService = ApiService(baseUrl: ApiUrl.user);

  Future<Map<String, dynamic>> getUserProfile(String? sessionCookie) async {
    print('UserService: getUserProfile called with sessionCookie: $sessionCookie');
    final response = await _apiService.get(
      '/profile',
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
    );

    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    return {
      'success': jsonResponse['success'] ?? false,
      'data': jsonResponse['data'],
      'error': jsonResponse['error'],
    };
  }
}