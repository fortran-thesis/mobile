import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:moldify/core/config/cache_config.dart';

class AppAuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _cookie;
  bool _hasSeenIntro = false;

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
    await CacheConfig.clearAll();
    await clearCookie();
  }
}