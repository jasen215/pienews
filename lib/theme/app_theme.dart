import 'package:flutter/cupertino.dart';

class AppTheme {
  static CupertinoThemeData getThemeData(
    BuildContext context,
    double fontScale, {
    Brightness? brightness,
  }) {
    final isDark = brightness == Brightness.dark;

    return CupertinoThemeData(
      brightness: brightness ?? MediaQuery.platformBrightnessOf(context),
      primaryColor: CupertinoColors.systemBlue,
      scaffoldBackgroundColor:
          isDark ? CupertinoColors.black : CupertinoColors.systemBackground,
      barBackgroundColor:
          isDark ? CupertinoColors.black : CupertinoColors.systemBackground,
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          fontSize: 14 * fontScale,
          color: isDark ? CupertinoColors.white : CupertinoColors.black,
          inherit: false,
        ),
        navTitleTextStyle: TextStyle(
          fontSize: 17 * fontScale,
          fontWeight: FontWeight.bold,
          color: isDark ? CupertinoColors.white : CupertinoColors.black,
          inherit: false,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontSize: 24 * fontScale,
          fontWeight: FontWeight.bold,
          color: isDark ? CupertinoColors.white : CupertinoColors.black,
          inherit: false,
        ),
      ),
    );
  }
}
