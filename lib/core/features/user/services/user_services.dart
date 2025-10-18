import 'package:dio/dio.dart';
import 'package:moldify/core/utils/dio_utils.dart';
import 'package:moldify/core/constants/api_url.dart';
import 'package:moldify/services/api_service.dart';

class UserService {
  final ApiService _apiService = ApiService(baseUrl: ApiUrl.user);

  Future<Map<String, dynamic>> getUserProfile(String? sessionCookie) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (sessionCookie != null && sessionCookie.isNotEmpty) {
      headers['Cookie'] = 'session=$sessionCookie';
    }

    final Response response = await _apiService.get(
      '/profile',
      headers: headers,
    );

    final Map<String, dynamic> jsonResponse = DioUtils.normalizeResponseData(response);

    return {
      'success': jsonResponse['success'] ?? false,
      'data': jsonResponse['data'],
      'error': jsonResponse['error'],
    };
  }
}