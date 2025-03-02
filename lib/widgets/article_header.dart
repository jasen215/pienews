import 'package:flutter/cupertino.dart';
import 'package:pienews/models/article.dart';
import 'package:pienews/utils/date_formatter.dart';

class ArticleHeader extends StatelessWidget {
  final Article article;

  const ArticleHeader({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final textColor = CupertinoTheme.of(context).textTheme.textStyle.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          article.title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'By ${article.author} • ${formatDate(article.publishedAt)}',
          style: TextStyle(
            fontSize: 14,
            color: textColor?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
