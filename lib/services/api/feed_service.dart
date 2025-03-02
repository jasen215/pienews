import 'package:flutter/foundation.dart';
import 'package:pienews/models/article.dart';
import 'package:pienews/models/feed.dart';
import 'package:pienews/services/api/api_client.dart';
import 'package:pienews/services/feed_service.dart';
import 'package:pienews/services/interfaces/feed_service_interface.dart';

class ApiFeedService implements FeedServiceInterface {
  final ApiClient _apiClient;
  final FeedService _localService;
  final ValueNotifier<String> _syncStatus = ValueNotifier('');
  final ValueNotifier<double> _syncProgress = ValueNotifier(0.0);
  final ValueNotifier<bool> _isSyncing = ValueNotifier(false);

  ApiFeedService({
    required ApiClient apiClient,
    FeedService? localService,
  })  : _apiClient = apiClient,
        _localService = localService ?? FeedService();

  ValueNotifier<bool> get isSyncing => _isSyncing;
  ValueNotifier<double> get syncProgress => _syncProgress;
  ValueNotifier<String> get syncStatus => _syncStatus;

  void updateSyncStatus(bool status) {
    _isSyncing.value = status;
  }

  void updateSyncProgress(double progress) {
    _syncProgress.value = progress;
  }

  @override
  Future<List<Feed>> getFeeds() async {
    try {
      syncStatus.value = 'Getting feeds...';
      final feeds = await _apiClient.getFeeds();
      await _localService.saveFeeds(feeds);
      syncStatus.value = '';
      return feeds;
    } catch (e) {
      return _localService.getFeeds();
    }
  }

  @override
  Future<List<Article>> getArticles(String feedId) async {
    try {
      syncStatus.value = 'Getting articles...';

      final articles = await _apiClient.getArticles(feedId: feedId);
      await _localService.saveArticles(feedId, articles);

      syncStatus.value = '';
      return articles;
    } catch (e) {
      return _localService.getArticles(feedId);
    }
  }

  Future<Map<String, int>> getUnreadCounts() async {
    // Use local service to get unread counts
    return _localService.getUnreadCounts();
  }

  Future<void> updateUnreadCounts(Map<String, int> unreadCounts) async {
    await _localService.updateUnreadCounts(unreadCounts);
  }

  @override
  Future<void> syncFeeds() async {
    try {
      syncStatus.value = 'Syncing feeds...';
      syncProgress.value = 0.0;

      // Get local starred counts
      final localCounts = await _localService.getUnreadAndStarredCounts();

      final feeds = await _apiClient.getFeeds();

      // Keep local starred counts
      final updatedFeeds = feeds.map((feed) {
        final localCount = localCounts[feed.id];
        final starredCount = localCount?['starredCount'] ?? feed.starredCount;
        return feed.copyWith(
          starredCount: starredCount,
        );
      }).toList();

      await _localService.saveFeeds(updatedFeeds);

      syncProgress.value = 1.0;
      syncStatus.value = 'Feed sync completed';
      await Future.delayed(const Duration(seconds: 1));
      syncStatus.value = '';
      syncProgress.value = 0.0;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> syncArticles(String feedId) async {
    try {
      syncStatus.value = 'Syncing articles...';
      syncProgress.value = 0.0;

      // Get local article starred status
      final localArticles = await _localService.getArticles(feedId);
      final Map<String, bool> localStarredStatus = {
        for (var article in localArticles) article.id: article.isStarred
      };

      var page = 1;
      var hasMore = true;
      final List<Article> allArticles = [];

      while (hasMore) {
        final articles = await _apiClient.getArticles(
          feedId: feedId,
          unreadOnly: false,
          limit: 100,
          page: page,
        );

        if (articles.isEmpty) {
          hasMore = false;
          break;
        }

        // Keep local starred status
        final updatedArticles = articles.map((article) {
          final localIsStarred =
              localStarredStatus[article.id] ?? article.isStarred;
          return article.copyWith(isStarred: localIsStarred);
        }).toList();

        allArticles.addAll(updatedArticles);
        syncProgress.value = 0.2 + (0.8 * (allArticles.length / 1000.0));

        if (articles.length < 100) {
          hasMore = false;
        } else {
          page++;
        }
      }

      if (allArticles.isNotEmpty) {
        final starredCount = allArticles.where((a) => a.isStarred).length;
        await _localService.saveArticles(feedId, allArticles);

        // Check saved status
        final afterSync = await _localService.getUnreadAndStarredCounts();
        final afterStarred = afterSync[feedId]?['starredCount'] ?? 0;

        // If starred count is inconsistent, verify again
        if (afterStarred != starredCount) {
          await _localService.verifyFeedCounts();
        }
      }

      syncProgress.value = 1.0;
      syncStatus.value = 'Article sync completed';
      await Future.delayed(const Duration(seconds: 1));
      syncStatus.value = '';
      syncProgress.value = 0.0;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> syncData(String feedId) async {
    await syncFeeds();
    await syncArticles(feedId);
  }

  @override
  Future<void> markArticleAsRead(String articleId) async {
    try {
      await _apiClient.markRead(articleId);
      await _localService.markArticleAsRead(articleId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markArticleAsUnread(String articleId) async {
    try {
      await _apiClient.markUnread(articleId);
      await _localService.markArticleAsUnread(articleId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markAllAsRead(String feedId, List<String> articleIds) async {
    try {
      await _apiClient.markAllRead(feedId: feedId, articleIds: articleIds);
      await _localService.markAllAsRead(feedId, articleIds);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> toggleArticleStarred(String articleId) async {
    try {
      final article = await _localService.getArticle(articleId);
      if (article != null) {
        if (article.isStarred) {
          await _apiClient.unstar(articleId);
        } else {
          await _apiClient.star(articleId);
        }
        await _localService.toggleArticleStarred(articleId);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Article?> getArticle(String articleId) async {
    return await _localService.getArticle(articleId);
  }

  @override
  Future<Feed> addFeed(String feedUrl) async {
    try {
      final feed = await _apiClient.addFeed(feedUrl);
      await _localService.saveFeeds([feed]);
      return feed;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> star(String articleId) async {
    try {
      await _apiClient.star(articleId);
      await _localService.toggleArticleStarred(articleId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unstar(String articleId) async {
    try {
      await _apiClient.unstar(articleId);
      await _localService.toggleArticleStarred(articleId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, Map<String, int>>> getUnreadAndStarredCounts() async {
    return await _localService.getUnreadAndStarredCounts();
  }

  @override
  Future<void> updateUnreadAndStarredCounts(
      Map<String, Map<String, int>> counts) async {
    await _localService.updateUnreadAndStarredCounts(counts);
  }
}
