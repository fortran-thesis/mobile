import 'dart:convert';

import 'package:dio/dio.dart';

class DioUtils {
  static Map<String, dynamic> normalizeResponseData(Response response) {
    final dynamic respData = response.data;
    if (respData == null) return <String, dynamic>{};
    if (respData is String) {
      try {
        final decoded = json.decode(respData);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
        return <String, dynamic>{};
      } catch (_) {
        return <String, dynamic>{};
      }
    }
    if (respData is Map) {
      return Map<String, dynamic>.from(respData);
    }
    return <String, dynamic>{};
  }
}