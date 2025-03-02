import 'package:pienews/models/article.dart';
import 'package:pienews/models/feed.dart';

abstract class FeedServiceInterface {
  // Data Synchronization
  Future<void> syncFeeds();
  Future<void> syncArticles(String feedId);
  Future<void> syncData(String feedId);

  // Local Data Operations
  Future<List<Feed>> getFeeds();
  Future<List<Article>> getArticles(String feedId);
  Future<Map<String, Map<String, int>>> getUnreadAndStarredCounts();
  Future<void> updateUnreadAndStarredCounts(
      Map<String, Map<String, int>> counts);
  Future<Article?> getArticle(String articleId);

  // State Updates (Update Both Local and Remote)
  Future<void> markArticleAsRead(String articleId);
  Future<void> markArticleAsUnread(String articleId);
  Future<void> markAllAsRead(String feedId, List<String> articleIds);
  Future<void> toggleArticleStarred(String articleId);
  Future<Feed> addFeed(String feedUrl);
}
