class ClosedMoldReport {
  final String id;
  final String caseName;
  final DateTime? dateObserved;
  final String? assignedMycologistId;
  final String? host;
  final String? location;
  final String status;

  const ClosedMoldReport({
    required this.id,
    required this.caseName,
    required this.dateObserved,
    required this.status,
    this.assignedMycologistId,
    this.host,
    this.location,
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
    );
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