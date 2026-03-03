import 'package:moldify/core/config/cache_config.dart';
import 'package:moldify/services/api_service.dart';
import '../../../constants/api_url.dart';
import '../models/wikimold.dart';

class WikiService {
  final ApiService _apiService = ApiService(baseUrl: ApiUrl.moldipedia);
  /// Fetch all moldipedia articles with optional pagination
  /// 
  /// [limit] - defaults to 10
  /// [pageToken] - for cursor-based pagination
  /// [sessionCookie] - optional, not required for public access
  Future<Map<String, dynamic>> fetchMoldipedia({
    int limit = 10,
    String? pageToken,
    String? sessionCookie,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        if (pageToken != null) 'pageToken': pageToken,
      };

      final response = await _apiService.get(
        '',
        queryParams: queryParams,
        sessionCookie: sessionCookie,
        cacheOptions: CacheConfig.staticData,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = response.data as Map<String, dynamic>;

        final List snapshot = decodedData['data']['snapshot'];
        final List<WikiArticle> articles =
        snapshot.map((item) => WikiArticle.fromJson(item)).toList();

        return {
          'articles': articles,
          'nextPageToken': decodedData['data']['nextPageToken'],
        };
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to Moldipedia: $e');
    }
  }

  /// Search moldipedia articles with optional query filter
  /// 
  /// [search] - search query for title/body
  /// [limit] - defaults to 10
  /// [pageToken] - for cursor-based pagination
  /// [sessionCookie] - optional, not required for public access
  Future<Map<String, dynamic>> searchMoldipedia({
    String? search,
    int limit = 10,
    String? pageToken,
    String? sessionCookie,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      queryParams['limit'] = limit.toString();
      if (pageToken != null && pageToken.isNotEmpty) queryParams['pageToken'] = pageToken;

      final response = await _apiService.get(
        '',
        queryParams: queryParams,
        sessionCookie: sessionCookie,
        cacheOptions: CacheConfig.staticData,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = response.data as Map<String, dynamic>;

        final List snapshot = decodedData['data']['snapshot'];
        final List<WikiArticle> articles =
        snapshot.map((item) => WikiArticle.fromJson(item)).toList();

        return {
          'articles': articles,
          'nextPageToken': decodedData['data']['nextPageToken'],
        };
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search Moldipedia: $e');
    }
  }

  Future<WikiArticle> fetchWikiArticleById({
    required String articleId,
    String? sessionCookie,
  }) async {
    if (articleId.isEmpty) {
      throw Exception('Invalid article ID');
    }

    if (sessionCookie == null || sessionCookie.isEmpty) {
      throw Exception('Unauthorized: session cookie is missing');
    }

    try {
      final response = await _apiService.get(
        '/$articleId',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        sessionCookie: sessionCookie.trim(),
        cacheOptions: CacheConfig.staticData,
      );

      final decoded = response.data as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return WikiArticle.fromJson(decoded['data']);
      } else if (response.statusCode == 404) {
        throw Exception('Article not found');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: please log in again');
      } else if (response.statusCode == 400) {
        throw Exception('Bad request: check article ID format');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch article: $e');
    }
  }
}


