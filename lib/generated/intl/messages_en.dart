// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(days) => "${days} days ago";

  static String m1(hours) => "${hours} hours ago";

  static String m2(minutes) => "${minutes} minutes ago";

  static String m3(title) => "Syncing ${title}...";

  static String m4(year, month, day) => "${year}-${month}-${day}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("About"),
        "account": MessageLookupByLibrary.simpleMessage("Account"),
        "accountInfo": MessageLookupByLibrary.simpleMessage("Account Info"),
        "accountSettings":
            MessageLookupByLibrary.simpleMessage("Account Settings"),
        "add": MessageLookupByLibrary.simpleMessage("Add"),
        "addFailed": MessageLookupByLibrary.simpleMessage("Add Failed"),
        "addFeed": MessageLookupByLibrary.simpleMessage("Add Feed"),
        "addSuccess": MessageLookupByLibrary.simpleMessage("Add Success"),
        "addingFeed": MessageLookupByLibrary.simpleMessage("Adding Feed"),
        "allFilter": MessageLookupByLibrary.simpleMessage("All"),
        "autoSyncFrequency": MessageLookupByLibrary.simpleMessage(
          "Auto SyncFrequency",
        ),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "clearCache": MessageLookupByLibrary.simpleMessage("Clear Cache"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "confirmLogout": MessageLookupByLibrary.simpleMessage("Confirm Logout"),
        "currentService":
            MessageLookupByLibrary.simpleMessage("Current Service"),
        "dark": MessageLookupByLibrary.simpleMessage("Dark"),
        "dataManagement":
            MessageLookupByLibrary.simpleMessage("Data Management"),
        "daysAgo": m0,
        "displaySettings":
            MessageLookupByLibrary.simpleMessage("Display Settings"),
        "email": MessageLookupByLibrary.simpleMessage("Email"),
        "english": MessageLookupByLibrary.simpleMessage("English"),
        "enterFeedUrl": MessageLookupByLibrary.simpleMessage("Enter Feed URL"),
        "error": MessageLookupByLibrary.simpleMessage("Error"),
        "everyHour": MessageLookupByLibrary.simpleMessage("Every Hour"),
        "exportData": MessageLookupByLibrary.simpleMessage("Export Data"),
        "feedAdded": MessageLookupByLibrary.simpleMessage("Feed Added"),
        "feedUrl": MessageLookupByLibrary.simpleMessage("Feed URL"),
        "feeds": MessageLookupByLibrary.simpleMessage("Feeds"),
        "followSystem": MessageLookupByLibrary.simpleMessage("Follow System"),
        "fontSize": MessageLookupByLibrary.simpleMessage("Font Size"),
        "hourly": MessageLookupByLibrary.simpleMessage("Hourly"),
        "hoursAgo": m1,
        "importData": MessageLookupByLibrary.simpleMessage("Import Data"),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "large": MessageLookupByLibrary.simpleMessage("Large"),
        "light": MessageLookupByLibrary.simpleMessage("Light"),
        "loadingImageError": MessageLookupByLibrary.simpleMessage(
          "Failed to load image",
        ),
        "login": MessageLookupByLibrary.simpleMessage("Login"),
        "logout": MessageLookupByLibrary.simpleMessage("Logout"),
        "medium": MessageLookupByLibrary.simpleMessage("Medium"),
        "minutesAgo": m2,
        "noArticles": MessageLookupByLibrary.simpleMessage("No articles"),
        "noContent":
            MessageLookupByLibrary.simpleMessage("No content available"),
        "noFeedsAvailable": MessageLookupByLibrary.simpleMessage(
          "No Feeds Available",
        ),
        "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "password": MessageLookupByLibrary.simpleMessage("Password"),
        "passwordMustBeAtLeast6Characters":
            MessageLookupByLibrary.simpleMessage(
          "Password must be at least 6 characters",
        ),
        "pleaseEnterAValidEmailAddress": MessageLookupByLibrary.simpleMessage(
          "Please enter a valid email address",
        ),
        "pleaseEnterYourEmail": MessageLookupByLibrary.simpleMessage(
          "Please enter your email",
        ),
        "pleaseEnterYourPassword": MessageLookupByLibrary.simpleMessage(
          "Please enter your password",
        ),
        "pushNotifications": MessageLookupByLibrary.simpleMessage(
          "Push Notifications",
        ),
        "readingPreferences": MessageLookupByLibrary.simpleMessage(
          "Reading Preferences",
        ),
        "retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "selectFeedService": MessageLookupByLibrary.simpleMessage(
          "Select Feed Service",
        ),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "showUncategorized": MessageLookupByLibrary.simpleMessage(
          "Show Uncategorized",
        ),
        "simplifiedChinese": MessageLookupByLibrary.simpleMessage(
          "Simplified Chinese",
        ),
        "small": MessageLookupByLibrary.simpleMessage("Small"),
        "starredFilter": MessageLookupByLibrary.simpleMessage("Starred"),
        "sync": MessageLookupByLibrary.simpleMessage("Sync"),
        "syncCompleted": MessageLookupByLibrary.simpleMessage("Sync completed"),
        "syncFailed": MessageLookupByLibrary.simpleMessage("Sync failed"),
        "syncFrequency": MessageLookupByLibrary.simpleMessage("Sync Frequency"),
        "syncOnlyOnWifi":
            MessageLookupByLibrary.simpleMessage("Sync Only On Wifi"),
        "syncingFeed": m3,
        "syncingFeeds":
            MessageLookupByLibrary.simpleMessage("Syncing feeds..."),
        "theme": MessageLookupByLibrary.simpleMessage("Theme"),
        "themeMode": MessageLookupByLibrary.simpleMessage("Theme Mode"),
        "themeSettings": MessageLookupByLibrary.simpleMessage("Theme Settings"),
        "uncategorized": MessageLookupByLibrary.simpleMessage("Uncategorized"),
        "unreadFilter": MessageLookupByLibrary.simpleMessage("Unread"),
        "username": MessageLookupByLibrary.simpleMessage("Username"),
        "version": MessageLookupByLibrary.simpleMessage("Version"),
        "welcomeBack": MessageLookupByLibrary.simpleMessage("Welcome Back"),
        "wifiOnly": MessageLookupByLibrary.simpleMessage("WiFi Only"),
        "yearMonthDay": m4,
      };
}
