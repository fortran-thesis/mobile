import 'package:moldify/core/features/mold_report/models/mold_report.dart';
import 'package:moldify/core/features/mold_report/service/mold_report_services.dart';

class MoldReportRepository {
  final MoldReportService _service = MoldReportService();

  // Simple in-memory page cache: page -> list of reports
  // Cache keyed by pageToken (use empty string for the first page)
  final Map<String, List<MoldReport>> _pagesCache = {};
  // Keep track of the order of page tokens as fetched
  final List<String> _pageTokensOrder = [];
  final Map<String, String?> _nextPageTokenMap = {};
  // Track all seen report IDs to detect duplicates across pages
  final Set<String> _seenReportIds = {};
  final int pageSize;

  MoldReportRepository({this.pageSize = 10});

  /// Return cached combined list (pages merged in fetch order)
  List<MoldReport> getCachedReports() {
    final List<MoldReport> combined = [];
    for (final token in _pageTokensOrder) {
      final page = _pagesCache[token];
      if (page != null) combined.addAll(page);
    }
    return combined;
  }

  /// Fetch a page from API. Uses cursor-based pagination with [pageToken].
  /// If [useCache] and the pageToken was fetched before, returns cached list.
  Future<List<MoldReport>> fetchPage({String? pageToken, bool useCache = true, String? sessionCookie}) async {
    final key = pageToken ?? '';
    if (useCache && _pagesCache.containsKey(key)) {
      print('MoldReportRepository: returning cached page for token "$key" (${_pagesCache[key]!.length} reports)');
      return _pagesCache[key]!;
    }

    print('MoldReportRepository: fetching page from API (pageToken: "$key", limit: $pageSize)');
    final result = await _service.fetchMoldReports(sessionCookie: sessionCookie, limit: pageSize, pageToken: pageToken, path: '/');
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

  // Check if all reports in this page are duplicates (already seen)
  final newReports = reports.where((r) => !_seenReportIds.contains(r.id)).toList();
  final duplicateCount = reports.length - newReports.length;
  
  if (duplicateCount > 0) {
    print('MoldReportRepository: found $duplicateCount duplicate reports, $newReports.length new reports');
  }
  
  // Add new report IDs to the seen set
  for (final report in newReports) {
    _seenReportIds.add(report.id);
  }

    // cache only new reports (avoid duplicates in the combined list)
    _pagesCache[key] = newReports;
    if (!_pageTokensOrder.contains(key)) _pageTokensOrder.add(key);

    // normalize next page token from a couple of likely keys / locations
    String? nextPageToken;
    // First check the top-level data object (where snapshot lives)
    if (raw is Map && (raw['nextPageToken'] != null || raw['next_page_token'] != null)) {
      nextPageToken = (raw['nextPageToken'] ?? raw['next_page_token']) as String?;
    } else {
      // Fall back to checking the top-level result
      nextPageToken = (result['nextPageToken'] ?? result['next_page_token']) as String?;
      if (nextPageToken == null && result['data'] is Map) {
        final inner = result['data'] as Map<String, dynamic>;
        nextPageToken = (inner['nextPageToken'] ?? inner['next_page_token']) as String?;
      }
    }
    
    // If we got an empty page, mark nextPageToken as null to signal no more pages
    if (reports.isEmpty && nextPageToken != null) {
      print('MoldReportRepository: received empty page, setting nextPageToken to null');
      nextPageToken = null;
    }
    
    // If all reports in this page were duplicates (newReports is empty), we've reached the end
    if (newReports.isEmpty && reports.isNotEmpty && nextPageToken != null) {
      print('MoldReportRepository: all reports in page are duplicates, setting nextPageToken to null (end of data)');
      nextPageToken = null;
    }
    
    // If the nextPageToken is the same as the current pageToken, we've reached the end
    // (backend is returning the same cursor, meaning no more data)
    if (nextPageToken != null && nextPageToken == pageToken) {
      print('MoldReportRepository: nextPageToken same as current pageToken, setting to null (end of data)');
      nextPageToken = null;
    }
    
    _nextPageTokenMap[key] = nextPageToken;
    print('MoldReportRepository: nextPageToken for "$key" = "$nextPageToken", hasMore = ${nextPageToken != null && nextPageToken.isNotEmpty}');
    return newReports;
  }

  /// Get next page token for a given pageToken (or first page if null)
  String? getNextPageToken(String? pageToken) => _nextPageTokenMap[pageToken ?? ''];

  /// Create a report via API and optionally update cache (prepend to first page)
  Future<void> createReport(MoldReport report, {String? sessionCookie}) async {
    await _service.createMoldReport(report.toJson(), sessionCookie: sessionCookie);
    // Prepend to first page cache if exists
    final firstKey = '';
    if (_pagesCache.containsKey(firstKey)) {
      final current = _pagesCache[firstKey]!;
      _pagesCache[firstKey] = [report, ...current];
    }
  }

  /// Get a report by id. First checks the in-memory cache, otherwise fetches
  /// from the service and inserts it into the first page cache for reuse.
  Future<MoldReport?> getReportById(String id, {String? sessionCookie}) async {
    // 1) search cache
    for (final page in _pagesCache.values) {
      for (final r in page) {
        if (r.id == id) return r;
      }
    }

    // 2) not found -> fetch from service
    try {
      final Map<String, dynamic> data = await _service.getMoldReportById(id, sessionCookie: sessionCookie);
      final Map<String, dynamic> payload = (data['data'] is Map<String, dynamic>) ? data['data'] as Map<String, dynamic> : data;
      final MoldReport report = MoldReport.fromJson(payload);

      // Only insert into cache when the fetched report looks valid (has an id).
      final firstKey = '';
      if (report.id.isNotEmpty) {
        if (_pagesCache.containsKey(firstKey)) {
          _pagesCache[firstKey] = [report, ..._pagesCache[firstKey]!];
        } else {
          _pagesCache[firstKey] = [report];
          if (!_pageTokensOrder.contains(firstKey)) _pageTokensOrder.add(firstKey);
        }
      }
      return report;
    } catch (e) {
      // bubble up or return null to caller
      rethrow;
    }
  }

  /// Clear cache (useful for refresh)
  void clearCache() {
    _pagesCache.clear();
    _pageTokensOrder.clear();
    _nextPageTokenMap.clear();
    _seenReportIds.clear();
  }
}
