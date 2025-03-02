import 'package:flutter/foundation.dart';
import 'package:pienews/services/api/feed_service.dart';

class SyncService {
  final ApiFeedService _feedService;
  final ValueNotifier<String> syncStatus;
  final ValueNotifier<double> syncProgress;

  SyncService({
    required ApiFeedService feedService,
  })  : _feedService = feedService,
        syncStatus = feedService.syncStatus,
        syncProgress = feedService.syncProgress;

  Future<void> syncFeed(String feedId) async {
    try {
      await _feedService.syncData(feedId);
    } catch (e) {
      debugPrint('sync error: $e');
      rethrow;
    }
  }

  Future<void> syncAll() async {
    try {
      await _feedService.syncFeeds();
    } catch (e) {
      debugPrint('sync error: $e');
      rethrow;
    }
  }
}
