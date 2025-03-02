import 'package:path/path.dart';
import 'package:pienews/models/article.dart';
import 'package:pienews/models/feed.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = 'pienews.db';
  static const _databaseVersion = 1;

  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE feeds(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        iconUrl TEXT,
        url TEXT,
        unreadCount INTEGER NOT NULL DEFAULT 0,
        starredCount INTEGER NOT NULL DEFAULT 0,
        category TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE articles(
        id TEXT PRIMARY KEY,
        feedId TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        summary TEXT,
        url TEXT,
        author TEXT,
        publishedAt INTEGER NOT NULL,
        isRead INTEGER NOT NULL,
        isStarred INTEGER NOT NULL DEFAULT 0,
        feedTitle TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (feedId) REFERENCES feeds (id)
      )
    ''');
  }

  // Feed operations
  Future<void> insertFeeds(List<Feed> feeds) async {
    final db = await database;
    await db.transaction((txn) async {
      // First get all existing feed IDs and starredCount
      final existingFeeds = await txn.query(
        'feeds',
        columns: ['id', 'starredCount'],
      );
      final Map<String, int> existingStarredCounts = {
        for (var feed in existingFeeds)
          feed['id'] as String: feed['starredCount'] as int
      };

      // Get actual article statistics for all feeds
      final statsResult = await txn.rawQuery('''
        SELECT
          feedId,
          COUNT(DISTINCT CASE WHEN isRead = 0 THEN id ELSE NULL END) as unreadCount,
          COUNT(DISTINCT CASE WHEN isStarred = 1 THEN id ELSE NULL END) as starredCount
        FROM articles
        WHERE feedId != ''
        GROUP BY feedId
      ''');

      final Map<String, Map<String, int>> articleStats = {
        for (var row in statsResult)
          row['feedId'] as String: {
            'unreadCount': row['unreadCount'] as int,
            'starredCount': row['starredCount'] as int,
          }
      };

      // Batch insert feeds, preserve local starredCount
      final batch = txn.batch();
      for (final feed in feeds) {
        // Skip empty feedId
        if (feed.id.isEmpty) continue;

        final existingStarredCount = existingStarredCounts[feed.id] ?? 0;
        final actualStats = articleStats[feed.id] ??
            {'unreadCount': 0, 'starredCount': existingStarredCount};

        batch.insert(
          'feeds',
          {
            'id': feed.id,
            'title': feed.title,
            'description': feed.description,
            'iconUrl': feed.iconUrl,
            'url': feed.url,
            'unreadCount': actualStats['unreadCount']!,
            'starredCount': actualStats['starredCount']!,
            'category': feed.category,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);

      // Verify all counts in the same transaction
      final verifyStatsResult = await txn.rawQuery('''
        SELECT
          a.feedId,
          COUNT(DISTINCT CASE WHEN a.isRead = 0 THEN a.id ELSE NULL END) as unreadCount,
          COUNT(DISTINCT CASE WHEN a.isStarred = 1 THEN a.id ELSE NULL END) as starredCount
        FROM articles a
        GROUP BY a.feedId
      ''');

      // Create stats result map
      final Map<String, Map<String, int>> feedStats = {
        for (var row in verifyStatsResult)
          row['feedId'] as String: {
            'unreadCount': row['unreadCount'] as int,
            'starredCount': row['starredCount'] as int,
          }
      };

      // Get all feeds
      final List<Map<String, dynamic>> allFeeds = await txn.query('feeds');
      final verifyBatch = txn.batch();

      for (final feed in allFeeds) {
        final String feedId = feed['id'] as String;
        final stats =
            feedStats[feedId] ?? {'unreadCount': 0, 'starredCount': 0};
        final currentUnread = feed['unreadCount'] as int;
        final currentStarred = feed['starredCount'] as int;

        if (currentUnread != stats['unreadCount'] ||
            currentStarred != stats['starredCount']) {
          verifyBatch.update(
            'feeds',
            {
              'unreadCount': stats['unreadCount'],
              'starredCount': stats['starredCount'],
            },
            where: 'id = ?',
            whereArgs: [feedId],
          );
        }
      }

      await verifyBatch.commit(noResult: true);
    });
  }

  Future<List<Feed>> getFeeds() async {
    final db = await database;
    final maps = await db.query(
      'feeds',
      orderBy: 'id ASC', // Sort by ID to maintain consistency
    );

    return maps.map((map) => Feed.fromJson(map)).toList();
  }

  Future<void> updateUnreadCount(String feedId, int count) async {
    final db = await database;
    await db.update(
      'feeds',
      {'unreadCount': count},
      where: 'id = ?',
      whereArgs: [feedId],
    );
  }

  // Article operations
  Future<void> insertArticles(String feedId, List<Article> articles) async {
    final db = await database;
    await db.transaction((txn) async {
      // Get existing articles' starred status
      final existingArticles = await txn.query(
        'articles',
        where: 'feedId = ?',
        whereArgs: [feedId],
      );

      final Map<String, bool> existingStarredStatus = {
        for (final existingArticle in existingArticles)
          existingArticle['id'] as String: existingArticle['isStarred'] == 1
      };

      // Insert new articles
      final batch = txn.batch();
      for (final article in articles) {
        // Preserve local starred status
        final bool isStarred =
            existingStarredStatus[article.id] ?? article.isStarred;

        final Map<String, dynamic> articleData = {
          'id': article.id,
          'feedId': feedId,
          'title': article.title,
          'content': article.content,
          'summary': article.summary,
          'url': article.url,
          'author': article.author,
          'publishedAt': article.publishedAt.millisecondsSinceEpoch,
          'feedTitle': article.feedTitle,
          'isRead': article.isRead ? 1 : 0,
          'isStarred': isStarred ? 1 : 0,
        };

        batch.insert(
          'articles',
          articleData,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit();

      // Recalculate unread and starred counts for this feed
      const countSql = '''
        SELECT
          COUNT(DISTINCT CASE WHEN isRead = 0 THEN id ELSE NULL END) as unreadCount,
          COUNT(DISTINCT CASE WHEN isStarred = 1 THEN id ELSE NULL END) as starredCount
        FROM articles
        WHERE feedId = ?
      ''';

      final result = await txn.rawQuery(countSql, [feedId]);
      if (result.isNotEmpty) {
        final unreadCount = result.first['unreadCount'] as int;
        final starredCount = result.first['starredCount'] as int;

        await txn.rawUpdate('''
          UPDATE feeds
          SET unreadCount = ?,
              starredCount = ?
          WHERE id = ?
        ''', [unreadCount, starredCount, feedId]);
      }
    });
  }

  Future<List<Article>> getArticles(String feedId, [Transaction? txn]) async {
    final db = txn ?? await database;

    try {
      // First get article list
      final List<Map<String, dynamic>> maps = await db.query(
        'articles',
        where: 'feedId = ?',
        whereArgs: [feedId],
        orderBy: 'publishedAt DESC',
      );

      // Get statistics in the same transaction
      final stats = await db.rawQuery('''
        SELECT
          COUNT(DISTINCT CASE WHEN isRead = 0 THEN id ELSE NULL END) as unreadCount,
          COUNT(DISTINCT CASE WHEN isStarred = 1 THEN id ELSE NULL END) as starredCount
        FROM articles
        WHERE feedId = ?
      ''', [feedId]);

      // Only update feed counts in non-transaction mode
      if (stats.isNotEmpty && txn == null) {
        final unreadCount = stats.first['unreadCount'] as int;
        final starredCount = stats.first['starredCount'] as int;

        // Use new database connection to update feed counts
        final updateDb = await database;
        await updateDb.update(
          'feeds',
          {
            'unreadCount': unreadCount,
            'starredCount': starredCount,
          },
          where: 'id = ?',
          whereArgs: [feedId],
        );
      }

      // Convert and return article list
      final articles = List.generate(maps.length, (i) {
        try {
          return Article.fromJson(maps[i]);
        } catch (e) {
          rethrow;
        }
      });

      return articles;
    } catch (e) {
      rethrow;
    }
  }

  Future<Article?> getArticle(String articleId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'articles',
      where: 'id = ?',
      whereArgs: [articleId],
      limit: 1,
    );
    if (maps.isEmpty) {
      return null;
    }
    return Article.fromJson(maps.first);
  }

  Future<void> markArticleAsRead(String articleId) async {
    final db = await database;
    await db.transaction((txn) async {
      // Get article's feedId
      final article = await txn.query(
        'articles',
        columns: ['feedId'],
        where: 'id = ?',
        whereArgs: [articleId],
      );

      if (article.isNotEmpty) {
        final feedId = article.first['feedId'] as String;

        // Update article status
        await txn.update(
          'articles',
          {'isRead': 1},
          where: 'id = ?',
          whereArgs: [articleId],
        );

        // Recalculate unread count for this feed
        final result = await txn.rawQuery('''
          SELECT COUNT(*) as count
          FROM articles
          WHERE feedId = ? AND isRead = 0
        ''', [feedId]);

        final unreadCount = Sqflite.firstIntValue(result) ?? 0;

        // Update feed's unread count
        await txn.update(
          'feeds',
          {'unreadCount': unreadCount},
          where: 'id = ?',
          whereArgs: [feedId],
        );
      }
    });
  }

  Future<void> markArticleAsUnread(String articleId) async {
    final db = await database;
    await db.update(
      'articles',
      {'isRead': 0},
      where: 'id = ?',
      whereArgs: [articleId],
    );
  }

  Future<void> markAllArticlesAsRead() async {
    final db = await database;
    await db.update(
      'articles',
      {'isRead': 1},
    );
  }

  Future<List<Article>> getUnreadArticles(String feedId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'articles',
      where: 'feedId = ? AND isRead = 0',
      whereArgs: [feedId],
    );

    return maps.map((map) => Article.fromJson(map)).toList();
  }

  Future<int> getUnreadCount(String feedId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM articles
      WHERE feedId = ? AND isRead = 0
    ''', [feedId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Method to toggle article's starred status
  Future<void> toggleArticleStarred(String articleId) async {
    final db = await database;
    await db.transaction((txn) async {
      // Get current article information
      final article = await txn.query(
        'articles',
        columns: ['feedId', 'isStarred'],
        where: 'id = ?',
        whereArgs: [articleId],
      );

      if (article.isNotEmpty) {
        final feedId = article.first['feedId'] as String;
        final isCurrentlyStarred = article.first['isStarred'] == 1;
        final newStarredStatus = !isCurrentlyStarred;

        // Update article status
        await txn.update(
          'articles',
          {'isStarred': newStarredStatus ? 1 : 0},
          where: 'id = ?',
          whereArgs: [articleId],
        );

        // Recalculate starred count for this feed
        final starredResult = await txn.rawQuery('''
          SELECT COUNT(*) as count
          FROM articles
          WHERE feedId = ? AND isStarred = 1
        ''', [feedId]);

        final starredCount = Sqflite.firstIntValue(starredResult) ?? 0;

        // Update feed's starred count
        await txn.update(
          'feeds',
          {'starredCount': starredCount},
          where: 'id = ?',
          whereArgs: [feedId],
        );
      }
    });
  }

  Future<List<Article>> getAllArticles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('articles');
    return List.generate(maps.length, (i) => Article.fromJson(maps[i]));
  }

  Future<List<Article>> getUnsyncedArticles() async {
    final db = await database;
    final maps = await db.query(
      'articles',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return maps.map((map) => Article.fromJson(map)).toList();
  }

  Future<void> updateSyncStatus(String articleId, bool isSynced) async {
    final db = await database;
    await db.update(
      'articles',
      {
        'isSynced': isSynced ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [articleId],
    );
  }

  Future<void> markArticlesAsRead(
      String feedId, List<String> articleIds) async {
    if (articleIds.isEmpty) return;

    final db = await database;
    await db.transaction((txn) async {
      // 1. Batch update articles status with a single SQL statement
      final placeholders = List.filled(articleIds.length, '?').join(',');
      final sql = '''
        UPDATE articles
        SET isRead = 1, isSynced = 0
        WHERE id IN ($placeholders)
      ''';

      await txn.rawUpdate(sql, articleIds);

      // 2. Update feed's unread and starred counts
      const countSql = '''
        SELECT
          COUNT(DISTINCT CASE WHEN isRead = 0 THEN id ELSE NULL END) as unreadCount,
          COUNT(DISTINCT CASE WHEN isStarred = 1 THEN id ELSE NULL END) as starredCount
        FROM articles
        WHERE feedId = ?
      ''';

      final result = await txn.rawQuery(countSql, [feedId]);
      if (result.isNotEmpty) {
        final unreadCount = result.first['unreadCount'] as int;
        final starredCount = result.first['starredCount'] as int;

        await txn.update(
          'feeds',
          {
            'unreadCount': unreadCount,
            'starredCount': starredCount,
          },
          where: 'id = ?',
          whereArgs: [feedId],
        );
      }
    });
  }

  Future<void> updateArticlesSyncStatus(
      List<String> articleIds, bool isSynced) async {
    if (articleIds.isEmpty) return;

    final db = await database;
    final placeholders = List.filled(articleIds.length, '?').join(',');
    final sql = '''
      UPDATE articles
      SET isSynced = ?
      WHERE id IN ($placeholders)
    ''';

    await db.rawUpdate(sql, [isSynced ? 1 : 0, ...articleIds]);
  }

  Future<void> insertArticlesBatch(List<Article> articles) async {
    if (articles.isEmpty) return;

    final db = await database;
    await db.transaction((txn) async {
      var batch = txn.batch();
      var count = 0;

      for (final article in articles) {
        // Check if article exists
        final existing = await txn.query(
          'articles',
          columns: ['id', 'isRead', 'isStarred'],
          where: 'id = ?',
          whereArgs: [article.id],
        );

        final Map<String, dynamic> articleData = article.toJson();

        if (existing.isNotEmpty) {
          // Preserve existing read and starred status
          articleData['isRead'] = existing.first['isRead'];
          articleData['isStarred'] = existing.first['isStarred'];
        }

        batch.insert(
          'articles',
          articleData,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        count++;
        if (count >= 100) {
          // Commit every 100 records
          await batch.commit(noResult: true);
          batch = txn.batch();
          count = 0;
        }
      }

      if (count > 0) {
        await batch.commit(noResult: true);
      }

      // Update unread counts for all feeds
      await _updateAllFeedsUnreadCount(txn);
    });
  }

  Future<void> _updateAllFeedsUnreadCount(Transaction txn) async {
    // One-time statistics for all feeds' unread and starred article counts
    final statsResult = await txn.rawQuery('''
      SELECT
        a.feedId,
        COUNT(DISTINCT CASE WHEN a.isRead = 0 THEN a.id ELSE NULL END) as unreadCount,
        COUNT(DISTINCT CASE WHEN a.isStarred = 1 THEN a.id ELSE NULL END) as starredCount
      FROM articles a
      GROUP BY a.feedId
    ''');

    // Reset all feed counts to 0
    await txn.rawUpdate('''
      UPDATE feeds
      SET unreadCount = 0,
          starredCount = 0
    ''');

    // Update unread and starred counts for each feed
    for (final row in statsResult) {
      final feedId = row['feedId'] as String;
      final unreadCount = row['unreadCount'] as int;
      final starredCount = row['starredCount'] as int;

      await txn.rawUpdate('''
        UPDATE feeds
        SET unreadCount = ?,
            starredCount = ?
        WHERE id = ?
      ''', [unreadCount, starredCount, feedId]);
    }
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('feeds');
      await txn.delete('articles');
    });
  }

  Future<void> updateAllFeedsUnreadCount() async {
    final db = await database;
    await db.transaction((txn) async {
      // Get statistics for all articles
      final statsResult = await txn.rawQuery('''
        SELECT
          feedId,
          COUNT(DISTINCT CASE WHEN isRead = 0 THEN id ELSE NULL END) as unreadCount,
          COUNT(DISTINCT CASE WHEN isStarred = 1 THEN id ELSE NULL END) as starredCount
        FROM articles
        GROUP BY feedId
      ''');

      // Update counts for each feed
      for (final row in statsResult) {
        final feedId = row['feedId'] as String;
        final unreadCount = row['unreadCount'] as int;
        final starredCount = row['starredCount'] as int;

        await txn.update(
          'feeds',
          {
            'unreadCount': unreadCount,
            'starredCount': starredCount,
          },
          where: 'id = ?',
          whereArgs: [feedId],
        );
      }
    });
  }

  Future<void> clearFeeds() async {
    final db = await database;
    await db.delete('feeds');
  }

  Future<void> clearArticles() async {
    final db = await database;
    await db.delete('articles');
  }

  Future<List<Feed>> getFeedsByIds(List<String> feedIds) async {
    if (feedIds.isEmpty) return [];

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'feeds',
      where: 'id IN (${List.filled(feedIds.length, '?').join(',')})',
      whereArgs: feedIds,
    );

    return maps.map((map) => Feed.fromJson(map)).toList();
  }

  Future<Feed?> getFeed(String feedId, [Transaction? txn]) async {
    final db = txn ?? await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'feeds',
      where: 'id = ?',
      whereArgs: [feedId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Feed.fromJson(maps.first);
  }

  Future<void> updateFeed(Feed feed) async {
    final db = await database;
    await db.update(
      'feeds',
      feed.toJson(),
      where: 'id = ?',
      whereArgs: [feed.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update article's starred status
  Future<void> updateArticleStarred(String articleId, bool isStarred) async {
    final db = await database;
    await db.transaction((txn) async {
      // Get article's feedId
      final article = await txn.query(
        'articles',
        columns: ['feedId'],
        where: 'id = ?',
        whereArgs: [articleId],
      );

      if (article.isNotEmpty) {
        final feedId = article.first['feedId'] as String;

        // Update article status
        await txn.update(
          'articles',
          {'isStarred': isStarred ? 1 : 0},
          where: 'id = ?',
          whereArgs: [articleId],
        );

        // Recalculate starred count for this feed
        final result = await txn.rawQuery('''
          SELECT COUNT(*) as count
          FROM articles
          WHERE feedId = ? AND isStarred = 1
        ''', [feedId]);

        final starredCount = Sqflite.firstIntValue(result) ?? 0;

        // Update feed's starred count
        await txn.update(
          'feeds',
          {'starredCount': starredCount},
          where: 'id = ?',
          whereArgs: [feedId],
        );
      }
    });
  }

  // Update feed's starred status
  Future<void> updateFeedStarred(String feedId, bool hasStarred) async {
    final db = await database;
    await db.update(
      'feeds',
      {'hasStarred': hasStarred ? 1 : 0},
      where: 'id = ?',
      whereArgs: [feedId],
    );
  }

  // Check if feed has other starred articles
  Future<bool> feedHasOtherStarredArticles(
      String feedId, String excludeArticleId) async {
    final db = await database;
    final result = await db.query(
      'articles',
      where: 'feedId = ? AND id != ? AND isStarred = 1',
      whereArgs: [feedId, excludeArticleId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Count starred articles for specified feed
  Future<int> getStarredCount(String feedId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM articles
      WHERE feedId = ? AND isStarred = 1
    ''', [feedId]);
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count;
  }

  // Update starred status for all feeds
  Future<void> updateAllFeedsStarredStatus() async {
    final db = await database;
    await db.transaction((txn) async {
      // Get starred article count for each feed
      final List<Map<String, dynamic>> results = await txn.rawQuery('''
        SELECT feedId, COUNT(*) as starredCount
        FROM articles
        WHERE isStarred = 1
        GROUP BY feedId
      ''');

      // Reset all feeds' starredCount to 0
      await txn.rawUpdate('''
        UPDATE feeds
        SET starredCount = 0
      ''');

      // Update feeds with starred articles
      for (final row in results) {
        final String feedId = row['feedId'] as String;
        final int starredCount = row['starredCount'] as int;

        await txn.rawUpdate('''
          UPDATE feeds
          SET starredCount = ?
          WHERE id = ?
        ''', [starredCount, feedId]);
      }
    });
  }

  // Get feeds with starred articles
  Future<List<Feed>> getStarredFeeds() async {
    final db = await database;
    final maps = await db.query(
      'feeds',
      where: 'starredCount > ?',
      whereArgs: [0],
      orderBy: 'id ASC',
    );
    return maps.map((map) => Feed.fromJson(map)).toList();
  }

  // Get feeds with unread articles
  Future<List<Feed>> getUnreadFeeds() async {
    final db = await database;
    final maps = await db.query(
      'feeds',
      where: 'unreadCount > ?',
      whereArgs: [0],
      orderBy: 'id ASC',
    );
    return maps.map((map) => Feed.fromJson(map)).toList();
  }

  // Fix starredCount in feeds table
  Future<void> fixFeedsStarredCount() async {
    final db = await database;

    await db.transaction((txn) async {
      // Count starred articles for each feed
      final statsResult = await txn.rawQuery('''
        SELECT
          feedId,
          COUNT(DISTINCT CASE WHEN isStarred = 1 THEN id ELSE NULL END) as starredCount
        FROM articles
        GROUP BY feedId
      ''');

      // Reset all feeds' starred count to 0
      await txn.rawUpdate('''
        UPDATE feeds
        SET starredCount = 0
      ''');

      if (statsResult.isNotEmpty) {
        final batch = txn.batch();

        for (final row in statsResult) {
          final feedId = row['feedId'] as String;
          final starredCount = row['starredCount'] as int;

          batch.rawUpdate('''
            UPDATE feeds
            SET starredCount = ?
            WHERE id = ?
          ''', [starredCount, feedId]);
        }

        await batch.commit(noResult: true);
      }
    });
  }

  Future<void> recalculateAllFeedsStarredCount() async {
    final db = await database;

    await db.transaction((txn) async {
      // Get starred article count for each feed
      final statsResult = await txn.rawQuery('''
        SELECT
          a.feedId,
          COUNT(DISTINCT CASE WHEN a.isStarred = 1 THEN a.id ELSE NULL END) as starredCount
        FROM articles a
        GROUP BY a.feedId
      ''');

      // Reset all feeds' starred count to 0
      await txn.rawUpdate('''
        UPDATE feeds
        SET starredCount = 0
      ''');

      // Update feeds with starred articles
      for (final row in statsResult) {
        final feedId = row['feedId'] as String;
        final starredCount = row['starredCount'] as int;

        if (starredCount > 0) {
          await txn.rawUpdate('''
            UPDATE feeds
            SET starredCount = ?
            WHERE id = ?
          ''', [starredCount, feedId]);
        }
      }
    });
  }

  Future<Map<String, Map<String, int>>> getUnreadAndStarredCounts() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query(
        'feeds',
        columns: ['id', 'unreadCount', 'starredCount'],
      );

      final Map<String, Map<String, int>> counts = {};
      for (final row in results) {
        final feedId = row['id'] as String;
        final unreadCount = row['unreadCount'] as int;
        final starredCount = row['starredCount'] as int;

        counts[feedId] = {
          'unreadCount': unreadCount,
          'starredCount': starredCount,
        };
      }

      return counts;
    } catch (e) {
      return {};
    }
  }

  Future<void> updateUnreadAndStarredCounts(
      Map<String, Map<String, int>> counts) async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        // Update counts for each feed
        for (final entry in counts.entries) {
          final String feedId = entry.key;
          final Map<String, int> feedCounts = entry.value;
          final int unreadCount = feedCounts['unreadCount'] ?? 0;
          final int starredCount = feedCounts['starredCount'] ?? 0;

          await txn.rawUpdate('''
            UPDATE feeds
            SET unreadCount = ?,
                starredCount = ?
            WHERE id = ?
          ''', [unreadCount, starredCount, feedId]);
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyFeedCounts() async {
    final stopwatch = Stopwatch()..start();

    try {
      final db = await database;
      await db.transaction((txn) async {
        // One-time statistics for all feeds
        final List<Map<String, dynamic>> statsResult = await txn.rawQuery('''
          SELECT
            a.feedId,
            COUNT(DISTINCT CASE WHEN a.isRead = 0 THEN a.id ELSE NULL END) as unreadCount,
            COUNT(DISTINCT CASE WHEN a.isStarred = 1 THEN a.id ELSE NULL END) as starredCount
          FROM articles a
          GROUP BY a.feedId
        ''');

        // Create a Map to store statistics
        final Map<String, Map<String, int>> feedStats = {
          for (var row in statsResult)
            row['feedId'] as String: {
              'unreadCount': row['unreadCount'] as int,
              'starredCount': row['starredCount'] as int,
            }
        };

        // Get all feeds
        final List<Map<String, dynamic>> feeds = await txn.query('feeds');

        // Batch update counts for all feeds
        final batch = txn.batch();
        int updateCount = 0;

        for (final feed in feeds) {
          final String feedId = feed['id'] as String;
          final stats =
              feedStats[feedId] ?? {'unreadCount': 0, 'starredCount': 0};
          final currentUnread = feed['unreadCount'] as int;
          final currentStarred = feed['starredCount'] as int;

          if (currentUnread != stats['unreadCount'] ||
              currentStarred != stats['starredCount']) {
            batch.update(
              'feeds',
              {
                'unreadCount': stats['unreadCount'],
                'starredCount': stats['starredCount'],
              },
              where: 'id = ?',
              whereArgs: [feedId],
            );
            updateCount++;
          }
        }

        if (updateCount > 0) {
          await batch.commit(noResult: true);
        }
      });
    } catch (e) {
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  Future<void> updateArticle(Article article) async {
    final db = await database;
    await db.update(
      'articles',
      {
        'title': article.title,
        'content': article.content,
        'summary': article.summary,
        'url': article.url,
        'author': article.author,
        'publishedAt': article.publishedAt.millisecondsSinceEpoch,
        'isRead': article.isRead ? 1 : 0,
        'isStarred': article.isStarred ? 1 : 0,
        'feedTitle': article.feedTitle,
      },
      where: 'id = ?',
      whereArgs: [article.id],
    );
  }

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }
}
