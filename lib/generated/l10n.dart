// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Account Settings`
  String get accountSettings {
    return Intl.message(
      'Account Settings',
      name: 'accountSettings',
      desc: '',
      args: [],
    );
  }

  /// `Current Service`
  String get currentService {
    return Intl.message(
      'Current Service',
      name: 'currentService',
      desc: '',
      args: [],
    );
  }

  /// `Select Feed Service`
  String get selectFeedService {
    return Intl.message(
      'Select Feed Service',
      name: 'selectFeedService',
      desc: '',
      args: [],
    );
  }

  /// `No content available`
  String get noContent {
    return Intl.message(
      'No content available',
      name: 'noContent',
      desc: '',
      args: [],
    );
  }

  /// `Reading Preferences`
  String get readingPreferences {
    return Intl.message(
      'Reading Preferences',
      name: 'readingPreferences',
      desc: '',
      args: [],
    );
  }

  /// `Font Size`
  String get fontSize {
    return Intl.message('Font Size', name: 'fontSize', desc: '', args: []);
  }

  /// `Theme`
  String get theme {
    return Intl.message('Theme', name: 'theme', desc: '', args: []);
  }

  /// `Sync`
  String get sync {
    return Intl.message('Sync', name: 'sync', desc: '', args: []);
  }

  /// `Sync Frequency`
  String get syncFrequency {
    return Intl.message(
      'Sync Frequency',
      name: 'syncFrequency',
      desc: '',
      args: [],
    );
  }

  /// `WiFi Only`
  String get wifiOnly {
    return Intl.message('WiFi Only', name: 'wifiOnly', desc: '', args: []);
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Push Notifications`
  String get pushNotifications {
    return Intl.message(
      'Push Notifications',
      name: 'pushNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Data Management`
  String get dataManagement {
    return Intl.message(
      'Data Management',
      name: 'dataManagement',
      desc: '',
      args: [],
    );
  }

  /// `Clear Cache`
  String get clearCache {
    return Intl.message('Clear Cache', name: 'clearCache', desc: '', args: []);
  }

  /// `Export Data`
  String get exportData {
    return Intl.message('Export Data', name: 'exportData', desc: '', args: []);
  }

  /// `Import Data`
  String get importData {
    return Intl.message('Import Data', name: 'importData', desc: '', args: []);
  }

  /// `About`
  String get about {
    return Intl.message('About', name: 'about', desc: '', args: []);
  }

  /// `Version`
  String get version {
    return Intl.message('Version', name: 'version', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Follow System`
  String get followSystem {
    return Intl.message(
      'Follow System',
      name: 'followSystem',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `Simplified Chinese`
  String get simplifiedChinese {
    return Intl.message(
      'Simplified Chinese',
      name: 'simplifiedChinese',
      desc: '',
      args: [],
    );
  }

  /// `Hourly`
  String get hourly {
    return Intl.message('Hourly', name: 'hourly', desc: '', args: []);
  }

  /// `No articles`
  String get noArticles {
    return Intl.message('No articles', name: 'noArticles', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Auto SyncFrequency`
  String get autoSyncFrequency {
    return Intl.message(
      'Auto SyncFrequency',
      name: 'autoSyncFrequency',
      desc: '',
      args: [],
    );
  }

  /// `Sync Only On Wifi`
  String get syncOnlyOnWifi {
    return Intl.message(
      'Sync Only On Wifi',
      name: 'syncOnlyOnWifi',
      desc: '',
      args: [],
    );
  }

  /// `Every Hour`
  String get everyHour {
    return Intl.message('Every Hour', name: 'everyHour', desc: '', args: []);
  }

  /// `Account`
  String get account {
    return Intl.message('Account', name: 'account', desc: '', args: []);
  }

  /// `Theme Settings`
  String get themeSettings {
    return Intl.message(
      'Theme Settings',
      name: 'themeSettings',
      desc: '',
      args: [],
    );
  }

  /// `Theme Mode`
  String get themeMode {
    return Intl.message('Theme Mode', name: 'themeMode', desc: '', args: []);
  }

  /// `Light`
  String get light {
    return Intl.message('Light', name: 'light', desc: '', args: []);
  }

  /// `Dark`
  String get dark {
    return Intl.message('Dark', name: 'dark', desc: '', args: []);
  }

  /// `Small`
  String get small {
    return Intl.message('Small', name: 'small', desc: '', args: []);
  }

  /// `Medium`
  String get medium {
    return Intl.message('Medium', name: 'medium', desc: '', args: []);
  }

  /// `Large`
  String get large {
    return Intl.message('Large', name: 'large', desc: '', args: []);
  }

  /// `Account Info`
  String get accountInfo {
    return Intl.message(
      'Account Info',
      name: 'accountInfo',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `Confirm Logout`
  String get confirmLogout {
    return Intl.message(
      'Confirm Logout',
      name: 'confirmLogout',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Username`
  String get username {
    return Intl.message('Username', name: 'username', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Adding Feed`
  String get addingFeed {
    return Intl.message('Adding Feed', name: 'addingFeed', desc: '', args: []);
  }

  /// `Feed Added`
  String get feedAdded {
    return Intl.message('Feed Added', name: 'feedAdded', desc: '', args: []);
  }

  /// `Add Failed`
  String get addFailed {
    return Intl.message('Add Failed', name: 'addFailed', desc: '', args: []);
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `No Feeds Available`
  String get noFeedsAvailable {
    return Intl.message(
      'No Feeds Available',
      name: 'noFeedsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Enter Feed URL`
  String get enterFeedUrl {
    return Intl.message(
      'Enter Feed URL',
      name: 'enterFeedUrl',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message('OK', name: 'ok', desc: '', args: []);
  }

  /// `Add Success`
  String get addSuccess {
    return Intl.message('Add Success', name: 'addSuccess', desc: '', args: []);
  }

  /// `Error`
  String get error {
    return Intl.message('Error', name: 'error', desc: '', args: []);
  }

  /// `Feeds`
  String get feeds {
    return Intl.message('Feeds', name: 'feeds', desc: '', args: []);
  }

  /// `Add`
  String get add {
    return Intl.message('Add', name: 'add', desc: '', args: []);
  }

  /// `Add Feed`
  String get addFeed {
    return Intl.message('Add Feed', name: 'addFeed', desc: '', args: []);
  }

  /// `Feed URL`
  String get feedUrl {
    return Intl.message('Feed URL', name: 'feedUrl', desc: '', args: []);
  }

  /// `Please enter your email`
  String get pleaseEnterYourEmail {
    return Intl.message(
      'Please enter your email',
      name: 'pleaseEnterYourEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email address`
  String get pleaseEnterAValidEmailAddress {
    return Intl.message(
      'Please enter a valid email address',
      name: 'pleaseEnterAValidEmailAddress',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your password`
  String get pleaseEnterYourPassword {
    return Intl.message(
      'Please enter your password',
      name: 'pleaseEnterYourPassword',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters`
  String get passwordMustBeAtLeast6Characters {
    return Intl.message(
      'Password must be at least 6 characters',
      name: 'passwordMustBeAtLeast6Characters',
      desc: '',
      args: [],
    );
  }

  /// `Welcome Back`
  String get welcomeBack {
    return Intl.message(
      'Welcome Back',
      name: 'welcomeBack',
      desc: '',
      args: [],
    );
  }

  /// `Sync completed`
  String get syncCompleted {
    return Intl.message(
      'Sync completed',
      name: 'syncCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Sync failed`
  String get syncFailed {
    return Intl.message('Sync failed', name: 'syncFailed', desc: '', args: []);
  }

  /// `Syncing feeds...`
  String get syncingFeeds {
    return Intl.message(
      'Syncing feeds...',
      name: 'syncingFeeds',
      desc: '',
      args: [],
    );
  }

  /// `Syncing {title}...`
  String syncingFeed(Object title) {
    return Intl.message(
      'Syncing $title...',
      name: 'syncingFeed',
      desc: '',
      args: [title],
    );
  }

  /// `Display Settings`
  String get displaySettings {
    return Intl.message(
      'Display Settings',
      name: 'displaySettings',
      desc: '',
      args: [],
    );
  }

  /// `Show Uncategorized`
  String get showUncategorized {
    return Intl.message(
      'Show Uncategorized',
      name: 'showUncategorized',
      desc: '',
      args: [],
    );
  }

  /// `Uncategorized`
  String get uncategorized {
    return Intl.message(
      'Uncategorized',
      name: 'uncategorized',
      desc: '',
      args: [],
    );
  }

  /// `Starred`
  String get starredFilter {
    return Intl.message('Starred', name: 'starredFilter', desc: '', args: []);
  }

  /// `Unread`
  String get unreadFilter {
    return Intl.message('Unread', name: 'unreadFilter', desc: '', args: []);
  }

  /// `All`
  String get allFilter {
    return Intl.message('All', name: 'allFilter', desc: '', args: []);
  }

  /// `Failed to load image`
  String get loadingImageError {
    return Intl.message(
      'Failed to load image',
      name: 'loadingImageError',
      desc: '',
      args: [],
    );
  }

  /// `{minutes} minutes ago`
  String minutesAgo(Object minutes) {
    return Intl.message(
      '$minutes minutes ago',
      name: 'minutesAgo',
      desc: '',
      args: [minutes],
    );
  }

  /// `{hours} hours ago`
  String hoursAgo(Object hours) {
    return Intl.message(
      '$hours hours ago',
      name: 'hoursAgo',
      desc: '',
      args: [hours],
    );
  }

  /// `{days} days ago`
  String daysAgo(Object days) {
    return Intl.message(
      '$days days ago',
      name: 'daysAgo',
      desc: '',
      args: [days],
    );
  }

  /// `{year}-{month}-{day}`
  String yearMonthDay(Object year, Object month, Object day) {
    return Intl.message(
      '$year-$month-$day',
      name: 'yearMonthDay',
      desc: '',
      args: [year, month, day],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
