import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:pienews/generated/l10n.dart';
import 'package:pienews/models/feed.dart';
import 'package:pienews/providers/auth_provider.dart';
import 'package:pienews/providers/feed_provider.dart';
import 'package:pienews/providers/settings_provider.dart';
import 'package:pienews/screens/article_list_screen.dart';
import 'package:pienews/screens/settings_screen.dart';
import 'package:pienews/widgets/filter_buttons.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Initialize FeedProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedProvider>().init(context);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels < -50 && !_isRefreshing) {
      _isRefreshing = true;
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        context.read<FeedProvider>().refresh(context).then((_) {
          _isRefreshing = false;
        }).catchError((error) {
          _isRefreshing = false;
          if (mounted) {
            showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: Text(S.of(context).error),
                content: Text(error.toString()),
                actions: [
                  CupertinoDialogAction(
                    child: Text(S.of(context).ok),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          }
        });
      } else {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              CupertinoSliverNavigationBar(
                largeTitle: Center(
                  child: Consumer<FeedProvider>(
                    builder: (context, feedProvider, _) {
                      final syncService = feedProvider.syncService;
                      return ValueListenableBuilder<String>(
                        valueListenable: syncService.syncStatus,
                        builder: (context, status, child) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'PieNews',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (status.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CupertinoActivityIndicator(
                                      radius: 8,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              status,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          ValueListenableBuilder<double>(
                                            valueListenable:
                                                syncService.syncProgress,
                                            builder:
                                                (context, progress, child) {
                                              if (progress <= 0) {
                                                return const SizedBox();
                                              }
                                              final percentage =
                                                  ((progress * 100)
                                                          .clamp(0, 100))
                                                      .toInt();
                                              return Text(
                                                ' ($percentage%)',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                leading: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.add),
                  onPressed: () async {
                    final feedUrl = await _showAddFeedDialog(context);
                    if (feedUrl != null && feedUrl.isNotEmpty) {
                      try {
                        if (!context.mounted) return;
                        _showLoading(context, S.of(context).addingFeed);

                        final feedProvider =
                            Provider.of<FeedProvider>(context, listen: false);
                        await feedProvider.addFeed(feedUrl);

                        if (!context.mounted) return;
                        Navigator.pop(context); // Close loading
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: Text(S.of(context).addSuccess),
                            content: Text(S.of(context).addSuccess),
                            actions: [
                              CupertinoDialogAction(
                                child: Text(S.of(context).ok),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        Navigator.pop(context); // Close loading
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: Text(S.of(context).error),
                            content: Text(S.of(context).addFailed),
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
                  },
                ),
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                border: null,
              ),
              Consumer2<FeedProvider, SettingsProvider>(
                builder: (context, feedProvider, settingsProvider, _) {
                  if (feedProvider.error != null) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(feedProvider.error!),
                            CupertinoButton(
                              onPressed: () {
                                final authProvider =
                                    context.read<AuthProvider>();
                                if (authProvider.isAuthenticated) {
                                  // Clear error status
                                  feedProvider.clearError();
                                  // Start refresh
                                  feedProvider.refresh(context);
                                }
                              },
                              child: Text(S.of(context).retry),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final groupedFeeds = feedProvider.groupedFeeds;
                  if (groupedFeeds.isEmpty) {
                    return SliverFillRemaining(
                      child:
                          Center(child: Text(S.of(context).noFeedsAvailable)),
                    );
                  }

                  // Filter out uncategorized groups (if not shown)
                  final displayGroups =
                      Map<String, List<Feed>>.from(groupedFeeds);
                  if (!settingsProvider.showUncategorized) {
                    displayGroups.remove('uncategorized');
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.only(bottom: 60),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final categories = displayGroups.keys.toList();
                          final category = categories[index ~/ 2];
                          final feeds = displayGroups[category]!;

                          // Group title
                          if (index % 2 == 0) {
                            return Container(
                              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: CupertinoColors.separator,
                                  ),
                                ),
                              ),
                              child: Text(
                                category == 'uncategorized'
                                    ? S.of(context).uncategorized
                                    : category,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }

                          // Feed list
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: feeds.length,
                            itemBuilder: (context, feedIndex) {
                              return _buildFeedTile(context, feeds[feedIndex]);
                            },
                          );
                        },
                        childCount: displayGroups.length * 2,
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 50),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: CupertinoTheme.of(context).barBackgroundColor,
                border: const Border(
                  top: BorderSide(
                    color: CupertinoColors.systemGrey4,
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(width: 60),
                    Consumer<FeedProvider>(
                      builder: (context, provider, _) => FilterButtons(
                        currentIndex: provider.filterIndex,
                        onFilterChanged: provider.setFilterIndex,
                        isArticleFilter: false,
                      ),
                    ),
                    const SizedBox(width: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _showAddFeedDialog(BuildContext context) async {
    String? feedUrl;

    return await showCupertinoDialog<String>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(S.of(context).addFeed),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: CupertinoTextField(
            placeholder: S.of(context).enterFeedUrl,
            onChanged: (value) => feedUrl = value,
            autofocus: true,
            clearButtonMode: OverlayVisibilityMode.editing,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(S.of(context).cancel),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: Text(S.of(context).add),
            onPressed: () => Navigator.pop(context, feedUrl),
          ),
        ],
      ),
    );
  }

  void _showLoading(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CupertinoActivityIndicator(),
              const SizedBox(height: 8),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultIcon(String title) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey5,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        title.isNotEmpty ? title[0].toUpperCase() : '?',
        style: const TextStyle(
          color: CupertinoColors.systemGrey,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFeedTile(BuildContext context, Feed feed) {
    final feedProvider = Provider.of<FeedProvider>(context);
    final displayCount = feedProvider.getDisplayCount(feed);

    return CupertinoListTile(
      leadingToTitle: 5,
      leading: CachedNetworkImage(
        width: 18,
        height: 18,
        imageUrl: feed.iconUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildDefaultIcon(feed.title),
        errorWidget: (context, url, error) => _buildDefaultIcon(feed.title),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(feed.title),
      ),
      trailing: displayCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: feedProvider.filterIndex == 0
                    ? CupertinoColors.systemYellow // Star filter uses yellow
                    : CupertinoColors.systemRed, // Other filters use red
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$displayCount',
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ArticleListScreen(feed: feed),
          ),
        );
      },
    );
  }
}
