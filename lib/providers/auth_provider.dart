import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppAuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _cookie;
  bool _isLoading = true;  // ADD THIS

  String? get cookie => _cookie;
  bool get isLoading => _isLoading;  // ADD THIS

  Future<void> saveCookie(String? cookie) async {
    if (cookie != null) {
      await _storage.write(key: 'auth_cookie', value: cookie);
      _cookie = cookie;
      notifyListeners();
    }
  }

  Future<void> loadCookie() async {
    _isLoading = true;  // ADD THIS
    _cookie = await _storage.read(key: 'auth_cookie');
    _isLoading = false;  // ADD THIS
    notifyListeners();
  }

  Future<void> clearCookie() async {
    await _storage.delete(key: 'auth_cookie');
    _cookie = null;
    notifyListeners();
  }

  Future<void> logout() async {
    await clearCookie();
  }
}