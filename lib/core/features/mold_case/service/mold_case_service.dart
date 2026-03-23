import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:moldify/core/config/cache_config.dart';
import 'package:moldify/core/constants/api_url.dart';
import 'package:moldify/services/api_service.dart';

class MoldCaseService {
  // API clients: case endpoints and report endpoints
  // Case endpoints root: /api/v1/mold-case
  final ApiService _caseApi = ApiService(baseUrl: ApiUrl.moldCase);
  // Report endpoints root: /api/v1/mold-report (used for assigned list and some analytics)
  final ApiService _reportApi = ApiService(baseUrl: ApiUrl.moldReport);

  /// Fetch all assigned mold cases for the authenticated curator.
  /// Endpoint: GET /api/v1/mold-case/assigned
  ///
  /// [limit] - page size (defaults to 10)
  /// [pageToken] - cursor token for pagination
  /// [sessionCookie] - required for authentication
  Future<Map<String, dynamic>> fetchAssignedMycologists({
    String? sessionCookie,
    int? limit,
    String? pageToken,
  }) async {
    try {
      final queryParams = <String, String>{
        if (limit != null) 'limit': limit.toString(),
        if (pageToken != null && pageToken.trim().isNotEmpty)
          'pageToken': pageToken.trim(),
      };

      final response = await _caseApi.get(
        '/assigned',
        headers: {'Content-Type': 'application/json'},
        sessionCookie: sessionCookie,
        queryParams: queryParams.isEmpty ? null : queryParams,
        cacheOptions: CacheConfig.noCache,
      );

      if (response.statusCode == 200 || response.statusCode == 304) {
        // 200 = fresh response, 304 = Not Modified (use cache)
        final responseData = response.data;
        if (responseData == null) {
          throw Exception('Empty response from server');
        }

        // Handle response structure: { data: { snapshot, nextPageToken } }
        // According to API docs, assigned reports return directly with data wrapper
        final Map<String, dynamic> responseBody =
            (responseData is Map<String, dynamic>) ? responseData : {};

        // Extract the data object
        final data = responseBody['data'] is Map<String, dynamic>
            ? responseBody['data'] as Map<String, dynamic>
            : responseBody;

        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Not a curator or session expired');
      } else if (response.statusCode == 404) {
        throw Exception('Failed to retrieve assigned mold reports');
      } else if (response.statusCode == 500) {
        final error = response.data is Map
            ? response.data['error']
            : 'Server error';
        throw Exception('Server error: $error');
      } else {
        throw Exception(
          'Failed to fetch assigned cases: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow; // Preserve error chain
    }
  }

  /// Get a single mold case by id.
  /// Endpoint: GET /:id
  Future<Map<String, dynamic>> getMoldCaseById(
    String id, {
    String? sessionCookie,
  }) async {
    try {
      final response = await _caseApi.get(
        '/$id',
        headers: {'Content-Type': 'application/json'},
        sessionCookie: sessionCookie,
        cacheOptions: CacheConfig.volatileData,
      );

      if (response.statusCode == 200 || response.statusCode == 304) {
        final responseData = response.data;
        if (responseData == null) {
          throw Exception('Empty response from server');
        }

        final Map<String, dynamic> responseBody =
            (responseData is Map<String, dynamic>) ? responseData : {};

        // Check application-level success flag
        final success = responseBody['success'];
        if (success == false) {
          final error = responseBody['error'] ?? 'Failed to fetch mold case';
          throw Exception(error);
        }

        final data = responseBody['data'] is Map<String, dynamic>
            ? responseBody['data'] as Map<String, dynamic>
            : responseBody;

        return data;
      } else if (response.statusCode == 404) {
        throw Exception('Mold case not found: $id');
      } else if (response.statusCode == 500) {
        final error = response.data is Map
            ? response.data['error']
            : 'Unknown error';
        throw Exception('Server error: $error');
      } else {
        throw Exception(
          'Failed to fetch mold case: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get mold cases by report ID.
  /// Endpoint: GET /by-report/:reportId
  Future<Map<String, dynamic>> getMoldCasesByReportId(
    String reportId, {
    String? sessionCookie,
  }) async {
    try {
      final response = await _caseApi.get(
        '/by-report/$reportId',
        headers: {'Content-Type': 'application/json'},
        sessionCookie: sessionCookie,
        cacheOptions: CacheConfig.volatileData,
      );

      if (response.statusCode == 200 || response.statusCode == 304) {
        final responseData = response.data;
        if (responseData == null) {
          throw Exception('Empty response from server');
        }

        final Map<String, dynamic> responseBody =
            (responseData is Map<String, dynamic>) ? responseData : {};

        // Check application-level success flag
        final success = responseBody['success'];
        if (success == false) {
          final error = responseBody['error'] ?? 'Failed to fetch mold cases';
          throw Exception(error);
        }

        final data = responseBody['data'] is Map<String, dynamic>
            ? responseBody['data'] as Map<String, dynamic>
            : responseBody;

        return data;
      } else if (response.statusCode == 404) {
        throw Exception('No mold cases found for report: $reportId');
      } else if (response.statusCode == 500) {
        final error = response.data is Map
            ? response.data['error']
            : 'Unknown error';
        throw Exception('Server error: $error');
      } else {
        throw Exception(
          'Failed to fetch mold cases: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update a mold case by id.
  Future<void> updateMoldCase(
    String id,
    Map<String, dynamic> update, {
    String? sessionCookie,
  }) async {
    final response = await _caseApi.patch(
      '/$id',
      headers: {'Content-Type': 'application/json'},
      body: update,
      sessionCookie: sessionCookie,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Failed to update mold case $id: ${response.statusCode} ${response.data}',
      );
    }
  }

  /// Delete a mold case by id.
  Future<void> deleteMoldCase(String id, {String? sessionCookie}) async {
    final response = await _caseApi.delete(
      '/$id',
      sessionCookie: sessionCookie,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to delete mold case $id: ${response.statusCode} ${response.data}',
      );
    }
  }

  /// Get all archived (closed) mold cases for the user.
  /// Endpoint: GET /archive
  ///
  /// [limit] - page size
  /// [pageToken] - cursor token for pagination
  /// [sessionCookie] - required for authentication
  Future<Map<String, dynamic>> getArchivedCases({
    String? sessionCookie,
    int? limit,
    String? pageToken,
  }) async {
    try {
      final queryParams = <String, String>{
        if (limit != null) 'limit': limit.toString(),
        if (pageToken != null && pageToken.trim().isNotEmpty)
          'pageToken': pageToken.trim(),
      };

      final response = await _caseApi.get(
        '/archive',
        headers: {'Content-Type': 'application/json'},
        sessionCookie: sessionCookie,
        queryParams: queryParams.isEmpty ? null : queryParams,
        cacheOptions: CacheConfig.volatileData,
      );

      if (response.statusCode == 200 || response.statusCode == 304) {
        final responseData = response.data;
        if (responseData == null) {
          throw Exception('Empty response from server');
        }

        final Map<String, dynamic> responseBody =
            (responseData is Map<String, dynamic>) ? responseData : {};

        // Check application-level success flag
        final success = responseBody['success'];
        if (success == false) {
          final error =
              responseBody['error'] ?? 'Failed to fetch archived cases';
          throw Exception(error);
        }

        final data = responseBody['data'] is Map<String, dynamic>
            ? responseBody['data'] as Map<String, dynamic>
            : responseBody;

        return data;
      } else if (response.statusCode == 404) {
        throw Exception('No archived cases found');
      } else if (response.statusCode == 500) {
        final error = response.data is Map
            ? response.data['error']
            : 'Unknown error';
        throw Exception('Server error: $error');
      } else {
        throw Exception(
          'Failed to fetch archived cases: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Dashboard: Get mold case priority breakdown for analytics
  /// Endpoint: GET /counts/priorities (from moldReport routes)
  /// Returns: {high: int, medium: int, low: int}
  /// Note: This uses the moldReport service endpoint for priority analytics
  Future<Map<String, dynamic>> getPriorityBreakdown({
    String? sessionCookie,
  }) async {
    // Use report API for priority analytics
    final response = await _reportApi.get(
      '/counts/priorities',
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
      cacheOptions: CacheConfig.volatileData,
    );

    if (response.statusCode == 200) {
      final responseBody = response.data as Map<String, dynamic>;
      // Extract the data wrapper if it exists, otherwise return the response as-is
      final data = responseBody['data'] is Map<String, dynamic>
          ? responseBody['data'] as Map<String, dynamic>
          : responseBody;
      return data;
    } else {
      throw Exception(
        'Failed to fetch priority breakdown: ${response.statusCode}',
      );
    }
  }

  /// Compress image to reduce file size for upload
  /// Reduces to max 1200px width/height and 80% quality
  Future<String> _compressImage(String imagePath) async {
    try {
      final File imageFile = File(imagePath);

      if (!imageFile.existsSync()) {
        return imagePath;
      }

      final bytes = await imageFile.readAsBytes();

      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        return imagePath;
      }

      // Resize if needed (max 1200px)
      if (image.width > 1200 || image.height > 1200) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? 1200 : null,
          height: image.height > image.width ? 1200 : null,
          interpolation: img.Interpolation.average,
        );
      }

      // Encode as JPEG with 80% quality
      final compressedBytes = img.encodeJpg(image, quality: 80);

      // Save to app cache directory
      final cacheDir = await getTemporaryDirectory();
      final compressedFile = File(
        '${cacheDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile.path;
    } catch (e) {
      return imagePath; // Fallback to original if compression fails
    }
  }

  /// Add a cultivation log entry to a mold case
  /// Endpoint: POST /:caseId/logs
  /// Supports image upload via multipart/form-data with automatic compression
  Future<Map<String, dynamic>> addCultivationLog(
    String caseId,
    Map<String, dynamic> logData, {
    String? imagePath,
    String? sessionCookie,
  }) async {
    try {
      // Prepare form fields
      final fields = <String, String>{
        'type': logData['type'] ?? 'vitro',
        'characteristics': jsonEncode(logData['characteristics'] ?? {}),
        'additional_info': logData['additional_info'] ?? '',
      };

      // Compress image if provided
      String? compressedImagePath = imagePath;
      if (imagePath != null && imagePath.isNotEmpty) {
        compressedImagePath = await _compressImage(imagePath);
      }

      // Use multipart request with image
      final response = await _caseApi.postMultipart(
        '/$caseId/logs',
        fields: fields,
        fileFieldName: 'image',
        filePath: compressedImagePath,
        sessionCookie: sessionCookie,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData == null) {
          throw Exception('Empty response from server');
        }

        final Map<String, dynamic> responseBody =
            (responseData is Map<String, dynamic>) ? responseData : {};

        final success = responseBody['success'];
        if (success == false) {
          final error =
              responseBody['error'] ?? 'Failed to add cultivation log';
          throw Exception(error);
        }

        final data = responseBody['data'] is Map<String, dynamic>
            ? responseBody['data'] as Map<String, dynamic>
            : responseBody;

        return {'success': success == false ? false : true, 'data': data};
      }
      throw Exception(
        'Failed to add cultivation log: ${response.statusCode} ${response.data}',
      );
    } catch (e) {
      throw Exception('Failed to add cultivation log: $e');
    }
  }

  /// Get cultivation logs for a mold case from subcollection
  /// Endpoint: GET /:caseId/logs
  Future<Map<String, dynamic>> getCultivationLogs(
    String caseId, {
    int limit = 50,
    String? pageToken,
    String? sessionCookie,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        if (pageToken != null && pageToken.trim().isNotEmpty)
          'pageToken': pageToken.trim(),
      };

      final response = await _caseApi.get(
        '/$caseId/logs',
        headers: {'Content-Type': 'application/json'},
        sessionCookie: sessionCookie,
        queryParams: queryParams,
        cacheOptions: CacheConfig.volatileData,
      );

      if (response.statusCode == 200 || response.statusCode == 304) {
        final responseData = response.data;
        if (responseData == null) {
          throw Exception('Empty response from server');
        }

        final Map<String, dynamic> responseBody =
            (responseData is Map<String, dynamic>) ? responseData : {};

        final success = responseBody['success'];
        if (success == false) {
          final error =
              responseBody['error'] ?? 'Failed to fetch cultivation logs';
          throw Exception(error);
        }

        final data = responseBody['data'] is Map<String, dynamic>
            ? responseBody['data'] as Map<String, dynamic>
            : responseBody;

        return data;
      }

      throw Exception(
        'Failed to fetch cultivation logs: ${response.statusCode} ${response.data}',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Update cultivation details for a mold case
  /// Endpoint: PATCH /:caseId/cultivation-details
  Future<Map<String, dynamic>> updateCultivationDetails(
    String caseId,
    Map<String, dynamic> details, {
    String? sessionCookie,
  }) async {
    final response = await _caseApi.patch(
      '/$caseId/cultivation-details',
      headers: {'Content-Type': 'application/json'},
      body: details,
      sessionCookie: sessionCookie,
    );

    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    }
    throw Exception(
      'Failed to update cultivation details: ${response.statusCode}',
    );
  }

  /// Analyze a cultivation log image using the backend ML service
  /// Endpoint: POST /:caseId/analyze-cultivation
  /// Supports image upload via multipart/form-data
  Future<Map<String, dynamic>> analyzeCultivationImage(
    String caseId,
    String imagePath, {
    String cultivationType = 'vivo',
    String? sessionCookie,
  }) async {
    final response = await _caseApi.postMultipart(
      '/$caseId/analyze-cultivation',
      headers: {'Content-Type': 'multipart/form-data'},
      fields: {'type': cultivationType},
      fileFieldName: 'image',
      filePath: imagePath,
      sessionCookie: sessionCookie,
    );

    if (response.statusCode == 200) {
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          return data;
        }
        return responseData;
      }
      return {'data': responseData};
    }
    throw Exception(
      'Failed to analyze cultivation image: ${response.statusCode}',
    );
  }

  /// Search assigned mold cases for the mycologist
  /// Endpoint: GET /search
  ///
  /// [search] - search query for case name
  /// [priority] - filter by priority (low, medium, high)
  /// [limit] - page size
  /// [pageToken] - cursor token for pagination
  /// [sessionCookie] - required for authentication
  Future<Map<String, dynamic>> searchMoldCases({
    String? search,
    String? priority,
    int? limit,
    String? pageToken,
    String? sessionCookie,
  }) async {
    try {
      final queryParams = <String, String>{
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (priority != null && priority.trim().isNotEmpty)
          'priority': priority.trim(),
        if (limit != null) 'limit': limit.toString(),
        if (pageToken != null && pageToken.trim().isNotEmpty)
          'pageToken': pageToken.trim(),
      };

      final response = await _caseApi.get(
        '/search',
        headers: {'Content-Type': 'application/json'},
        queryParams: queryParams.isEmpty ? null : queryParams,
        sessionCookie: sessionCookie,
        cacheOptions: CacheConfig.volatileData,
      );

      if (response.statusCode == 200 || response.statusCode == 304) {
        final responseData = response.data;
        if (responseData == null) {
          throw Exception('Empty response from server');
        }

        final Map<String, dynamic> responseBody =
            (responseData is Map<String, dynamic>) ? responseData : {};

        // Check application-level success flag
        final success = responseBody['success'];
        if (success == false) {
          final error = responseBody['error'] ?? 'Failed to search mold cases';
          throw Exception(error);
        }

        final data = responseBody['data'] is Map<String, dynamic>
            ? responseBody['data'] as Map<String, dynamic>
            : responseBody;

        return data;
      } else if (response.statusCode == 404) {
        throw Exception('No cases found matching search criteria');
      } else if (response.statusCode == 500) {
        final error = response.data is Map
            ? response.data['error']
            : 'Unknown error';
        throw Exception('Server error: $error');
      } else {
        throw Exception(
          'Failed to search mold cases: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Submit final mold verdict from mycologist
  /// Endpoint: PATCH /:caseId/verdict
  ///
  /// [caseId] - ID of the mold case
  /// [moldId] - ID of the confirmed mold species
  /// [moldName] - Name of the confirmed mold species
  /// [confidence] - Confidence score (0-100) from lookup algorithm
  /// [notes] - Optional mycologist notes on the verdict
  /// [sessionCookie] - required for authentication
  Future<Map<String, dynamic>> submitVerdict(
    String caseId, {
    required String moldId,
    required String moldName,
    required double confidence,
    String? notes,
    String? sessionCookie,
  }) async {
    try {
      final body = {
        'moldId': moldId,
        'moldName': moldName,
        'confidence': confidence,
        if (notes != null && notes.isNotEmpty) 'mycologist_notes': notes,
      };

      final response = await _caseApi.patch(
        '/$caseId/verdict',
        headers: {'Content-Type': 'application/json'},
        body: body,
        sessionCookie: sessionCookie,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData == null) {
          throw Exception('Empty response from server');
        }

        final Map<String, dynamic> responseBody =
            (responseData is Map<String, dynamic>) ? responseData : {};

        final success = responseBody['success'];
        if (success == false) {
          final error = responseBody['error'] ?? 'Failed to submit verdict';
          throw Exception(error);
        }

        final data = responseBody['data'] is Map<String, dynamic>
            ? responseBody['data'] as Map<String, dynamic>
            : responseBody;

        return data;
      } else if (response.statusCode == 400) {
        final error = response.data is Map
            ? response.data['error']
            : 'Bad request';
        throw Exception('Invalid verdict data: $error');
      } else if (response.statusCode == 404) {
        throw Exception('Mold case not found: $caseId');
      } else if (response.statusCode == 500) {
        final error = response.data is Map
            ? response.data['error']
            : 'Unknown error';
        throw Exception('Server error: $error');
      } else {
        throw Exception(
          'Failed to submit verdict: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
