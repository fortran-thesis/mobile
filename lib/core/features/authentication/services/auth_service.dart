import 'package:moldify/core/utils/dio_utils.dart';
import 'package:moldify/services/api_service.dart';
import '../../../constants/api_url.dart';

class AuthService {
  final ApiService _apiService = ApiService(baseUrl: ApiUrl.auth);

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _apiService.post(
      '/login',
      headers: {'Content-Type': 'application/json'},
      data: {
        'username': username,
        'password': password,
      },
    );

    final Map<String, dynamic> jsonResponse = DioUtils.normalizeResponseData(response);
    final bool success = jsonResponse['success'] ?? false;
    final dynamic data = jsonResponse['data'];
    final dynamic error = jsonResponse['error'];
    final String? cookie = response.headers.value('set-cookie');

    return {
      'success': success,
      'data': data,
      'error': error,
      'cookie': cookie,
    };
  }

  Future<Map<String, dynamic>> loginOAuth(String token) async {
    final response = await _apiService.post(
      '/login/oauth',
      headers: {'Content-Type': 'application/json'},
      data: {
        'token': token,
      },
    );

    final Map<String, dynamic> jsonResponse = DioUtils.normalizeResponseData(response);
    final bool success = jsonResponse['success'] ?? false;
    final dynamic data = jsonResponse['data'];
    final dynamic error = jsonResponse['error'];
    final String? cookie = response.headers.value('set-cookie');

    return {
      'success': success,
      'data': data,
      'error': error,
      'cookie': cookie,
    };
  }

  Future<Map<String, dynamic>> registerUser(String username, String email, String password) async {
    final response = await _apiService.post(
      '/register',
      headers: {'Content-Type': 'application/json'},
      data: {
        'username': username,
        'email': email,
        'password': password,
      },
    );

    final Map<String, dynamic> jsonResponse = DioUtils.normalizeResponseData(response);
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
      data: {
        'email': email,
        'code': code,
      },
    );

    final Map<String, dynamic> jsonResponse = DioUtils.normalizeResponseData(response);
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
      data: {
        'email': email,
      },
    );

    final Map<String, dynamic> jsonResponse = DioUtils.normalizeResponseData(response);
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
      data: {
        'email': email,
      },
    );

    final Map<String, dynamic> jsonResponse = DioUtils.normalizeResponseData(response);
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
      data: {
        'token': token,
      },
    );

    final Map<String, dynamic> jsonResponse = DioUtils.normalizeResponseData(response);
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
      data: {
        'token': token,
        'newPassword': newPass,
      },
    );

    final Map<String, dynamic> jsonResponse = DioUtils.normalizeResponseData(response);
    final bool success = jsonResponse['success'] ?? false;
    final dynamic data = jsonResponse['data'];
    final dynamic error = jsonResponse['error'];

    return {
      'success': success,
      'data': data,
      'error': error,
    };
  }
}