import 'package:dio/dio.dart';

class ApiService {
  final String baseUrl;
  final Dio _dio;

  ApiService({
    required this.baseUrl,
    String? sessionCookie,
    BaseOptions? options,
  }) : _dio = Dio(options ?? BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(milliseconds: 5000), receiveTimeout: const Duration(milliseconds: 10000))) {
    if (sessionCookie != null) {
      _dio.options.headers['Cookie'] = 'session=$sessionCookie';
    }

    // simple logger (optional)
    _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    // Example auth cookie interceptor (keeps header updated)
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      // if you maintain cookie elsewhere, set here:
      // options.headers['Cookie'] = 'session=$currentCookie';
      handler.next(options);
    }, onError: (e, handler) {
      handler.next(e);
    }, onResponse: (r, handler) {
      handler.next(r);
    }));
  }

  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters, Map<String, String>? headers}) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParameters, options: Options(headers: headers));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(String endpoint, {Object? data, Map<String, dynamic>? queryParameters, Map<String, String>? headers}) async {
    try {
      return await _dio.post(endpoint, data: data, queryParameters: queryParameters, options: Options(headers: headers));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> patch(String endpoint, {Object? data, Map<String, dynamic>? queryParameters, Map<String, String>? headers}) async {
    try {
      return await _dio.patch(endpoint, data: data, queryParameters: queryParameters, options: Options(headers: headers));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(String endpoint, {Map<String, dynamic>? queryParameters, Map<String, String>? headers}) async {
    try {
      return await _dio.delete(endpoint, queryParameters: queryParameters, options: Options(headers: headers));
    } catch (e) {
      rethrow;
    }
  }

  // helper for multipart file upload (useful for images)
  Future<Response> uploadFile(String endpoint, {required String fieldName, required List<int> fileBytes, required String filename, Map<String, dynamic>? data, Map<String, String>? headers, ProgressCallback? onSendProgress}) async {
    try {
      final form = FormData.fromMap({
        ...?data,
        fieldName: MultipartFile.fromBytes(fileBytes, filename: filename),
      });
      return await _dio.post(endpoint, data: form, options: Options(headers: headers), onSendProgress: onSendProgress);
    } catch (e) {
      rethrow;
    }
  }
}
