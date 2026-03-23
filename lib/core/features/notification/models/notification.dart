/// Notification model matching the API's `Notification` interface.
///
/// Fields use snake_case JSON keys and camelCase Dart properties,
/// following the same pattern as [MoldCase] and [MoldReport].
class AppNotification {
  final String id;
  final String recipientId;
  final String type;
  final String title;
  final String body;
  final String? referenceId;
  final String? referenceType;
  final bool isRead;
  final DateTime? createdAt;

  AppNotification({
    required this.id,
    required this.recipientId,
    required this.type,
    required this.title,
    required this.body,
    this.referenceId,
    this.referenceType,
    required this.isRead,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      recipientId: json['recipient_id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      referenceId: json['reference_id']?.toString(),
      referenceType: json['reference_type']?.toString(),
      isRead: json['is_read'] == true,
      createdAt: _parseDate(json['metadata']),
    );
  }

  /// Parse created_at from the metadata sub-object.
  /// Backend returns `{ metadata: { created_at: { _seconds, _nanoseconds } } }`.
  static DateTime? _parseDate(dynamic metadata) {
    if (metadata == null) return null;
    if (metadata is Map<String, dynamic>) {
      final raw = metadata['created_at'];
      if (raw is Map<String, dynamic>) {
        final seconds = raw['_seconds'] ?? raw['seconds'];
        if (seconds is int) {
          return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
        }
      }
      if (raw is String) {
        try {
          return DateTime.parse(raw).toUtc();
        } catch (_) {
          return null;
        }
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipient_id': recipientId,
      'type': type,
      'title': title,
      'body': body,
      'reference_id': referenceId,
      'reference_type': referenceType,
      'is_read': isRead,
    };
  }

  /// Return a copy with [isRead] set to true (optimistic UI update).
  AppNotification copyWithRead() {
    return AppNotification(
      id: id,
      recipientId: recipientId,
      type: type,
      title: title,
      body: body,
      referenceId: referenceId,
      referenceType: referenceType,
      isRead: true,
      createdAt: createdAt,
    );
  }
}
