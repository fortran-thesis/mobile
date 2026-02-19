import 'dart:convert';

import 'package:moldify/services/api_service.dart';
import '../../../constants/api_url.dart';


class AuthService {
  final ApiService _apiService = ApiService(baseUrl: ApiUrl.auth);

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _apiService.post(
      '/login?device=mobile',
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
    final String? setCookie = response.headers['set-cookie'];

    String? sessionCookie;
    if (setCookie != null) {
      final cookies = setCookie.split(',');
      for (final cookie in cookies) {
        if (cookie.trim().startsWith('session=')) {
          // Only take the cookie value up to the first semicolon
          sessionCookie = cookie.trim().split(';').first;
          break;
        }
      }
    }

    return {
      'success': success,
      'data': data,
      'error': error,
      'cookie': sessionCookie,
    };
  }

  Future<Map<String, dynamic>> loginOAuth(String token) async {
    final endpoint = '/login/oauth?device=mobile';
    print('🔵 loginOAuth: Making request to $endpoint');
    
    try {
      final response = await _apiService.post(
        endpoint,
        headers: {'Content-Type': 'application/json'},
        body: {
          'token': token,
        },
      );

      print('🔵 loginOAuth: Response URL = ${response.request?.url}');
      print('🔵 loginOAuth: Response status = ${response.statusCode}');
      print('🔵 loginOAuth: Response body = ${response.body}');

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final bool success = jsonResponse['success'] ?? false;
      final dynamic data = jsonResponse['data'];
      final dynamic error = jsonResponse['error'];
      final String? setCookie = response.headers['set-cookie'];

      print('success: $success');
      print('data: $data');
      print('error: $error');
      print('setCookie: $setCookie');

      String? sessionCookie;
      if (setCookie != null) {
        final cookies = setCookie.split(',');
        for (final cookie in cookies) {
          if (cookie.trim().startsWith('session=')) {
            // Extract just the JWT value (after 'session='), removing any semicolons
            sessionCookie = cookie.trim().split(';').first.split('=').last;
            break;
          }
        }
      }

      return {
        'success': success,
        'data': data,
        'error': error,
        'sessionValue': sessionCookie,
      };
    } catch (e) {
      print('❌ loginOAuth: Exception occurred: $e');
      return {
        'success': false,
        'data': null,
        'error': 'Failed to connect to server: $e',
        'sessionValue': null,
      };
    }
  }

  Future<Map<String, dynamic>> registerUser(String username, String email, String password, String firstName, String lastName, String address, String phoneNumber) async {
    final response = await _apiService.post(
      '/register',
      headers: {'Content-Type': 'application/json'},
      body: {
        'username': username,
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'address': address,
        'phoneNumber': phoneNumber
      },
    );

    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    final bool success = jsonResponse['success'] ?? false;
    final dynamic data = jsonResponse['data'];
    final dynamic error = jsonResponse['error'];

    return {
      'success': success,
      'data': data,
      'error': error,
    };
  }

  Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    final response = await _apiService.post(
      '/verify-code',
      headers: {'Content-Type': 'application/json'},
      body: {
        'email': email,
        'code': code,
      },
    );

    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    final bool success = jsonResponse['success'] ?? false;
    final dynamic data = jsonResponse['data'];
    final dynamic error = jsonResponse['error'];

    return {
      'success': success,
      'data': data,
      'error': error,
    };
  }

  Future<Map<String, dynamic>> forgotUsername(String email) async {
    final response = await _apiService.post(
      '/forgot-username',
      headers: {'Content-Type': 'application/json'},
      body: {
        'email': email,
      },
    );

    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    final bool success = jsonResponse['success'] ?? false;
    final dynamic data = jsonResponse['data'];
    final dynamic error = jsonResponse['error'];

    return {
      'success': success,
      'data': data,
      'error': error,
    };
  }

  Future<Map<String,dynamic>> forgotPassword(String email) async {
    final response = await _apiService.post(
      '/forgot-password',
      headers: {'Content-Type': 'application/json'},
      body: {
        'email': email,
      },
    );

    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    final bool success = jsonResponse['success'] ?? false;
    final dynamic data = jsonResponse['data'];
    final dynamic error = jsonResponse['error'];

    return {
      'success': success,
      'data': data,
      'error': error,
    };
  }

  Future<Map<String,dynamic>> verifiedForgotUsername(String token) async {
    final response = await _apiService.post(
      '/forgot-username/verify',
      headers: {'Content-Type': 'application/json'},
      body: {
        'token': token,
      },
    );

    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    final bool success = jsonResponse['success'] ?? false;
    final dynamic data = jsonResponse['data'];
    final dynamic error = jsonResponse['error'];

    return {
      'success': success,
      'data': data,
      'error': error,
    };
  }

  Future<Map<String,dynamic>> verifiedForgotPassword(String token, String newPass) async {
    final response = await _apiService.post(
      '/forgot-password/verify',
      headers: {'Content-Type': 'application/json'},
      body: {
        'token': token,
        'newPassword': newPass,
      },
    );

    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    final bool success = jsonResponse['success'] ?? false;
    final dynamic data = jsonResponse['data'];
    final dynamic error = jsonResponse['error'];

    return {
      'success': success,
      'data': data,
      'error': error,
    };
  }
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String? sessionCookie,
  }) async {
    final response = await _apiService.post(
      '/change-password',
      headers: {'Content-Type': 'application/json'},
      body: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
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