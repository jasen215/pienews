import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _showUncategorizedKey = 'show_uncategorized';
  late SharedPreferences _prefs;
  bool _showUncategorized = true; // Default to show uncategorized

  SettingsProvider() {
    _loadSettings();
  }

  bool get showUncategorized => _showUncategorized;

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _showUncategorized = _prefs.getBool(_showUncategorizedKey) ?? true;
    notifyListeners();
  }

  Future<void> setShowUncategorized(bool value) async {
    if (_showUncategorized != value) {
      _showUncategorized = value;
      await _prefs.setBool(_showUncategorizedKey, value);
      notifyListeners();
    }
  }
}
