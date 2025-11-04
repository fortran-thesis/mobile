import 'package:moldify/core/features/mold_case/models/mold_case.dart';
import 'package:moldify/core/features/mold_case/service/mold_case_service.dart';

class MoldCaseRepository {
  final MoldCaseService _service = MoldCaseService();

  // Simple in-memory page cache: page -> list of cases
  final Map<String, List<MoldCase>> _pagesCache = {};
  // Keep track of the order of page tokens as fetched
  final List<String> _pageTokensOrder = [];
  final Map<String, String?> _nextPageTokenMap = {};
  // Track all seen case IDs to detect duplicates across pages
  final Set<String> _seenCaseIds = {};
  final int pageSize;

  MoldCaseRepository({this.pageSize = 10});

  /// Return cached combined list (pages merged in fetch order)
  List<MoldCase> getCachedCases() {
    final List<MoldCase> combined = [];
    for (final token in _pageTokensOrder) {
      final page = _pagesCache[token];
      if (page != null) combined.addAll(page);
    }
    return combined;
  }

  /// Fetch a page from API. Uses cursor-based pagination with [pageToken].
  /// If [useCache] and the pageToken was fetched before, returns cached list.
  Future<List<MoldCase>> fetchPage({String? pageToken, bool useCache = true, String? sessionCookie}) async {
    final key = pageToken ?? '';
    if (useCache && _pagesCache.containsKey(key)) {
      print('MoldCaseRepository: returning cached page for token "$key" (${_pagesCache[key]!.length} cases)');
      return _pagesCache[key]!;
    }

    print('MoldCaseRepository: fetching page from API (pageToken: "$key", limit: $pageSize)');
    final result = await _service.fetchAssignedMycologists(
      sessionCookie: sessionCookie,
      limit: pageSize,
      pageToken: pageToken,
    );
    print('MoldCaseRepository: raw API response: $result');

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

    print('MoldCaseRepository: normalized rawDataList (${rawDataList.length} items)');

    final List<MoldCase> cases = rawDataList
        .map((e) => MoldCase.fromJson(e as Map<String, dynamic>))
        .where((c) => c.mycologistId.isNotEmpty) // ignore invalid/empty placeholder objects
        .toList();

    print('MoldCaseRepository: parsed ${cases.length} valid cases (filtered empty ids)');

    // Check if all cases in this page are duplicates (already seen)
    final newCases = cases.where((c) => !_seenCaseIds.contains(c.mycologistId)).toList();
    final duplicateCount = cases.length - newCases.length;

    if (duplicateCount > 0) {
      print('MoldCaseRepository: found $duplicateCount duplicate cases, ${newCases.length} new cases');
    }

    // Add new case IDs to the seen set
    for (final moldCase in newCases) {
      _seenCaseIds.add(moldCase.mycologistId);
    }

    // cache only new cases (avoid duplicates in the combined list)
    _pagesCache[key] = newCases;
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
    if (cases.isEmpty && nextPageToken != null) {
      print('MoldCaseRepository: received empty page, setting nextPageToken to null');
      nextPageToken = null;
    }

    // If all cases in this page were duplicates (newCases is empty), we've reached the end
    if (newCases.isEmpty && cases.isNotEmpty && nextPageToken != null) {
      print('MoldCaseRepository: all cases in page are duplicates, setting nextPageToken to null (end of data)');
      nextPageToken = null;
    }

    // If the nextPageToken is the same as the current pageToken, we've reached the end
    if (nextPageToken != null && nextPageToken == pageToken) {
      print('MoldCaseRepository: nextPageToken same as current pageToken, setting to null (end of data)');
      nextPageToken = null;
    }

    _nextPageTokenMap[key] = nextPageToken;
    print('MoldCaseRepository: nextPageToken for "$key" = "$nextPageToken", hasMore = ${nextPageToken != null && nextPageToken.isNotEmpty}');
    return newCases;
  }

  /// Get next page token for a given pageToken (or first page if null)
  String? getNextPageToken(String? pageToken) => _nextPageTokenMap[pageToken ?? ''];

  /// Get a case by id. First checks the in-memory cache, otherwise fetches
  /// from the service and inserts it into the first page cache for reuse.
  Future<MoldCase?> getCaseById(String id, {String? sessionCookie}) async {
    // 1) search cache
    for (final page in _pagesCache.values) {
      for (final c in page) {
        if (c.mycologistId == id) return c;
      }
    }

    // 2) not found -> fetch from service
    try {
      final Map<String, dynamic> data = await _service.getMoldCaseById(id, sessionCookie: sessionCookie);
      final Map<String, dynamic> payload = (data['data'] is Map<String, dynamic>) ? data['data'] as Map<String, dynamic> : data;
      final MoldCase moldCase = MoldCase.fromJson(payload);

      // Only insert into cache when the fetched case looks valid (has an id).
      final firstKey = '';
      if (moldCase.mycologistId.isNotEmpty) {
        _seenCaseIds.add(moldCase.mycologistId);
        if (_pagesCache.containsKey(firstKey)) {
          _pagesCache[firstKey] = [moldCase, ..._pagesCache[firstKey]!];
        } else {
          _pagesCache[firstKey] = [moldCase];
          if (!_pageTokensOrder.contains(firstKey)) _pageTokensOrder.add(firstKey);
        }
      }
      return moldCase;
    } catch (e) {
      rethrow;
    }
  }

  /// Clear cache (useful for refresh)
  void clearCache() {
    _pagesCache.clear();
    _pageTokensOrder.clear();
    _nextPageTokenMap.clear();
    _seenCaseIds.clear();
  }
}
