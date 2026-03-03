import 'package:moldify/services/api_service.dart';
import '../../../constants/api_url.dart';

class TestService {
  final ApiService _apiService = ApiService(baseUrl: ApiUrl.test);

  Future<Map<String, dynamic>> getSecure(String? sessionCookie) async {
    final response = await _apiService.get(
      '/secure',
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
    );

    final Map<String, dynamic> jsonResponse = response.data as Map<String, dynamic>;
    return {
      'success': jsonResponse['success'] ?? false,
      'data': jsonResponse['data'],
      'error': jsonResponse['error'],
    };
  }
}

