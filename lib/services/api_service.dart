import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:moldify/core/config/app_config.dart';
import 'package:moldify/core/config/cache_config.dart';
import 'package:moldify/core/utils/logger.dart';

/// Centralised HTTP client built on [Dio].
///
/// Features added over the old `http`-based wrapper:
///  - Session-cookie injection via interceptor (no per-call boilerplate)
///  - Debug-only request/response logging (replaces scattered `print()` calls)
///  - Global connect / receive timeouts
///  - `validateStatus: (_) => true` so callers can still inspect status codes
///    themselves (non-breaking for existing service code)
///  - Multipart upload helper using Dio's [FormData]
///  - Auth error detection (401/403) via response interceptor
class ApiService {
  final String baseUrl;
  late final Dio _dio;

  // Stream controller for auth errors
  static final StreamController<int> _authErrorController = StreamController<int>.broadcast();
  static Stream<int> get authErrorStream => _authErrorController.stream;

  // Callback for auth errors
  static Function(int statusCode)? _onAuthError;
  static set onAuthError(Function(int statusCode) callback) => _onAuthError = callback;

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

    // ── Auth error interceptor ───────────────────────────────────────────
    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          // Only treat 401 (Unauthorized) as an auth error that requires logout.
          // 403 (Forbidden) means the session is valid but the user lacks the role/
          // permission for that specific resource — it must NOT clear the session.
          if (response.statusCode == 401) {
            AppLogger.e('ApiService: Auth error detected - Status: ${response.statusCode}');
            // Emit the auth error
            _authErrorController.add(response.statusCode ?? 0);
            // Call the callback if set
            _onAuthError?.call(response.statusCode ?? 0);
          }
          return handler.next(response);
        },
      ),
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

  /// Dispose resources (call when app is shutting down)
  static void dispose() {
    _authErrorController.close();
  }
}
