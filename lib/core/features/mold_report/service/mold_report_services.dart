import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:moldify/core/config/cache_config.dart';
import 'package:moldify/core/constants/api_url.dart';
import 'package:moldify/services/api_service.dart';
import 'package:moldify/core/utils/logger.dart';

class MoldReportService {
  final ApiService _apiService = ApiService(baseUrl: ApiUrl.moldReport);

  /// Create a new mold report using multipart/form-data.
  ///
  /// The backend expects a multipart upload with the file field named
  /// `cover_photo` (single file) and the other report fields provided as
  /// form fields. Complex fields (lists/maps) are JSON-encoded before being
  /// attached to the form.
  ///
  /// [report] should be a Map containing the report fields using the
  /// backend-expected keys (snake_case). [coverPhoto] is an optional file to
  /// upload under the field name `cover_photo`. Pass [sessionCookie] for
  /// authenticated requests.
  Future<Map<String, dynamic>> createMoldReport(
    Map<String, dynamic> report, {
    File? coverPhoto,
    List<File>? coverPhotos,
    String? sessionCookie,
    /// If true, poll the server after creation until the case detail's
    /// `cover_photo` array is populated or the timeout elapses. This is
    /// frontend-only behavior to work around the backend returning before
    /// async uploads complete.
    bool waitForPhotos = false,
    /// Poll interval in seconds
    int pollIntervalSeconds = 1,
    /// Maximum wait time in seconds
    int timeoutSeconds = 15,
  }) async {
    final photosToUpload =
        coverPhotos ?? (coverPhoto != null ? [coverPhoto] : <File>[]);

    final formData = FormData();
    formData.fields.add(MapEntry('details', json.encode(report)));

    for (final photo in photosToUpload) {
      final filename = photo.path.split(Platform.pathSeparator).last;
      // Read bytes and create multipart file (works for temp files)
      final bytes = await photo.readAsBytes();
      final multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: filename,
      );
      formData.files.add(MapEntry('cover_photo', multipartFile));
    }

    final response = await _apiService.dio.post(
      '',
      data: formData,
      options: Options(
        headers:
            sessionCookie != null ? {'Cookie': 'session=$sessionCookie'} : null,
        validateStatus: (_) => true,
      ),
    );

    // Session cookie is included in headers. Dio handles multipart boundaries
    // correctly even with custom headers.

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (response.data == null ||
          (response.data is String && (response.data as String).isEmpty)) {
        return <String, dynamic>{};
      }
      final Map<String, dynamic> created = response.data as Map<String, dynamic>;

      // Optionally poll for uploaded photos if requested and we have an id
      if (waitForPhotos) {
        try {
          final id = (created['id'] ?? created['_id'] ?? created['case_id'])?.toString();
          if (id != null && id.isNotEmpty) {
            final int maxTries = (timeoutSeconds / (pollIntervalSeconds > 0 ? pollIntervalSeconds : 1)).ceil();
            int tries = 0;
            while (tries < maxTries) {
              await Future.delayed(Duration(seconds: pollIntervalSeconds));
              tries += 1;
              try {
                final refreshed = await getMoldReportById(id, sessionCookie: sessionCookie);
                // Check first case_detail cover_photo
                final caseDetails = refreshed['case_details'] as List<dynamic>?;
                if (caseDetails != null && caseDetails.isNotEmpty) {
                  final first = caseDetails.first as Map<String, dynamic>?;
                  if (first != null) {
                    final covers = first['cover_photo'];
                    if (covers is List && covers.isNotEmpty) {
                      return refreshed;
                    }
                    if (covers is String && covers.isNotEmpty) {
                      return refreshed;
                    }
                  }
                }
              } catch (_) {
                // ignore and retry until timeout
              }
            }
          }
        } catch (_) {
          // ignore polling errors and return initial created payload
        }
      }

      return created;
    } else {
      throw Exception(
        'Failed to create mold report: ${response.statusCode} ${response.data}',
      );
    }
  }

  /// Fetch a list of mold reports. Returns decoded JSON list. Caller can map
  /// to model instances if desired. This method expects the backend to return
  /// a paginated result with shape: { data: [...], nextPageToken: string | null }
  Future<Map<String, dynamic>> fetchMoldReports({
    String? sessionCookie,
    int? limit,
    String? pageToken,
    String path = '/user',
  }) async {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (pageToken != null) queryParams['pageToken'] = pageToken;

    final response = await _apiService.get(
      path,
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
      queryParams: queryParams.isEmpty ? null : queryParams,
      cacheOptions: CacheConfig.volatileData,
    );

    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch mold reports: ${response.statusCode}');
    }
  }

  /// Fetch archived mold reports.
  Future<Map<String, dynamic>> fetchArchived({
    String? sessionCookie,
    int? limit,
    String? pageToken,
  }) async {
    return fetchMoldReports(
      sessionCookie: sessionCookie,
      limit: limit,
      pageToken: pageToken,
      path: '/archive',
    );
  }

  /// Fetch closed mold reports (includes rejected) for authenticated user with cursor-based pagination.
  /// Endpoint: GET /user/closed
  Future<Map<String, dynamic>> fetchClosedMoldReports({
    String? sessionCookie,
    int? limit,
    String? pageToken,
  }) async {
    return fetchMoldReports(
      sessionCookie: sessionCookie,
      limit: limit,
      pageToken: pageToken,
      path: '/user/closed',
    );
  }

  /// Get a single mold report by id.
  Future<Map<String, dynamic>> getMoldReportById(
    String id, {
    String? sessionCookie,
  }) async {
    final response = await _apiService.get(
      '/$id',
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
      cacheOptions: CacheConfig.volatileData,
    );

    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch mold report $id: ${response.statusCode}');
  }

  /// Post a case detail to a report (/:id/case-details)
  Future<Map<String, dynamic>> postCaseDetail(
    String reportId,
    Map<String, dynamic> caseDetail, {
    String? sessionCookie,
  }) async {
    final response = await _apiService.post(
      '/$reportId/case-details',
      headers: {'Content-Type': 'application/json'},
      body: caseDetail,
      sessionCookie: sessionCookie,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    }
    throw Exception(
      'Failed to post case detail for report $reportId: ${response.statusCode} ${response.data}',
    );
  }

  /// Alias for postCaseDetail for consistency with other service methods
  Future<Map<String, dynamic>> addCaseDetailToReport(
    String reportId,
    Map<String, dynamic> caseDetail, {
    String? sessionCookie,
  }) async {
    return postCaseDetail(reportId, caseDetail, sessionCookie: sessionCookie);
  }

  /// Patch a mold report by id.
  Future<void> patchMoldReport(
    String id,
    Map<String, dynamic> update, {
    String? sessionCookie,
  }) async {
    final response = await _apiService.patch(
      '/$id',
      headers: {'Content-Type': 'application/json'},
      body: update,
      sessionCookie: sessionCookie,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to patch mold report $id: ${response.statusCode} ${response.data}',
      );
    }
  }

  /// Hard delete a mold report
  Future<void> deleteMoldReportHard(String id, {String? sessionCookie}) async {
    final response = await _apiService.delete(
      '/hard/$id',
      sessionCookie: sessionCookie,
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to hard delete mold report $id: ${response.statusCode} ${response.data}',
      );
    }
  }

  /// Soft delete a mold report
  Future<void> deleteMoldReportSoft(String id, {String? sessionCookie}) async {
    final response = await _apiService.delete(
      '/soft/$id',
      sessionCookie: sessionCookie,
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to soft delete mold report $id: ${response.statusCode} ${response.data}',
      );
    }
  }

  /// Dashboard: Get report counts by status for mycologist dashboard
  /// Endpoint: GET /counts/statuses
  /// Returns: {pending: int, in_progress: int, resolved: int, rejected: int}
  Future<Map<String, dynamic>> getReportCounts({String? sessionCookie}) async {
    final response = await _apiService.get(
      '/counts/statuses',
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
      cacheOptions: CacheConfig.volatileData,
    );

    if (response.statusCode == 200) {
      final responseBody = response.data as Map<String, dynamic>;
      // Extract the data wrapper if it exists, otherwise return the response as-is
      final data = responseBody['data'] is Map<String, dynamic>
          ? responseBody['data'] as Map<String, dynamic>
          : responseBody;
      return data;
    }
    throw Exception('Failed to fetch report counts: ${response.statusCode}');
  }

  /// Dashboard: Get assigned reports count for mycologist
  /// Endpoint: GET /assigned/count
  /// Query params: id (mycologist user id)
  /// Returns: { data: { total: int } }
  Future<Map<String, dynamic>> getAssignedReportsCount({
    required String mycologistId,
    String? sessionCookie,
  }) async {
    final response = await _apiService.get(
      '/assigned/count',
      headers: {'Content-Type': 'application/json'},
      queryParams: {
        'id': mycologistId,
      },
      sessionCookie: sessionCookie,
      cacheOptions: CacheConfig.refresh,
    );

    if (response.statusCode == 200 || response.statusCode == 304) {
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        return responseData;
      }
      return <String, dynamic>{};
    }
    if (response.statusCode == 400) {
      throw Exception('Missing mycologist id');
    }
    throw Exception('Failed to fetch assigned reports count: ${response.statusCode}');
  }

  /// Dashboard: Get monthly totals for reporting metrics
  /// Endpoint: GET /counts/monthly
  /// Returns: {months: List<{month: string, total: int}>}
  Future<Map<String, dynamic>> getMonthlyTotals({String? sessionCookie}) async {
    final response = await _apiService.get(
      '/counts/monthly',
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
      cacheOptions: CacheConfig.volatileData,
    );

    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch monthly totals: ${response.statusCode}');
  }

  /// Dashboard: Get combined total counts (all reports, cases, etc.)
  /// Endpoint: GET /counts/totals
  /// Returns: {total_reports: int, total_cases: int, ...}
  Future<Map<String, dynamic>> getCombinedTotalCounts({String? sessionCookie}) async {
    final response = await _apiService.get(
      '/counts/totals',
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
      cacheOptions: CacheConfig.volatileData,
    );

    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch combined total counts: ${response.statusCode}');
  }

  /// Dashboard: Get moldipedia articles for WikiMold section
  /// Endpoint: GET /moldipedia?limit=3
  /// Returns: {data: {snapshot: List<{id, title, author_id, cover_photo, ...}>}}
  Future<List<Map<String, dynamic>>> getMoldipediaArticles({
    String? sessionCookie,
    int limit = 3,
  }) async {
    final response = await _apiService.get(
      '/moldipedia?limit=$limit',
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
      cacheOptions: CacheConfig.staticData,
    );

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      final snapshot = (data['data']?['snapshot'] as List<dynamic>?) ?? [];
      return snapshot.map((item) => item as Map<String, dynamic>).toList();
    }
    throw Exception('Failed to fetch moldipedia articles: ${response.statusCode}');
  }

  /// Search and filter mold reports
  /// Endpoint: GET /search
  /// Query parameters:
  ///   - search: search query (searches case name, host, location, reporter name, status)
  ///   - status: filter by status (pending, in progress, resolved, rejected)
  ///   - limit: results per page (default: 10)
  ///   - pageToken: pagination token
  Future<Map<String, dynamic>> searchMoldReports({
    String? search,
    String? status,
    int? limit,
    String? pageToken,
    String? sessionCookie,
  }) async {
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (pageToken != null && pageToken.isNotEmpty) queryParams['pageToken'] = pageToken;

    final response = await _apiService.get(
      '/search',
      headers: {'Content-Type': 'application/json'},
      queryParams: queryParams,
      sessionCookie: sessionCookie,
      cacheOptions: CacheConfig.volatileData,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to search mold reports: ${response.statusCode} ${response.data}',
      );
    }

    return response.data as Map<String, dynamic>;
  }
}