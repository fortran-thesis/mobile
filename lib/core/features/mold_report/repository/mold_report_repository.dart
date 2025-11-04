import 'package:moldify/core/features/mold_report/models/mold_report.dart';
import 'package:moldify/core/features/mold_report/service/mold_report_services.dart';

class MoldReportRepository {
  final MoldReportService _service = MoldReportService();
  final int pageSize;

  MoldReportRepository({this.pageSize = 10});

  /// Fetch a page from API. Uses cursor-based pagination with [pageToken].
  Future<List<MoldReport>> fetchPage({String? pageToken, String? sessionCookie}) async {
    print('MoldReportRepository: fetching page from API (pageToken: "$pageToken", limit: $pageSize)');
    final result = await _service.fetchMoldReports(sessionCookie: sessionCookie, limit: pageSize, pageToken: pageToken, path: '/user');
    print('MoldReportRepository: raw API response: $result');

    // Normalize the returned data shape. Backend may return:
    // - { success: true, data: { snapshot: [...], nextPageToken: ... } }
    // - { data: [ ... ], nextPageToken: '...' }
    // - { data: { data: [ ... ] } }
    // - [ ... ] (raw list)
    // - { ... } (single object)
    dynamic raw = result;
    if (result.containsKey('data')) raw = result['data'];

    List<dynamic> rawDataList = <dynamic>[];
    if (raw is List) {
      rawDataList = raw;
    } else if (raw is Map) {
      // Check for 'snapshot' field first (new backend format)
      if (raw['snapshot'] is List) {
        rawDataList = raw['snapshot'] as List<dynamic>;
      } else if (raw['data'] is List) {
        // If data is a wrapper map that itself contains a list under 'data'
        rawDataList = raw['data'] as List<dynamic>;
      } else {
        // treat single object as a one-element list
        rawDataList = [raw];
      }
    } else {
      rawDataList = <dynamic>[];
    }

    print('MoldReportRepository: normalized rawDataList (${rawDataList.length} items): $rawDataList');

    final List<MoldReport> reports = rawDataList
        .map((e) => MoldReport.fromJson(e as Map<String, dynamic>))
        .where((r) => r.id.isNotEmpty) // ignore invalid/empty placeholder objects
        .toList();

    print('MoldReportRepository: parsed ${reports.length} valid reports (filtered empty ids)');
    return reports;
  }

  /// Get a report by id.
  Future<MoldReport?> getReportById(String id, {String? sessionCookie}) async {
    try {
      final Map<String, dynamic> data = await _service.getMoldReportById(id, sessionCookie: sessionCookie);
      final Map<String, dynamic> payload = (data['data'] is Map<String, dynamic>) ? data['data'] as Map<String, dynamic> : data;
      final MoldReport report = MoldReport.fromJson(payload);
      return report;
    } catch (e) {
      rethrow;
    }
  }

  /// Create a mold report.
  Future<void> createMoldReport(MoldReport report, {String? sessionCookie}) async {
    await _service.createMoldReport(report.toJson(), sessionCookie: sessionCookie);
  }
}
