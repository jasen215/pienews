import 'package:flutter/cupertino.dart';

class ArticleContent extends StatelessWidget {
  final String content;

  const ArticleContent({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      style: CupertinoTheme.of(context).textTheme.textStyle,
    );
  }
}
