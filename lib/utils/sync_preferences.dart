import 'package:shared_preferences/shared_preferences.dart';

class SyncPreferences {
  static const String _lastSyncTimeKey = 'last_sync_time';

  static Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(_lastSyncTimeKey);
    return millis != null ? DateTime.fromMillisecondsSinceEpoch(millis) : null;
  }

  static Future<void> setLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncTimeKey, time.millisecondsSinceEpoch);
  }
}
