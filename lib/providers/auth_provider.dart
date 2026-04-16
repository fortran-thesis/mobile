import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:moldify/core/config/cache_config.dart';
import 'package:moldify/core/utils/cache_invalidation.dart';
import 'package:moldify/core/utils/logger.dart';
import 'package:moldify/services/api_service.dart';

class AppAuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _cookie;
  bool _hasSeenIntro = false;
  late StreamSubscription<int> _authErrorSubscription;

  String? get cookie => _cookie;
  bool get hasSeenIntro => _hasSeenIntro;

  Future<void> saveCookie(String? cookie) async {
    if (cookie != null) {
      await _storage.write(key: 'auth_cookie', value: cookie);
      _cookie = cookie;
      notifyListeners();
    }
  }

  Future<void> loadCookie() async {
    _cookie = await _storage.read(key: 'auth_cookie');
    _hasSeenIntro = await _storage.read(key: 'has_seen_intro') == 'true';
    
    // Listen to auth errors from API service
    _authErrorSubscription = ApiService.authErrorStream.listen((statusCode) {
      AppLogger.w('AppAuthProvider: Auth error detected - Status: $statusCode');
      // Automatically logout and clear cookie on 401/403
      logout();
    });
    
    notifyListeners();
  }

  Future<void> markIntroAsSeen() async {
    await _storage.write(key: 'has_seen_intro', value: 'true');
    _hasSeenIntro = true;
    notifyListeners();
  }

  Future<void> clearCookie() async {
    await _storage.delete(key: 'auth_cookie');
    _cookie = null;
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
    _authErrorSubscription.cancel();
    ApiService.dispose();
    super.dispose();
  }
}