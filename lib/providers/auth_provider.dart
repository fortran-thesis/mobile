import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppAuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _cookie;

  String? get cookie => _cookie;

  Future<void> saveCookie(String? cookie) async {
    if (cookie != null) {
      await _storage.write(key: 'auth_cookie', value: cookie);
      _cookie = cookie;
      notifyListeners();
    }
  }

  Future<void> loadCookie() async {
    _cookie = await _storage.read(key: 'auth_cookie');
    notifyListeners();
  }

  Future<void> clearCookie() async {
    await _storage.delete(key: 'auth_cookie');
    _cookie = null;
    notifyListeners();
  }

  Future<void> logout() async {
    await clearCookie();
    // Optionally, clear other user data here
  }
}

