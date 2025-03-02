import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pienews/generated/l10n.dart';
import 'package:pienews/models/service_type.dart';
import 'package:pienews/providers/auth_provider.dart';
import 'package:pienews/providers/feed_provider.dart';
import 'package:pienews/providers/font_provider.dart';
import 'package:pienews/providers/locale_provider.dart';
import 'package:pienews/providers/settings_provider.dart';
import 'package:pienews/providers/theme_provider.dart';
import 'package:pienews/screens/home_screen.dart';
import 'package:pienews/screens/login_screen.dart';
import 'package:pienews/services/api/api_client.dart';
import 'package:pienews/theme/app_theme.dart';
import 'package:pienews/utils/constants.dart';
import 'package:pienews/utils/routes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Read service type from local storage
  final localPrefs = await SharedPreferences.getInstance();
  final serviceTypeString = localPrefs.getString(StorageKeys.serviceType);
  ServiceType initialServiceType = ServiceType.theOldReader; // Default value
  if (serviceTypeString != null) {
    try {
      initialServiceType = ServiceType.values.firstWhere(
        (type) => type.serviceId == serviceTypeString,
        orElse: () => ServiceType.theOldReader,
      );
    } catch (e) {
      debugPrint(
          'Error parsing service type: $e, using default value ${initialServiceType.name}');
    }
  } else {
    debugPrint(
        'No saved service type found, using default value ${initialServiceType.name}');
  }

  // Create API client and use loaded service type
  final apiClient = await ApiClient.createClient(initialServiceType.serviceId);
  // Initialize API client, restore login status
  await apiClient.init();

  // Output login status information
  debugPrint(
      'App startup: Login status=${apiClient.isLoggedIn}, Service type=${apiClient.serviceType.name}');
  if (apiClient.user != null) {
    debugPrint('Logged in user: ${apiClient.user?.email}');
  }

  runApp(
    MultiProvider(
      providers: [
        // Create all providers in one place
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider<FeedProvider>(
          create: (context) => FeedProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FontProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // After app launch, ensure logged-in users automatically sync data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final isAuthenticated = authProvider.isAuthenticated;

      debugPrint('App initialization complete: Auth status=$isAuthenticated');

      if (isAuthenticated) {
        debugPrint('Starting data synchronization');
        context.read<FeedProvider>().syncWithServer().catchError((error) {
          debugPrint('Data sync failed: $error');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer3 to get all needed providers, ensuring rebuild on state changes
    return Consumer3<AuthProvider, ThemeProvider, FontProvider>(
      builder: (context, authProvider, themeProvider, fontProvider, _) {
        final brightness = themeProvider.themeMode == ThemeMode.system
            ? MediaQuery.platformBrightnessOf(context)
            : themeProvider.themeMode == ThemeMode.light
                ? Brightness.light
                : Brightness.dark;

        final isAuthenticated = authProvider.isAuthenticated;

        debugPrint('Building CupertinoApp: Auth status=$isAuthenticated');

        return CupertinoApp(
          title: 'PieNews',
          theme: AppTheme.getThemeData(
            context,
            fontProvider.fontScale,
            brightness: brightness,
          ),
          onGenerateRoute: AppRouter.generateRoute,
          home: isAuthenticated ? const HomeScreen() : const LoginScreen(),
          localizationsDelegates: const [
            S.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          locale: Provider.of<LocaleProvider>(context).locale,
        );
      },
    );
  }
}
