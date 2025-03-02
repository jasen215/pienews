import 'package:flutter/cupertino.dart';

extension TextStyleExtension on TextStyle {
  TextStyle withFontScale(double scale) {
    return copyWith(fontSize: fontSize! * scale);
  }
}
