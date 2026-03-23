import 'package:moldify/services/api_service.dart';
import '../../../constants/api_url.dart';
import '../models/report_model.dart';

class UserReportService {
  final ApiService _apiService = ApiService(baseUrl: ApiUrl.userReport);

  Future<UserReport> createReport({
    required UserReport report,
    String? sessionCookie,
  }) async {
    if (sessionCookie == null || sessionCookie.isEmpty) {
      throw Exception('Unauthorized: session cookie is missing');
    }

    try {
      final response = await _apiService.post(
        '',
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: report.toJson(),
        sessionCookie: sessionCookie.trim(),
      );

      final decoded = response.data as Map<String, dynamic>;

      if (response.statusCode == 200 && decoded['success'] == true) {
        return UserReport.fromJson(decoded['data']);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: please log in again');
      } else if (response.statusCode == 400) {
        throw Exception('Validation Error: ${decoded['error']}');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to submit report: $e');
    }
  }
}
