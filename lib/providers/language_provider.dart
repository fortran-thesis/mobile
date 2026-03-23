import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _langKey = 'farmer_language';

  Locale _selectedLocale;
  bool _isFarmer = false;

  final SharedPreferences _prefs;

  LanguageProvider(this._prefs)
      : _selectedLocale = Locale(
          _prefs.getString(_langKey) ?? 'en',
        );

  /// The locale that is actually applied to the app.
  /// Returns the farmer's chosen locale only when the logged-in user is a
  /// farmer; mycologists/experts always fall back to English regardless of any
  /// stored preference.
  Locale get effectiveLocale => _isFarmer ? _selectedLocale : const Locale('en');

  Locale get selectedLocale => _selectedLocale;

  bool get isFarmer => _isFarmer;

  /// Called after the user profile loads so that the provider knows whether
  /// the current session belongs to a farmer.
  void setRole({required bool isFarmer}) {
    if (_isFarmer == isFarmer) return;
    _isFarmer = isFarmer;
    notifyListeners();
  }

  /// Persists and applies the new locale. Only meaningful when the user is a
  /// farmer — experts see English regardless.
  Future<void> setLocale(Locale locale) async {
    if (_selectedLocale == locale) return;
    _selectedLocale = locale;
    await _prefs.setString(_langKey, locale.languageCode);
    notifyListeners();
  }
}
