import 'package:moldify/services/api_service.dart';
import '../../../constants/api_url.dart';

class FlagReportService {
  final ApiService _apiService = ApiService(baseUrl: ApiUrl.flagReport);

  /// Fetch paginated flag reports from `GET /api/v1/flag-report`.
  /// Returns `{ snapshot: [...], nextPageToken: "..." }`.
  Future<Map<String, dynamic>> getFlagReports({
    String? sessionCookie,
    int limit = 20,
    String? pageToken,
  }) async {
    if (sessionCookie == null || sessionCookie.isEmpty) {
      throw Exception('Unauthorized: session cookie is missing');
    }

    final queryParams = <String, String>{
      'limit': limit.toString(),
      if (pageToken != null && pageToken.trim().isNotEmpty)
        'pageToken': pageToken.trim(),
    };

    final resp = await _apiService.get(
      '/',
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      queryParams: queryParams,
      sessionCookie: sessionCookie.trim(),
    );

    if (resp.statusCode == 200 || resp.statusCode == 304) {
      final body = resp.data as Map<String, dynamic>;
      final data = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : body;
      return data;
    }

    throw Exception('Failed to fetch flag reports: ${resp.statusCode}');
  }

  /// Create a flag report using the API proxy endpoint `/api/v1/flag-report`.
  /// Expects body with keys: `content_id`, `content_type`, `reason`, `details`.
  Future<Map<String, dynamic>> createFlagReport({
    required Map<String, dynamic> payload,
    String? sessionCookie,
  }) async {
    if (sessionCookie == null || sessionCookie.isEmpty) {
      throw Exception('Unauthorized: session cookie is missing');
    }

    final resp = await _apiService.post(
      '/',
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: payload,
      sessionCookie: sessionCookie.trim(),
    );

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return resp.data as Map<String, dynamic>;
    }

    throw Exception('Failed to create flag report: ${resp.statusCode}');
  }
}
