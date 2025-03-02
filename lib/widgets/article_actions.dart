import 'package:flutter/cupertino.dart';
import 'package:pienews/models/article.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleActions extends StatelessWidget {
  final Article article;

  const ArticleActions({super.key, required this.article});

  Future<void> _openInBrowser() async {
    if (article.url != null) {
      final url = Uri.parse(article.url!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: _openInBrowser,
      child: const Icon(CupertinoIcons.globe),
    );
  }
}
