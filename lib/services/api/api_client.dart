import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pienews/models/article.dart';
import 'package:pienews/models/feed.dart';
import 'package:pienews/models/service_type.dart';
import 'package:pienews/models/user.dart';
import 'package:pienews/services/api/api_response.dart';
import 'package:pienews/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'feedbin_api_client.dart'; // Import FeedbinApiClient
import 'the_old_reader_api_client.dart'; // Import TheOldReaderApiClient

abstract class ApiClient {
  // Storage key constants
  static const String tokenKey = 'api_token';
  static const String userKey = 'user';
  static const String userEmailKey = 'user_email';
  // Use constants from StorageKeys
  static String get serviceTypeKey => StorageKeys.serviceType;

  ServiceType serviceType;
  String? token;
  User? user;
  bool isLoggedIn = false;

  ApiClient(this.serviceType);

  // HTTP basic operations
  Future<http.Response> get(String path,
      {Map<String, String>? queryParameters});
  Future<http.Response> post(String path,
      {Map<String, dynamic>? body, Map<String, String>? additionalHeaders});
  Future<http.Response> put(String path,
      {Map<String, dynamic>? body, Map<String, String>? additionalHeaders});
  Future<http.Response> delete(String path,
      {Map<String, dynamic>? body, Map<String, String>? additionalHeaders});

  // Authentication related
  Future<void> login(String email, String password);
  Future<bool> validate();
  Future<void> clearToken();
  Future<void> setToken(String? token);
  Future<void> setUser(User user);
  Future<void> saveUserEmail(String email);

  // Feed related operations
  Future<List<Feed>> getFeeds();
  Future<Feed> addFeed(String feedUrl);
  Future<Map<String, int>> getUnreadCounts();

  // Article related operations
  Future<List<Article>> getArticles(
      {String? feedId, bool unreadOnly = false, int limit = 100, int page = 1});
  Future<ArticleResponse> getAllArticles(
      {DateTime? since, String? continuation, int limit = 100});
  Future<void> markRead(String articleId);
  Future<void> markUnread(String articleId);
  Future<void> markAllRead({required String feedId, List<String>? articleIds});
  Future<void> star(String articleId);
  Future<void> unstar(String articleId);

  // Utility methods
  bool requiresAuth(String path) => true;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Restore token
    final savedToken = prefs.getString('${serviceType.name}_$tokenKey');
    if (savedToken != null) {
      token = savedToken;
      isLoggedIn = true;
    }

    // Restore user email
    final savedEmail = prefs.getString('${serviceType.name}_$userEmailKey');
    if (savedEmail != null) {
      user = User(email: savedEmail);
    }

    // Verify authentication status
    if (isLoggedIn && token != null) {
      try {
        final isValid = await validate();
        if (!isValid) {
          await clearToken();
        }
      } catch (e) {
        // Handle exceptions during validation without interrupting app startup
        debugPrint('Token validation failed: ${e.toString()}');
        // If validation fails, clear token but don't affect app startup
        await clearToken();
      }
    }
  }

  void dispose() {
    // Clean up resources
  }

  /// Unified method to create API client
  static Future<ApiClient> createClient(String service,
      {String? email, String? password}) async {
    // Get saved service type
    final savedServiceType = await getLastUsedServiceType();
    final normalizedService = service.toLowerCase().trim();
    final requestedServiceType = ServiceType.fromString(normalizedService);

    // If the requested service type is different from the saved one, update it
    if (requestedServiceType != savedServiceType) {
      await saveServiceType(requestedServiceType);
    } else {}

    // Create appropriate client based on service type
    switch (requestedServiceType) {
      case ServiceType.feedbin:
        return FeedbinApiClient(
          email: email ?? '',
          password: password ?? '',
        );
      case ServiceType.theOldReader:
        return TheOldReaderApiClient(
          email: email ?? '',
          password: password ?? '',
        );
    }
  }

  static Future<void> saveServiceType(ServiceType serviceType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(serviceTypeKey, serviceType.serviceId);
  }

  static Future<ServiceType> getLastUsedServiceType() async {
    final prefs = await SharedPreferences.getInstance();
    final serviceId = prefs.getString(serviceTypeKey);

    ServiceType serviceType;
    if (serviceId != null) {
      try {
        serviceType = ServiceType.values.firstWhere(
          (type) => type.serviceId.toLowerCase() == serviceId.toLowerCase(),
        );
      } catch (e) {
        serviceType = ServiceType.theOldReader;
        // Save default service type
        await saveServiceType(serviceType);
      }
    } else {
      serviceType = ServiceType.theOldReader;
      // Save default service type
      await saveServiceType(serviceType);
    }

    return serviceType;
  }
}
