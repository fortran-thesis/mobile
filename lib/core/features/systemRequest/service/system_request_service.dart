import 'dart:convert';
import 'package:http/http.dart' as http;
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
  Future<SystemRequestResponse> submitRequest({
    required String sessionCookie,
    required String type,
    required String message,
    required String userId,
  }) async {
    try {

      final response = await http.post(
        Uri.parse(ApiUrl.sysReq),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'session=$sessionCookie',
        },
        body: jsonEncode({
          'type': type,
          'message': message,
          'userId': userId,
        }),
      );


      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        print('Received HTML instead of JSON - wrong endpoint!');
        return SystemRequestResponse(
          success: false,
          error: 'Invalid endpoint - received HTML instead of JSON. Check API URL.',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SystemRequestResponse.fromJson(data);
      } else {
        return SystemRequestResponse.fromJson(data);
      }
    } catch (e, stackTrace) {
      print('SystemRequestService error: $e');
      print('Stack trace: $stackTrace');
      return SystemRequestResponse(
        success: false,
        error: 'Network error: ${e.toString()}',
      );
    }
  }
}