import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:moldify/core/constants/api_url.dart';
import 'package:moldify/services/api_service.dart';

class MoldCaseService {
  final ApiService _apiService = ApiService(baseUrl: ApiUrl.moldCase);

  /// Fetch all assigned mycologists. Returns a list of mold cases.
  /// Endpoint: GET /assigned
  Future<Map<String, dynamic>> fetchAssignedMycologists({
    String? sessionCookie,
    int? limit,
    String? pageToken,
  }) async {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (pageToken != null) queryParams['pageToken'] = pageToken;

    final response = await _apiService.get(
      '/assigned',
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
      queryParams: queryParams.isEmpty ? null : queryParams,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded =
          json.decode(response.body) as Map<String, dynamic>;
      return decoded;
    } else {
      throw Exception('Failed to fetch assigned mycologists: ${response.statusCode}');
    }
  }

  /// Get a single mold case by id.
  Future<Map<String, dynamic>> getMoldCaseById(
    String id, {
    String? sessionCookie,
  }) async {
    final response = await _apiService.get(
      '/$id',
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch mold case $id: ${response.statusCode}');
  }

  /// Get mold cases by report ID.
  /// Endpoint: GET /by-report/:reportId
  Future<Map<String, dynamic>> getMoldCasesByReportId(
    String reportId, {
    String? sessionCookie,
  }) async {
    final response = await _apiService.get(
      '/by-report/$reportId',
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch mold cases for report $reportId: ${response.statusCode}');
  }

  /// Update a mold case by id.
  Future<void> updateMoldCase(
    String id,
    Map<String, dynamic> update, {
    String? sessionCookie,
  }) async {
    print('MoldCaseService.updateMoldCase: id=$id');
    print('MoldCaseService.updateMoldCase: update=$update');
    final response = await _apiService.patch(
      '/$id',
      headers: {'Content-Type': 'application/json'},
      body: update,
      sessionCookie: sessionCookie,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Failed to update mold case $id: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Delete a mold case by id.
  Future<void> deleteMoldCase(
    String id, {
    String? sessionCookie,
  }) async {
    final response = await _apiService.delete(
      '/$id',
      sessionCookie: sessionCookie,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to delete mold case $id: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Get all archived (closed) mold cases for the user.
  /// Endpoint: GET /archive
  Future<Map<String, dynamic>> getArchivedCases({
    String? sessionCookie,
    int? limit,
    String? pageToken,
  }) async {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (pageToken != null) queryParams['pageToken'] = pageToken;

    final response = await _apiService.get(
      '/archive',
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
      queryParams: queryParams.isEmpty ? null : queryParams,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded =
          json.decode(response.body) as Map<String, dynamic>;
      return decoded;
    } else {
      throw Exception('Failed to fetch archived cases: ${response.statusCode}');
    }
  }

  /// Dashboard: Get mold case priority breakdown for analytics
  /// Endpoint: GET /counts/priorities (from moldReport routes)
  /// Returns: {high: int, medium: int, low: int}
  /// Note: This uses the moldReport service endpoint for priority analytics
  Future<Map<String, dynamic>> getPriorityBreakdown({
    String? sessionCookie,
  }) async {
    // Create temporary service for report analytics
    final reportService = _apiService;
    final response = await reportService.get(
      '/counts/priorities',
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded =
          json.decode(response.body) as Map<String, dynamic>;
      return decoded;
    } else {
      throw Exception('Failed to fetch priority breakdown: ${response.statusCode}');
    }
  }

  /// Compress image to reduce file size for upload
  /// Reduces to max 1200px width/height and 80% quality
  Future<String> _compressImage(String imagePath) async {
    try {
      print('🖼️ Starting image compression for: $imagePath');
      final File imageFile = File(imagePath);
      
      if (!imageFile.existsSync()) {
        print('❌ Image file does not exist: $imagePath');
        return imagePath;
      }

      final bytes = await imageFile.readAsBytes();
      print('📊 Original image size: ${(bytes.length / 1024 / 1024).toStringAsFixed(2)} MB');
      
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        print('❌ Failed to decode image, using original');
        return imagePath;
      }

      print('📐 Original dimensions: ${image.width}x${image.height}');

      // Resize if needed (max 1200px)
      if (image.width > 1200 || image.height > 1200) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? 1200 : null,
          height: image.height > image.width ? 1200 : null,
          interpolation: img.Interpolation.average,
        );
        print('📐 Resized dimensions: ${image.width}x${image.height}');
      }

      // Encode as JPEG with 80% quality
      final compressedBytes = img.encodeJpg(image, quality: 80);
      print('📊 Compressed image size: ${(compressedBytes.length / 1024).toStringAsFixed(2)} KB');
      
      // Save to app cache directory
      final cacheDir = await getTemporaryDirectory();
      final compressedFile = File('${cacheDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      await compressedFile.writeAsBytes(compressedBytes);
      print('✅ Compressed image saved to: ${compressedFile.path}');
      
      return compressedFile.path;
    } catch (e, stackTrace) {
      print('❌ Image compression failed: $e');
      print('Stack trace: $stackTrace');
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
      print('🌾 addCultivationLog: Starting for caseId=$caseId');
      print('🌾 addCultivationLog: logData=$logData');
      print('🌾 addCultivationLog: imagePath=$imagePath');

      // Prepare form fields
      final fields = <String, String>{
        'type': logData['type'] ?? 'vitro',
        'characteristics': jsonEncode(logData['characteristics'] ?? {}),
        'additional_info': logData['additional_info'] ?? '',
      };
      
      print('🌾 Form fields: $fields');

      // Compress image if provided
      String? compressedImagePath = imagePath;
      if (imagePath != null && imagePath.isNotEmpty) {
        print('🌾 Compressing image before upload: $imagePath');
        compressedImagePath = await _compressImage(imagePath);
        print('🌾 Compressed image path: $compressedImagePath');
      } else {
        print('⚠️ No image path provided');
      }

      // Use multipart request with image
      print('🌾 Sending multipart request to /$caseId/logs');
      final response = await _apiService.postMultipart(
        '/$caseId/logs',
        fields: fields,
        fileFieldName: 'image',
        filePath: compressedImagePath,
        sessionCookie: sessionCookie,
      );

      print('🌾 Response status: ${response.statusCode}');
      print('🌾 Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Failed to add cultivation log: ${response.statusCode} ${response.body}');
    } catch (e, stackTrace) {
      print('❌ addCultivationLog error: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to add cultivation log: $e');
    }
  }

  /// Update cultivation details for a mold case
  /// Endpoint: PATCH /:caseId/cultivation-details
  Future<Map<String, dynamic>> updateCultivationDetails(
    String caseId,
    Map<String, dynamic> details, {
    String? sessionCookie,
  }) async {
    final response = await _apiService.patch(
      '/$caseId/cultivation-details',
      headers: {'Content-Type': 'application/json'},
      body: details,
      sessionCookie: sessionCookie,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to update cultivation details: ${response.statusCode}');
  }

  /// Analyze a cultivation log image using the backend ML service
  /// Endpoint: POST /:caseId/analyze-cultivation
  /// Supports image upload via multipart/form-data
  Future<Map<String, dynamic>> analyzeCultivationImage(
    String caseId,
    String imagePath, {
    String? sessionCookie,
  }) async {
    // This would typically use a multipart request with the image file
    // For now, returning a placeholder that matches the backend response
    final response = await _apiService.post(
      '/$caseId/analyze-cultivation',
      headers: {'Content-Type': 'application/json'},
      body: {'image_path': imagePath},
      sessionCookie: sessionCookie,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to analyze cultivation image: ${response.statusCode}');
  }

  /// Search assigned mold cases for the mycologist
  /// Endpoint: GET /search
  /// Query parameters: search, priority, limit, pageToken
  Future<Map<String, dynamic>> searchMoldCases({
    String? search,
    String? priority,
    int? limit,
    String? pageToken,
    String? sessionCookie,
  }) async {
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (priority != null && priority.isNotEmpty) queryParams['priority'] = priority;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (pageToken != null && pageToken.isNotEmpty) queryParams['pageToken'] = pageToken;

    final response = await _apiService.get(
      '/search?${Uri(queryParameters: queryParams).query}',
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to search mold cases: ${response.statusCode}');
    }
    return json.decode(response.body) as Map<String, dynamic>;
  }
}