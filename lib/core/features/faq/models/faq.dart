class FAQ {
  final String id;
  final String question;
  final String answer;
  final FAQMetadata? metadata;

  FAQ({
    required this.id,
    required this.question,
    required this.answer,
    this.metadata,
  });

  factory FAQ.fromJson(Map<String, dynamic> json) {
    print('FAQ.fromJson: parsing json=$json');

    // Parse metadata if it exists
    FAQMetadata? metadata;
    final rawMetadata = json['metadata'];
    if (rawMetadata is Map<String, dynamic>) {
      metadata = FAQMetadata.fromJson(rawMetadata);
    }

    return FAQ(
      id: json['id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
      metadata: metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      if (metadata != null) 'metadata': metadata!.toJson(),
    };
  }

  @override
  String toString() {
    return 'FAQ(id: $id, question: $question, answer: $answer, metadata: $metadata)';
  }
}

class FAQMetadata {
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  FAQMetadata({
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory FAQMetadata.fromJson(Map<String, dynamic> json) {
    return FAQMetadata(
      createdAt: _parseTimestamp(json['created_at']),
      updatedAt: _parseTimestamp(json['updated_at']),
      deletedAt: _parseTimestamp(json['deleted_at']),
    );
  }

  static DateTime? _parseTimestamp(dynamic raw) {
    if (raw == null) return null;
    
    if (raw is DateTime) return raw.toUtc();
    
    if (raw is String) {
      try {
        return DateTime.parse(raw).toUtc();
      } catch (_) {
        return null;
      }
    }
    
    // Firestore-like timestamp: {_seconds: ..., _nanoseconds: ...}
    if (raw is Map<String, dynamic>) {
      final seconds = raw['_seconds'] ?? raw['seconds'];
      if (seconds is num) {
        return DateTime.fromMillisecondsSinceEpoch(seconds.toInt() * 1000, isUtc: true);
      }
    }
    
    // Unix timestamp in milliseconds
    if (raw is num) {
      return DateTime.fromMillisecondsSinceEpoch(raw.toInt(), isUtc: true);
    }
    
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (deletedAt != null) 'deleted_at': deletedAt!.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'FAQMetadata(createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }
}
