import 'package:flutter/cupertino.dart';
import 'package:pienews/models/article.dart';
import 'package:pienews/models/feed.dart';
import 'package:pienews/screens/account_settings_screen.dart';
import 'package:pienews/screens/article_detail_screen.dart';
import 'package:pienews/screens/article_list_screen.dart';
import 'package:pienews/screens/home_screen.dart';
import 'package:pienews/screens/login_screen.dart';
import 'package:pienews/screens/settings_screen.dart';

// Route names constants
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Route names
  static const String home = '/';
  static const String login = '/login';
  static const String settings = '/settings';
  static const String accountSettings = '/account_settings';
  static const String articleList = '/article_list';
  static const String articleDetail = '/article_detail';
}

// Router generator
class AppRouter {
  // Private constructor to prevent instantiation
  AppRouter._();

  // Generate routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return CupertinoPageRoute(
          builder: (_) => const HomeScreen(),
        );
      case AppRoutes.login:
        return CupertinoPageRoute(
          builder: (_) => const LoginScreen(),
        );
      case AppRoutes.settings:
        return CupertinoPageRoute(
          builder: (_) => const SettingsScreen(),
        );
      case AppRoutes.accountSettings:
        return CupertinoPageRoute(
          builder: (_) => const AccountSettingsScreen(),
        );
      case AppRoutes.articleList:
        final feed = settings.arguments as Feed;
        return CupertinoPageRoute(
          builder: (_) => ArticleListScreen(feed: feed),
        );
      case AppRoutes.articleDetail:
        final article = settings.arguments as Article;
        return CupertinoPageRoute(
          builder: (_) => ArticleDetailScreen(article: article),
        );
      default:
        return CupertinoPageRoute(
          builder: (_) => const HomeScreen(),
        );
    }
  }

  // Navigate to home
  static void navigateToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  // Navigate to login
  static void navigateToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  // Navigate to settings
  static void navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.settings);
  }

  // Navigate to account settings
  static void navigateToAccountSettings(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.accountSettings);
  }

  // Navigate to article list
  static void navigateToArticleList(BuildContext context, Feed feed) {
    Navigator.pushNamed(
      context,
      AppRoutes.articleList,
      arguments: feed,
    );
  }

  // Navigate to article detail
  static void navigateToArticleDetail(BuildContext context, Article article) {
    Navigator.pushNamed(
      context,
      AppRoutes.articleDetail,
      arguments: article,
    );
  }
}
