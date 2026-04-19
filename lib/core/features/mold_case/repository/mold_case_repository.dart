import 'package:moldify/core/features/mold_case/models/mold_case.dart';
import 'package:moldify/core/features/mold_case/service/mold_case_service.dart';
import 'package:moldify/core/features/mold_report/service/mold_report_services.dart';
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

    // Extract snapshot and nextPageToken.
    // The backend has returned a few shapes in the past, so accept all of them.
    final dynamic rawSnapshot = result['snapshot'] ?? result['cases'] ?? result['data'];
    final nextPageTokenValue = result['nextPageToken'];

    List<dynamic> rawDataList = <dynamic>[];
    if (rawSnapshot is List) {
      rawDataList = rawSnapshot;
    } else if (rawSnapshot is Map) {
      if (rawSnapshot['snapshot'] is List) {
        rawDataList = rawSnapshot['snapshot'] as List<dynamic>;
      } else if (rawSnapshot['cases'] is List) {
        rawDataList = rawSnapshot['cases'] as List<dynamic>;
      } else if (rawSnapshot['data'] is List) {
        rawDataList = rawSnapshot['data'] as List<dynamic>;
      } else {
        rawDataList = [rawSnapshot];
      }
    }

    AppLogger.d('MoldCaseRepository: normalized rawDataList (${rawDataList.length} items)');

    // Normalize API response fields to match MoldCase model expectations
    // API returns: case_name, assigned_mycologist_id, id
    // Model expects: name, mycologist_id, mold_report_id
    final List<MoldCase> cases = rawDataList
        .map((e) => _normalizeMoldReportFields(e as Map<String, dynamic>))
        .map((e) => MoldCase.fromJson(e))
      .where((c) => c.id.isNotEmpty)
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
    final moldCase = json['mold_case'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['mold_case'] as Map)
        : <String, dynamic>{};

    return {
      ...json,
      // Map legacy and alternate field names to the MoldCase model.
      'id': json['id'] ?? json['_id'] ?? json['case_id'] ?? json['report_id'],
      'name': json['case_name'] ?? json['name'] ?? json['title'] ?? moldCase['case_name'] ?? moldCase['name'],
      'mycologist_id': json['assigned_mycologist_id'] ?? json['mycologist_id'] ?? moldCase['assigned_mycologist_id'] ?? moldCase['mycologist_id'],
      'mold_report_id': json['mold_report_id'] ?? json['report_id'] ?? json['case_id'] ?? moldCase['mold_report_id'] ?? moldCase['report_id'],
      'photo_url': json['photo_url'] ?? json['cover_photo'] ?? json['coverPhoto'] ?? json['report_cover_photo'] ?? moldCase['photo_url'] ?? moldCase['cover_photo'],
      'crop_name': json['crop_name'] ?? json['host'] ?? moldCase['crop_name'] ?? moldCase['host'],
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
      .where((c) => c.id.isNotEmpty)
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

  /// Enrich mold cases with crop names from mold reports when missing.
  /// For each case with null cropName, fetches the mold report and extracts the host.
  /// Returns the enriched cases list (or original if report fetch fails).
  Future<List<MoldCase>> enrichCasesWithCropNames(
    List<MoldCase> cases, {
    String? sessionCookie,
  }) async {
    if (cases.isEmpty) return cases;

    final casesNeedingCropName = cases.where((c) => c.cropName == null || c.cropName!.isEmpty).toList();
    if (casesNeedingCropName.isEmpty) return cases;

    AppLogger.d('MoldCaseRepository: enriching ${casesNeedingCropName.length} cases with crop names');

    final moldReportService = MoldReportService();
    final enrichedCases = <MoldCase>[];

    for (final moldCase in cases) {
      // If case already has a crop name, keep it as is
      if (moldCase.cropName != null && moldCase.cropName!.isNotEmpty) {
        enrichedCases.add(moldCase);
        continue;
      }

      try {
        // Fetch the mold report to get the host/crop name
        final reportData = await moldReportService.getMoldReportById(
          moldCase.moldReportId,
          sessionCookie: sessionCookie,
        );

        final host = reportData['host']?.toString().trim() ?? reportData['data']?['host']?.toString().trim();
        if (host != null && host.isNotEmpty) {
          // Enrich the case with the crop name
          enrichedCases.add(moldCase.copyWith(cropName: host));
          AppLogger.d('MoldCaseRepository: enriched case ${moldCase.id} with crop name: $host');
        } else {
          enrichedCases.add(moldCase);
        }
      } catch (e) {
        AppLogger.w('MoldCaseRepository: failed to fetch crop name for case ${moldCase.id}: $e');
        enrichedCases.add(moldCase); // Keep original if fetch fails
      }
    }

    return enrichedCases;
  }
}

