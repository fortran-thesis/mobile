class WikiArticle {
  final String id;
  final String title;
  final String body;
  final String author;
  final String? coverPhoto;
  final List<String> tags;

  WikiArticle({
    required this.id,
    required this.title,
    required this.body,
    required this.author,
    this.coverPhoto,
    required this.tags,
  });

  factory WikiArticle.fromJson(Map<String, dynamic> json) {
    return WikiArticle(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      author: json['author'] ?? 'Unknown',
      coverPhoto: json['cover_photo'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}