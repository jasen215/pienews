import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:pienews/generated/l10n.dart';
import 'package:pienews/models/feed.dart';
import 'package:pienews/providers/feed_provider.dart';
import 'package:pienews/providers/font_provider.dart';
import 'package:pienews/screens/article_detail_screen.dart';
import 'package:pienews/widgets/filter_buttons.dart';
import 'package:provider/provider.dart';

class ArticleListScreen extends StatefulWidget {
  final Feed feed;

  const ArticleListScreen({super.key, required this.feed});

  @override
  State<ArticleListScreen> createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends State<ArticleListScreen> {
  final ScrollController _scrollController = ScrollController();
  int? _lastFilterIndex;

  @override
  void initState() {
    super.initState();

    _lastFilterIndex = context.read<FeedProvider>().filterIndex;

    // Load articles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final feedProvider = context.read<FeedProvider>();

      // If not loading, start loading articles
      if (!feedProvider.isLoading) {
        feedProvider.fetchArticles(widget.feed.id);
      } else {}
    });
  }

  @override
  void didUpdateWidget(covariant ArticleListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentFilterIndex = context.read<FeedProvider>().filterIndex;
    if (_lastFilterIndex != currentFilterIndex) {
      _lastFilterIndex = currentFilterIndex;
      // Use post frame callback to avoid calling setState in build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final feedProvider = context.read<FeedProvider>();
        if (!feedProvider.isLoading) {
          feedProvider.fetchArticles(widget.feed.id);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = CupertinoTheme.of(context).textTheme.textStyle.color;
    final secondaryTextColor = textColor?.withOpacity(0.8);

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              CupertinoSliverNavigationBar(
                largeTitle: Center(
                  child: Text(
                    widget.feed.title,
                    style: const TextStyle(
                      // fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                // middle: Text(
                //   widget.feed.title,
                //   style: const TextStyle(
                //     fontSize: 17,
                //   ),
                //   overflow: TextOverflow.ellipsis,
                // ),
                border: null,
              ),
              CupertinoSliverRefreshControl(
                onRefresh: () async {
                  await context.read<FeedProvider>().refreshFeed(widget.feed);
                },
              ),
              Consumer<FeedProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const SliverFillRemaining(
                      child: Center(child: CupertinoActivityIndicator()),
                    );
                  }

                  if (provider.filteredArticles.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(child: Text(S.of(context).noArticles)),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.only(bottom: 60),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final article = provider.filteredArticles[index];
                          return Consumer<FontProvider>(
                            builder: (context, fontProvider, _) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) =>
                                          ArticleDetailScreen(article: article),
                                    ),
                                  );
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                        right: 8,
                                        top: 15,
                                      ),
                                      child: CachedNetworkImage(
                                        width: 18,
                                        height: 18,
                                        imageUrl: widget.feed.iconUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const Icon(
                                          CupertinoIcons.news,
                                          color: CupertinoColors.systemBlue,
                                          size: 18,
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(
                                          CupertinoIcons.news,
                                          color: CupertinoColors.systemBlue,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                article.feedTitle,
                                                style: TextStyle(
                                                  fontSize: 10 *
                                                      fontProvider.fontScale,
                                                  color: secondaryTextColor
                                                      ?.withOpacity(0.4),
                                                ),
                                              ),
                                              Text(
                                                _formatDate(
                                                    article.publishedAt),
                                                style: TextStyle(
                                                  fontSize: 10 *
                                                      fontProvider.fontScale,
                                                  color: secondaryTextColor
                                                      ?.withOpacity(0.4),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            article.title,
                                            style: TextStyle(
                                              fontSize:
                                                  14 * fontProvider.fontScale,
                                              color: article.isRead
                                                  ? secondaryTextColor
                                                      ?.withOpacity(0.5)
                                                  : textColor,
                                            ),
                                          ),
                                          if (article.summary != null) ...[
                                            Text(
                                              article.summary!,
                                              style: TextStyle(
                                                fontSize:
                                                    14 * fontProvider.fontScale,
                                                color: article.isRead
                                                    ? secondaryTextColor
                                                        ?.withOpacity(0.2)
                                                    : secondaryTextColor
                                                        ?.withOpacity(0.4),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: provider.filteredArticles.length,
                      ),
                    ),
                  );
                },
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
                    CupertinoButton(
                      padding: const EdgeInsets.all(12),
                      onPressed: _markAllAsRead,
                      child: Icon(
                        CupertinoIcons.check_mark_circled,
                        color: textColor?.withOpacity(0.6),
                      ),
                    ),
                    Consumer<FeedProvider>(
                      builder: (context, provider, _) => FilterButtons(
                        currentIndex: provider.filterIndex,
                        onFilterChanged: provider.setFilterIndex,
                        isArticleFilter: true,
                      ),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        CupertinoIcons.refresh,
                        color: textColor?.withOpacity(0.6),
                      ),
                      onPressed: () {
                        context
                            .read<FeedProvider>()
                            .fetchArticles(widget.feed.id);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return S.of(context).minutesAgo(difference.inMinutes);
      }
      return S.of(context).hoursAgo(difference.inHours);
    } else if (difference.inDays < 30) {
      return S.of(context).daysAgo(difference.inDays);
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final feedProvider = context.read<FeedProvider>();
      // Mark all articles of current feed as read, and get next unread feed
      final nextUnreadFeed = await feedProvider.markAllAsRead(widget.feed.id);

      if (nextUnreadFeed != null && mounted) {
        // Load articles of new feed before redirecting
        await feedProvider.fetchArticles(nextUnreadFeed.id);

        // Wait one frame to ensure data is loaded
        await Future.microtask(() {});

        if (mounted) {
          // If next unread feed is found, use pushReplacement for page redirect
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => ArticleListScreen(feed: nextUnreadFeed),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text(S.of(context).error),
            content: Text(e.toString()),
            actions: [
              CupertinoDialogAction(
                child: Text(S.of(context).confirm),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }
}
