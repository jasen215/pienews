import 'package:flutter/cupertino.dart';
import 'package:pienews/generated/l10n.dart';
import 'package:pienews/providers/auth_provider.dart';
import 'package:pienews/providers/feed_provider.dart';
import 'package:pienews/providers/theme_provider.dart';
import 'package:pienews/screens/login_screen.dart';
import 'package:pienews/services/database/database_helper.dart';
import 'package:provider/provider.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  Widget _buildHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Text(
        title,
        style: TextStyle(
          color: CupertinoTheme.of(context)
              .textTheme
              .textStyle
              .color
              ?.withOpacity(0.6),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Clear database
      await DatabaseHelper.instance.clearAllData();
      if (!context.mounted) return;

      // Logout and clean authentication information
      await context.read<AuthProvider>().logout();
      if (!context.mounted) return;

      // Clear FeedProvider state
      context.read<FeedProvider>().clearAll();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text(S.of(context).error),
            content: Text(e.toString()),
            actions: [
              CupertinoDialogAction(
                child: Text(S.of(context).ok),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget _buildServiceInfo(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return CupertinoListTile(
      title: Text(S.of(context).currentService),
      trailing: Text(
        auth.currentService.name,
        style: const TextStyle(
          color: CupertinoColors.systemGrey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    final backgroundColor =
        isDarkMode ? CupertinoColors.black : CupertinoColors.systemGrey6;

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: CupertinoNavigationBar(
        middle: Text(S.of(context).accountSettings),
        backgroundColor: CupertinoColors.systemBackground,
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              CupertinoListSection.insetGrouped(
                header: _buildHeader(context, S.of(context).accountInfo),
                children: [
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) => Column(
                      children: [
                        _buildServiceInfo(context),
                        CupertinoListTile(
                          title: Text(S.of(context).email),
                          trailing: Text(
                            auth.user?.email ?? '',
                            style: const TextStyle(
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CupertinoButton(
                  onPressed: () async {
                    final shouldLogout = await showCupertinoDialog<bool>(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: Text(S.of(context).logout),
                        content: Text(S.of(context).confirmLogout),
                        actions: [
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(S.of(context).logout),
                          ),
                          CupertinoDialogAction(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(S.of(context).cancel),
                          ),
                        ],
                      ),
                    );

                    if (shouldLogout == true && context.mounted) {
                      await _handleLogout(context);
                    }
                  },
                  padding: EdgeInsets.zero,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.destructiveRed,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      S.of(context).logout,
                      style: const TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
