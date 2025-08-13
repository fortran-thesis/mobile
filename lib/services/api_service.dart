import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<http.Response> get(String endpoint, {Map<String, String>? headers, Map<String, dynamic>? queryParams, String? sessionCookie}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams?.map((k, v) => MapEntry(k, v.toString())));
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
      final url = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams?.map((k, v) => MapEntry(k, v.toString())));
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
      final url = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams?.map((k, v) => MapEntry(k, v.toString())));
      final allHeaders = {...?headers};
      if (sessionCookie != null) {
        allHeaders['Cookie'] = 'session=$sessionCookie';
      }
      return await http.patch(url, headers: allHeaders, body: json.encode(body));
    } catch (e) {
      throw Exception('PATCH request failed: $e');
    }
  }

  Future<http.Response> delete(String endpoint, {Map<String, String>? headers, Map<String, dynamic>? queryParams, String? sessionCookie}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams?.map((k, v) => MapEntry(k, v.toString())));
      final allHeaders = {...?headers};
      if (sessionCookie != null) {
        allHeaders['Cookie'] = 'session=$sessionCookie';
      }
      return await http.delete(url, headers: allHeaders);
    } catch (e) {
      throw Exception('DELETE request failed: $e');
    }
  }


}
