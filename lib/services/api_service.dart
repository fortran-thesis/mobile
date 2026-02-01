import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<http.Response> get(String endpoint, {Map<String, String>? headers, Map<String, dynamic>? queryParams, String? sessionCookie}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      // Only replace query parameters if new ones are provided
      // This preserves any query params already in the endpoint string (e.g., ?device=mobile)
      final url = queryParams != null && queryParams.isNotEmpty
          ? uri.replace(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())))
          : uri;
      final allHeaders = {...?headers};
      if (sessionCookie != null) {
        allHeaders['Cookie'] = 'session=$sessionCookie';
      }
      return await http.get(url, headers: allHeaders);
    } catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  Future<http.Response> post(String endpoint, {Map<String, String>? headers, Object? body, Map<String, dynamic>? queryParams, String? sessionCookie}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      // Only replace query parameters if new ones are provided
      // This preserves any query params already in the endpoint string (e.g., ?device=mobile)
      final url = queryParams != null && queryParams.isNotEmpty
          ? uri.replace(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())))
          : uri;
      final allHeaders = {...?headers};
      if (sessionCookie != null) {
        allHeaders['Cookie'] = 'session=$sessionCookie';
      }
      return await http.post(url, headers: allHeaders, body: json.encode(body));
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  Future<http.Response> patch(String endpoint, {Map<String, String>? headers, Object? body, Map<String, dynamic>? queryParams, String? sessionCookie}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      // Only replace query parameters if new ones are provided
      // This preserves any query params already in the endpoint string (e.g., ?device=mobile)
      final url = queryParams != null && queryParams.isNotEmpty
          ? uri.replace(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())))
          : uri;
      final allHeaders = {...?headers};
      if (sessionCookie != null) {
        allHeaders['Cookie'] = 'session=$sessionCookie';
      }
      final encodedBody = json.encode(body);
      print('ApiService.patch: endpoint=$endpoint');
      print('ApiService.patch: url=$url');
      print('ApiService.patch: headers=$allHeaders');
      print('ApiService.patch: body=$encodedBody');
      final response = await http.patch(url, headers: allHeaders, body: encodedBody);
      print('ApiService.patch: response status=${response.statusCode}');
      print('ApiService.patch: response body=${response.body}');
      return response;
    } catch (e) {
      throw Exception('PATCH request failed: $e');
    }
  }

  Future<http.Response> delete(String endpoint, {Map<String, String>? headers, Map<String, dynamic>? queryParams, String? sessionCookie}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      // Only replace query parameters if new ones are provided
      // This preserves any query params already in the endpoint string (e.g., ?device=mobile)
      final url = queryParams != null && queryParams.isNotEmpty
          ? uri.replace(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())))
          : uri;
      final allHeaders = {...?headers};
      if (sessionCookie != null) {
        allHeaders['Cookie'] = 'session=$sessionCookie';
      }
      return await http.delete(url, headers: allHeaders);
    } catch (e) {
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
