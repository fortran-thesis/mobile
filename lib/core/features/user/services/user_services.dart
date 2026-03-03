import 'dart:convert';
import 'dart:io';

import 'package:moldify/core/config/cache_config.dart';
import 'package:moldify/core/constants/api_url.dart';
import 'package:moldify/services/api_service.dart';

class UserService {
  final ApiService _apiService = ApiService(baseUrl: ApiUrl.user);

  Future<Map<String, dynamic>> getUserProfile(String? sessionCookie) async {
    final response = await _apiService.get(
      '/profile',
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
      },
      sessionCookie: sessionCookie,
      cacheOptions: CacheConfig.noCache,
    );

    final Map<String, dynamic> jsonResponse = response.data as Map<String, dynamic>;
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
      if (photoFile == null) {
        final Map<String, dynamic> details = {};

        if (firstName != null && firstName.isNotEmpty) {
          details['firstName'] = firstName;
        }
        if (lastName != null && lastName.isNotEmpty) {
          details['lastName'] = lastName;
        }
        if (username != null && username.isNotEmpty) {
          details['username'] = username;
        }
        if (displayName != null && displayName.isNotEmpty) {
          details['displayName'] = displayName;
        }
        if (address != null && address.isNotEmpty) {
          details['address'] = address;
        }
        if (phoneNumber != null && phoneNumber.isNotEmpty) {
          details['phoneNumber'] = phoneNumber;
        }

        final body = {
          'details': details,
        };

        final response = await _apiService.patch(
          '/profile',
          headers: {'Content-Type': 'application/json'},
          body: body,
          sessionCookie: sessionCookie,
        );

        final jsonResponse = response.data as Map<String, dynamic>;
        return {
          'success': jsonResponse['success'] ?? false,
          'data': jsonResponse['data'],
          'error': jsonResponse['error'],
        };
      }

      // Multipart PATCH with photo upload
      final details = <String, dynamic>{};
      if (firstName != null && firstName.isNotEmpty) details['firstName'] = firstName;
      if (lastName != null && lastName.isNotEmpty) details['lastName'] = lastName;
      if (username != null && username.isNotEmpty) details['username'] = username;
      if (displayName != null && displayName.isNotEmpty) details['displayName'] = displayName;
      if (address != null && address.isNotEmpty) details['address'] = address;
      if (phoneNumber != null && phoneNumber.isNotEmpty) details['phoneNumber'] = phoneNumber;

      final response = await _apiService.patchMultipart(
        '/profile',
        fields: {'details': json.encode(details)},
        fileFieldName: 'photo',
        filePath: photoFile.path,
        headers: {'Accept': 'application/json'},
        sessionCookie: sessionCookie,
      );

      final jsonResponse = response.data as Map<String, dynamic>;
      return {
        'success': jsonResponse['success'] ?? false,
        'data': jsonResponse['data'],
        'error': jsonResponse['error'],
      };
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'error': e.toString(),
      };
    }
  }
}