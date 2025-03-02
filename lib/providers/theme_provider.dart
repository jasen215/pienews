import 'package:flutter/cupertino.dart';
import 'package:pienews/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeMode {
  system,
  light,
  dark;
}

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);
    if (savedTheme != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.name == savedTheme,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode.name);
      notifyListeners();
    }
  }

  String getThemeLabel(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.system:
        return S.of(context).followSystem;
      case ThemeMode.light:
        return S.of(context).light;
      case ThemeMode.dark:
        return S.of(context).dark;
    }
  }
}
