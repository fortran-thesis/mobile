import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _langKey = 'farmer_language';

  Locale _selectedLocale;
  bool _isFarmer = false;
  bool _roleSet = false; // Tracks whether user has logged in

  final SharedPreferences _prefs;

  LanguageProvider(this._prefs)
      : _selectedLocale = Locale(
          _prefs.getString(_langKey) ?? 'en',
        );

  /// The locale that is actually applied to the app.
  /// Before login (_roleSet == false): returns the user's selected locale (farmers can pick Filipino early)
  /// After login (_roleSet == true):
  ///   - If farmer: returns the user's selected locale
  ///   - If mycologist: always returns English regardless of preference
  Locale get effectiveLocale {
    if (!_roleSet) {
      // Pre-auth: honor the selected locale (user can pick Filipino on welcome/intro screens)
      return _selectedLocale;
    }
    // Post-auth: only farmers can use non-English locales
    return _isFarmer ? _selectedLocale : const Locale('en');
  }

  Locale get selectedLocale => _selectedLocale;

  bool get isFarmer => _isFarmer;

  /// Called after the user profile loads so that the provider knows whether
  /// the current session belongs to a farmer.
  void setRole({required bool isFarmer}) {
    if (_roleSet && _isFarmer == isFarmer) return;
    _isFarmer = isFarmer;
    _roleSet = true;
    notifyListeners();
  }

  /// Called on logout to reset the provider state so locale switching works again pre-auth.
  void resetRole() {
    _isFarmer = false;
    _roleSet = false;
    notifyListeners();
  }

  /// Persists and applies the new locale.
  Future<void> setLocale(Locale locale) async {
    if (_selectedLocale == locale) return;
    _selectedLocale = locale;
    await _prefs.setString(_langKey, locale.languageCode);
    notifyListeners();
  }
}
