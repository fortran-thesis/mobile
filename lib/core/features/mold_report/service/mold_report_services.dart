import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:moldify/core/constants/api_url.dart';
import 'package:moldify/services/api_service.dart';

class MoldReportService {
  final ApiService _apiService = ApiService(baseUrl: ApiUrl.moldReport);

  /// Create a new mold report. [report] should be JSON-serializable (Map or
  /// object with toJson()). Pass [sessionCookie] when available so the
  /// request includes the server session cookie for authentication.
  /// Create a new mold report using multipart/form-data.
  ///
  /// The backend expects a multipart upload with the file field named
  /// `cover_photo` (single file) and the other report fields provided as
  /// form fields. Complex fields (lists/maps) are JSON-encoded before being
  /// attached to the form.
  ///
  /// [report] should be a Map containing the report fields using the
  /// backend-expected keys (snake_case). [coverPhoto] is an optional file to
  /// upload under the field name `cover_photo`. Pass [sessionCookie] for
  /// authenticated requests.
  Future<Map<String, dynamic>> createMoldReport(
    Map<String, dynamic> report, {
    File? coverPhoto,
    String? sessionCookie,
    /// When true, prints the raw `report` Map (pretty JSON) before it's
    /// converted into multipart form fields. Useful for debugging what the
    /// client is about to send to the server. Defaults to false.
    bool debugDumpPayload = true,
    /// When true, prints the constructed multipart request fields and file
    /// metadata (field name, filename, content-type, length) before sending.
    bool debugDumpMultipart = false,
    /// When true, prints a base64-encoded snapshot of the final multipart
    /// request bytes that will be sent. Useful for byte-level diffs with
    /// Postman/server logs. Note: this builds the request twice when enabled.
    bool debugDumpRawBytes = false,
  }) async {
    final uri = Uri.parse('${ApiUrl.moldReport}/user');

    // Helper to build the MultipartRequest so we can snapshot bytes without
    // consuming the stream that would be sent.
    Future<http.MultipartRequest> _buildRequest() async {
      final request = http.MultipartRequest('POST', uri);
      if (sessionCookie != null) {
        request.headers['Cookie'] = 'session=$sessionCookie';
      }

      // Keep legacy behavior: attach the whole report as a single `details`
      // field (JSON blob). This mirrors the current server expectations.
      request.fields['details'] = json.encode(report);

      if (coverPhoto != null) {
        final filename = coverPhoto.path.split(Platform.pathSeparator).last;
        final bytes = await coverPhoto.readAsBytes();

        String ext = filename.split('.').length > 1 ? filename.split('.').last.toLowerCase() : 'jpeg';
        String subtype = 'jpeg';
        if (ext == 'png') subtype = 'png';
        else if (ext == 'jpg' || ext == 'jpeg') subtype = 'jpeg';
        else if (ext == 'webp') subtype = 'webp';

        final multipartFile = http.MultipartFile.fromBytes(
          'cover_photo',
          bytes,
          filename: filename,
          contentType: MediaType('image', subtype),
        );
        request.files.add(multipartFile);
      }

      return request;
    }

    // Optional debug: print the raw payload before converting to form fields.
    if (debugDumpPayload) {
      try {
        final pretty = const JsonEncoder.withIndent('  ').convert(report);
        print('MoldReport payload (before converting to fields):\n$pretty');
      } catch (e) {
        print('Failed to pretty-print mold report payload: $e');
        print('Raw payload: $report');
      }
    }

    // If requested, build a temporary request and print multipart fields/files
    // metadata before sending.
    if (debugDumpMultipart || debugDumpRawBytes) {
      final snapshot = await _buildRequest();

      if (debugDumpMultipart) {
        try {
          print('MoldReport multipart fields:');
          snapshot.fields.forEach((k, v) {
            final display = v is String && v.length > 100 ? '${v.substring(0, 100)}... (len=${v.length})' : v;
            print('  $k: $display');
          });

          if (snapshot.files.isEmpty) {
            print('MoldReport multipart files: (none)');
          } else {
            print('MoldReport multipart files:');
            for (final f in snapshot.files) {
              print('  field=${f.field}, filename=${f.filename}, contentType=${f.contentType}, length=${f.length}');
            }
          }
        } catch (e) {
          print('Failed to dump multipart info: $e');
        }
      }

      if (debugDumpRawBytes) {
        try {
          final byteStream = await snapshot.finalize();
          final bytes = await http.ByteStream(byteStream).fold<List<int>>([], (a, b) => a..addAll(b));
          final encoded = base64.encode(bytes);
          print('MoldReport multipart raw bytes (base64, ${bytes.length} bytes):');
          // Print chunks so long logs are easier to inspect (split every 2048 chars)
          const chunk = 2048;
          for (var i = 0; i < encoded.length; i += chunk) {
            print(encoded.substring(i, i + chunk > encoded.length ? encoded.length : i + chunk));
          }
        } catch (e) {
          print('Failed to dump raw multipart bytes: $e');
        }
      }
    }

    // Build the real request and send it.
    final request = await _buildRequest();
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (response.body.isEmpty) return <String, dynamic>{};
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Failed to create mold report: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Fetch a list of mold reports. Returns decoded JSON list. Caller can map
  /// to model instances if desired. This method expects the backend to return
  /// a paginated result with shape: { data: [...], nextPageToken: string | null }
  Future<Map<String, dynamic>> fetchMoldReports({
    String? sessionCookie,
    int? limit,
    String? pageToken,
    String path = '/',
  }) async {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (pageToken != null) queryParams['pageToken'] = pageToken;

    final response = await _apiService.get(
      path,
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
      queryParams: queryParams.isEmpty ? null : queryParams,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded =
          json.decode(response.body) as Map<String, dynamic>;
      return decoded;
    } else {
      throw Exception('Failed to fetch mold reports: ${response.statusCode}');
    }
  }

  /// Fetch archived mold reports.
  Future<Map<String, dynamic>> fetchArchived({
    String? sessionCookie,
    int? limit,
    String? pageToken,
  }) async {
    return fetchMoldReports(
      sessionCookie: sessionCookie,
      limit: limit,
      pageToken: pageToken,
      path: '/archive',
    );
  }

  /// Get a single mold report by id.
  Future<Map<String, dynamic>> getMoldReportById(
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
    throw Exception('Failed to fetch mold report $id: ${response.statusCode}');
  }

  /// Post a case detail to a report (/:id/case-details)
  Future<Map<String, dynamic>> postCaseDetail(
    String reportId,
    Map<String, dynamic> caseDetail, {
    String? sessionCookie,
  }) async {
    final response = await _apiService.post(
      '/$reportId/case-details',
      headers: {'Content-Type': 'application/json'},
      body: caseDetail,
      sessionCookie: sessionCookie,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception(
      'Failed to post case detail for report $reportId: ${response.statusCode} ${response.body}',
    );
  }

  /// Patch a mold report by id.
  Future<void> patchMoldReport(
    String id,
    Map<String, dynamic> update, {
    String? sessionCookie,
  }) async {
    final response = await _apiService.patch(
      '/$id',
      headers: {'Content-Type': 'application/json'},
      body: update,
      sessionCookie: sessionCookie,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to patch mold report $id: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Hard delete a mold report
  Future<void> deleteMoldReportHard(String id, {String? sessionCookie}) async {
    final response = await _apiService.delete(
      '/hard/$id',
      sessionCookie: sessionCookie,
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to hard delete mold report $id: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Soft delete a mold report
  Future<void> deleteMoldReportSoft(String id, {String? sessionCookie}) async {
    final response = await _apiService.delete(
      '/soft/$id',
      sessionCookie: sessionCookie,
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to soft delete mold report $id: ${response.statusCode} ${response.body}',
      );
    }
  }
}
