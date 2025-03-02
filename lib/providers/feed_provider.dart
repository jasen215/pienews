import 'package:flutter/cupertino.dart';
import 'package:pienews/models/article.dart';
import 'package:pienews/models/feed.dart';
import 'package:pienews/providers/auth_provider.dart';
import 'package:pienews/services/api/api_client.dart';
import 'package:pienews/services/api/api_exception.dart';
import 'package:pienews/services/api/feed_service.dart';
import 'package:pienews/services/database/database_helper.dart';
import 'package:pienews/services/sync_preferences.dart';
import 'package:pienews/services/sync_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

class FeedProvider with ChangeNotifier {
  static const String _filterIndexKey = 'feed_filter_index';
  ApiClient _apiClient;
  late ApiFeedService _feedService;
  late SyncService _syncService;
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Feed> _feeds = [];
  List<Article> _articles = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _error;
  int _filterIndex = 2; // 0: Starred, 1: Unread, 2: All
  int _previousFilterIndex = 2;
  BuildContext? _context;
  bool _isArticleLoading = false;
  final _articleLoadLock = Lock();

  FeedProvider({
    required ApiClient apiClient,
    ApiFeedService? feedService,
  }) : _apiClient = apiClient {
    // Initialize FeedService
    _feedService = feedService ?? ApiFeedService(apiClient: apiClient);

    _syncService = SyncService(feedService: _feedService);
    _loadFilterState();
    _loadFeeds();
  }

  void updateApiClient(ApiClient newApiClient) {
    _apiClient = newApiClient;
    _feedService = ApiFeedService(apiClient: newApiClient);
    _syncService = SyncService(feedService: _feedService);

    notifyListeners();
  }

  void init(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Save context for dispose
    _context = context;

    // Add API client listener
    authProvider.addApiClientListener(updateApiClient);

    // Immediately get the current API client
    final currentApiClient = authProvider.apiClient;
    if (currentApiClient != null) {
      updateApiClient(currentApiClient);
    }

    // Load local data, but don't trigger sync (sync already triggered in MyApp)
    _loadFeeds();
  }

  @override
  void dispose() {
    if (_context != null) {
      final authProvider = Provider.of<AuthProvider>(_context!, listen: false);
      authProvider.removeApiClientListener(updateApiClient);
    }
    super.dispose();
  }

  void switchService(ApiClient newApiClient) {
    // Update API client
    _apiClient = newApiClient;

    // Clear existing data
    _feeds = [];
    _articles = [];
    _error = null;

    // Create new FeedService
    _feedService = ApiFeedService(apiClient: newApiClient);

    // Recreate SyncService
    _syncService = SyncService(feedService: _feedService);

    // If logged in, reload data
    if (_apiClient.isLoggedIn) {
      _loadFeeds();
    } else {}

    notifyListeners();
  }

  void updateService() {
    // Clear existing data
    _feeds = [];
    _articles = [];
    _error = null;

    // Reload data
    _loadFeeds();
    notifyListeners();
  }

  Future<void> _loadFeeds() async {
    try {
      _feeds = await _db.getFeeds();

      // Fix starredCount
      await _db.fixFeedsStarredCount();

      // Reload fixed data
      _feeds = await _db.getFeeds();

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load saved filter state
  Future<void> _loadFilterState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _filterIndex =
          prefs.getInt(_filterIndexKey) ?? 2; // Default value is 2 (All)
      notifyListeners();
    } catch (e) {
      // If loading fails, keep default value
    }
  }

  // Save filter state
  Future<void> _saveFilterState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_filterIndexKey, _filterIndex);
    } catch (e) {
      // If saving fails, log error
    }
  }

  List<Feed> get feeds => _feeds;
  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  SyncService get syncService => _syncService;
  int get filterIndex => _filterIndex;
  int get previousFilterIndex => _previousFilterIndex;

  List<Feed> get filteredFeeds {
    switch (_filterIndex) {
      case 0: // Starred
        final starredFeeds = _feeds.where((feed) {
          return feed.starredCount > 0;
        }).toList();
        return starredFeeds;
      case 1: // Unread
        final unreadFeeds = _feeds.where((feed) {
          return feed.unreadCount > 0;
        }).toList();
        return unreadFeeds;
      default: // All
        return _feeds;
    }
  }

  // Get the count to display (returns different count based on filter type)
  int getDisplayCount(Feed feed) {
    switch (_filterIndex) {
      case 0: // Starred
        return feed.starredCount;
      case 1: // Unread
        return feed.unreadCount;
      default: // All
        return feed.unreadCount + feed.starredCount;
    }
  }

  List<Article> get filteredArticles {
    switch (_filterIndex) {
      case 0: // Starred
        final starredArticles = _articles.where((article) {
          return article.isStarred;
        }).toList();
        return starredArticles;
      case 1: // Unread
        final unreadArticles = _articles.where((article) {
          return !article.isRead;
        }).toList();
        return unreadArticles;
      default: // All
        return _articles;
    }
  }

  Future<void> syncWithServer({DateTime? since}) async {
    if (_isSyncing) {
      return;
    }

    try {
      _isSyncing = true;

      _syncService.syncStatus.value = 'Syncing...';
      _syncService.syncProgress.value = 0.0;

      // Get last sync time
      final lastSyncTime = await SyncPreferences.getLastSyncTime();

      // 1. Sync feeds
      _syncService.syncStatus.value = 'Syncing feeds...';
      final feeds = await _feedService.getFeeds();

      // Get local starred counts
      final localCounts = await _feedService.getUnreadAndStarredCounts();

      // Preserve local starred counts
      final updatedFeeds = feeds.map((feed) {
        final localCount = localCounts[feed.id];
        final starredCount = localCount?['starredCount'] ?? feed.starredCount;
        return feed.copyWith(
          starredCount: starredCount,
        );
      }).toList();

      // Save all feeds at once
      await _db.insertFeeds(updatedFeeds);
      _feeds = updatedFeeds;
      notifyListeners();
      _syncService.syncProgress.value = 0.2;

      // 2. Sync articles
      var totalArticles = 0;
      String? continuation;

      do {
        _syncService.syncStatus.value = totalArticles > 0
            ? 'Synced $totalArticles articles...'
            : 'Syncing new articles...';

        try {
          final response = await _apiClient.getAllArticles(
            since: lastSyncTime ?? since,
            continuation: continuation,
            limit: 100,
          );

          if (response.articles.isEmpty) {
            break;
          }

          totalArticles += response.articles.length;

          // Group articles by feed
          final articlesByFeed = <String, List<Article>>{};
          for (final article in response.articles) {
            articlesByFeed.putIfAbsent(article.feedId, () => []).add(article);
          }

          // Save articles for each feed separately
          for (final feedId in articlesByFeed.keys) {
            final articles = articlesByFeed[feedId]!;
            await _db.insertArticles(feedId, articles);
          }

          // Update UI after each batch of articles is saved
          notifyListeners();

          // Update progress
          final progress = 0.2 + (0.8 * (totalArticles / 1000.0));
          _syncService.syncProgress.value = progress > 1.0 ? 1.0 : progress;

          continuation = response.continuation;
        } catch (e) {
          break;
        }
      } while (continuation != null);

      // Update last sync time
      final now = DateTime.now();
      await SyncPreferences.setLastSyncTime(now);

      // Verify all feed counts one last time
      await _db.verifyFeedCounts();
      _feeds = await _db.getFeeds();

      // Update UI one last time
      notifyListeners();

      _syncService.syncStatus.value = 'Sync completed';
      _syncService.syncProgress.value = 1.0;
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isSyncing = false;
      // Ensure latest data is loaded and UI is updated after sync completes
      await _loadFeeds();
      _syncService.syncStatus.value = '';
      _syncService.syncProgress.value = 0.0;
      notifyListeners();
    }
  }

  Future<void> _updateAllFeedsUnreadCount() async {
    try {
      // Get unread count for each feed from database
      for (final feed in _feeds) {
        final unreadCount = await _db.getUnreadCount(feed.id);

        // Update unread count in memory
        _feeds = _feeds.map((f) {
          if (f.id == feed.id) {
            return f.copyWith(unreadCount: unreadCount);
          }
          return f;
        }).toList();

        // Update unread count in database
        await _db.updateUnreadCount(feed.id, unreadCount);
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshFeed(Feed feed) async {
    if (_isSyncing) return;
    try {
      _isLoading = true;
      notifyListeners();

      // Use new sync method
      await _syncService.syncFeed(feed.id);

      // Reload data
      await loadFeeds();
      await fetchArticles(feed.id);

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(BuildContext context) async {
    await syncWithServer();
  }

  Future<void> loadLocalArticles(String feedId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Read all articles from local database
      _articles = await _db.getArticles(feedId);

      // Apply filters
      final List<Article> filtered = _articles.where((article) {
        switch (_filterIndex) {
          case 0: // Starred
            return article.isStarred;
          case 1: // Unread
            return !article.isRead;
          default: // All
            return true;
        }
      }).toList();

      _articles = filtered;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchArticles(String feedId) async {
    if (_isLoading) {
      return;
    }

    await _articleLoadLock.synchronized(() async {
      if (_isArticleLoading) {
        return;
      }

      try {
        _isArticleLoading = true;
        _isLoading = true;
        _error = null;
        notifyListeners();

        // Get latest feed data
        final feed = await _db.getFeed(feedId);
        if (feed != null) {
          _feeds = _feeds.map((f) => f.id == feedId ? feed : f).toList();
        }

        // Read articles from database
        _articles = await _db.getArticles(feedId);

        // Apply filters
        final List<Article> filtered = _articles.where((article) {
          switch (_filterIndex) {
            case 0: // Starred
              return article.isStarred;
            case 1: // Unread
              return !article.isRead;
            default: // All
              return true;
          }
        }).toList();

        _articles = filtered;
      } catch (e) {
        _error = e.toString();
      } finally {
        _isArticleLoading = false;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> markArticleAsRead(String articleId) async {
    try {
      if (!_apiClient.isLoggedIn) {
        throw ApiException('Authentication required', 401);
      }
      _error = null;
      await _feedService.markArticleAsRead(articleId);

      _articles = _articles.map((article) {
        if (article.id == articleId) {
          return Article(
            id: article.id,
            title: article.title,
            content: article.content,
            summary: article.summary,
            url: article.url,
            author: article.author,
            publishedAt: article.publishedAt,
            isRead: true,
            feedTitle: article.feedTitle,
            feedId: article.feedId,
          );
        }
        return article;
      }).toList();

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setFilterIndex(int index) {
    if (_filterIndex != index) {
      _previousFilterIndex = _filterIndex; // Save old filter state
      _filterIndex = index;
      _saveFilterState();
      notifyListeners();
    }
  }

  Future<void> markCurrentArticlesAsRead() async {
    final unreadArticles =
        _articles.where((article) => !article.isRead).toList();
    for (final article in unreadArticles) {
      await markArticleAsRead(article.id);
    }
  }

  Future<Article?> toggleArticleStarred(String articleId) async {
    try {
      final article = _articles.firstWhere((a) => a.id == articleId);

      final newIsStarred = !article.isStarred;

      // Call API to modify server state
      if (!newIsStarred) {
        await _feedService.unstar(articleId);
      } else {
        await _feedService.star(articleId);
      }

      // Update starred status in database
      await _db.updateArticleStarred(articleId, newIsStarred);

      // Update article state in memory
      final updatedArticle = Article(
        id: article.id,
        title: article.title,
        content: article.content,
        summary: article.summary,
        url: article.url,
        author: article.author,
        publishedAt: article.publishedAt,
        isRead: article.isRead,
        isStarred: newIsStarred,
        feedTitle: article.feedTitle,
        feedId: article.feedId,
      );

      _articles =
          _articles.map((a) => a.id == articleId ? updatedArticle : a).toList();

      // Update feed starred count
      final feedId = article.feedId;
      final starredCount =
          _articles.where((a) => a.feedId == feedId && a.isStarred).length;

      _feeds = _feeds.map((feed) {
        if (feed.id == feedId) {
          return feed.copyWith(starredCount: starredCount);
        }
        return feed;
      }).toList();

      notifyListeners();
      return updatedArticle;
    } catch (e) {
      return null;
    }
  }

  Future<Feed> addFeed(String feedUrl) async {
    try {
      await _feedService.addFeed(feedUrl);
      final feeds = await _feedService.getFeeds();
      final newFeed = feeds.firstWhere((feed) => feed.url == feedUrl);
      _feeds = [..._feeds, newFeed];
      notifyListeners();
      return newFeed;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addFeedAndSync(String feedUrl) async {
    try {
      final newFeed = await addFeed(feedUrl);
      await _syncService.syncFeed(newFeed.id);
      _feeds = [..._feeds, newFeed];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  List<Article> getArticles(String feedId) {
    return filteredArticles
        .where((article) => article.feedId == feedId)
        .toList();
  }

  Future<void> fetchAllArticles() async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _articles = await _db.getAllArticles();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, List<Feed>> get groupedFeeds {
    final groups = <String, List<Feed>>{};

    for (final feed in filteredFeeds) {
      final category = feed.category.isEmpty ? 'uncategorized' : feed.category;
      groups.putIfAbsent(category, () => []).add(feed);
    }

    // Sort groups
    final sortedGroups = Map.fromEntries(
      groups.entries.toList()
        ..sort((a, b) {
          if (a.key == 'uncategorized') return 1;
          if (b.key == 'uncategorized') return -1;
          return a.key.compareTo(b.key);
        }),
    );

    // Sort feeds within each group
    for (final feeds in sortedGroups.values) {
      feeds.sort((a, b) => a.title.compareTo(b.title));
    }

    return sortedGroups;
  }

  bool hasNextArticle(Article article) {
    final index = _articles.indexWhere((a) => a.id == article.id);
    return index < _articles.length - 1;
  }

  bool hasPreviousArticle(Article article) {
    final index = _articles.indexWhere((a) => a.id == article.id);
    return index > 0;
  }

  Article? getNextArticle(Article article) {
    final index = _articles.indexWhere((a) => a.id == article.id);
    if (index < _articles.length - 1) {
      return _articles[index + 1];
    }
    return null;
  }

  Article? getPreviousArticle(Article article) {
    final index = _articles.indexWhere((a) => a.id == article.id);
    if (index > 0) {
      return _articles[index - 1];
    }
    return null;
  }

  Future<Article?> toggleArticleRead(String articleId) async {
    try {
      final article = _articles.firstWhere((a) => a.id == articleId);

      final newIsRead = !article.isRead;

      if (!newIsRead) {
        await _feedService.markArticleAsUnread(articleId);
      } else {
        await _feedService.markArticleAsRead(articleId);
      }

      final updatedArticle = Article(
        id: article.id,
        feedId: article.feedId,
        title: article.title,
        content: article.content,
        summary: article.summary,
        url: article.url,
        author: article.author,
        publishedAt: article.publishedAt,
        isRead: newIsRead,
        isStarred: article.isStarred,
        feedTitle: article.feedTitle,
      );

      _articles =
          _articles.map((a) => a.id == articleId ? updatedArticle : a).toList();

      // Update feed unread count
      final feedId = article.feedId;
      final unreadCount =
          _articles.where((a) => a.feedId == feedId && !a.isRead).length;

      _feeds = _feeds.map((feed) {
        if (feed.id == feedId) {
          return Feed(
            id: feed.id,
            title: feed.title,
            description: feed.description,
            iconUrl: feed.iconUrl,
            url: feed.url,
            unreadCount: unreadCount,
            starredCount: feed.starredCount,
            category: feed.category,
          );
        }
        return feed;
      }).toList();

      // Update unread count in database
      await _db.updateUnreadCount(feedId, unreadCount);

      notifyListeners();
      return updatedArticle;
    } catch (e) {
      return null;
    }
  }

  Article? getArticle(String articleId) {
    try {
      return _articles.firstWhere((a) => a.id == articleId);
    } catch (e) {
      return null;
    }
  }

  Future<Feed?> markAllAsRead(String feedId) async {
    try {
      if (!_apiClient.isLoggedIn) {
        throw ApiException('Authentication required', 401);
      }
      _error = null;

      // 1. Get IDs of all unread articles
      final unreadArticles =
          _articles.where((article) => !article.isRead).toList();
      final unreadArticleIds =
          unreadArticles.map((article) => article.id).toList();

      if (unreadArticleIds.isEmpty) {
        return null;
      }

      // 2. Immediately update local database and in-memory state
      await _db.markArticlesAsRead(feedId, unreadArticleIds);

      // 3. Immediately update article state in memory and refresh UI
      _articles = _articles.map<Article>((article) {
        if (unreadArticleIds.contains(article.id)) {
          return Article(
            id: article.id,
            feedId: article.feedId,
            title: article.title,
            content: article.content,
            summary: article.summary,
            url: article.url,
            author: article.author,
            publishedAt: article.publishedAt,
            isRead: true, // Update to read
            isStarred: article.isStarred,
            feedTitle: article.feedTitle,
          );
        }
        return article;
      }).toList();

      // 4. Update feed unread count
      _feeds = _feeds.map<Feed>((feed) {
        if (feed.id == feedId) {
          // Set unread count to 0 as all articles are marked as read
          return Feed(
            id: feed.id,
            title: feed.title,
            description: feed.description,
            iconUrl: feed.iconUrl,
            url: feed.url,
            unreadCount: 0, // Set directly to 0
            starredCount: feed.starredCount,
            category: feed.category,
          );
        }
        return feed;
      }).toList();

      // 5. Update display based on current filter
      if (_filterIndex == 1) {
        // Unread filter
        _articles = _articles.where((article) => !article.isRead).toList();
      }

      // 6. Notify UI to update immediately
      notifyListeners();

      // 7. Asynchronously execute server sync
      await _feedService.markAllAsRead(feedId, unreadArticleIds);

      // 8. Find and return next unread feed
      return getNextUnreadFeed(feedId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> loadFeeds() async {
    try {
      _feeds = await _db.getFeeds();

      // Fix starredCount
      await _db.fixFeedsStarredCount();

      // Reload fixed data
      _feeds = await _db.getFeeds();

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get feeds ordered as in home screen
  List<Feed> _getOrderedFeeds() {
    // Get a copy of all feeds
    final allFeeds = List<Feed>.from(_feeds);
    final orderedFeeds = <Feed>[];

    // Get grouped feeds to determine order
    final groups = <String, List<Feed>>{};
    for (final feed in allFeeds) {
      final category = feed.category.isEmpty ? 'uncategorized' : feed.category;
      groups.putIfAbsent(category, () => []).add(feed);
    }

    // Sort groups
    final sortedGroups = Map.fromEntries(
      groups.entries.toList()
        ..sort((a, b) {
          if (a.key == 'uncategorized') return 1;
          if (b.key == 'uncategorized') return -1;
          return a.key.compareTo(b.key);
        }),
    );

    // Sort feeds within each group and add to result list
    for (final feeds in sortedGroups.values) {
      feeds.sort((a, b) => a.title.compareTo(b.title));
      orderedFeeds.addAll(feeds);
    }

    return orderedFeeds;
  }

  Feed? getNextUnreadFeed(String currentFeedId) {
    // Ensure currentFeedId has 'feed/' prefix
    if (!currentFeedId.startsWith('feed/') &&
        !currentFeedId.startsWith('user/') &&
        !currentFeedId.startsWith('tor/sponsored/')) {
      currentFeedId = 'feed/$currentFeedId';
    }

    // Get feeds ordered as in home screen
    final orderedFeeds = _getOrderedFeeds();

    // Find current feed position in all feeds
    final currentIndex =
        orderedFeeds.indexWhere((feed) => feed.id == currentFeedId);

    if (currentIndex == -1) {
      // If current feed not found, find first feed with unread articles from beginning
      for (var i = 0; i < orderedFeeds.length; i++) {
        if (orderedFeeds[i].unreadCount > 0) {
          return orderedFeeds[i];
        }
      }
      return null;
    }

    // Search forward from current position for first feed with unread articles
    for (var i = currentIndex + 1; i < orderedFeeds.length; i++) {
      if (orderedFeeds[i].unreadCount > 0) {
        return orderedFeeds[i];
      }
    }

    // If not found, search from beginning up to current position
    for (var i = 0; i < currentIndex; i++) {
      if (orderedFeeds[i].unreadCount > 0) {
        return orderedFeeds[i];
      }
    }

    return null;
  }

  void clearAll() {
    _feeds.clear();
    _articles.clear();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> syncAll() async {
    try {
      // Sync feeds
      await syncFeeds();
      // Update UI immediately
      notifyListeners();

      // Sync articles
      await syncArticles();

      // Update last sync time
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
          'last_sync_time', DateTime.now().millisecondsSinceEpoch);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> syncFeeds() async {
    try {
      final feeds = await _apiClient.getFeeds();
      _feeds = feeds;
      notifyListeners();
    } catch (e) {
      _syncService.syncStatus.value = 'Sync failed: $e';
      rethrow;
    }
  }

  Future<void> syncArticles() async {
    try {
      // Get all feeds
      final feeds = await _db.getFeeds();
      final int totalFeeds = feeds.length;
      int currentFeed = 0;

      // Iterate through each feed
      for (var feed in feeds) {
        currentFeed++;
        _syncService.syncStatus.value =
            'Syncing feed ($currentFeed/$totalFeeds)...';
        _syncService.syncProgress.value = currentFeed / totalFeeds;

        int page = 1;
        bool hasMore = true;
        int totalArticles = 0;

        while (hasMore) {
          final articles = await _apiClient.getArticles(
            feedId: feed.id,
            page: page,
          );

          if (articles.isEmpty) {
            hasMore = false;
            continue;
          }

          totalArticles += articles.length;
          _syncService.syncStatus.value =
              'Syncing feed ($currentFeed/$totalFeeds), synced $totalArticles articles...';

          // Save articles to database
          await _db.insertArticles(feed.id, articles);

          // Update unread count
          final unreadCount = await _db.getUnreadCount(feed.id);

          // Update feed unread count in memory
          _feeds = _feeds.map((f) {
            if (f.id == feed.id) {
              return f.copyWith(unreadCount: unreadCount);
            }
            return f;
          }).toList();

          // Update UI after each page is synced
          notifyListeners();

          page++;
        }

        // After syncing a feed, confirm unread count again
        final finalUnreadCount = await _db.getUnreadCount(feed.id);

        // Update feed unread count in memory
        _feeds = _feeds.map((f) {
          if (f.id == feed.id) {
            return f.copyWith(unreadCount: finalUnreadCount);
          }
          return f;
        }).toList();

        // Update UI after each feed is synced
        notifyListeners();
      }

      // After all syncing is complete, update all feed unread counts
      await _updateAllFeedsUnreadCount();

      // Update UI one last time
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> syncFeed(String feedId) async {
    if (_isSyncing) return;
    try {
      _isSyncing = true;

      // Get unread count from server
      final unreadCounts = await _feedService.getUnreadCounts();
      final serverUnreadCount = unreadCounts[feedId] ?? 0;

      // Get local unread count
      final localUnreadCount = await _db.getUnreadCount(feedId);

      // If unread counts don't match, need to resync
      if (serverUnreadCount != localUnreadCount) {
        int page = 1;
        bool hasMore = true;
        final List<Article> allArticles = [];

        while (hasMore) {
          final articles = await _apiClient.getArticles(
            feedId: feedId,
            unreadOnly: false, // Get all articles
            limit: 100,
            page: page,
          );

          if (articles.isEmpty) {
            hasMore = false;
            break;
          }

          allArticles.addAll(articles);

          // If we got fewer articles than requested, no more articles are available
          if (articles.length < 100) {
            hasMore = false;
          } else {
            page++;
          }
        }

        // Save all articles to database
        if (allArticles.isNotEmpty) {
          await _db.insertArticles(feedId, allArticles);
        }

        // Verify unread count again
        final newLocalUnreadCount = await _db.getUnreadCount(feedId);
        if (newLocalUnreadCount != serverUnreadCount) {}
      } else {}
    } catch (e) {
      rethrow;
    } finally {
      _isSyncing = false;
    }
  }
}
