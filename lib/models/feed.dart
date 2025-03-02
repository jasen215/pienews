class Feed {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final String url;
  final int unreadCount;
  final int starredCount;
  final String category;

  Feed({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.url,
    required this.unreadCount,
    required this.starredCount,
    required this.category,
  }) {
    // Validate data
    assert(id.isNotEmpty, 'Feed ID cannot be empty');
    assert(title.isNotEmpty, 'Feed title cannot be empty');
    assert(url.isNotEmpty, 'Feed URL cannot be empty');
    assert(unreadCount >= 0, 'Unread count cannot be negative');
    assert(starredCount >= 0, 'Starred count cannot be negative');
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconUrl': iconUrl,
      'url': url,
      'unreadCount': unreadCount,
      'starredCount': starredCount,
      'category': category,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory Feed.fromMap(Map<String, dynamic> map) {
    return Feed(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      iconUrl: map['iconUrl'] as String? ?? '',
      url: map['url'] as String? ?? '',
      unreadCount: (map['unreadCount'] as num?)?.toInt() ?? 0,
      starredCount: (map['starredCount'] as num?)?.toInt() ?? 0,
      category: map['category'] as String? ?? '',
    );
  }

  factory Feed.fromJson(Map<String, dynamic> json) => Feed.fromMap(json);

  Feed copyWith({
    String? id,
    String? title,
    String? description,
    String? iconUrl,
    String? url,
    int? unreadCount,
    int? starredCount,
    String? category,
  }) {
    return Feed(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      url: url ?? this.url,
      unreadCount: unreadCount ?? this.unreadCount,
      starredCount: starredCount ?? this.starredCount,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Feed &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          iconUrl == other.iconUrl &&
          url == other.url &&
          unreadCount == other.unreadCount &&
          starredCount == other.starredCount &&
          category == other.category;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      iconUrl.hashCode ^
      url.hashCode ^
      unreadCount.hashCode ^
      starredCount.hashCode ^
      category.hashCode;

  @override
  String toString() {
    return 'Feed{id: $id, title: $title, unreadCount: $unreadCount, starredCount: $starredCount}';
  }
}
