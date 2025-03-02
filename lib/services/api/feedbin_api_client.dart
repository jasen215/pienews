import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

class FeedbinApiClient extends ApiClient {
  static const String _baseUrl = 'https://api.feedbin.com/v2';
  static const String _authEndpoint = '/authentication.json';
  static const String _entriesEndpoint = '/entries.json';
  static const String _unreadEntriesEndpoint = '/unread_entries.json';

  late String email;
  late String password;
  http.Client? _client;

  // Add retry-related constants
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 1);

  FeedbinApiClient({
    String? email,
    String? password,
  }) : super(ServiceType.feedbin) {
    this.email = email ?? '';
    this.password = password ?? '';
  }

  http.Client get client {
    _client ??= http.Client();
    return _client!;
  }

  // Add a safe method to close the client
  void _closeClient() {
    _client?.close();
    _client = null;
  }

  // Add a request method with retry mechanism
  Future<http.Response> _retryableRequest(
      Future<http.Response> Function() request) async {
    int attempts = 0;
    while (attempts < _maxRetries) {
      try {
        return await request();
      } catch (e) {
        attempts++;
        if (e is HandshakeException || e is SocketException) {
          if (attempts == _maxRetries) {
            throw ApiException('Network connection failed: ${e.toString()}', 0);
          }
          // Close existing client and create a new one
          _closeClient();
          await Future.delayed(_retryDelay * attempts);
          continue;
        }
        rethrow;
      }
    }
    throw ApiException('Maximum retry attempts exceeded', 0);
  }

  String get baseUrl => _baseUrl;

  Map<String, String> get headers {
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (isLoggedIn && token != null) {
      headers['Authorization'] = 'Basic $token';
    } else {}

    return headers;
  }

  /// Get unread counts
  @override
  Future<Map<String, int>> getUnreadCounts() async {
    try {
      final response = await get(_unreadEntriesEndpoint);

      if (response.statusCode == 200) {
        final List<dynamic> unreadIds =
            (json.decode(response.body) as List).cast<dynamic>();

        // Group unread counts by feed
        final Map<String, int> unreadCounts = {};
        for (final id in unreadIds) {
          final article =
              await DatabaseHelper.instance.getArticle(id.toString());
          if (article != null) {
            final feedId = article.feedId;
            unreadCounts[feedId] = (unreadCounts[feedId] ?? 0) + 1;
          }
        }

        return unreadCounts;
      }

      return {};
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> init() async {
    await super.init();

    // If there's a stored user email, use it to update the current email
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString(ApiClient.userEmailKey);
    if (storedEmail != null) {
      email = storedEmail;
    }

    // Verify authentication status

    // If authentication state is inconsistent, clear all auth information
    if ((token != null && user == null) || (token == null && user != null)) {
      await clearToken();
    } else if (isLoggedIn && token != null) {
      try {
        // Verify authentication information
        final response = await _retryableRequest(() async {
          return await client.get(
            Uri.parse('$baseUrl$_authEndpoint'),
            headers: {
              'Authorization': 'Basic $token',
              'Accept': 'application/json',
            },
          );
        });

        if (response.statusCode != 200) {
          await clearToken();
        } else {
          // Decode username and password from token
          try {
            final decodedAuth = utf8.decode(base64.decode(token!));
            final parts = decodedAuth.split(':');
            if (parts.length == 2) {
              email = parts[0];
              password = parts[1];
            } else {
              await clearToken();
            }
          } catch (e) {
            await clearToken();
          }
        }
      } catch (e) {
        await clearToken();
      }
    }
  }

  @override
  Future<http.Response> get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    if (requiresAuth(path) && !isLoggedIn) {
      throw ApiException('Authentication required', 401);
    }

    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: queryParameters,
    );

    return _retryableRequest(() async {
      final response = await client.get(uri, headers: headers);
      _validateResponse(response);
      return response;
    });
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

    // Process request body based on Content-Type
    String? processedBody;
    if (requestHeaders['Content-Type'] == 'application/x-www-form-urlencoded') {
      // Special handling for array parameters
      if (body != null) {
        final Map<String, List<String>> formData = {};
        body.forEach((key, value) {
          if (value is List) {
            // For arrays, create a separate parameter for each element
            formData[key] = value.map((item) => item.toString()).toList();
          } else {
            formData[key] = [value.toString()];
          }
        });

        // Build URL-encoded string with repeated parameter names
        final List<String> params = [];
        formData.forEach((key, values) {
          for (final value in values) {
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

    final response = await client.post(
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

    return await client.put(
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
      return await client.delete(
        uri,
        headers: requestHeaders,
        body: json.encode(body),
      );
    }

    return await client.delete(uri, headers: requestHeaders);
  }

  @override
  Future<void> login(String email, String password) async {
    try {
      // Use base64 encoded email and password as Basic auth token
      final String credentials = base64.encode(utf8.encode('$email:$password'));

      // Verify if authentication is valid
      final response = await _retryableRequest(() async {
        return await client.get(
          Uri.parse('$baseUrl$_authEndpoint'),
          headers: {
            'Authorization': 'Basic $credentials',
            'Accept': 'application/json',
          },
        );
      });

      if (response.statusCode == 200) {
        // Login successful, save authentication information
        await setToken(credentials);
        await setUser(User(email: email));
        await saveUserEmail(email);
        isLoggedIn = true;
      } else {
        throw ApiException('Authentication failed', response.statusCode);
      }
    } catch (e) {
      await clearToken();
      rethrow;
    }
  }

  @override
  void dispose() {
    _closeClient();
    super.dispose();
  }

  @override
  bool requiresAuth(String path) {
    // Authentication endpoint doesn't require authentication
    if (path == '/authentication.json') {
      return false;
    }
    return true; // All other endpoints require authentication
  }

  void _validateResponse(http.Response response) {
    if (response.statusCode == 401) {
      throw ApiException('Authentication failed', response.statusCode);
    }

    final contentType = response.headers['content-type'];
    if (contentType?.contains('application/json') != true) {
      throw ApiException(
          'Server returned a non-JSON response', response.statusCode);
    }

    if (response.statusCode != 200) {
      throw ApiException('Request failed', response.statusCode);
    }
  }

  @override
  Future<List<Feed>> getFeeds() async {
    try {
      // 1. Get subscription list
      final response = await get('/subscriptions.json');

      if (response.statusCode == 404) {
        return await DatabaseHelper.instance.getFeeds();
      }

      final List<dynamic> data =
          (json.decode(response.body) as List).cast<dynamic>();

      // 2. Get category information
      final taggingsResponse = await get('/taggings.json');

      // Create feed_id to category mapping
      final Map<String, String> feedCategories = {};
      if (taggingsResponse.statusCode == 200) {
        final List<dynamic> taggings =
            (json.decode(taggingsResponse.body) as List).cast<dynamic>();
        for (final tagging in taggings) {
          feedCategories[tagging['feed_id'].toString()] =
              tagging['name'] as String;
        }
      } else {}

      final feeds = data.map((item) {
        final feedId = item['feed_id'].toString();
        final category = feedCategories[feedId];

        return Feed.fromJson({
          'id': feedId,
          'title': item['title'] ?? '',
          'description': item['feed_url'] ?? '',
          'url': item['site_url'] ?? item['feed_url'] ?? '',
          'iconUrl': item['favicon_url'],
          'category': category,
        });
      }).toList();

      // Get unread counts from database and create updated feeds list
      final db = DatabaseHelper.instance;
      final updatedFeeds = <Feed>[];
      for (final feed in feeds) {
        final unreadCount = await db.getUnreadCount(feed.id);
        updatedFeeds.add(feed.copyWith(unreadCount: unreadCount));
      }

      await db.insertFeeds(updatedFeeds);
      return updatedFeeds;
    } catch (e) {
      return await DatabaseHelper.instance.getFeeds();
    }
  }

  @override
  Future<List<Article>> getArticles({
    String? feedId,
    bool unreadOnly = true,
    int limit = 100,
    int page = 1,
  }) async {
    final queryParams = <String, String>{
      'per_page': limit.toString(),
      'page': page.toString(),
    };

    if (feedId != null) {
      queryParams['feed_id'] = feedId;
    }
    if (unreadOnly) {
      queryParams['read'] = 'false';
    }

    final response = await get(_entriesEndpoint, queryParameters: queryParams);

    if (response.statusCode == 200) {
      final List<dynamic> data =
          (json.decode(response.body) as List).cast<dynamic>();

      if (data.isEmpty) {
        return [];
      }

      final articles = data.map((item) {
        final feedId = item['feed_id']?.toString() ?? '';
        final publishedAt = DateTime.parse(item['published'] as String);

        return Article.fromJson({
          'id': item['id']?.toString() ?? '',
          'title': item['title'] as String? ?? 'Untitled',
          'content': item['content'] as String? ?? '',
          'summary': item['summary'] as String? ?? '',
          'url': item['url'] as String? ?? '',
          'author': item['author'] as String?,
          'publishedAt': publishedAt.toIso8601String(),
          'feedId': feedId,
          'feedTitle': '',
          'isRead': false,
          'isStarred': false,
        });
      }).toList();

      // If the number of articles equals the per page limit, there might be more pages
      if (articles.length == limit) {}

      return articles;
    } else {
      throw ApiException('Failed to get articles', response.statusCode);
    }
  }

  @override
  Future<void> markAllRead(
      {required String feedId, List<String>? articleIds}) async {
    try {
      if (articleIds != null && articleIds.isNotEmpty) {
        await delete(
          '/unread_entries.json',
          body: {
            'unread_entries': articleIds.map((id) => int.parse(id)).toList(),
          },
        );

        // Update local database
        final db = DatabaseHelper.instance;
        for (final articleId in articleIds) {
          await db.markArticleAsRead(articleId);
        }
      } else {
        // Get all unread articles for this feed
        final db = DatabaseHelper.instance;
        final articles = await db.getUnreadArticles(feedId);
        final articleIds = articles.map((a) => a.id).toList();

        if (articleIds.isNotEmpty) {
          await delete(
            '/unread_entries.json',
            body: {
              'unread_entries': articleIds.map((id) => int.parse(id)).toList(),
            },
          );

          // Update local database
          for (final articleId in articleIds) {
            await db.markArticleAsRead(articleId);
          }
        }
      }

      // Update feed's unread count
      final db = DatabaseHelper.instance;
      final unreadCount = await db.getUnreadCount(feedId);
      await db.updateUnreadCount(feedId, unreadCount);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markRead(String articleId) async {
    try {
      final response = await delete(
        '/unread_entries.json',
        body: {
          'unread_entries': [int.parse(articleId)],
        },
      );

      if (response.statusCode != 200) {
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
      final response = await post(
        '/unread_entries.json',
        body: {
          'unread_entries': [int.parse(articleId)],
        },
      );

      if (response.statusCode != 200) {
        throw ApiException(
            'Failed to mark article as unread', response.statusCode);
      }

      // Update local database
      await DatabaseHelper.instance.markArticleAsUnread(articleId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> star(String articleId) async {
    final response = await post('/entries/$articleId/star.json');

    if (response.statusCode != 200) {
      throw ApiException('Failed to star article', response.statusCode);
    }
  }

  @override
  Future<void> unstar(String articleId) async {
    final response = await post('/entries/$articleId/unstar.json');

    if (response.statusCode != 200) {
      throw ApiException('Failed to unstar article', response.statusCode);
    }
  }

  @override
  Future<bool> validate() async {
    try {
      if (token == null) {
        return false;
      }

      final response = await _retryableRequest(() async {
        return await client.get(
          Uri.parse('$baseUrl$_authEndpoint'),
          headers: {
            'Authorization': 'Basic $token',
            'Accept': 'application/json',
          },
        );
      });

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

        final List<dynamic> itemsList = items.cast<dynamic>();

        // Get list of unread article IDs, with retry mechanism
        Set<String> unreadSet = {};
        Set<String> starredSet = {};

        try {
          // Retry up to 3 times
          for (int i = 0; i < 3; i++) {
            try {
              final unreadResponse = await get('/unread_entries.json');
              final List<dynamic> unreadIds =
                  (json.decode(unreadResponse.body) as List).cast<dynamic>();
              unreadSet =
                  Set<String>.from(unreadIds.map((id) => id.toString()));
              break;
            } catch (e) {
              if (i == 2) rethrow; // Last retry failed, throw exception
              await Future.delayed(
                  const Duration(seconds: 1)); // Wait 1 second before retrying
            }
          }

          // Get list of starred article IDs, with retry mechanism
          for (int i = 0; i < 3; i++) {
            try {
              final starredResponse = await get('/starred_entries.json');
              final List<dynamic> starredIds =
                  (json.decode(starredResponse.body) as List).cast<dynamic>();
              starredSet =
                  Set<String>.from(starredIds.map((id) => id.toString()));
              break;
            } catch (e) {
              if (i == 2) rethrow; // Last retry failed, throw exception
              await Future.delayed(
                  const Duration(seconds: 1)); // Wait 1 second before retrying
            }
          }
        } catch (e) {
          // If getting status fails, assume all articles are unread
          unreadSet =
              Set<String>.from(itemsList.map((item) => item['id'].toString()));
          starredSet = {};
        }

        final articles = itemsList
            .map((item) {
              try {
                final id = item['id'].toString();
                final feedId = item['feed_id']?.toString() ?? '';
                final publishedAt = DateTime.parse(item['published'] as String);

                return Article(
                  id: id,
                  title: item['title'] as String? ?? 'Untitled',
                  content: item['content'] as String? ?? '',
                  summary: item['summary'] as String? ?? '',
                  url: item['url'] as String? ?? '',
                  author: item['author'] as String?,
                  publishedAt: publishedAt,
                  feedId: feedId,
                  feedTitle: '', // Will update later through feed list
                  isRead: !unreadSet.contains(id), // Set based on server status
                  isStarred:
                      starredSet.contains(id), // Set based on server status
                );
              } catch (e) {
                return null;
              }
            })
            .whereType<Article>()
            .toList();

        // Calculate next page
        String? nextContinuation;
        final perPage = int.parse(params['n'] ?? '100');
        if (articles.length >= perPage) {
          final currentPage =
              continuation != null ? int.parse(continuation) : 1;
          nextContinuation = (currentPage + 1).toString();
        }

        return ArticleResponse(
          articles: articles,
          continuation: nextContinuation,
        );
      } else {
        throw ApiException('Failed to get articles', response.statusCode);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Feed> addSubscription(String feedUrl) async {
    try {
      final response = await post(
        '/subscriptions.json',
        body: {'feed_url': feedUrl},
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final feed = Feed.fromJson({
          'id': data['feed_id'].toString(),
          'title': data['title'] ?? '',
          'description': data['feed_url'] ?? '',
          'url': data['site_url'] ?? data['feed_url'] ?? '',
          'iconUrl': data['favicon_url'],
          'unreadCount': 0,
          'hasStarred': false,
        });

        // Save to local database
        await DatabaseHelper.instance.insertFeeds([feed]);
        return feed;
      } else {
        throw ApiException('Failed to add subscription', response.statusCode);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAllAsRead(String feedId, List<String> articleIds) async {
    try {
      final response = await delete(
        '/unread_entries.json',
        body: {
          'unread_entries': articleIds.map((id) => int.parse(id)).toList(),
        },
      );

      if (response.statusCode != 200) {
        throw ApiException(
            'Failed to mark multiple articles as read', response.statusCode);
      }

      // Update local database
      final db = DatabaseHelper.instance;
      for (final articleId in articleIds) {
        await db.markArticleAsRead(articleId);
      }

      // Update feed's unread count
      if (feedId.isNotEmpty) {
        final unreadCount = await db.getUnreadCount(feedId);
        await db.updateUnreadCount(feedId, unreadCount);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Feed> addFeed(String feedUrl) async {
    try {
      final response = await post(
        '/subscriptions.json',
        body: {'feed_url': feedUrl},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final feed = Feed.fromJson({
          'id': data['feed_id'].toString(),
          'title': data['title'] ?? '',
          'description': data['description'] ?? '',
          'url': data['feed_url'] ?? feedUrl,
          'iconUrl': data['icon_url'],
          'unreadCount': 0,
          'hasStarred': false,
        });

        // Save to local database
        await DatabaseHelper.instance.insertFeeds([feed]);
        return feed;
      } else {
        throw ApiException('Failed to add feed', response.statusCode);
      }
    } catch (e) {
      rethrow;
    }
  }
}
