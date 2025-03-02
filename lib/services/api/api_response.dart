import 'package:pienews/models/article.dart';

class ArticleResponse {
  final List<Article> articles;
  final String? continuation;

  ArticleResponse({
    required this.articles,
    this.continuation,
  });
}
