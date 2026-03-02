import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<http.Response> get(String endpoint, {Map<String, String>? headers, Map<String, dynamic>? queryParams, String? sessionCookie}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final url = queryParams != null && queryParams.isNotEmpty
          ? uri.replace(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())))
          : uri;
      final allHeaders = {...?headers};
      if (sessionCookie != null) {
        allHeaders['Cookie'] = 'session=$sessionCookie';
      }
      print('🌐 [GET] $url');
      final response = await http.get(url, headers: allHeaders);
      print('✅ [GET] ${response.statusCode} $url');
      print('   body: ${response.body.length > 300 ? response.body.substring(0, 300) + "..." : response.body}');
      return response;
    } catch (e) {
      print('❌ [GET] $baseUrl$endpoint → $e');
      throw Exception('GET request failed: $e');
    }
  }

  Future<http.Response> post(String endpoint, {Map<String, String>? headers, Object? body, Map<String, dynamic>? queryParams, String? sessionCookie}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final url = queryParams != null && queryParams.isNotEmpty
          ? uri.replace(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())))
          : uri;
      final allHeaders = {...?headers};
      if (sessionCookie != null) {
        allHeaders['Cookie'] = 'session=$sessionCookie';
      }
      print('🌐 [POST] $url');
      print('   body: ${json.encode(body)}');
      final response = await http.post(url, headers: allHeaders, body: json.encode(body));
      print('✅ [POST] ${response.statusCode} $url');
      print('   body: ${response.body.length > 300 ? response.body.substring(0, 300) + "..." : response.body}');
      return response;
    } catch (e) {
      print('❌ [POST] $baseUrl$endpoint → $e');
      throw Exception('POST request failed: $e');
    }
  }

  Future<http.Response> patch(String endpoint, {Map<String, String>? headers, Object? body, Map<String, dynamic>? queryParams, String? sessionCookie}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final url = queryParams != null && queryParams.isNotEmpty
          ? uri.replace(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())))
          : uri;
      final allHeaders = {...?headers};
      if (sessionCookie != null) {
        allHeaders['Cookie'] = 'session=$sessionCookie';
      }
      final encodedBody = json.encode(body);
      print('🌐 [PATCH] $url');
      print('   body: $encodedBody');
      final response = await http.patch(url, headers: allHeaders, body: encodedBody);
      print('✅ [PATCH] ${response.statusCode} $url');
      print('   body: ${response.body.length > 300 ? response.body.substring(0, 300) + "..." : response.body}');
      return response;
    } catch (e) {
      print('❌ [PATCH] $baseUrl$endpoint → $e');
      throw Exception('PATCH request failed: $e');
    }
  }

  Future<http.Response> delete(String endpoint, {Map<String, String>? headers, Map<String, dynamic>? queryParams, String? sessionCookie}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final url = queryParams != null && queryParams.isNotEmpty
          ? uri.replace(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())))
          : uri;
      final allHeaders = {...?headers};
      if (sessionCookie != null) {
        allHeaders['Cookie'] = 'session=$sessionCookie';
      }
      print('🌐 [DELETE] $url');
      final response = await http.delete(url, headers: allHeaders);
      print('✅ [DELETE] ${response.statusCode} $url');
      return response;
    } catch (e) {
      print('❌ [DELETE] $baseUrl$endpoint → $e');
      throw Exception('DELETE request failed: $e');
    }
  }

  Future<http.Response> postMultipart(
    String endpoint, {
    Map<String, String>? fields,
    String? fileFieldName,
    String? filePath,
    Map<String, String>? headers,
    String? sessionCookie,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', url);

      // Add headers
      if (sessionCookie != null) {
        request.headers['Cookie'] = 'session=$sessionCookie';
      }
      if (headers != null) {
        request.headers.addAll(headers);
      }

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add file
      if (fileFieldName != null && filePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath(fileFieldName, filePath),
        );
      }

      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
      throw Exception('Multipart POST request failed: $e');
    }
  }
}
