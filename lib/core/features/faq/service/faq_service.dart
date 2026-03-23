import 'package:moldify/core/config/cache_config.dart';
import 'package:moldify/core/constants/api_url.dart';
import 'package:moldify/services/api_service.dart';

class FAQService {
  final ApiService _apiService = ApiService(baseUrl: ApiUrl.baseUrl);

  /// Get all FAQs with pagination
  /// 
  /// Pass [sessionCookie] for authenticated requests.
  /// [limit] defaults to 10, [pageToken] is for pagination.
  /// Use the new [limit] parameter instead of [pageSize].
  Future<Map<String, dynamic>> getAllFAQ({
    String? sessionCookie,
    int limit = 10,
    String? pageToken,
  }) async {
    try {
      final queryParams = {
        'limit': limit.toString(),
        if (pageToken != null) 'pageToken': pageToken,
      };

      final response = await _apiService.get(
        '/api/v1/faq',
        queryParams: queryParams,
        sessionCookie: sessionCookie,
        cacheOptions: CacheConfig.staticData,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        }
        throw Exception('Failed to fetch FAQs: ${data['error']}');
      }
      throw Exception('Failed to fetch FAQs: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Search FAQs with optional query filter
  /// 
  /// [search] - search query for question/answer
  /// [limit] defaults to 10
  /// [pageToken] - for pagination
  Future<Map<String, dynamic>> searchFAQ({
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
        '/api/v1/faq',
        queryParams: queryParams,
        sessionCookie: sessionCookie,
        cacheOptions: CacheConfig.staticData,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        }
        throw Exception('Failed to search FAQs: ${data['error']}');
      }
      throw Exception('Failed to search FAQs: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Get a specific FAQ by ID
  /// 
  /// Pass [sessionCookie] for authenticated requests.
  Future<Map<String, dynamic>> getFAQById(
    String id, {
    String? sessionCookie,
  }) async {
    try {
      final response = await _apiService.get(
        '/api/v1/faq/$id',
        sessionCookie: sessionCookie,
        cacheOptions: CacheConfig.staticData,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        }
        throw Exception('Failed to fetch FAQ: ${data['error']}');
      }
      throw Exception('FAQ not found: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new FAQ
  /// 
  /// Requires curator/admin role.
  /// [question] and [answer] are required fields.
  Future<Map<String, dynamic>> createFAQ({
    required String question,
    required String answer,
    required String sessionCookie,
  }) async {
    try {
      final body = {
        'question': question,
        'answer': answer,
      };

      final response = await _apiService.post(
        '/api/v1/faq',
        body: body,
        sessionCookie: sessionCookie,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        }
        throw Exception('Failed to create FAQ: ${data['error']}');
      }
      throw Exception('Failed to create FAQ: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing FAQ
  /// 
  /// Requires curator/admin role.
  /// [question] and [answer] are optional - only provide fields to update.
  Future<Map<String, dynamic>> updateFAQ(
    String id, {
    String? question,
    String? answer,
    required String sessionCookie,
  }) async {
    try {
      final body = <String, dynamic>{
        if (question != null) 'question': question,
        if (answer != null) 'answer': answer,
      };

      if (body.isEmpty) {
        throw Exception('No fields to update');
      }

      final response = await _apiService.patch(
        '/api/v1/faq/$id',
        body: body,
        sessionCookie: sessionCookie,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        }
        throw Exception('Failed to update FAQ: ${data['error']}');
      }
      throw Exception('Failed to update FAQ: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Soft delete an FAQ
  /// 
  /// Requires admin role.
  /// Soft deleted items are marked as deleted but not permanently removed.
  Future<void> softDeleteFAQ(
    String id, {
    required String sessionCookie,
  }) async {
    try {
      final response = await _apiService.delete(
        '/api/v1/faq/soft/$id',
        sessionCookie: sessionCookie,
      );

      if (response.statusCode != 200) {
        final data = response.data as Map<String, dynamic>;
        throw Exception('Failed to delete FAQ: ${data['error']}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Hard delete an FAQ
  /// 
  /// Requires admin role.
  /// This permanently removes the FAQ from the database.
  Future<void> deleteFAQ(
    String id, {
    required String sessionCookie,
  }) async {
    try {
      final response = await _apiService.delete(
        '/api/v1/faq/hard/$id',
        sessionCookie: sessionCookie,
      );

      if (response.statusCode != 200) {
        final data = response.data as Map<String, dynamic>;
        throw Exception('Failed to permanently delete FAQ: ${data['error']}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
