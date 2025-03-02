import 'package:html/parser.dart' show parse;

class Article {
  final String id;
  final String title;
  final String? content;
  final String? summary;
  final String? url;
  final String? author;
  final DateTime publishedAt;
  final bool isRead;
  final bool isStarred;
  final String feedTitle;
  final String feedId;

  Article({
    required this.id,
    required this.title,
    this.content,
    this.summary,
    this.url,
    this.author,
    required this.publishedAt,
    this.isRead = false,
    this.isStarred = false,
    required this.feedTitle,
    required this.feedId,
  });

  Article copyWith({
    String? id,
    String? title,
    String? content,
    String? summary,
    String? url,
    String? author,
    DateTime? publishedAt,
    bool? isRead,
    bool? isStarred,
    String? feedTitle,
    String? feedId,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      url: url ?? this.url,
      author: author ?? this.author,
      publishedAt: publishedAt ?? this.publishedAt,
      isRead: isRead ?? this.isRead,
      isStarred: isStarred ?? this.isStarred,
      feedTitle: feedTitle ?? this.feedTitle,
      feedId: feedId ?? this.feedId,
    );
  }

  static String _cleanHtml(String? html) {
    if (html == null) return '';
    final document = parse(html);
    return document.body?.text.trim() ?? '';
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    // Handle data returned from database
    if (json.containsKey('publishedAt')) {
      return Article(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String?,
        summary: json['summary'] as String?,
        url: json['url'] as String?,
        author: json['author'] as String?,
        publishedAt:
            DateTime.fromMillisecondsSinceEpoch(json['publishedAt'] as int),
        isRead: json['isRead'] == 1,
        isStarred: json['isStarred'] == 1,
        feedTitle: json['feedTitle'] as String,
        feedId: json['feedId'] as String,
      );
    }

    // Handle data returned from API
    return Article(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      content: json['content']?['content'] as String? ??
          json['summary']?['content'] as String? ??
          '',
      summary: _cleanHtml(json['summary']?['content'] as String?),
      url: json['canonical']?[0]?['href'] as String?,
      author: json['author'] as String?,
      publishedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['published'] as int) * 1000,
      ),
      isRead: (json['categories'] as List?)
              ?.contains('user/-/state/com.google/read') ??
          false,
      isStarred: (json['categories'] as List?)
              ?.contains('user/-/state/com.google/starred') ??
          false,
      feedTitle: json['origin']?['title'] as String? ?? '',
      feedId: json['feedId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'summary': summary,
      'url': url,
      'author': author,
      'publishedAt': publishedAt.millisecondsSinceEpoch,
      'isRead': isRead ? 1 : 0,
      'isStarred': isStarred ? 1 : 0,
      'feedTitle': feedTitle,
      'feedId': feedId,
    };
  }
}
