import 'package:moldify/core/features/mold_case/models/mold_case.dart';
import 'package:moldify/core/features/mold_case/service/mold_case_service.dart';
import 'package:moldify/core/utils/logger.dart';

class MoldCaseRepository {
  final MoldCaseService _service = MoldCaseService();
  final int pageSize;

  MoldCaseRepository({this.pageSize = 10});

  /// Fetch a page from API. Uses cursor-based pagination with [pageToken].
  /// Returns both the cases list and the nextPageToken for pagination.
  Future<Map<String, dynamic>> fetchPageWithToken({
    String? pageToken, 
    String? sessionCookie,
  }) async {
    AppLogger.d('MoldCaseRepository: fetching page from API (pageToken: "$pageToken", limit: $pageSize)');
    final result = await _service.fetchAssignedMycologists(
      sessionCookie: sessionCookie,
      limit: pageSize,
      pageToken: pageToken,
    );
    AppLogger.d('MoldCaseRepository: raw API response: $result');

    // Extract snapshot and nextPageToken
    final snapshot = result['snapshot'];
    final nextPageTokenValue = result['nextPageToken'];

    List<dynamic> rawDataList = <dynamic>[];
    if (snapshot is List) {
      rawDataList = snapshot;
    } else if (snapshot is Map) {
      rawDataList = [snapshot];
    } else {
      rawDataList = <dynamic>[];
    }

    AppLogger.d('MoldCaseRepository: normalized rawDataList (${rawDataList.length} items)');

    // Normalize API response fields to match MoldCase model expectations
    // API returns: case_name, assigned_mycologist_id, id
    // Model expects: name, mycologist_id, mold_report_id
    final List<MoldCase> cases = rawDataList
        .map((e) => _normalizeMoldReportFields(e as Map<String, dynamic>))
        .map((e) => MoldCase.fromJson(e))
        .where((c) => c.mycologistId.isNotEmpty)
        .toList();

    final String? nextToken = 
        (nextPageTokenValue != null && nextPageTokenValue.toString().trim().isNotEmpty)
            ? nextPageTokenValue.toString().trim()
            : null;

    AppLogger.d('MoldCaseRepository: parsed ${cases.length} valid cases, nextToken: "$nextToken"');
    
    return {
      'cases': cases,
      'nextPageToken': nextToken,
    };
  }

  /// Fetch a page from API. Uses cursor-based pagination with [pageToken].
  /// Legacy method - returns only the cases list for backward compatibility.
  Future<List<MoldCase>> fetchPage({String? pageToken, String? sessionCookie}) async {
    final result = await fetchPageWithToken(pageToken: pageToken, sessionCookie: sessionCookie);
    return result['cases'] as List<MoldCase>;
  }

  /// Normalize field names from /api/v1/mold-case/assigned response
  /// to match MoldCase model expectations. Also handles legacy mold-report fields for compatibility.
  Map<String, dynamic> _normalizeMoldReportFields(Map<String, dynamic> json) {
    return {
      ...json,
      // Map legacy mold-report field names to mold-case field names (backward compatibility)
      if (json.containsKey('case_name')) 'name': json['case_name'],
      if (json.containsKey('assigned_mycologist_id')) 'mycologist_id': json['assigned_mycologist_id'],
      // The 'id' from mold-report endpoint is the report ID
      if (json.containsKey('id') && !json.containsKey('mold_report_id')) 'mold_report_id': json['id'],
    };
  }

  /// Fetch a case by ID from API.
  Future<MoldCase?> getCaseById(String id, {String? sessionCookie}) async {
    final data = await _service.getMoldCaseById(id, sessionCookie: sessionCookie);
    final payload = (data['data'] is Map<String, dynamic>) ? data['data'] as Map<String, dynamic> : data;
    return MoldCase.fromJson(payload);
  }

  /// Fetch cases by report ID from API.
  Future<List<MoldCase>> getCasesByReportId(String reportId, {String? sessionCookie}) async {
    final data = await _service.getMoldCasesByReportId(reportId, sessionCookie: sessionCookie);
    
    // Normalize the returned data shape
    dynamic raw = data;
    if (data.containsKey('data')) raw = data['data'];

    List<dynamic> rawDataList = <dynamic>[];
    if (raw is List) {
      rawDataList = raw;
    } else if (raw is Map) {
      if (raw['snapshot'] is List) {
        rawDataList = raw['snapshot'] as List<dynamic>;
      } else if (raw['data'] is List) {
        rawDataList = raw['data'] as List<dynamic>;
      } else {
        rawDataList = [raw];
      }
    }

    return rawDataList
        .map((e) => MoldCase.fromJson(e as Map<String, dynamic>))
        .where((c) => c.mycologistId.isNotEmpty)
        .toList();
  }

  /// Update a mold case by id.
  Future<void> updateMoldCase(
    String id,
    Map<String, dynamic> update, {
    String? sessionCookie,
  }) async {
    await _service.updateMoldCase(id, update, sessionCookie: sessionCookie);
  }

  /// Search assigned mold cases by mycologist with optional filters.
  /// Returns both the cases list and the nextPageToken for pagination.
  Future<Map<String, dynamic>> searchCasesWithToken({
    String? search,
    String? priority,
    String? pageToken,
    String? sessionCookie,
  }) async {
    final result = await _service.searchMoldCases(
      search: search,
      priority: priority,
      limit: pageSize,
      pageToken: pageToken,
      sessionCookie: sessionCookie,
    );

    final snapshot = result['snapshot'];
    final nextPageTokenValue = result['nextPageToken'];

    List<dynamic> rawDataList = <dynamic>[];
    if (snapshot is List) {
      rawDataList = snapshot;
    } else if (snapshot is Map) {
      rawDataList = [snapshot];
    }

    final List<MoldCase> cases = rawDataList
        .map((e) => MoldCase.fromJson(e as Map<String, dynamic>))
        .where((c) => c.id.isNotEmpty)
        .toList();

    final String? nextToken = 
        (nextPageTokenValue != null && nextPageTokenValue.toString().trim().isNotEmpty)
            ? nextPageTokenValue.toString().trim()
            : null;

    return {
      'cases': cases,
      'nextPageToken': nextToken,
    };
  }

  /// Search assigned mold cases by mycologist with optional filters.
  /// Legacy method - returns only the cases list for backward compatibility.
  Future<List<MoldCase>> searchCases({
    String? search,
    String? priority,
    String? pageToken,
    String? sessionCookie,
  }) async {
    final result = await searchCasesWithToken(
      search: search,
      priority: priority,
      pageToken: pageToken,
      sessionCookie: sessionCookie,
    );
    return result['cases'] as List<MoldCase>;
  }
}
