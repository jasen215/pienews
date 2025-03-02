import 'package:flutter/widgets.dart';
import 'package:pienews/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontProvider with ChangeNotifier {
  static const String _fontSizeKey = 'font_size';
  static const double _defaultFontSize = 1.0;
  static const double _minFontSize = 0.8;
  static const double _maxFontSize = 1.4;

  late SharedPreferences _prefs;
  double _fontScale = _defaultFontSize;

  FontProvider() {
    _loadFontSize();
  }

  double get fontScale => _fontScale;
  double get minFontSize => _minFontSize;
  double get maxFontSize => _maxFontSize;

  Future<void> _loadFontSize() async {
    _prefs = await SharedPreferences.getInstance();
    _fontScale = _prefs.getDouble(_fontSizeKey) ?? _defaultFontSize;
    notifyListeners();
  }

  Future<void> setFontSize(double scale) async {
    if (scale != _fontScale) {
      _fontScale = scale;
      await _prefs.setDouble(_fontSizeKey, scale);
      notifyListeners();
    }
  }

  String getFontSizeLabel(BuildContext context) {
    if (_fontScale <= 0.9) return S.of(context).small;
    if (_fontScale <= 1.1) return S.of(context).medium;
    return S.of(context).large;
  }
}
