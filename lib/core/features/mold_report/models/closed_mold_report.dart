import 'dart:convert';

class ClosedMoldReport {
  final String id;
  final String caseName;
  final DateTime? dateObserved;
  final String? assignedMycologistId;
  final String? host;
  final String? location;
  final String status;
  final String? imageUrl;

  const ClosedMoldReport({
    required this.id,
    required this.caseName,
    required this.dateObserved,
    required this.status,
    this.assignedMycologistId,
    this.host,
    this.location,
    this.imageUrl,
  });

  factory ClosedMoldReport.fromJson(Map<String, dynamic> json) {
    return ClosedMoldReport(
      id:
          json['id']?.toString() ??
          json['_id']?.toString() ??
          json['report_id']?.toString() ??
          '',
      caseName:
          json['case_name']?.toString() ??
          json['name']?.toString() ??
          'Untitled Case',
      dateObserved: _parseDate(json['date_observed'] ?? json['created_at']),
      assignedMycologistId: json['assigned_mycologist_id']?.toString(),
      host: json['host']?.toString(),
      location: json['location']?.toString(),
      status: json['status']?.toString() ?? '',
      imageUrl: _resolveImageUrl(json),
    );
  }

  static String? _extractPhotoUrl(dynamic raw) {
    if (raw is String) {
      final normalized = raw.trim();
      if (normalized.isEmpty ||
          normalized == 'no_image' ||
          normalized == '[]' ||
          normalized == 'null') {
        return null;
      }

      if (normalized.startsWith('[') && normalized.endsWith(']')) {
        try {
          final decoded = jsonDecode(normalized);
          return _extractPhotoUrl(decoded);
        } catch (_) {
          // Keep normalized string fallback if JSON parsing fails.
        }
      }

      return normalized;
    }

    if (raw is List) {
      for (final item in raw) {
        final extracted = _extractPhotoUrl(item);
        if (extracted != null) return extracted;
      }
      return null;
    }

    if (raw is Map) {
      return _extractPhotoUrl(
        raw['url'] ?? raw['image_url'] ?? raw['photo_url'] ?? raw['secure_url'],
      );
    }

    return null;
  }

  static String? _resolveImageUrl(Map<String, dynamic> json) {
    final moldReport = json['mold_report'] is Map
        ? Map<String, dynamic>.from(json['mold_report'] as Map)
        : <String, dynamic>{};

    final caseDetailsRaw = json['case_details'] ?? moldReport['case_details'];
    final caseDetails = caseDetailsRaw is List
        ? caseDetailsRaw
        : caseDetailsRaw is Map
        ? <dynamic>[caseDetailsRaw]
        : const <dynamic>[];

    final candidates = <dynamic>[
      json['cover_photo'],
      json['cover_photo_url'],
      json['coverPhoto'],
      json['coverPhotoUrl'],
      json['report_cover_photo'],
      json['photo_url'],
      json['image_url'],
      moldReport['cover_photo'],
      moldReport['cover_photo_url'],
      moldReport['coverPhoto'],
      moldReport['coverPhotoUrl'],
      moldReport['report_cover_photo'],
      moldReport['photo_url'],
      moldReport['image_url'],
    ];

    for (final detail in caseDetails) {
      if (detail is! Map) continue;
      final entry = Map<String, dynamic>.from(detail);
      candidates.add(entry['cover_photo']);
      candidates.add(entry['cover_photo_url']);
      candidates.add(entry['photo_url']);
      candidates.add(entry['image_url']);
      candidates.add(entry['url']);
    }

    for (final candidate in candidates) {
      final url = _extractPhotoUrl(candidate);
      if (url != null) return url;
    }

    return null;
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
}