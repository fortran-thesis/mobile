import 'package:moldify/core/config/cache_config.dart';
import 'package:moldify/services/api_service.dart';
import '../../../constants/api_url.dart';
import '../models/wikimold.dart';

class WikiService {
  final ApiService _apiService = ApiService(baseUrl: ApiUrl.moldipedia);
  /// Fetch all moldipedia articles with cursor-based pagination
  /// Endpoint: GET /
  /// 
  /// [limit] - page size (defaults to 10)
  /// [pageToken] - cursor token for pagination
  /// [sessionCookie] - optional, not required for public access
  Future<Map<String, dynamic>> fetchMoldipedia({
    int limit = 10,
    String? pageToken,
    String? sessionCookie,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        if (pageToken != null && pageToken.trim().isNotEmpty) 'pageToken': pageToken.trim(),
      };

      final response = await _apiService.get(
        '',
        queryParams: queryParams.isEmpty ? null : queryParams,
        sessionCookie: sessionCookie,
        cacheOptions: CacheConfig.staticData,
      );

      if (response.statusCode == 200 || response.statusCode == 304) {
        // 200 = fresh response, 304 = Not Modified (use cache)
        final responseData = response.data;
        if (responseData == null) {
          throw Exception('Empty response from server');
        }

        // Handle response structure: { success, data: { snapshot, nextPageToken } }
        final Map<String, dynamic> responseBody = 
            (responseData is Map<String, dynamic>) ? responseData : {};
        
        // Extract the data object from either direct response or wrapped in 'data' key
        final data = responseBody['data'] is Map<String, dynamic>
            ? responseBody['data'] as Map<String, dynamic>
            : responseBody;

        final snapshot = data['snapshot'];
        if (snapshot is! List) {
          throw Exception('Invalid snapshot format: expected array but got ${snapshot.runtimeType}');
        }

        final List<WikiArticle> articles = (snapshot as List<dynamic>)
            .whereType<Map>()
            .map((item) => WikiArticle.fromJson(Map<String, dynamic>.from(item)))
            .where((article) => article.id.isNotEmpty)
            .toList();

        final nextTokenValue = data['nextPageToken'];
        final String? nextToken = 
            (nextTokenValue != null && nextTokenValue.toString().trim().isNotEmpty)
                ? nextTokenValue.toString().trim()
                : null;

        return {
          'articles': articles,
          'nextPageToken': nextToken,
        };
      } else if (response.statusCode == 404) {
        throw Exception('Moldipedia articles not found');
      } else if (response.statusCode == 500) {
        final error = response.data is Map ? response.data['error'] : 'Unknown error';
        throw Exception('Server error: $error');
      } else {
        throw Exception('Failed to fetch articles: HTTP ${response.statusCode}');
      }
    } catch (e) {
      rethrow; // Let the caller handle the detailed error
    }
  }

  /// Search moldipedia articles with optional query filter and pagination
  /// 
  /// [search] - search query for title/body
  /// [limit] - page size (defaults to 10)
  /// [pageToken] - cursor token for pagination
  /// [sessionCookie] - optional, not required for public access
  Future<Map<String, dynamic>> searchMoldipedia({
    String? search,
    int limit = 10,
    String? pageToken,
    String? sessionCookie,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (pageToken != null && pageToken.trim().isNotEmpty) 'pageToken': pageToken.trim(),
      };

      final response = await _apiService.get(
        '',
        queryParams: queryParams.isEmpty ? null : queryParams,
        sessionCookie: sessionCookie,
        cacheOptions: CacheConfig.staticData,
      );

      if (response.statusCode == 200 || response.statusCode == 304) {
        // 200 = fresh response, 304 = Not Modified (use cache)
        final responseData = response.data;
        if (responseData == null) throw Exception('Empty response from server');
        
        final Map<String, dynamic> responseBody = 
            (responseData is Map<String, dynamic>) ? responseData : {};
        
        final data = responseBody['data'] is Map<String, dynamic>
            ? responseBody['data'] as Map<String, dynamic>
            : responseBody;

        final snapshot = data['snapshot'];
        if (snapshot is! List) 
          throw Exception('Invalid snapshot format: expected array but got ${snapshot.runtimeType}');

        final List<WikiArticle> articles = (snapshot as List<dynamic>)
            .whereType<Map>()
            .map((item) => WikiArticle.fromJson(Map<String, dynamic>.from(item)))
            .where((article) => article.id.isNotEmpty)
            .toList();

        final nextTokenValue = data['nextPageToken'];
        final String? nextToken = 
            (nextTokenValue != null && nextTokenValue.toString().trim().isNotEmpty)
                ? nextTokenValue.toString().trim()
                : null;

        return {
          'articles': articles,
          'nextPageToken': nextToken,
        };
      } else if (response.statusCode == 404) {
        throw Exception('Moldipedia articles not found');
      } else if (response.statusCode == 500) {
        final error = response.data is Map ? response.data['error'] : 'Unknown error';
        throw Exception('Server error: $error');
      } else {
        throw Exception('Failed to search articles: HTTP ${response.statusCode}');
      }
    } catch (e) {
      rethrow; // Preserve error chain
    }
  }

  /// Fetch a single moldipedia article by ID
  /// 
  /// [articleId] - the ID of the article to fetch
  /// [sessionCookie] - session cookie for authentication (optional)
  Future<WikiArticle> fetchWikiArticleById({
    required String articleId,
    String? sessionCookie,
  }) async {
    if (articleId.isEmpty) {
      throw Exception('Invalid article ID: cannot be empty');
    }

    try {
      final response = await _apiService.get(
        '/$articleId',
        headers: {'Content-Type': 'application/json'},
        sessionCookie: sessionCookie,
        cacheOptions: CacheConfig.staticData,
      );

      if (response.statusCode == 200 || response.statusCode == 304) {
        // 200 = fresh response, 304 = Not Modified (use cache)
        final responseData = response.data;
        if (responseData == null) throw Exception('Empty response from server');
        
        final Map<String, dynamic> responseBody = 
            (responseData is Map<String, dynamic>) ? responseData : {};
        
        final articleData = responseBody['data'] is Map<String, dynamic>
            ? responseBody['data'] as Map<String, dynamic>
            : responseBody;

        if (articleData.isEmpty) 
          throw Exception('Invalid article data structure from server');

        return WikiArticle.fromJson(articleData);
      } else if (response.statusCode == 404) {
        throw Exception('Article not found: $articleId');
      } else if (response.statusCode == 500) {
        final error = response.data is Map ? response.data['error'] : 'Unknown error';
        throw Exception('Server error: $error');
      } else {
        throw Exception('Failed to fetch article: HTTP ${response.statusCode}');
      }
    } catch (e) {
      rethrow; // Preserve error chain
    }
  }
}


