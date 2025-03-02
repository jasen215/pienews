import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pienews/generated/l10n.dart';
import 'package:pienews/providers/font_provider.dart';
import 'package:pienews/providers/locale_provider.dart';
import 'package:pienews/providers/settings_provider.dart';
import 'package:pienews/providers/theme_provider.dart';
import 'package:pienews/screens/account_settings_screen.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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

  String _getLanguageLabel(BuildContext context, String locale) {
    switch (locale) {
      case 'system':
        return S.of(context).followSystem;
      case 'en_US':
        return S.of(context).english;
      case 'zh_CN':
        return S.of(context).simplifiedChinese;
      default:
        return locale;
    }
  }

  String _getThemeLabel(BuildContext context, ThemeMode themeMode) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.getThemeLabel(context);
  }

  void _showThemeSelector(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(S.of(context).theme),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              themeProvider.setThemeMode(ThemeMode.system);
              Navigator.pop(context);
            },
            isDefaultAction: themeProvider.themeMode == ThemeMode.system,
            child: Text(S.of(context).followSystem),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              themeProvider.setThemeMode(ThemeMode.light);
              Navigator.pop(context);
            },
            isDefaultAction: themeProvider.themeMode == ThemeMode.light,
            child: Text(S.of(context).light),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              themeProvider.setThemeMode(ThemeMode.dark);
              Navigator.pop(context);
            },
            isDefaultAction: themeProvider.themeMode == ThemeMode.dark,
            child: Text(S.of(context).dark),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).cancel),
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(S.of(context).language),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              localeProvider.setLocale('system');
              Navigator.pop(context);
            },
            isDefaultAction: localeProvider.currentLocale == 'system',
            child: Text(S.of(context).followSystem),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              localeProvider.setLocale('en_US');
              Navigator.pop(context);
            },
            isDefaultAction: localeProvider.currentLocale == 'en_US',
            child: Text(S.of(context).english),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              localeProvider.setLocale('zh_CN');
              Navigator.pop(context);
            },
            isDefaultAction: localeProvider.currentLocale == 'zh_CN',
            child: Text(S.of(context).simplifiedChinese),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).cancel),
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
        middle: Text(S.of(context).settings),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CupertinoListSection.insetGrouped(
                header: _buildHeader(context, S.of(context).account),
                children: [
                  CupertinoListTile(
                    title: Text(S.of(context).accountSettings),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const AccountSettingsScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              CupertinoListSection.insetGrouped(
                header: _buildHeader(context, S.of(context).readingPreferences),
                children: [
                  Consumer<FontProvider>(
                    builder: (context, fontProvider, _) => Column(
                      children: [
                        CupertinoListTile(
                          title: Text(S.of(context).fontSize),
                          trailing: Text(
                            fontProvider.getFontSizeLabel(context),
                            style: const TextStyle(
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              const Text('A', style: TextStyle(fontSize: 14)),
                              Expanded(
                                child: CupertinoSlider(
                                  value: fontProvider.fontScale,
                                  min: fontProvider.minFontSize,
                                  max: fontProvider.maxFontSize,
                                  onChanged: (value) {
                                    fontProvider.setFontSize(value);
                                  },
                                ),
                              ),
                              const Text('A', style: TextStyle(fontSize: 20)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) => CupertinoListTile(
                      title: Text(S.of(context).theme),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getThemeLabel(context, themeProvider.themeMode),
                            style: const TextStyle(
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          const CupertinoListTileChevron(),
                        ],
                      ),
                      onTap: () => _showThemeSelector(context),
                    ),
                  ),
                  Consumer<LocaleProvider>(
                    builder: (context, localeProvider, _) => CupertinoListTile(
                      title: Text(S.of(context).language),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getLanguageLabel(
                                context, localeProvider.currentLocale),
                            style: const TextStyle(
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          const CupertinoListTileChevron(),
                        ],
                      ),
                      onTap: () => _showLanguageSelector(context),
                    ),
                  ),
                ],
              ),
              CupertinoListSection.insetGrouped(
                header: _buildHeader(context, S.of(context).displaySettings),
                children: [
                  Consumer<SettingsProvider>(
                    builder: (context, settings, _) => CupertinoListTile(
                      title: Text(S.of(context).showUncategorized),
                      trailing: CupertinoSwitch(
                        value: settings.showUncategorized,
                        onChanged: settings.setShowUncategorized,
                      ),
                    ),
                  ),
                ],
              ),
              CupertinoListSection.insetGrouped(
                header: _buildHeader(context, S.of(context).about),
                children: [
                  CupertinoListTile(
                    title: Text(S.of(context).version),
                    trailing: FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data?.version ?? '',
                          style: const TextStyle(
                            color: CupertinoColors.systemGrey,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
