import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  static const String _localeKey = 'locale';
  static const String systemLocale = 'system';
  late SharedPreferences _prefs;
  Locale? _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Locale? get locale => _locale;

  Future<void> _loadLocale() async {
    _prefs = await SharedPreferences.getInstance();
    final String? localeString = _prefs.getString(_localeKey);
    if (localeString != null && localeString != systemLocale) {
      _locale = _createLocale(localeString);
    }
    notifyListeners();
  }

  Future<void> setLocale(String? localeString) async {
    if (localeString == systemLocale) {
      _locale = null;
    } else {
      _locale = _createLocale(localeString!);
    }
    await _prefs.setString(_localeKey, localeString ?? systemLocale);
    notifyListeners();
  }

  Locale _createLocale(String localeString) {
    final parts = localeString.split('_');
    return parts.length > 1 ? Locale(parts[0], parts[1]) : Locale(parts[0]);
  }

  String get currentLocale {
    if (_locale == null) return systemLocale;
    if (_locale!.countryCode != null) {
      return '${_locale!.languageCode}_${_locale!.countryCode}';
    }
    return _locale!.languageCode;
  }
}
