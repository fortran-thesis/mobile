import 'package:moldify/core/config/cache_config.dart';
import 'package:moldify/core/constants/api_url.dart';
import 'package:moldify/services/api_service.dart';

class MoldCatalogEntry {
  final String id;
  final String name;
  final String description;
  final Map<String, String> additionalInfo;
  final Map<String, String> prevention;

  const MoldCatalogEntry({
    required this.id,
    required this.name,
    required this.description,
    required this.additionalInfo,
    required this.prevention,
  });
}

class MoldService {
  final ApiService _apiService = ApiService(baseUrl: ApiUrl.mold);

  String _readString(dynamic value) => value?.toString().trim() ?? '';

  String _readMapString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      final asText = _readString(value);
      if (asText.isNotEmpty) return asText;
    }
    return '';
  }

  MoldCatalogEntry _parseCatalogEntry(Map<String, dynamic> raw) {
    final details = raw['mold_details'] is Map<String, dynamic>
        ? raw['mold_details'] as Map<String, dynamic>
        : <String, dynamic>{};
    final info = details['info'] is Map<String, dynamic>
        ? details['info'] as Map<String, dynamic>
        : <String, dynamic>{};
    final taxonomy = info['taxonomy'] is Map<String, dynamic>
        ? info['taxonomy'] as Map<String, dynamic>
        : <String, dynamic>{};
    final preventionRaw = details['prevention'] is Map<String, dynamic>
        ? details['prevention'] as Map<String, dynamic>
        : <String, dynamic>{};

    final id = _readMapString(raw, ['id', 'moldId', 'mold_id']);

    final name = _readMapString(raw, ['name', 'moldName']).isNotEmpty
        ? _readMapString(raw, ['name', 'moldName'])
        : _readMapString(taxonomy, ['genus']);

    final description = _readMapString(info, ['description', 'overview']);

    final additionalInfo = <String, String>{};
    final additionalInfoRaw = info['additional_info'];
    if (additionalInfoRaw is List) {
      for (final item in additionalInfoRaw.whereType<Map>()) {
        final infoMap = Map<String, dynamic>.from(item);
        final title = _readMapString(infoMap, ['title', 'name']);
        final content = _readMapString(infoMap, ['description', 'content', 'value']);
        if (title.isNotEmpty && content.isNotEmpty) {
          additionalInfo[title] = content;
        }
      }
    }

    String readControl(List<String> keys) => _readMapString(preventionRaw, keys);

    final prevention = <String, String>{
      'Physical Control': readControl(['physicalControl', 'physical_control']),
      'Mechanical Control': readControl(['mechanicalControl', 'mechanical_control']),
      'Cultural Control': readControl(['culturalControl', 'cultural_control']),
      'Biological Control': readControl(['biologicalControl', 'biological_control']),
      'Chemical Control': readControl(['chemicalControl', 'chemical_control']),
    };

    return MoldCatalogEntry(
      id: id,
      name: name,
      description: description,
      additionalInfo: additionalInfo,
      prevention: prevention,
    );
  }

  Future<List<MoldCatalogEntry>> fetchAllMoldCatalog({
    String? sessionCookie,
    int pageSize = 100,
    int maxPages = 20,
  }) async {
    final entries = <MoldCatalogEntry>[];
    final seenIds = <String>{};
    final seenNames = <String>{};
    String? pageToken;
    int pageCount = 0;

    while (pageCount < maxPages) {
      final queryParams = <String, String>{
        'limit': pageSize.toString(),
        if (pageToken != null && pageToken.trim().isNotEmpty)
          'pageToken': pageToken.trim(),
      };

      final response = await _apiService.get(
        '',
        queryParams: queryParams,
        sessionCookie: sessionCookie,
        cacheOptions: CacheConfig.staticData,
      );

      if (response.statusCode != 200 && response.statusCode != 304) {
        throw Exception('Failed to fetch molds: HTTP ${response.statusCode}');
      }

      final responseBody = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};

      final data = responseBody['data'] is Map<String, dynamic>
          ? responseBody['data'] as Map<String, dynamic>
          : responseBody;

      final snapshot = data['snapshot'];
      if (snapshot is! List) {
        throw Exception('Invalid mold payload: expected snapshot array');
      }

      for (final item in snapshot.whereType<Map>()) {
        final mold = Map<String, dynamic>.from(item);
        final entry = _parseCatalogEntry(mold);

        if (entry.name.isEmpty) continue;

        if (entry.id.isNotEmpty) {
          if (seenIds.add(entry.id)) {
            entries.add(entry);
          }
          continue;
        }

        final normalizedName = entry.name.toLowerCase();
        if (seenNames.add(normalizedName)) {
          entries.add(entry);
        }
      }

      final nextTokenRaw = data['nextPageToken']?.toString().trim();
      if (nextTokenRaw == null || nextTokenRaw.isEmpty) break;

      pageToken = nextTokenRaw;
      pageCount += 1;
    }

    entries.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return entries;
  }

  Future<MoldCatalogEntry?> fetchMoldById(
    String moldId, {
    String? sessionCookie,
  }) async {
    final id = moldId.trim();
    if (id.isEmpty) return null;

    final response = await _apiService.get(
      '/$id',
      sessionCookie: sessionCookie,
      cacheOptions: CacheConfig.staticData,
    );

    if (response.statusCode == 404) return null;
    if (response.statusCode != 200 && response.statusCode != 304) {
      throw Exception('Failed to fetch mold by id: HTTP ${response.statusCode}');
    }

    final responseBody = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{};

    final data = responseBody['data'] is Map<String, dynamic>
        ? responseBody['data'] as Map<String, dynamic>
        : responseBody;

    if (data.isEmpty) return null;
    return _parseCatalogEntry(data);
  }

  Future<List<String>> fetchAllMoldOptions({
    String? sessionCookie,
    int pageSize = 100,
    int maxPages = 20,
  }) async {
    final catalog = await fetchAllMoldCatalog(
      sessionCookie: sessionCookie,
      pageSize: pageSize,
      maxPages: maxPages,
    );
    return catalog.map((entry) => entry.name).toList();
  }
}
