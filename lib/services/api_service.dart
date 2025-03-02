import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pienews/models/article.dart';
import 'package:pienews/models/feed.dart';

class ApiService {
  static const String baseUrl = 'https://theoldreader.com/reader/api/0';
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/accounts/ClientLogin'),
      body: {
        'client': 'RSSReader',
        'accountType': 'HOSTED_OR_GOOGLE',
        'Email': username,
        'Passwd': password,
      },
    );

    if (response.statusCode == 200) {
      final token = response.body.split('Auth=')[1].trim();
      setToken(token);
      return token;
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<List<Feed>> getFeeds() async {
    if (_token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$baseUrl/subscription/list'),
      headers: {'Authorization': 'GoogleLogin auth=$_token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Feed> feeds = [];
      for (var item in (data['subscriptions'] as List)) {
        feeds.add(Feed.fromJson(item as Map<String, dynamic>));
      }
      return feeds;
    } else {
      throw Exception('Failed to load feeds');
    }
  }

  Future<List<Article>> getArticles({
    required String feedId,
    bool unreadOnly = true,
    int limit = 20,
  }) async {
    if (_token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse(
        '$baseUrl/stream/contents/$feedId?n=$limit${unreadOnly ? '&xt=user/-/state/com.google/read' : ''}',
      ),
      headers: {'Authorization': 'GoogleLogin auth=$_token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Article> articles = [];
      for (var item in (data['items'] as List)) {
        articles.add(Article.fromJson(item as Map<String, dynamic>));
      }
      return articles;
    } else {
      throw Exception('Failed to load articles');
    }
  }

  Future<void> markAsRead(String articleId) async {
    if (_token == null) throw Exception('Not authenticated');

    await http.post(
      Uri.parse('$baseUrl/edit-tag'),
      headers: {
        'Authorization': 'GoogleLogin auth=$_token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'i': [articleId],
        'a': ['user/-/state/com.google/read'],
      }),
    );
  }
}
