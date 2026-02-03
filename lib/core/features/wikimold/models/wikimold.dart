class WikiArticle {
  final String id;
  final String title;
  final String body;
  final String authorId;
  final String? coverPhoto;
  final List<String> tags;

  WikiArticle({
    required this.id,
    required this.title,
    required this.body,
    required this.authorId,
    this.coverPhoto,
    required this.tags,
  });

  factory WikiArticle.fromJson(Map<String, dynamic> json) {
    return WikiArticle(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      authorId: json['author_id'],
      coverPhoto: json['cover_photo'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}