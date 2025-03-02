// Mocks generated by Mockito 5.4.4 from annotations
// in pienews/test/unit/feed_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i8;

import 'package:http/http.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:pienews/models/article.dart' as _i9;
import 'package:pienews/models/feed.dart' as _i3;
import 'package:pienews/models/service_type.dart' as _i6;
import 'package:pienews/models/user.dart' as _i7;
import 'package:pienews/services/api/api_client.dart' as _i5;
import 'package:pienews/services/api/api_response.dart' as _i4;
import 'package:pienews/services/feed_service.dart' as _i10;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeResponse_0 extends _i1.SmartFake implements _i2.Response {
  _FakeResponse_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeFeed_1 extends _i1.SmartFake implements _i3.Feed {
  _FakeFeed_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeArticleResponse_2 extends _i1.SmartFake
    implements _i4.ArticleResponse {
  _FakeArticleResponse_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [ApiClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockApiClient extends _i1.Mock implements _i5.ApiClient {
  @override
  _i6.ServiceType get serviceType => (super.noSuchMethod(
        Invocation.getter(#serviceType),
        returnValue: _i6.ServiceType.feedbin,
        returnValueForMissingStub: _i6.ServiceType.feedbin,
      ) as _i6.ServiceType);

  @override
  set serviceType(_i6.ServiceType? _serviceType) => super.noSuchMethod(
        Invocation.setter(
          #serviceType,
          _serviceType,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set token(String? _token) => super.noSuchMethod(
        Invocation.setter(
          #token,
          _token,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set user(_i7.User? _user) => super.noSuchMethod(
        Invocation.setter(
          #user,
          _user,
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool get isLoggedIn => (super.noSuchMethod(
        Invocation.getter(#isLoggedIn),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  set isLoggedIn(bool? _isLoggedIn) => super.noSuchMethod(
        Invocation.setter(
          #isLoggedIn,
          _isLoggedIn,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i8.Future<_i2.Response> get(
    String? path, {
    Map<String, String>? queryParameters,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #get,
          [path],
          {#queryParameters: queryParameters},
        ),
        returnValue: _i8.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #get,
            [path],
            {#queryParameters: queryParameters},
          ),
        )),
        returnValueForMissingStub:
            _i8.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #get,
            [path],
            {#queryParameters: queryParameters},
          ),
        )),
      ) as _i8.Future<_i2.Response>);

  @override
  _i8.Future<_i2.Response> post(
    String? path, {
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #post,
          [path],
          {
            #body: body,
            #additionalHeaders: additionalHeaders,
          },
        ),
        returnValue: _i8.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #post,
            [path],
            {
              #body: body,
              #additionalHeaders: additionalHeaders,
            },
          ),
        )),
        returnValueForMissingStub:
            _i8.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #post,
            [path],
            {
              #body: body,
              #additionalHeaders: additionalHeaders,
            },
          ),
        )),
      ) as _i8.Future<_i2.Response>);

  @override
  _i8.Future<_i2.Response> put(
    String? path, {
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #put,
          [path],
          {
            #body: body,
            #additionalHeaders: additionalHeaders,
          },
        ),
        returnValue: _i8.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #put,
            [path],
            {
              #body: body,
              #additionalHeaders: additionalHeaders,
            },
          ),
        )),
        returnValueForMissingStub:
            _i8.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #put,
            [path],
            {
              #body: body,
              #additionalHeaders: additionalHeaders,
            },
          ),
        )),
      ) as _i8.Future<_i2.Response>);

  @override
  _i8.Future<_i2.Response> delete(
    String? path, {
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #delete,
          [path],
          {
            #body: body,
            #additionalHeaders: additionalHeaders,
          },
        ),
        returnValue: _i8.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #delete,
            [path],
            {
              #body: body,
              #additionalHeaders: additionalHeaders,
            },
          ),
        )),
        returnValueForMissingStub:
            _i8.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #delete,
            [path],
            {
              #body: body,
              #additionalHeaders: additionalHeaders,
            },
          ),
        )),
      ) as _i8.Future<_i2.Response>);

  @override
  _i8.Future<void> login(
    String? email,
    String? password,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #login,
          [
            email,
            password,
          ],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<bool> validate() => (super.noSuchMethod(
        Invocation.method(
          #validate,
          [],
        ),
        returnValue: _i8.Future<bool>.value(false),
        returnValueForMissingStub: _i8.Future<bool>.value(false),
      ) as _i8.Future<bool>);

  @override
  _i8.Future<void> clearToken() => (super.noSuchMethod(
        Invocation.method(
          #clearToken,
          [],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<void> setToken(String? token) => (super.noSuchMethod(
        Invocation.method(
          #setToken,
          [token],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<void> setUser(_i7.User? user) => (super.noSuchMethod(
        Invocation.method(
          #setUser,
          [user],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<void> saveUserEmail(String? email) => (super.noSuchMethod(
        Invocation.method(
          #saveUserEmail,
          [email],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<List<_i3.Feed>> getFeeds() => (super.noSuchMethod(
        Invocation.method(
          #getFeeds,
          [],
        ),
        returnValue: _i8.Future<List<_i3.Feed>>.value(<_i3.Feed>[]),
        returnValueForMissingStub:
            _i8.Future<List<_i3.Feed>>.value(<_i3.Feed>[]),
      ) as _i8.Future<List<_i3.Feed>>);

  @override
  _i8.Future<_i3.Feed> addFeed(String? feedUrl) => (super.noSuchMethod(
        Invocation.method(
          #addFeed,
          [feedUrl],
        ),
        returnValue: _i8.Future<_i3.Feed>.value(_FakeFeed_1(
          this,
          Invocation.method(
            #addFeed,
            [feedUrl],
          ),
        )),
        returnValueForMissingStub: _i8.Future<_i3.Feed>.value(_FakeFeed_1(
          this,
          Invocation.method(
            #addFeed,
            [feedUrl],
          ),
        )),
      ) as _i8.Future<_i3.Feed>);

  @override
  _i8.Future<Map<String, int>> getUnreadCounts() => (super.noSuchMethod(
        Invocation.method(
          #getUnreadCounts,
          [],
        ),
        returnValue: _i8.Future<Map<String, int>>.value(<String, int>{}),
        returnValueForMissingStub:
            _i8.Future<Map<String, int>>.value(<String, int>{}),
      ) as _i8.Future<Map<String, int>>);

  @override
  _i8.Future<List<_i9.Article>> getArticles({
    String? feedId,
    bool? unreadOnly = false,
    int? limit = 100,
    int? page = 1,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #getArticles,
          [],
          {
            #feedId: feedId,
            #unreadOnly: unreadOnly,
            #limit: limit,
            #page: page,
          },
        ),
        returnValue: _i8.Future<List<_i9.Article>>.value(<_i9.Article>[]),
        returnValueForMissingStub:
            _i8.Future<List<_i9.Article>>.value(<_i9.Article>[]),
      ) as _i8.Future<List<_i9.Article>>);

  @override
  _i8.Future<_i4.ArticleResponse> getAllArticles({
    DateTime? since,
    String? continuation,
    int? limit = 100,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #getAllArticles,
          [],
          {
            #since: since,
            #continuation: continuation,
            #limit: limit,
          },
        ),
        returnValue:
            _i8.Future<_i4.ArticleResponse>.value(_FakeArticleResponse_2(
          this,
          Invocation.method(
            #getAllArticles,
            [],
            {
              #since: since,
              #continuation: continuation,
              #limit: limit,
            },
          ),
        )),
        returnValueForMissingStub:
            _i8.Future<_i4.ArticleResponse>.value(_FakeArticleResponse_2(
          this,
          Invocation.method(
            #getAllArticles,
            [],
            {
              #since: since,
              #continuation: continuation,
              #limit: limit,
            },
          ),
        )),
      ) as _i8.Future<_i4.ArticleResponse>);

  @override
  _i8.Future<void> markRead(String? articleId) => (super.noSuchMethod(
        Invocation.method(
          #markRead,
          [articleId],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<void> markUnread(String? articleId) => (super.noSuchMethod(
        Invocation.method(
          #markUnread,
          [articleId],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<void> markAllRead({
    required String? feedId,
    List<String>? articleIds,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #markAllRead,
          [],
          {
            #feedId: feedId,
            #articleIds: articleIds,
          },
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<void> star(String? articleId) => (super.noSuchMethod(
        Invocation.method(
          #star,
          [articleId],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<void> unstar(String? articleId) => (super.noSuchMethod(
        Invocation.method(
          #unstar,
          [articleId],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  bool requiresAuth(String? path) => (super.noSuchMethod(
        Invocation.method(
          #requiresAuth,
          [path],
        ),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  _i8.Future<void> init() => (super.noSuchMethod(
        Invocation.method(
          #init,
          [],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [FeedService].
///
/// See the documentation for Mockito's code generation for more information.
class MockFeedService extends _i1.Mock implements _i10.FeedService {
  @override
  _i8.Future<List<_i3.Feed>> getFeeds() => (super.noSuchMethod(
        Invocation.method(
          #getFeeds,
          [],
        ),
        returnValue: _i8.Future<List<_i3.Feed>>.value(<_i3.Feed>[]),
        returnValueForMissingStub:
            _i8.Future<List<_i3.Feed>>.value(<_i3.Feed>[]),
      ) as _i8.Future<List<_i3.Feed>>);

  @override
  _i8.Future<List<_i9.Article>> getArticles(String? feedId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getArticles,
          [feedId],
        ),
        returnValue: _i8.Future<List<_i9.Article>>.value(<_i9.Article>[]),
        returnValueForMissingStub:
            _i8.Future<List<_i9.Article>>.value(<_i9.Article>[]),
      ) as _i8.Future<List<_i9.Article>>);

  @override
  _i8.Future<_i9.Article?> getArticle(String? articleId) => (super.noSuchMethod(
        Invocation.method(
          #getArticle,
          [articleId],
        ),
        returnValue: _i8.Future<_i9.Article?>.value(),
        returnValueForMissingStub: _i8.Future<_i9.Article?>.value(),
      ) as _i8.Future<_i9.Article?>);

  @override
  _i8.Future<Map<String, int>> getUnreadCounts() => (super.noSuchMethod(
        Invocation.method(
          #getUnreadCounts,
          [],
        ),
        returnValue: _i8.Future<Map<String, int>>.value(<String, int>{}),
        returnValueForMissingStub:
            _i8.Future<Map<String, int>>.value(<String, int>{}),
      ) as _i8.Future<Map<String, int>>);

  @override
  _i8.Future<void> updateUnreadCounts(Map<String, int>? unreadCounts) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateUnreadCounts,
          [unreadCounts],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<void> syncFeeds() => (super.noSuchMethod(
        Invocation.method(
          #syncFeeds,
          [],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<void> syncArticles(String? feedId) => (super.noSuchMethod(
        Invocation.method(
          #syncArticles,
          [feedId],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<void> syncData(String? feedId) => (super.noSuchMethod(
        Invocation.method(
          #syncData,
          [feedId],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<void> markArticleAsRead(String? articleId) => (super.noSuchMethod(
        Invocation.method(
          #markArticleAsRead,
          [articleId],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<void> markArticleAsUnread(String? articleId) =>
      (super.noSuchMethod(
        Invocation.method(
          #markArticleAsUnread,
          [articleId],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<void> markAllAsRead(
    String? feedId,
    List<String>? articleIds,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #markAllAsRead,
          [
            feedId,
            articleIds,
          ],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<void> toggleArticleStarred(String? articleId) =>
      (super.noSuchMethod(
        Invocation.method(
          #toggleArticleStarred,
          [articleId],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<_i3.Feed> addSubscription(String? feedUrl) => (super.noSuchMethod(
        Invocation.method(
          #addSubscription,
          [feedUrl],
        ),
        returnValue: _i8.Future<_i3.Feed>.value(_FakeFeed_1(
          this,
          Invocation.method(
            #addSubscription,
            [feedUrl],
          ),
        )),
        returnValueForMissingStub: _i8.Future<_i3.Feed>.value(_FakeFeed_1(
          this,
          Invocation.method(
            #addSubscription,
            [feedUrl],
          ),
        )),
      ) as _i8.Future<_i3.Feed>);

  @override
  _i8.Future<_i3.Feed> addFeed(String? feedUrl) => (super.noSuchMethod(
        Invocation.method(
          #addFeed,
          [feedUrl],
        ),
        returnValue: _i8.Future<_i3.Feed>.value(_FakeFeed_1(
          this,
          Invocation.method(
            #addFeed,
            [feedUrl],
          ),
        )),
        returnValueForMissingStub: _i8.Future<_i3.Feed>.value(_FakeFeed_1(
          this,
          Invocation.method(
            #addFeed,
            [feedUrl],
          ),
        )),
      ) as _i8.Future<_i3.Feed>);

  @override
  _i8.Future<void> saveFeeds(List<_i3.Feed>? feeds) => (super.noSuchMethod(
        Invocation.method(
          #saveFeeds,
          [feeds],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<void> saveArticles(
    String? feedId,
    List<_i9.Article>? articles,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #saveArticles,
          [
            feedId,
            articles,
          ],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<Map<String, Map<String, int>>> getUnreadAndStarredCounts() =>
      (super.noSuchMethod(
        Invocation.method(
          #getUnreadAndStarredCounts,
          [],
        ),
        returnValue: _i8.Future<Map<String, Map<String, int>>>.value(
            <String, Map<String, int>>{}),
        returnValueForMissingStub:
            _i8.Future<Map<String, Map<String, int>>>.value(
                <String, Map<String, int>>{}),
      ) as _i8.Future<Map<String, Map<String, int>>>);

  @override
  _i8.Future<void> updateUnreadAndStarredCounts(
          Map<String, Map<String, int>>? counts) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateUnreadAndStarredCounts,
          [counts],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<void> verifyFeedCounts() => (super.noSuchMethod(
        Invocation.method(
          #verifyFeedCounts,
          [],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<void> updateFeed(_i9.Article? article) => (super.noSuchMethod(
        Invocation.method(
          #updateFeed,
          [article],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);
}
