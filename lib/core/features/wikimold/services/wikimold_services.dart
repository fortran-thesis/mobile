import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constants/api_url.dart';
import '../models/wikimold.dart';

class WikiService {
  Future<Map<String, dynamic>> fetchMoldipedia({
    String? pageToken,
    String? sessionCookie,
  }) async {
    String url = ApiUrl.moldipedia;
    if (pageToken != null) {
      url += '?pageToken=$pageToken';
    }

    try {
      final response = await http.get(
        Uri.parse(url),
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


