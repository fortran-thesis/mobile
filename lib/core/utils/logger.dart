import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Lightweight logger that only emits output in **debug** builds.
///
/// Uses [dart:developer.log] which is stripped in release mode by the Dart
/// compiler, and additionally gates behind [kDebugMode] so that even in
/// profile builds no work is done.
///
/// Usage:
/// ```dart
/// import 'package:moldify/core/utils/logger.dart';
/// AppLogger.d('some value: $x');            // general debug
/// AppLogger.w('unexpected state');           // warning
/// AppLogger.e('failed to load', error: e);  // error with optional object
/// ```
class AppLogger {
  AppLogger._();

  /// Debug-level log.
  static void d(String message, {String tag = 'Moldify'}) {
    if (kDebugMode) {
      developer.log(message, name: tag);
    }
  }

  /// Warning-level log.
  static void w(String message, {String tag = 'Moldify'}) {
    if (kDebugMode) {
      developer.log('⚠️ $message', name: tag);
    }
  }

  /// Error-level log, with optional [error] and [stackTrace].
  static void e(
    String message, {
    String tag = 'Moldify',
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      developer.log(
        '❌ $message',
        name: tag,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
