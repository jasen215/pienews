// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in the test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pienews/generated/l10n.dart';
import 'package:pienews/models/service_type.dart';
import 'package:pienews/providers/auth_provider.dart';
import 'package:pienews/providers/feed_provider.dart';
import 'package:pienews/providers/font_provider.dart';
import 'package:pienews/providers/locale_provider.dart';
import 'package:pienews/providers/settings_provider.dart';
import 'package:pienews/providers/theme_provider.dart';
import 'package:pienews/screens/login_screen.dart';
import 'package:pienews/services/api/api_client.dart';
import 'package:provider/provider.dart';

// Mock API client for testing
class MockApiClient extends Mock implements ApiClient {
  @override
  bool get isLoggedIn => false;

  @override
  ServiceType get serviceType => ServiceType.feedbin;
}

void main() {
  testWidgets('App starts with login screen', (WidgetTester tester) async {
    // Create mock API client
    final mockApiClient = MockApiClient();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => AuthProvider(apiClient: mockApiClient)),
          ChangeNotifierProvider(
              create: (_) => FeedProvider(apiClient: mockApiClient)),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => FontProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ],
        child: CupertinoApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: const LoginScreen(),
        ),
      ),
    );

    // Wait for app to load
    await tester.pumpAndSettle();

    // Verify if login screen is displayed
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(CupertinoTextField),
        findsNWidgets(2)); // Username and password fields
    expect(find.byType(CupertinoButton),
        findsAtLeast(1)); // At least one button (service selection or login)
  });
}
