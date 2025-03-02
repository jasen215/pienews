import 'package:flutter/cupertino.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pienews/generated/l10n.dart';
import 'package:pienews/models/article.dart';
import 'package:pienews/providers/feed_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({
    super.key,
    required this.article,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Delay execution to ensure Provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FeedProvider>();
      if (!widget.article.isRead) {
        provider.toggleArticleRead(widget.article.id);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl() async {
    if (widget.article.url == null) return;

    final uri = Uri.parse(widget.article.url!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = CupertinoTheme.of(context).textTheme.textStyle.color;
    final secondaryTextColor = textColor?.withOpacity(0.8);
    final isDarkMode =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final backgroundColor =
        isDarkMode ? CupertinoColors.black : CupertinoColors.systemBackground;

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.article.feedTitle),
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
      child: Column(
        children: [
          Expanded(
            child: CupertinoScrollbar(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 80,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: widget.article.url != null ? _launchUrl : null,
                        child: Text(
                          widget.article.title,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: CupertinoTheme.of(context)
                                .textTheme
                                .textStyle
                                .color,
                            decoration: null,
                          ),
                        ),
                      ),
                      if (widget.article.author != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.article.feedTitle,
                          style: TextStyle(
                            color: CupertinoTheme.of(context)
                                .textTheme
                                .textStyle
                                .color
                                ?.withOpacity(0.4),
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Container(
                        height: 1,
                        color: CupertinoColors.separator,
                      ),
                      const SizedBox(height: 16),
                      HtmlWidget(
                        widget.article.content ??
                            widget.article.summary ??
                            S.of(context).noContent,
                        textStyle: TextStyle(
                          fontSize: 18,
                          color: secondaryTextColor?.withOpacity(0.6),
                          fontWeight: FontWeight.normal,
                        ),
                        onTapUrl: (url) async {
                          final uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                          return true;
                        },
                        customStylesBuilder: (element) {
                          if (element.localName == 'a') {
                            return {
                              'color': '#007AFF',
                              'text-decoration': 'none',
                            };
                          }
                          return null;
                        },
                        onTapImage: (ImageMetadata image) {
                          showCupertinoModalPopup(
                            context: context,
                            builder: (context) => Container(
                              color: CupertinoColors.black,
                              child: SafeArea(
                                child: Stack(
                                  children: [
                                    PhotoView(
                                      imageProvider:
                                          NetworkImage(image.sources.first.url),
                                      minScale:
                                          PhotoViewComputedScale.contained,
                                      maxScale:
                                          PhotoViewComputedScale.covered * 2,
                                      backgroundDecoration: const BoxDecoration(
                                        color: CupertinoColors.black,
                                      ),
                                      loadingBuilder: (context, event) =>
                                          const Center(
                                        child: CupertinoActivityIndicator(),
                                      ),
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Center(
                                        child: Text(
                                          S.of(context).loadingImageError,
                                          style: TextStyle(
                                            color: CupertinoColors.systemRed
                                                .withOpacity(0.8),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: CupertinoButton(
                                        padding: const EdgeInsets.all(8),
                                        color: CupertinoColors.black
                                            .withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(20),
                                        child: const Icon(
                                          CupertinoIcons.xmark,
                                          color: CupertinoColors.white,
                                          size: 20,
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        onErrorBuilder: (context, element, error) => Center(
                          child: Text(
                            S.of(context).loadingImageError,
                            style: TextStyle(
                              color: CupertinoColors.systemRed.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Consumer<FeedProvider>(
            builder: (context, provider, _) {
              final article =
                  provider.getArticle(widget.article.id) ?? widget.article;
              final hasNext = provider.hasNextArticle(article);
              final hasPrevious = provider.hasPreviousArticle(article);

              return Container(
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
                        onPressed: () {
                          provider.toggleArticleRead(article.id);
                        },
                        child: Icon(
                          article.isRead
                              ? CupertinoIcons.circle_fill
                              : CupertinoIcons.circle,
                          color: article.isRead
                              ? CupertinoColors.systemBlue
                              : CupertinoTheme.of(context)
                                  .textTheme
                                  .textStyle
                                  .color
                                  ?.withOpacity(0.8),
                        ),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.all(12),
                        onPressed: () {
                          provider.toggleArticleStarred(article.id);
                        },
                        child: Icon(
                          article.isStarred
                              ? CupertinoIcons.star_fill
                              : CupertinoIcons.star,
                          color: article.isStarred
                              ? CupertinoColors.systemBlue
                              : CupertinoTheme.of(context)
                                  .textTheme
                                  .textStyle
                                  .color
                                  ?.withOpacity(0.8),
                        ),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.all(12),
                        onPressed: () {
                          Share.share(article.url ?? article.title);
                        },
                        child: Icon(
                          CupertinoIcons.share,
                          color: CupertinoTheme.of(context)
                              .textTheme
                              .textStyle
                              .color
                              ?.withOpacity(0.8),
                        ),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.all(12),
                        onPressed: hasPrevious
                            ? () {
                                final previousArticle =
                                    provider.getPreviousArticle(article);
                                if (previousArticle != null) {
                                  Navigator.pushReplacement(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => ArticleDetailScreen(
                                          article: previousArticle),
                                    ),
                                  );
                                }
                              }
                            : null,
                        child: Icon(
                          CupertinoIcons.chevron_up,
                          color: hasPrevious
                              ? CupertinoTheme.of(context)
                                  .textTheme
                                  .textStyle
                                  .color
                                  ?.withOpacity(0.8)
                              : CupertinoColors.systemGrey3,
                        ),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.all(12),
                        onPressed: hasNext
                            ? () {
                                final nextArticle =
                                    provider.getNextArticle(article);
                                if (nextArticle != null) {
                                  Navigator.pushReplacement(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => ArticleDetailScreen(
                                          article: nextArticle),
                                    ),
                                  );
                                }
                              }
                            : null,
                        child: Icon(
                          CupertinoIcons.chevron_down,
                          color: hasNext
                              ? CupertinoTheme.of(context)
                                  .textTheme
                                  .textStyle
                                  .color
                                  ?.withOpacity(0.8)
                              : CupertinoColors.systemGrey3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
