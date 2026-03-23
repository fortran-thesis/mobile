import 'package:moldify/services/api_service.dart';
import '../../../constants/api_url.dart';

class SystemRequestResponse {
  final bool success;
  final String? error;
  final Map<String, dynamic>? data;

  SystemRequestResponse({
    required this.success,
    this.error,
    this.data,
  });

  factory SystemRequestResponse.fromJson(Map<String, dynamic> json) {
    return SystemRequestResponse(
      success: json['success'] ?? false,
      error: json['error'],
      data: json['data'],
    );
  }
}

class SystemRequestService {
  final ApiService _apiService = ApiService(baseUrl: ApiUrl.sysReq);

  Future<SystemRequestResponse> submitRequest({
    required String sessionCookie,
    required String type,
    required String message,
    required String userId,
  }) async {
    try {
      final response = await _apiService.post(
        '',
        body: {
          'type': type,
          'message': message,
          'user_id': userId,
        },
        sessionCookie: sessionCookie,
      );

      final responseData = response.data;

      // Check if server returned HTML instead of JSON
      if (responseData is String &&
          (responseData.trim().startsWith('<!DOCTYPE') ||
              responseData.trim().startsWith('<html'))) {
        return SystemRequestResponse(
          success: false,
          error: 'Invalid endpoint - received HTML instead of JSON. Check API URL.',
        );
      }

      final data = responseData as Map<String, dynamic>;
      return SystemRequestResponse.fromJson(data);
    } catch (e) {
      return SystemRequestResponse(
        success: false,
        error: 'Network error: ${e.toString()}',
      );
    }
  }
}