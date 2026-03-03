import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:moldify/core/config/app_config.dart';
import 'package:moldify/core/config/cache_config.dart';

/// Centralised HTTP client built on [Dio].
///
/// Features added over the old `http`-based wrapper:
///  - Session-cookie injection via interceptor (no per-call boilerplate)
///  - Debug-only request/response logging (replaces scattered `print()` calls)
///  - Global connect / receive timeouts
///  - `validateStatus: (_) => true` so callers can still inspect status codes
///    themselves (non-breaking for existing service code)
///  - Multipart upload helper using Dio's [FormData]
class ApiService {
  final String baseUrl;
  late final Dio _dio;

  ApiService({required this.baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        // Let callers handle status codes — don't throw on non-2xx.
        validateStatus: (_) => true,
        responseType: ResponseType.json,
      ),
    );

    // ── Logging (debug builds only) ──────────────────────────────────────
    if (AppConfig.debugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          // ignore: avoid_print
          logPrint: (obj) => print(obj), // uses dart:developer in release
        ),
      );
    }

    // ── Response caching ─────────────────────────────────────────────────
    _dio.interceptors.add(
      DioCacheInterceptor(options: CacheConfig.defaultOptions),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Build the common headers map, injecting the session cookie when present.
  Map<String, dynamic> _buildHeaders(
    Map<String, String>? extra,
    String? sessionCookie,
  ) {
    final h = <String, dynamic>{...?extra};
    if (sessionCookie != null) {
      h['Cookie'] = 'session=$sessionCookie';
    }
    return h;
  }

  // ── Public API (same signatures as before) ─────────────────────────────

  Future<Response> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    String? sessionCookie,
    CacheOptions? cacheOptions,
  }) async {
    try {
      final options = Options(headers: _buildHeaders(headers, sessionCookie));
      if (cacheOptions != null) {
        options.extra = <String, dynamic>{
          ...?options.extra,
          ...cacheOptions.toExtra(),
        };
      }
      return await _dio.get(
        endpoint,
        queryParameters: queryParams,
        options: options,
      );
    } on DioException catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  Future<Response> post(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    Map<String, dynamic>? queryParams,
    String? sessionCookie,
  }) async {
    try {
      return await _dio.post(
        endpoint,
        data: body,
        queryParameters: queryParams,
        options: Options(
          headers: _buildHeaders(headers, sessionCookie),
          extra: CacheConfig.noCache.toExtra(),
        ),
      );
    } on DioException catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  Future<Response> patch(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    Map<String, dynamic>? queryParams,
    String? sessionCookie,
  }) async {
    try {
      return await _dio.patch(
        endpoint,
        data: body,
        queryParameters: queryParams,
        options: Options(
          headers: _buildHeaders(headers, sessionCookie),
          extra: CacheConfig.noCache.toExtra(),
        ),
      );
    } on DioException catch (e) {
      throw Exception('PATCH request failed: $e');
    }
  }

  Future<Response> delete(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    String? sessionCookie,
  }) async {
    try {
      return await _dio.delete(
        endpoint,
        queryParameters: queryParams,
        options: Options(
          headers: _buildHeaders(headers, sessionCookie),
          extra: CacheConfig.noCache.toExtra(),
        ),
      );
    } on DioException catch (e) {
      throw Exception('DELETE request failed: $e');
    }
  }

  /// Multipart POST (file upload).
  ///
  /// Accepts an optional single file via [fileFieldName] + [filePath],
  /// and/or a map of extra [FormData] [fields].
  Future<Response> postMultipart(
    String endpoint, {
    Map<String, String>? fields,
    String? fileFieldName,
    String? filePath,
    Map<String, String>? headers,
    String? sessionCookie,
  }) async {
    try {
      final formMap = <String, dynamic>{...?fields};

      if (fileFieldName != null && filePath != null) {
        formMap[fileFieldName] = await MultipartFile.fromFile(filePath);
      }

      return await _dio.post(
        endpoint,
        data: FormData.fromMap(formMap),
        options: Options(
          headers: _buildHeaders(headers, sessionCookie),
          extra: CacheConfig.noCache.toExtra(),
        ),
      );
    } on DioException catch (e) {
      throw Exception('Multipart POST request failed: $e');
    }
  }

  /// Multipart PATCH (file upload for updates).
  Future<Response> patchMultipart(
    String endpoint, {
    Map<String, String>? fields,
    String? fileFieldName,
    String? filePath,
    Map<String, String>? headers,
    String? sessionCookie,
  }) async {
    try {
      final formMap = <String, dynamic>{...?fields};

      if (fileFieldName != null && filePath != null) {
        formMap[fileFieldName] = await MultipartFile.fromFile(filePath);
      }

      return await _dio.patch(
        endpoint,
        data: FormData.fromMap(formMap),
        options: Options(
          headers: _buildHeaders(headers, sessionCookie),
          extra: CacheConfig.noCache.toExtra(),
        ),
      );
    } on DioException catch (e) {
      throw Exception('Multipart PATCH request failed: $e');
    }
  }

  /// Expose the underlying [Dio] instance for advanced use cases
  /// (e.g. custom interceptors, download, streaming).
  Dio get dio => _dio;
}
