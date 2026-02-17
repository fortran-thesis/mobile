import 'dart:convert';
import 'package:moldify/core/constants/api_url.dart';
import 'package:moldify/services/api_service.dart';

class FAQService {
  final ApiService _apiService = ApiService(baseUrl: ApiUrl.baseUrl);

  /// Get all FAQs with pagination
  /// 
  /// Pass [sessionCookie] for authenticated requests.
  /// [pageSize] defaults to 10, [pageToken] is for pagination.
  Future<Map<String, dynamic>> getAllFAQ({
    String? sessionCookie,
    int pageSize = 10,
    String? pageToken,
  }) async {
    try {
      final queryParams = {
        'pageSize': pageSize.toString(),
        if (pageToken != null) 'pageToken': pageToken,
      };

      final response = await _apiService.get(
        '/api/v1/faq',
        queryParams: queryParams,
        sessionCookie: sessionCookie,
      );

      print('FAQService.getAllFAQ: status=${response.statusCode}');
      print('FAQService.getAllFAQ: body=${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          return json['data'] as Map<String, dynamic>;
        }
        throw Exception('Failed to fetch FAQs: ${json['error']}');
      }
      throw Exception('Failed to fetch FAQs: ${response.statusCode}');
    } catch (e) {
      print('FAQService.getAllFAQ: error=$e');
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
      );

      print('FAQService.getFAQById: id=$id, status=${response.statusCode}');
      print('FAQService.getFAQById: body=${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          return json['data'] as Map<String, dynamic>;
        }
        throw Exception('Failed to fetch FAQ: ${json['error']}');
      }
      throw Exception('FAQ not found: ${response.statusCode}');
    } catch (e) {
      print('FAQService.getFAQById: error=$e');
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

      print('FAQService.createFAQ: status=${response.statusCode}');
      print('FAQService.createFAQ: body=${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          return json['data'] as Map<String, dynamic>;
        }
        throw Exception('Failed to create FAQ: ${json['error']}');
      }
      throw Exception('Failed to create FAQ: ${response.statusCode}');
    } catch (e) {
      print('FAQService.createFAQ: error=$e');
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

      print('FAQService.updateFAQ: id=$id, status=${response.statusCode}');
      print('FAQService.updateFAQ: body=${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          return json['data'] as Map<String, dynamic>;
        }
        throw Exception('Failed to update FAQ: ${json['error']}');
      }
      throw Exception('Failed to update FAQ: ${response.statusCode}');
    } catch (e) {
      print('FAQService.updateFAQ: error=$e');
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

      print('FAQService.softDeleteFAQ: id=$id, status=${response.statusCode}');

      if (response.statusCode != 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception('Failed to delete FAQ: ${json['error']}');
      }
    } catch (e) {
      print('FAQService.softDeleteFAQ: error=$e');
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

      print('FAQService.deleteFAQ: id=$id, status=${response.statusCode}');

      if (response.statusCode != 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception('Failed to permanently delete FAQ: ${json['error']}');
      }
    } catch (e) {
      print('FAQService.deleteFAQ: error=$e');
      rethrow;
    }
  }
}
