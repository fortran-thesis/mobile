import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:moldify/core/config/cache_config.dart';
import 'package:moldify/core/utils/cache_invalidation.dart';
import 'package:moldify/core/utils/logger.dart';
import 'package:moldify/core/services/fcm_service.dart';
import 'package:moldify/services/api_service.dart';

class AppAuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _cookie;
  bool _hasSeenIntro = false;
  StreamSubscription<int>? _authErrorSubscription;
  bool _isHydrated = false;

  String? get cookie => _cookie;
  bool get hasSeenIntro => _hasSeenIntro;
  bool get isHydrated => _isHydrated;

  Future<void> saveCookie(String? cookie) async {
    if (cookie != null) {
      await _storage.write(key: 'auth_cookie', value: cookie);
      _cookie = cookie;
      unawaited(FCMService.instance.updateSessionCookie(cookie));
      notifyListeners();
    }
  }

  Future<void> loadCookie() async {
    if (_isHydrated) return;

    final stopwatch = Stopwatch()..start();
    try {
      _cookie = await _storage.read(key: 'auth_cookie');
      _hasSeenIntro = await _storage.read(key: 'has_seen_intro') == 'true';

      // Listen to auth errors from API service.
      _authErrorSubscription ??= ApiService.authErrorStream.listen((
        statusCode,
      ) {
        AppLogger.w(
          'AppAuthProvider: Auth error detected - Status: $statusCode',
        );
        // Automatically logout and clear cookie on 401/403.
        logout();
      });

      unawaited(FCMService.instance.updateSessionCookie(_cookie));
    } finally {
      _isHydrated = true;
      stopwatch.stop();
      AppLogger.d(
        'AppAuthProvider hydrated in ${stopwatch.elapsedMilliseconds}ms',
        tag: 'Startup',
      );
      notifyListeners();
    }
  }

  Future<void> markIntroAsSeen() async {
    await _storage.write(key: 'has_seen_intro', value: 'true');
    _hasSeenIntro = true;
    notifyListeners();
  }

  Future<void> clearCookie() async {
    await _storage.delete(key: 'auth_cookie');
    _cookie = null;
    unawaited(FCMService.instance.updateSessionCookie(null));
    notifyListeners();
  }

  Future<void> logout() async {
    AppLogger.d('AppAuthProvider: Logging out user');
    CacheInvalidationHub.instance.emit(
      CacheInvalidationEvent(
        entity: InvalidationEntity.authSession,
        operation: InvalidationOperation.delete,
        occurredAt: DateTime.now().toUtc(),
      ),
    );
    await CacheConfig.clearAll();
    await clearCookie();
  }

  @override
  void dispose() {
    _authErrorSubscription?.cancel();
    ApiService.dispose();
    super.dispose();
  }
}
