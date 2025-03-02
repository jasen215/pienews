import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pienews/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Test', () {
    testWidgets('Test Complete User Flow', (tester) async {
      // Start application
      app.main();
      await tester.pumpAndSettle();

      // Wait for application to load
      await tester.pump(const Duration(seconds: 2));

      // 1. Login Flow Test
      expect(find.text('Login'), findsOneWidget);

      // Find username and password fields
      final usernameField = find.byKey(const Key('username_field'));
      final passwordField = find.byKey(const Key('password_field'));

      // Enter test account information
      await tester.enterText(usernameField, 'test_user');
      await tester.enterText(passwordField, 'test_password');

      // Click login button
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // 2. Verify successful navigation to main screen
      expect(find.byType(CupertinoTabBar), findsOneWidget);

      // Wait for feeds to load
      await tester.pump(const Duration(seconds: 2));

      // 3. Test feed list
      // Verify feed list is displayed
      expect(find.byType(ListView), findsOneWidget);

      // Click the first feed
      final firstFeed = find.byType(CupertinoListTile).first;
      await tester.tap(firstFeed);
      await tester.pumpAndSettle();

      // 4. Test article list
      // Verify navigation to article list screen
      expect(find.byType(CupertinoNavigationBar), findsOneWidget);

      // Wait for articles to load
      await tester.pump(const Duration(seconds: 2));

      // Click the first article
      final firstArticle = find.byType(CupertinoListTile).first;
      await tester.tap(firstArticle);
      await tester.pumpAndSettle();

      // 5. Test article detail page
      // Verify article content is displayed
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Test mark as read/unread functionality
      final readButton = find.byKey(const Key('read_button'));
      await tester.tap(readButton);
      await tester.pumpAndSettle();

      // Test star functionality
      final starButton = find.byKey(const Key('star_button'));
      await tester.tap(starButton);
      await tester.pumpAndSettle();

      // 6. Return to article list
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();

      // 7. Test bottom navigation
      // Switch to starred tab
      await tester.tap(find.byIcon(CupertinoIcons.star));
      await tester.pumpAndSettle();

      // Switch to settings tab
      await tester.tap(find.byIcon(CupertinoIcons.settings));
      await tester.pumpAndSettle();

      // 8. Test logout
      final logoutButton = find.byKey(const Key('logout_button'));
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      // Verify return to login page
      expect(find.text('Login'), findsOneWidget);
    });
  });
}
