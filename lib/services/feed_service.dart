import 'package:pienews/models/article.dart';
import 'package:pienews/models/feed.dart';
import 'package:pienews/services/database/database_helper.dart';
import 'package:pienews/services/interfaces/feed_service_interface.dart';

class FeedService implements FeedServiceInterface {
  final DatabaseHelper _db;

  FeedService({DatabaseHelper? db}) : _db = db ?? DatabaseHelper.instance;

  @override
  Future<List<Feed>> getFeeds() async {
    return await _db.getFeeds();
  }

  @override
  Future<List<Article>> getArticles(String feedId) async {
    return await _db.getArticles(feedId);
  }

  @override
  Future<Article?> getArticle(String articleId) async {
    return await _db.getArticle(articleId);
  }

  Future<Map<String, int>> getUnreadCounts() async {
    try {
      final feeds = await _db.getFeeds();
      final Map<String, int> unreadCounts = {};

      for (final feed in feeds) {
        final count = await _db.getUnreadCount(feed.id);
        unreadCounts[feed.id] = count;
      }

      return unreadCounts;
    } catch (e) {
      return {};
    }
  }

  Future<void> updateUnreadCounts(Map<String, int> unreadCounts) async {
    try {
      for (final entry in unreadCounts.entries) {
        final String id = entry.key;
        final int count = entry.value;
        await _db.updateUnreadCount(id, count);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> syncFeeds() async {
    // Base service does not implement sync operations
    throw UnimplementedError('Base service does not support sync operations');
  }

  @override
  Future<void> syncArticles(String feedId) async {
    // Base service does not implement sync operations
    throw UnimplementedError('Base service does not support sync operations');
  }

  @override
  Future<void> syncData(String feedId) async {
    // Base service does not implement sync operations
    throw UnimplementedError('Base service does not support sync operations');
  }

  @override
  Future<void> markArticleAsRead(String articleId) async {
    await _db.markArticleAsRead(articleId);
  }

  @override
  Future<void> markArticleAsUnread(String articleId) async {
    await _db.markArticleAsUnread(articleId);
  }

  @override
  Future<void> markAllAsRead(String feedId, List<String> articleIds) async {
    await _db.markArticlesAsRead(feedId, articleIds);
  }

  @override
  Future<void> toggleArticleStarred(String articleId) async {
    await _db.toggleArticleStarred(articleId);
  }

  Future<Feed> addSubscription(String feedUrl) async {
    // Base service does not implement subscription operations
    throw UnimplementedError(
        'Base service does not support subscription operations');
  }

  @override
  Future<Feed> addFeed(String feedUrl) async {
    throw UnimplementedError(
        'Local service does not support adding feed sources');
  }

  // Internal helper methods
  Future<void> saveFeeds(List<Feed> feeds) async {
    await _db.insertFeeds(feeds);
  }

  Future<void> saveArticles(String feedId, List<Article> articles) async {
    await _db.insertArticles(feedId, articles);
  }

  @override
  Future<Map<String, Map<String, int>>> getUnreadAndStarredCounts() async {
    return await _db.getUnreadAndStarredCounts();
  }

  @override
  Future<void> updateUnreadAndStarredCounts(
      Map<String, Map<String, int>> counts) async {
    await _db.updateUnreadAndStarredCounts(counts);
  }

  Future<void> verifyFeedCounts() async {
    await _db.verifyFeedCounts();
  }

  Future<void> updateFeed(Article article) async {
    await _db.updateArticle(article);
  }
}
