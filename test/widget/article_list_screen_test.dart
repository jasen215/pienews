import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pienews/generated/l10n.dart';
import 'package:pienews/models/article.dart';
import 'package:pienews/models/feed.dart';
import 'package:pienews/providers/feed_provider.dart';
import 'package:pienews/providers/font_provider.dart';
import 'package:pienews/screens/article_list_screen.dart';
import 'package:provider/provider.dart';

import 'article_list_screen_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FeedProvider>(),
  MockSpec<FontProvider>(),
])
void main() {
  late MockFeedProvider mockFeedProvider;
  late MockFontProvider mockFontProvider;
  late Feed testFeed;

  setUp(() {
    mockFeedProvider = MockFeedProvider();
    mockFontProvider = MockFontProvider();
    testFeed = Feed(
      id: '1',
      title: 'Test Feed',
      description: 'Test Description',
      iconUrl: 'icon.png',
      url: 'https://example.com/feed',
      unreadCount: 0,
      starredCount: 0,
      category: 'test',
    );

    when(mockFontProvider.fontScale).thenReturn(1.0);
  });

  Widget createTestApp(Widget child) {
    return CupertinoApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<FeedProvider>.value(value: mockFeedProvider),
          ChangeNotifierProvider<FontProvider>.value(value: mockFontProvider),
        ],
        child: child,
      ),
    );
  }

  testWidgets('ArticleListScreen shows loading indicator when loading',
      (WidgetTester tester) async {
    // Arrange
    when(mockFeedProvider.isLoading).thenReturn(true);
    when(mockFeedProvider.filteredArticles).thenReturn([]);

    // Act
    await tester.pumpWidget(createTestApp(ArticleListScreen(feed: testFeed)));
    await tester.pump();

    // Assert
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
  });

  testWidgets('ArticleListScreen shows articles when loaded',
      (WidgetTester tester) async {
    // Arrange
    final testArticles = [
      Article(
        id: '1',
        feedId: '1',
        title: 'Test Article 1',
        content: 'Content 1',
        url: 'https://example.com/1',
        publishedAt: DateTime.now(),
        isRead: false,
        isStarred: false,
        feedTitle: 'Test Feed',
      ),
      Article(
        id: '2',
        feedId: '1',
        title: 'Test Article 2',
        content: 'Content 2',
        url: 'https://example.com/2',
        publishedAt: DateTime.now(),
        isRead: true,
        isStarred: true,
        feedTitle: 'Test Feed',
      ),
    ];

    when(mockFeedProvider.isLoading).thenReturn(false);
    when(mockFeedProvider.filteredArticles).thenReturn(testArticles);

    // Act
    await tester.pumpWidget(createTestApp(ArticleListScreen(feed: testFeed)));
    await tester.pump();

    // Assert
    expect(find.text('Test Article 1'), findsOneWidget);
    expect(find.text('Test Article 2'), findsOneWidget);
  });

  testWidgets('ArticleListScreen shows empty message when no articles',
      (WidgetTester tester) async {
    // Arrange
    when(mockFeedProvider.isLoading).thenReturn(false);
    when(mockFeedProvider.filteredArticles).thenReturn([]);

    // Act
    await tester.pumpWidget(createTestApp(ArticleListScreen(feed: testFeed)));
    await tester.pump();

    // Assert
    expect(find.text('No articles'), findsOneWidget);
  });
}
