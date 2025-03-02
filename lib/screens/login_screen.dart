import 'dart:async' show unawaited;

import 'package:flutter/cupertino.dart';
import 'package:pienews/generated/l10n.dart';
import 'package:pienews/models/service_type.dart';
import 'package:pienews/providers/auth_provider.dart';
import 'package:pienews/providers/feed_provider.dart';
import 'package:pienews/screens/home_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  ServiceType _selectedService =
      ServiceType.feedbin; // Default to Feedbin service

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _showServicePicker(BuildContext context) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          S.of(context).selectFeedService,
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedService = ServiceType.feedbin;
              });
            },
            isDefaultAction: _selectedService == ServiceType.feedbin,
            child: const Text(
              'Feedbin',
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedService = ServiceType.theOldReader;
              });
            },
            isDefaultAction: _selectedService == ServiceType.theOldReader,
            child: const Text(
              'The Old Reader',
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(S.of(context).cancel),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_isLoading) {
      return;
    }

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showError('Please enter username and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Switch to selected service
      final auth = context.read<AuthProvider>();
      await auth.switchService(_selectedService);

      // Then login
      await auth.login(username, password);

      // Start syncing data
      if (mounted) {
        final feedProvider = context.read<FeedProvider>();
        // Sync data in background
        unawaited(
            feedProvider.syncWithServer().then((_) {}).catchError((e) {}));
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(S.of(context).error),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text(S.of(context).ok),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final backgroundColor =
        isDarkMode ? CupertinoColors.black : CupertinoColors.systemBackground;

    return CupertinoPageScaffold(
      key: const Key('login_screen'),
      backgroundColor: backgroundColor,
      navigationBar: CupertinoNavigationBar(
        middle: Text(S.of(context).login),
        backgroundColor: backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode
                ? CupertinoColors.systemGrey.withOpacity(0.3)
                : CupertinoColors.systemGrey4,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showServicePicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: CupertinoColors.systemGrey4,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.globe,
                        color: CupertinoColors.systemGrey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedService.name,
                          style: const TextStyle(
                            color: CupertinoColors.systemGrey4,
                          ),
                        ),
                      ),
                      const Icon(
                        CupertinoIcons.chevron_down,
                        color: CupertinoColors.systemGrey,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _usernameController,
                placeholder: S.of(context).username,
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    CupertinoIcons.person,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoColors.systemGrey4,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _passwordController,
                placeholder: S.of(context).password,
                obscureText: true,
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    CupertinoIcons.lock,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoColors.systemGrey4,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 24),
              CupertinoButton.filled(
                onPressed: _isLoading ? null : _login,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: CupertinoActivityIndicator(),
                      ),
                    !_isLoading
                        ? Text(S.of(context).login)
                        : Text(
                            S.of(context).login,
                            style: const TextStyle(
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
