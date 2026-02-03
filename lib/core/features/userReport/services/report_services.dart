import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constants/api_url.dart';
import '../models/report_model.dart';

class UserReportService {

  Future<UserReport> createReport({
    required UserReport report,
    String? sessionCookie,
  }) async {
    if (sessionCookie == null || sessionCookie.isEmpty) {
      throw Exception('Unauthorized: session cookie is missing');
    }

    try {
      final response = await http.post(
        Uri.parse(ApiUrl.userReport),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Cookie': 'session=${sessionCookie.trim()}',
        },
        body: json.encode(report.toJson()),
      );

      print('Report response code: ${response.statusCode}');
      print('Report response body: ${response.body}');

      final decoded = json.decode(response.body);

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
