import 'dart:convert';
import 'package:moldify/core/constants/api_url.dart';
import 'package:moldify/services/api_service.dart';

class MoldCaseService {
  final ApiService _apiService = ApiService(baseUrl: ApiUrl.moldCase);

  /// Fetch all assigned mycologists. Returns a list of mold cases.
  /// Endpoint: GET /assigned
  Future<Map<String, dynamic>> fetchAssignedMycologists({
    String? sessionCookie,
    int? limit,
    String? pageToken,
  }) async {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (pageToken != null) queryParams['pageToken'] = pageToken;

    final response = await _apiService.get(
      '/assigned',
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
      queryParams: queryParams.isEmpty ? null : queryParams,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded =
          json.decode(response.body) as Map<String, dynamic>;
      return decoded;
    } else {
      throw Exception('Failed to fetch assigned mycologists: ${response.statusCode}');
    }
  }

  /// Get a single mold case by id.
  Future<Map<String, dynamic>> getMoldCaseById(
    String id, {
    String? sessionCookie,
  }) async {
    final response = await _apiService.get(
      '/$id',
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch mold case $id: ${response.statusCode}');
  }

  /// Get mold cases by report ID.
  /// Endpoint: GET /by-report/:reportId
  Future<Map<String, dynamic>> getMoldCasesByReportId(
    String reportId, {
    String? sessionCookie,
  }) async {
    final response = await _apiService.get(
      '/by-report/$reportId',
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch mold cases for report $reportId: ${response.statusCode}');
  }

  /// Update a mold case by id.
  Future<void> updateMoldCase(
    String id,
    Map<String, dynamic> update, {
    String? sessionCookie,
  }) async {
    print('MoldCaseService.updateMoldCase: id=$id');
    print('MoldCaseService.updateMoldCase: update=$update');
    final response = await _apiService.patch(
      '/$id',
      headers: {'Content-Type': 'application/json'},
      body: update,
      sessionCookie: sessionCookie,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Failed to update mold case $id: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Delete a mold case by id.
  Future<void> deleteMoldCase(
    String id, {
    String? sessionCookie,
  }) async {
    final response = await _apiService.delete(
      '/$id',
      sessionCookie: sessionCookie,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to delete mold case $id: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Get all archived (closed) mold cases for the user.
  /// Endpoint: GET /archive
  Future<Map<String, dynamic>> getArchivedCases({
    String? sessionCookie,
    int? limit,
    String? pageToken,
  }) async {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (pageToken != null) queryParams['pageToken'] = pageToken;

    final response = await _apiService.get(
      '/archive',
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
      queryParams: queryParams.isEmpty ? null : queryParams,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded =
          json.decode(response.body) as Map<String, dynamic>;
      return decoded;
    } else {
      throw Exception('Failed to fetch archived cases: ${response.statusCode}');
    }
  }

  /// Dashboard: Get mold case priority breakdown for analytics
  /// Endpoint: GET /counts/priorities (from moldReport routes)
  /// Returns: {high: int, medium: int, low: int}
  /// Note: This uses the moldReport service endpoint for priority analytics
  Future<Map<String, dynamic>> getPriorityBreakdown({
    String? sessionCookie,
  }) async {
    // Create temporary service for report analytics
    final reportService = _apiService;
    final response = await reportService.get(
      '/counts/priorities',
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded =
          json.decode(response.body) as Map<String, dynamic>;
      return decoded;
    } else {
      throw Exception('Failed to fetch priority breakdown: ${response.statusCode}');
    }
  }}