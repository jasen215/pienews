import 'package:flutter/cupertino.dart';

// Application constants class
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();
}

// Color constants
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  static const Color primaryColor = CupertinoColors.systemBlue;
  static const Color secondaryColor = CupertinoColors.systemYellow;
  static const Color errorColor = CupertinoColors.systemRed;

  // Border color for dark mode
  static const Color darkModeBorderColor = CupertinoColors.systemGrey;
  static const double darkModeBorderOpacity = 0.3;

  // Border color for light mode
  static const Color lightModeBorderColor = CupertinoColors.systemGrey4;
}

// Dimensions constants
class AppDimensions {
  // Private constructor to prevent instantiation
  AppDimensions._();

  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  static const double borderWidth = 0.5;
  static const double borderRadius = 8.0;

  static const double iconSize = 18.0;
}

// Storage keys
class StorageKeys {
  // Private constructor to prevent instantiation
  StorageKeys._();

  static const String themeMode = 'theme_mode';
  static const String fontSize = 'font_size';
  static const String locale = 'locale';
  static const String serviceType = 'service_type';
}

// Time constants
class AppTimes {
  // Private constructor to prevent instantiation
  AppTimes._();

  static const Duration syncInterval = Duration(minutes: 30);
  static const Duration animationDuration = Duration(milliseconds: 300);
}
