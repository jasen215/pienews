import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pienews/models/article.dart';
import 'package:pienews/models/feed.dart';
import 'package:pienews/services/api/api_client.dart';
import 'package:pienews/services/api/feed_service.dart';
import 'package:pienews/services/feed_service.dart';

import 'feed_service_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ApiClient>(),
  MockSpec<FeedService>(),
])
void main() {
  late ApiFeedService feedService;
  late ApiClient mockApiClient;
  late FeedService mockLocalService;

  setUp(() {
    mockApiClient = MockApiClient();
    mockLocalService = MockFeedService();
    feedService = ApiFeedService(
      apiClient: mockApiClient,
      localService: mockLocalService,
    );
  });

  group('ApiFeedService', () {
    group('getFeeds', () {
      test(
          'should return feeds from API and save them locally when API call succeeds',
          () async {
        // Arrange
        final testFeeds = [
          Feed(
            id: '1',
            title: 'Test Feed 1',
            description: 'Description 1',
            iconUrl: 'icon1.png',
            unreadCount: 5,
            starredCount: 2,
            url: 'https://example.com/feed1',
            category: 'test',
          ),
          Feed(
            id: '2',
            title: 'Test Feed 2',
            description: 'Description 2',
            iconUrl: 'icon2.png',
            unreadCount: 3,
            starredCount: 1,
            url: 'https://example.com/feed2',
            category: 'test',
          ),
        ];

        when(mockApiClient.getFeeds()).thenAnswer((_) async => testFeeds);
        when(mockLocalService.saveFeeds(testFeeds)).thenAnswer((_) async {});

        // Act
        final result = await feedService.getFeeds();

        // Assert
        expect(result, equals(testFeeds));
        verify(mockApiClient.getFeeds()).called(1);
        verify(mockLocalService.saveFeeds(testFeeds)).called(1);
      });

      test('should return feeds from local service when API call fails',
          () async {
        // Arrange
        final testFeeds = [
          Feed(
            id: '1',
            title: 'Local Feed 1',
            description: 'Local Description 1',
            iconUrl: 'local_icon1.png',
            unreadCount: 2,
            starredCount: 1,
            url: 'https://example.com/local1',
            category: 'test',
          ),
        ];

        when(mockApiClient.getFeeds()).thenThrow(Exception('API Error'));
        when(mockLocalService.getFeeds()).thenAnswer((_) async => testFeeds);

        // Act
        final result = await feedService.getFeeds();

        // Assert
        expect(result, equals(testFeeds));
        verify(mockApiClient.getFeeds()).called(1);
        verify(mockLocalService.getFeeds()).called(1);
      });
    });

    group('getArticles', () {
      const testFeedId = '1';

      test(
          'should return articles from API and save them locally when API call succeeds',
          () async {
        // Arrange
        final testArticles = [
          Article(
            id: '1',
            feedId: testFeedId,
            title: 'Test Article 1',
            content: 'Content 1',
            url: 'https://example.com/article1',
            publishedAt: DateTime.now(),
            isRead: false,
            isStarred: false,
            feedTitle: 'Feed 1',
          ),
        ];

        when(mockApiClient.getArticles(feedId: testFeedId))
            .thenAnswer((_) async => testArticles);
        when(mockLocalService.saveArticles(testFeedId, testArticles))
            .thenAnswer((_) async {});

        // Act
        final result = await feedService.getArticles(testFeedId);

        // Assert
        expect(result, equals(testArticles));
        verify(mockApiClient.getArticles(feedId: testFeedId)).called(1);
        verify(mockLocalService.saveArticles(testFeedId, testArticles))
            .called(1);
      });

      test('should return articles from local service when API call fails',
          () async {
        // Arrange
        final testArticles = [
          Article(
            id: '1',
            feedId: testFeedId,
            title: 'Local Article 1',
            content: 'Local Content 1',
            url: 'https://example.com/local_article1',
            publishedAt: DateTime.now(),
            isRead: false,
            isStarred: false,
            feedTitle: 'Local Feed 1',
          ),
        ];

        when(mockApiClient.getArticles(feedId: testFeedId))
            .thenThrow(Exception('API Error'));
        when(mockLocalService.getArticles(testFeedId))
            .thenAnswer((_) async => testArticles);

        // Act
        final result = await feedService.getArticles(testFeedId);

        // Assert
        expect(result, equals(testArticles));
        verify(mockApiClient.getArticles(feedId: testFeedId)).called(1);
        verify(mockLocalService.getArticles(testFeedId)).called(1);
      });
    });
  });
}
