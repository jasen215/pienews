import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pienews/models/article.dart';
import 'package:pienews/models/feed.dart';
import 'package:pienews/models/service_type.dart';
import 'package:pienews/models/user.dart';
import 'package:pienews/services/api/api_client.dart';
import 'package:pienews/services/api/api_exception.dart';
import 'package:pienews/services/api/api_response.dart';
import 'package:pienews/services/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TheOldReaderApiClient extends ApiClient {
  static const String _baseUrl = 'https://theoldreader.com/reader/api/0';
  static const String _authEndpoint = '/accounts/ClientLogin';
  static const String _streamContentsEndpoint = '/stream/contents';
  static const String _unreadCountEndpoint = '/unread-count';

  late String email;
  late String password;
  final http.Client _client = http.Client();

  TheOldReaderApiClient({String? email, String? password})
      : super(ServiceType.theOldReader) {
    this.email = email ?? '';
    this.password = password ?? '';
  }

  String get baseUrl => _baseUrl;

  Map<String, String> get headers {
    final Map<String, String> headers = {
      'Accept': 'application/json',
    };

    if (isLoggedIn && token != null) {
      headers['Authorization'] = 'GoogleLogin auth=$token';
    } else {}

    return headers;
  }

  /// Get unread counts
  @override
  Future<Map<String, int>> getUnreadCounts() async {
    try {
      final response = await get(_unreadCountEndpoint, queryParameters: {
        'output': 'json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['unreadcounts'] != null) {
          final Map<String, int> unreadCounts = {};
          for (final item in data['unreadcounts'] as List) {
            final String id = item['id'] as String;
            final int count = item['count'] as int;
            unreadCounts[id] = count;
          }
          return unreadCounts;
        }
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$_authEndpoint'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client': 'RSSReader',
          'accountType': 'HOSTED_OR_GOOGLE',
          'service': 'reader',
          'Email': email,
          'Passwd': password,
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.contains('Auth=')) {
          final token = responseBody.split('Auth=')[1].split('\n')[0].trim();
          await setToken(token);
          await setUser(User(email: email));
          await saveUserEmail(email);
        } else {
          throw ApiException('Invalid response format', response.statusCode);
        }
      } else {
        throw ApiException('Authentication failed', response.statusCode);
      }
    } catch (e) {
      await clearToken();
      rethrow;
    }
  }

  @override
  Future<List<Feed>> getFeeds() async {
    try {
      final response = await get('/subscription/list', queryParameters: {
        'output': 'json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['subscriptions'] != null) {
          final feeds = (data['subscriptions'] as List).map((item) {
            final categories = item['categories'] as List?;
            final category = categories?.isNotEmpty == true
                ? categories!.first['label'] as String
                : null;

            // Handle icon URL
            String? iconUrl = item['iconUrl'] as String?;
            if (iconUrl != null && iconUrl.startsWith('//')) {
              iconUrl = 'https:$iconUrl';
            }

            return Feed(
              id: item['id'] as String,
              title: item['title'] as String,
              description: item['description'] as String? ?? '',
              iconUrl: iconUrl ?? '',
              url: (item['url'] as String?) ?? '',
              unreadCount: item['numUnread'] as int? ?? 0,
              starredCount: 0,
              category: category ?? '',
            );
          }).toList();

          await DatabaseHelper.instance.insertFeeds(feeds);
          return feeds;
        }
      }

      return await DatabaseHelper.instance.getFeeds();
    } catch (e) {
      return await DatabaseHelper.instance.getFeeds();
    }
  }

  @override
  Future<List<Article>> getArticles({
    String? feedId,
    bool unreadOnly = false,
    int limit = 100,
    int page = 1,
  }) async {
    final params = {
      'output': 'json',
      'n': limit.toString(),
    };

    // For first page, don't add continuation token
    if (page > 1) {
      params['c'] = 'page$page';
    }

    // No longer using unreadOnly parameter, instead get all articles
    // Determine read status on client side based on server response
    final uri = Uri.parse(feedId != null
            ? '$baseUrl$_streamContentsEndpoint/$feedId'
            : '$baseUrl$_streamContentsEndpoint')
        .replace(queryParameters: params);

    final response = await _client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['items'] != null) {
        final articles = (data['items'] as List).map((item) {
          final id = item['id'] as String;
          final publishedAt = DateTime.fromMillisecondsSinceEpoch(
            (item['published'] as int) * 1000,
          );
          final categories = item['categories'] as List? ?? [];
          final isRead = categories.contains('user/-/state/com.google/read');
          final isStarred =
              categories.contains('user/-/state/com.google/starred');

          return Article.fromJson({
            'id': id,
            'title': item['title'] as String? ?? 'Untitled',
            'content': item['content']?['content'] as String? ?? '',
            'summary': item['summary']?['content'] as String? ?? '',
            'url': item['canonical']?[0]?['href'] as String? ?? '',
            'author': item['author'] as String?,
            'publishedAt': publishedAt.toIso8601String(),
            'feedId': item['origin']?['streamId'] as String? ?? '',
            'feedTitle': item['origin']?['title'] as String? ?? '',
            'isRead': isRead,
            'isStarred': isStarred,
          });
        }).toList();

        // Save articles to database
        if (articles.isNotEmpty) {
          await DatabaseHelper.instance.insertArticles(feedId ?? '', articles);
          // Update feeds starred status
          await DatabaseHelper.instance.updateAllFeedsStarredStatus();
        }

        if (articles.length == limit) {}

        return articles;
      }
    }
    return [];
  }

  @override
  Future<void> markAllRead(
      {required String feedId, List<String>? articleIds}) async {
    try {
      if (articleIds != null && articleIds.isNotEmpty) {
        // If article IDs are provided, use edit-tag endpoint
        final uri = Uri.parse('$baseUrl/edit-tag');
        final requestHeaders = {
          ...headers,
          'Content-Type': 'application/x-www-form-urlencoded',
        };

        // Build request body, create an i parameter for each article ID
        final params = articleIds.map((id) => 'i=$id').join('&');
        final body = '$params&a=user/-/state/com.google/read';

        final response = await _client.post(
          uri,
          headers: requestHeaders,
          body: body,
        );

        if (response.statusCode != 200) {
          throw ApiException(
              'Failed to mark articles as read', response.statusCode);
        }
      } else {
        // If no article IDs are provided, use mark-all-as-read endpoint
        final uri = Uri.parse('$baseUrl/mark-all-as-read');
        final requestHeaders = {
          ...headers,
          'Content-Type': 'application/x-www-form-urlencoded',
        };

        final body = 's=$feedId';

        final response = await _client.post(
          uri,
          headers: requestHeaders,
          body: body,
        );

        if (response.statusCode != 200) {
          throw ApiException(
              'Failed to mark all articles as read', response.statusCode);
        }
      }

      // Update local database
      final db = DatabaseHelper.instance;
      if (articleIds != null && articleIds.isNotEmpty) {
        for (final articleId in articleIds) {
          await db.markArticleAsRead(articleId);
        }
      } else {
        final articles = await db.getUnreadArticles(feedId);
        for (final article in articles) {
          await db.markArticleAsRead(article.id);
        }
      }

      // Update feed unread count
      await db.updateUnreadCount(feedId, 0);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markRead(String articleId) async {
    try {
      if (!isLoggedIn || token == null) {
        await init();

        if (!isLoggedIn || token == null) {
          throw ApiException(
              'Authentication expired, please log in again', 401);
        }
      }

      // Use x-www-form-urlencoded format for request
      final uri = Uri.parse('$baseUrl/edit-tag');
      final response = await _client.post(
        uri,
        headers: {
          ...headers,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'i': articleId, // No longer using i[]
          'a': 'user/-/state/com.google/read',
        },
      );

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          await clearToken();
        }
        throw ApiException(
            'Failed to mark article as read', response.statusCode);
      }

      // Update local database
      await DatabaseHelper.instance.markArticleAsRead(articleId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markUnread(String articleId) async {
    try {
      if (!isLoggedIn || token == null) {
        await init();
        if (!isLoggedIn || token == null) {
          throw ApiException(
              'Authentication expired, please log in again', 401);
        }
      }

      final uri = Uri.parse('$baseUrl/edit-tag');
      final requestHeaders = {
        ...headers,
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final encodedBody = 'i=$articleId&r=user/-/state/com.google/read';

      final response = await _client.post(
        uri,
        headers: requestHeaders,
        body: encodedBody,
      );

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          await clearToken();
        }
        throw ApiException(
            'Failed to mark article as unread', response.statusCode);
      }

      await DatabaseHelper.instance.markArticleAsUnread(articleId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> star(String articleId) async {
    try {
      if (!isLoggedIn || token == null) {
        await init();

        if (!isLoggedIn || token == null) {
          throw ApiException(
              'Authentication expired, please log in again', 401);
        }
      }

      final uri = Uri.parse('$baseUrl/edit-tag');

      final requestHeaders = {
        ...headers,
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final requestBody = {
        'i': articleId,
        'a': 'user/-/state/com.google/starred',
      };

      // Manually build form-urlencoded format request body
      final encodedBody = requestBody.entries
          .map((e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');

      final response = await _client.post(
        uri,
        headers: requestHeaders,
        body: encodedBody,
      );

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          await clearToken();
        }
        throw ApiException('Failed to star article', response.statusCode);
      }

      final db = DatabaseHelper.instance;

      // Update article starred status
      await db.updateArticleStarred(articleId, true);

      // Get article's feed
      final article = await db.getArticle(articleId);
      if (article != null) {
        // Update feed starred status
        await db.updateFeedStarred(article.feedId, true);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> unstar(String articleId) async {
    try {
      if (!isLoggedIn || token == null) {
        await init();

        if (!isLoggedIn || token == null) {
          throw ApiException(
              'Authentication expired, please log in again', 401);
        }
      }

      final uri = Uri.parse('$baseUrl/edit-tag');

      final requestHeaders = {
        ...headers,
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final requestBody = {
        'i': articleId,
        'r': 'user/-/state/com.google/starred',
      };

      // Manually build form-urlencoded format request body
      final encodedBody = requestBody.entries
          .map((e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');

      final response = await _client.post(
        uri,
        headers: requestHeaders,
        body: encodedBody,
      );

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          await clearToken();
        }
        throw ApiException('Failed to unstar article', response.statusCode);
      }

      final db = DatabaseHelper.instance;

      // Update article starred status
      await db.updateArticleStarred(articleId, false);

      // Get article's feed
      final article = await db.getArticle(articleId);
      if (article != null) {
        // Check if feed has other starred articles
        final hasOtherStarredArticles =
            await db.feedHasOtherStarredArticles(article.feedId, articleId);
        if (!hasOtherStarredArticles) {
          // If no other starred articles, update feed starred status to false
          await db.updateFeedStarred(article.feedId, false);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> validate() async {
    try {
      if (token == null) {
        return false;
      }

      // Use unread count endpoint to validate token
      final response = await _client.get(
        Uri.parse('$baseUrl$_unreadCountEndpoint'),
        headers: {
          'Authorization': 'GoogleLogin auth=$token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> setToken(String? token) async {
    this.token = token;
    isLoggedIn = token != null;

    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${serviceType.name}_${ApiClient.tokenKey}', token);
    }
  }

  @override
  Future<void> setUser(User user) async {
    this.user = user;
  }

  @override
  Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        '${serviceType.name}_${ApiClient.userEmailKey}', email);
  }

  @override
  Future<void> clearToken() async {
    token = null;
    isLoggedIn = false;
    user = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${serviceType.name}_${ApiClient.tokenKey}');
    await prefs.remove('${serviceType.name}_${ApiClient.userEmailKey}');
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  @override
  Future<http.Response> get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: queryParameters,
    );
    return await _client.get(uri, headers: headers);
  }

  @override
  Future<http.Response> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final requestHeaders = {...headers};
    if (additionalHeaders != null) {
      requestHeaders.addAll(additionalHeaders);
    }

    // By Content-Type, process request body
    String? processedBody;
    if (requestHeaders['Content-Type'] == 'application/x-www-form-urlencoded') {
      // Special handling for array parameters
      if (body != null) {
        final Map<String, List<String>> formData = {};
        body.forEach((key, value) {
          if (value is List) {
            // If it's an array, create a separate parameter for each element
            formData[key] = value.map((item) => item.toString()).toList();
          } else {
            formData[key] = [value.toString()];
          }
        });

        // Build URL-encoded string, repeating parameter names
        final List<String> params = [];
        formData.forEach((key, values) {
          for (var value in values) {
            params.add(
                '${Uri.encodeComponent(key)}=${Uri.encodeComponent(value)}');
          }
        });
        processedBody = params.join('&');
      }
    } else {
      // Default to JSON format
      processedBody = body != null ? json.encode(body) : null;
    }

    final response = await _client.post(
      uri,
      headers: requestHeaders,
      body: processedBody,
    );

    return response;
  }

  @override
  Future<http.Response> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final requestHeaders = {...headers};
    if (additionalHeaders != null) {
      requestHeaders.addAll(additionalHeaders);
    }

    return await _client.put(
      uri,
      headers: requestHeaders,
      body: body != null ? json.encode(body) : null,
    );
  }

  @override
  Future<http.Response> delete(String path,
      {Map<String, dynamic>? body,
      Map<String, String>? additionalHeaders}) async {
    final uri = Uri.parse('$baseUrl$path');
    final requestHeaders = {...headers};

    if (body != null) {
      return await _client.delete(
        uri,
        headers: requestHeaders,
        body: json.encode(body),
      );
    }

    return await _client.delete(uri, headers: requestHeaders);
  }

  @override
  Future<ArticleResponse> getAllArticles({
    DateTime? since,
    String? continuation,
    int limit = 100,
  }) async {
    try {
      final params = <String, String>{
        'n': limit.toString(),
        'output': 'json',
      };

      if (since != null) {
        params['ot'] = (since.millisecondsSinceEpoch ~/ 1000).toString();
      }

      if (continuation != null) {
        params['c'] = continuation;
      }

      final response = await get(
        '/stream/contents',
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;

        if (items == null || items.isEmpty) {
          return ArticleResponse(articles: [], continuation: null);
        }

        final articles = items
            .map((item) {
              try {
                final categories = item['categories'] as List? ?? [];
                final isRead =
                    categories.contains('user/-/state/com.google/read');
                final isStarred =
                    categories.contains('user/-/state/com.google/starred');

                return Article(
                  id: item['id']?.toString() ?? '',
                  title: item['title']?.toString() ?? 'Untitled',
                  content: item['content']?['content']?.toString() ??
                      item['summary']?['content']?.toString() ??
                      '',
                  summary: item['summary']?['content']?.toString() ?? '',
                  url: item['canonical']?[0]?['href']?.toString() ??
                      item['alternate']?[0]?['href']?.toString() ??
                      '',
                  author: item['author']?.toString() ?? '',
                  publishedAt: DateTime.fromMillisecondsSinceEpoch(
                      ((item['published'] as num?)?.toInt() ?? 0) * 1000),
                  feedId: item['origin']?['streamId']?.toString() ?? '',
                  feedTitle:
                      item['origin']?['title']?.toString() ?? 'Unknown Feed',
                  isRead: isRead,
                  isStarred: isStarred,
                );
              } catch (e) {
                return null;
              }
            })
            .whereType<Article>()
            .toList();

        return ArticleResponse(
          articles: articles,
          continuation: data['continuation']?.toString(),
        );
      }

      return ArticleResponse(articles: [], continuation: null);
    } catch (e) {
      return ArticleResponse(articles: [], continuation: null);
    }
  }

  @override
  Future<Feed> addFeed(String feedUrl) async {
    try {
      final response = await post(
        '/subscription/quickadd',
        body: {'quickadd': feedUrl},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['streamId'] != null) {
          // Get feed details
          final feedResponse = await get(
            '/stream/details/${data['streamId']}',
            queryParameters: {'output': 'json'},
          );

          if (feedResponse.statusCode == 200) {
            final feedData = json.decode(feedResponse.body);
            final feed = Feed.fromJson({
              'id': data['streamId'],
              'title': feedData['title'] ?? '',
              'description': feedData['description'] ?? '',
              'url': feedData['url'] ?? feedUrl,
              'iconUrl': feedData['iconUrl'],
              'unreadCount': 0,
              'starredCount': 0,
            });

            // Save to local database
            await DatabaseHelper.instance.insertFeeds([feed]);
            return feed;
          }
        }
        throw ApiException(
            'Could not get feed information', response.statusCode);
      } else {
        throw ApiException('Failed to add feed', response.statusCode);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAllAsRead(String feedId, List<String> articleIds) async {
    try {
      final response = await post(
        '/edit-tag',
        body: {
          'i': articleIds,
          'a': 'user/-/state/com.google/read',
        },
      );

      if (response.statusCode != 200) {
        throw ApiException(
            'Failed to mark articles as read in bulk', response.statusCode);
      }

      // Update local database
      final db = DatabaseHelper.instance;
      for (final articleId in articleIds) {
        await db.markArticleAsRead(articleId);
      }

      // Update feed unread count
      if (feedId.isNotEmpty) {
        final unreadCount = await db.getUnreadCount(feedId);
        await db.updateUnreadCount(feedId, unreadCount);
      }
    } catch (e) {
      rethrow;
    }
  }
}
