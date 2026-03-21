import 'package:moldify/services/api_service.dart';
import '../../../constants/api_url.dart';

/// Service for mold lookup functionality using symptoms, signs, and characteristics
class LookupService {
  final ApiService _apiService = ApiService(baseUrl: ApiUrl.lookup);

  /// Perform mold lookup based on reported symptoms, signs, and characteristics
  ///
  /// Returns a list of molds ranked by confidence score (0-100%)
  /// The lookup endpoint performs case-insensitive keyword matching across
  /// mold databases to provide farmers with the most likely candidates.
  ///
  /// [reportedSymptoms] - List of observed symptom descriptions (e.g. "yellowing", "wilting")
  /// [reportedSigns] - List of observed signs (e.g. "white coating", "spotting")
  /// [reportedCharacteristics] - List of environmental/growth characteristics
  /// [sessionCookie] - Optional session cookie for authenticated requests
  ///
  /// Returns: List<Map<String, dynamic>> with fields:
  /// - moldId: String - Unique mold identifier
  /// - moldName: String - Common/scientific name of the mold
  /// - confidence: double - Confidence score percentage (0-100)
  Future<List<Map<String, dynamic>>> performLookup({
    List<String> reportedSymptoms = const [],
    List<String> reportedSigns = const [],
    List<String> reportedCharacteristics = const [],
    String? sessionCookie,
  }) async {
    try {
      // Prepare request body - backend accepts both snake_case and camelCase
      // Sending both for compatibility
      final body = {
        "symptoms": reportedSymptoms,
        "signs": reportedSigns,
        "characteristics": reportedCharacteristics,
        "reported_symptoms": reportedSymptoms,
        "reported_signs": reportedSigns,
        "reported_characteristics": reportedCharacteristics,
      };

      // Call backend lookup endpoint
      // No caching for lookup results as they're user-input dependent and dynamic
      final response = await _apiService.post(
        '',
        headers: {'Content-Type': 'application/json'},
        body: body,
        sessionCookie: sessionCookie,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData == null) {
          throw Exception('Empty response from lookup service');
        }

        // Extract data from response wrapper { success: true, data: [...] }
        final Map<String, dynamic> responseBody =
            (responseData is Map<String, dynamic>) ? responseData : {};

        // Check success flag
        final success = responseBody['success'] ?? false;
        if (!success) {
          final error = responseBody['error'] ?? 'Lookup failed';
          throw Exception(error);
        }

        // Extract lookup results array from data field
        final data = responseBody['data'];
        if (data is! List) {
          throw Exception('Invalid lookup results format: expected array');
        }

        // Convert to List<Map<String, dynamic>>
        return data
            .whereType<Map<String, dynamic>>()
            .toList();
      } else if (response.statusCode == 400) {
        final error = response.data is Map
            ? response.data['error']
            : 'Invalid lookup parameters';
        throw Exception('Validation error: $error');
      } else if (response.statusCode == 500) {
        final error = response.data is Map
            ? response.data['error']
            : 'Server error';
        throw Exception('Server error: $error');
      } else {
        throw Exception('Lookup failed: HTTP ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Convenience method to perform lookup from existing lists of items
  /// Useful when you already have parsed symptom/sign/characteristic lists
  Future<List<Map<String, dynamic>>> lookupFromLists(
    List<String> symptoms,
    List<String> signs,
    List<String> characteristics, {
    String? sessionCookie,
  }) async {
    return performLookup(
      reportedSymptoms: symptoms,
      reportedSigns: signs,
      reportedCharacteristics: characteristics,
      sessionCookie: sessionCookie,
    );
  }
}
