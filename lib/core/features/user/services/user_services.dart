import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:moldify/core/constants/api_url.dart';
import 'package:moldify/services/api_service.dart';

class UserService {
  final ApiService _apiService = ApiService(baseUrl: ApiUrl.user);

  Future<Map<String, dynamic>> getUserProfile(String? sessionCookie) async {
    print(
        'UserService: getUserProfile called with sessionCookie: $sessionCookie');
    final response = await _apiService.get(
      '/profile',
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
      },
      sessionCookie: sessionCookie,

    );

    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    return {
      'success': jsonResponse['success'] ?? false,
      'data': jsonResponse['data'],
      'error': jsonResponse['error'],
    };
  }

  Future<Map<String, dynamic>> editProfile({
    required String? sessionCookie,
    String? firstName,
    String? lastName,
    String? username,
    String? displayName,
    String? address,
    String? phoneNumber,
    File? photoFile,
  }) async {
    try {
      print('Starting editProfile...');
      print('Received parameters:');
      print('username: $username');
      print('firstName: $firstName');
      print('lastName: $lastName');
      print('displayName: $displayName');


      if (photoFile == null) {
        final Map<String, dynamic> details = {};

        if (firstName != null && firstName.isNotEmpty)
          details['firstName'] = firstName;
        if (lastName != null && lastName.isNotEmpty)
          details['lastName'] = lastName;
        if (username != null && username.isNotEmpty)
          details['username'] = username;
        if (displayName != null && displayName.isNotEmpty)
          details['displayName'] = displayName;
        if (address != null && address.isNotEmpty)
          details['address'] = address;
        if (phoneNumber != null && phoneNumber.isNotEmpty)
          details['phoneNumber'] = phoneNumber;

        final body = {
          'details': details,
        };

        print('Request body: $body');

        final response = await _apiService.patch(
          '/profile',
          headers: {'Content-Type': 'application/json'},
          body: body,
          sessionCookie: sessionCookie,
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('Request timed out');
          },
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        final jsonResponse = json.decode(response.body);
        return {
          'success': jsonResponse['success'] ?? false,
          'data': jsonResponse['data'],
          'error': jsonResponse['error'],
        };
      }


      final uri = Uri.parse('${ApiUrl.user}/profile');
      final request = http.MultipartRequest('PATCH', uri);

      // 1. Ensure the Cookie header is correctly formatted
      if (sessionCookie != null && sessionCookie.isNotEmpty) {
        request.headers['cookie'] = 'session=$sessionCookie';
      }

      // 2. Add other necessary headers
      request.headers['Accept'] = 'application/json';

      // 3. Add fields
      final details = <String, dynamic>{};
      if (firstName != null && firstName.isNotEmpty) details['firstName'] = firstName;
      if (lastName != null && lastName.isNotEmpty) details['lastName'] = lastName;
      if (username != null && username.isNotEmpty) details['username'] = username;
      if (displayName != null && displayName.isNotEmpty) details['displayName'] = displayName;
      if (address != null && address.isNotEmpty) details['address'] = address;
      if (phoneNumber != null && phoneNumber.isNotEmpty) details['phoneNumber'] = phoneNumber;

      request.fields['details'] = json.encode(details);

      // 4. Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          photoFile.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final jsonResponse = json.decode(response.body);
      return {
        'success': jsonResponse['success'] ?? false,
        'data': jsonResponse['data'],
        'error': jsonResponse['error'],
      };
    } on TimeoutException catch (e) {
      print('Timeout error: $e');
      return {
        'success': false,
        'data': null,
        'error': 'Request timed out. Please check your connection.',
      };
    } catch (e, stackTrace) {
      print('Error in editProfile: $e');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'data': null,
        'error': e.toString(),
      };
    }
  }
}