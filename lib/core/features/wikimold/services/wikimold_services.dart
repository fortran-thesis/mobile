import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constants/api_url.dart';
import '../models/wikimold.dart';

class WikiService {
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

      final uri = Uri.parse(ApiUrl.moldipedia).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (sessionCookie != null) 'Cookie': 'session=$sessionCookie',
        },
      );
      print('Moldipedia response code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);

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

      final uri = Uri.parse(ApiUrl.moldipedia).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (sessionCookie != null) 'Cookie': 'session=$sessionCookie',
        },
      );
      print('WikiService.searchMoldipedia: status=${response.statusCode}');
      print('WikiService.searchMoldipedia: search=$search');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);

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
    // 1️⃣ Ensure articleId is not empty
    if (articleId.isEmpty) {
      throw Exception('Invalid article ID');
    }

    final url = '${ApiUrl.moldipedia}/$articleId';
    print('Fetching article with URL: $url');

    // 2️⃣ Ensure the cookie is valid
    if (sessionCookie == null || sessionCookie.isEmpty) {
      throw Exception('Unauthorized: session cookie is missing');
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // make sure server expects JSON
          'Cookie': 'session=${sessionCookie.trim()}', // ✅ send correctly
        },
      );

      print('Response code: ${response.statusCode}');
      print('Response body: ${response.body}');

      final decoded = json.decode(response.body);

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


