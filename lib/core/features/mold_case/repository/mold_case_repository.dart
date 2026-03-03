import 'package:moldify/core/features/mold_case/models/mold_case.dart';
import 'package:moldify/core/features/mold_case/service/mold_case_service.dart';
import 'package:moldify/core/utils/logger.dart';

class MoldCaseRepository {
  final MoldCaseService _service = MoldCaseService();
  final int pageSize;

  MoldCaseRepository({this.pageSize = 10});

  /// Fetch a page from API. Uses cursor-based pagination with [pageToken].
  Future<List<MoldCase>> fetchPage({String? pageToken, String? sessionCookie}) async {
    AppLogger.d('MoldCaseRepository: fetching page from API (pageToken: "$pageToken", limit: $pageSize)');
    final result = await _service.fetchAssignedMycologists(
      sessionCookie: sessionCookie,
      limit: pageSize,
      pageToken: pageToken,
    );
    AppLogger.d('MoldCaseRepository: raw API response: $result');

    // Normalize the returned data shape. Backend may return:
    // - { success: true, data: { snapshot: [...], nextPageToken: ... } }
    // - { data: [ ... ], nextPageToken: '...' }
    // - [ ... ] (raw list)
    dynamic raw = result;
    if (result.containsKey('data')) raw = result['data'];

    List<dynamic> rawDataList = <dynamic>[];
    if (raw is List) {
      rawDataList = raw;
    } else if (raw is Map) {
      // Check for 'snapshot' field first (backend format)
      if (raw['snapshot'] is List) {
        rawDataList = raw['snapshot'] as List<dynamic>;
      } else if (raw['data'] is List) {
        rawDataList = raw['data'] as List<dynamic>;
      } else {
        // treat single object as a one-element list
        rawDataList = [raw];
      }
    } else {
      rawDataList = <dynamic>[];
    }

    AppLogger.d('MoldCaseRepository: normalized rawDataList (${rawDataList.length} items)');

    final List<MoldCase> cases = rawDataList
        .map((e) => MoldCase.fromJson(e as Map<String, dynamic>))
        .where((c) => c.mycologistId.isNotEmpty) // ignore invalid/empty placeholder objects
        .toList();

    AppLogger.d('MoldCaseRepository: parsed ${cases.length} valid cases (filtered empty ids)');
    return cases;
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

  /// Search assigned mold cases by mycologist with optional filters
  Future<List<MoldCase>> searchCases({
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

    dynamic raw = result;
    if (result.containsKey('data')) raw = result['data'];

    List<dynamic> rawDataList = <dynamic>[];
    if (raw is List) {
      rawDataList = raw;
    } else if (raw is Map) {
      if (raw['snapshot'] is List) {
        rawDataList = raw['snapshot'] as List<dynamic>;
      } else if (raw['data'] is List) {
        rawDataList = raw['data'] as List<dynamic>;
      }
    }

    return rawDataList
        .map((e) => MoldCase.fromJson(e as Map<String, dynamic>))
        .where((c) => c.id.isNotEmpty)
        .toList();
  }
}
