class WikiArticle {
  final String id;
  final String title;
  final String body;
  final String findings;
  final String treatments;
  final String author;
  final String? coverPhoto;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? mycologistId;
  final DateTime? approvedAt;

  WikiArticle({
    required this.id,
    required this.title,
    required this.body,
    required this.findings,
    required this.treatments,
    required this.author,
    this.coverPhoto,
    required this.tags,
    this.createdAt,
    this.updatedAt,
    this.mycologistId,
    this.approvedAt,
  });

  factory WikiArticle.fromJson(Map<String, dynamic> json) {
    // Extract dates from metadata object if available
    final metadata = json['metadata'] is Map<String, dynamic> 
        ? json['metadata'] as Map<String, dynamic>
        : <String, dynamic>{};
    
    return WikiArticle(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      body: _extractContent(
        json,
        const [
          'body',
          'description',
          'content',
        ],
      ),
      findings: _extractContent(
        json,
        const [
          'findings',
          'finding',
          'stage1_content',
          'stage1Content',
          'mechanical_content',
          'mechanicalContent',
        ],
      ),
      treatments: _extractContent(
        json,
        const [
          'treatments',
          'treatment',
          'stage2_content',
          'stage2Content',
          'chemical_content',
          'chemicalContent',
          'recommendations',
        ],
      ),
      author: json['author']?.toString() ?? 'Unknown',
      coverPhoto: json['cover_photo']?.toString(),
      tags: _parseTags(json['tags']),
      createdAt: _parseDate(metadata['created_at']) ?? _parseDate(json['created_at']),
      updatedAt: _parseDate(metadata['updated_at']) ?? _parseDate(json['updated_at']),
      mycologistId: json['mycologist_id']?.toString() ?? metadata['mycologist_id']?.toString(),
      approvedAt: _parseDate(metadata['approved_at']) ?? _parseDate(json['approved_at']),
    );
  }

  static List<String> _parseTags(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<String>()
          .where((tag) => tag.trim().isNotEmpty)
          .toList();
    }
    return <String>[];
  }

  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        return DateTime.parse(raw);
      } catch (_) {
        return null;
      }
    }
    if (raw is Map<String, dynamic>) {
      final seconds = raw['_seconds'] ?? raw['seconds'];
      if (seconds is int) {
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
      }
    }
    return null;
  }

  static String _extractContent(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final raw = json[key];
      final parsed = _normalizeContent(raw);
      if (parsed.isNotEmpty) return parsed;
    }
    return '';
  }

  static String _normalizeContent(dynamic raw) {
    if (raw == null) return '';

    if (raw is String) {
      return raw.trim();
    }

    if (raw is List) {
      final values = raw
          .map((item) => _normalizeContent(item))
          .where((item) => item.isNotEmpty)
          .toList();
      return values.join('<br/>').trim();
    }

    if (raw is Map) {
      final values = raw.values
          .map((item) => _normalizeContent(item))
          .where((item) => item.isNotEmpty)
          .toList();
      return values.join('<br/>').trim();
    }

    return raw.toString().trim();
  }
}