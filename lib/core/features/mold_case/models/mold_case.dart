class MoldCase {
  final String id;
  final String mycologistId;
  final String name;
  final String moldReportId;
  final String? photoUrl;
  final String priority; // "low" | "medium" | "high"
  final DateTime startDate;
  final DateTime? endDate;
  final CultivationDetails? cultivationDetails;
  final List<CultivationLog>? cultivationLogs;
  final bool isArchived;

  MoldCase({
    required this.id,
    required this.mycologistId,
    required this.name,
    required this.moldReportId,
    this.photoUrl,
    required this.priority,
    required this.startDate,
    this.endDate,
    this.cultivationDetails,
    this.cultivationLogs,
    required this.isArchived,
  });

  factory MoldCase.fromJson(Map<String, dynamic> json) {
    // Parse cultivation_details
    final rawCultivationDetails = json['cultivation_details'];
    CultivationDetails? cultivationDetails;
    if (rawCultivationDetails is Map<String, dynamic>) {
      cultivationDetails = CultivationDetails.fromJson(rawCultivationDetails);
    }

    // Parse cultivation_logs
    final rawLogs = json['cultivation_logs'];
    List<CultivationLog>? logs;
    if (rawLogs is List) {
      logs = rawLogs
          .map((e) => CultivationLog.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return MoldCase(
      id: json['id']?.toString() ?? '',
      mycologistId: json['mycologist_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      moldReportId: json['mold_report_id']?.toString() ?? '',
      photoUrl: _parsePhotoUrl(json['photo_url']),
      priority: json['priority']?.toString() ?? 'low',
      startDate: _parseDate(json['start_date']) ?? DateTime.now(),
      endDate: _parseDate(json['end_date']),
      cultivationDetails: cultivationDetails,
      cultivationLogs: logs,
      isArchived: json['is_archived'] == null
          ? false
          : (json['is_archived'] is bool
              ? json['is_archived'] as bool
              : (json['is_archived'].toString() == '1' || json['is_archived'].toString().toLowerCase() == 'true')),
    );
  }

  static String? _parsePhotoUrl(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) {
      // Filter out string representations of empty arrays or null
      if (raw.isEmpty || raw == '[]' || raw == 'null') return null;
      return raw;
    }
    if (raw is List) {
      // If it's a list, try to get the first URL
      if (raw.isEmpty) return null;
      final first = raw.first;
      if (first is String && first.isNotEmpty) return first;
      return null;
    }
    return null;
  }

  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw.toUtc();
    if (raw is String) {
      try {
        return DateTime.parse(raw).toUtc();
      } catch (_) {
        return null;
      }
    }
    // Handle Firestore timestamp format: {_seconds: ..., _nanoseconds: ...}
    if (raw is Map<String, dynamic>) {
      final seconds = raw['_seconds'] ?? raw['seconds'];
      if (seconds is int) {
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mycologist_id': mycologistId,
      'name': name,
      'mold_report_id': moldReportId,
      'photo_url': photoUrl,
      'priority': priority,
      'start_date': startDate.toUtc().toIso8601String(),
      'end_date': endDate?.toUtc().toIso8601String(),
      if (cultivationDetails != null) 'cultivation_details': cultivationDetails!.toJson(),
      if (cultivationLogs != null) 'cultivation_logs': cultivationLogs!.map((e) => e.toJson()).toList(),
      'is_archived': isArchived,
    };
  }
}

class CultivationDetails {
  final String growthMedium;
  final InVivoDetails? inVivoDetails;
  final InVitroDetails? inVitroDetails;

  CultivationDetails({
    required this.growthMedium,
    this.inVivoDetails,
    this.inVitroDetails,
  });

  factory CultivationDetails.empty() {
    return CultivationDetails(
      growthMedium: '',
    );
  }

  factory CultivationDetails.fromJson(Map<String, dynamic> json) {
    InVivoDetails? inVivo;
    InVitroDetails? inVitro;

    if (json['in_vivo_details'] is Map<String, dynamic>) {
      inVivo = InVivoDetails.fromJson(json['in_vivo_details'] as Map<String, dynamic>);
    }

    if (json['in_vitro_details'] is Map<String, dynamic>) {
      inVitro = InVitroDetails.fromJson(json['in_vitro_details'] as Map<String, dynamic>);
    }

    return CultivationDetails(
      growthMedium: json['growth_medium']?.toString() ?? '',
      inVivoDetails: inVivo,
      inVitroDetails: inVitro,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'growth_medium': growthMedium,
      if (inVivoDetails != null) 'in_vivo_details': inVivoDetails!.toJson(),
      if (inVitroDetails != null) 'in_vitro_details': inVitroDetails!.toJson(),
    };
  }
}

class InVivoDetails {
  final num environmentalTemperature;

  InVivoDetails({required this.environmentalTemperature});

  factory InVivoDetails.fromJson(Map<String, dynamic> json) {
    return InVivoDetails(
      environmentalTemperature: json['environmental_temperature'] as num? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'environmental_temperature': environmentalTemperature,
    };
  }
}

class InVitroDetails {
  final num incubationTemperature;

  InVitroDetails({required this.incubationTemperature});

  factory InVitroDetails.fromJson(Map<String, dynamic> json) {
    return InVitroDetails(
      incubationTemperature: json['incubation_temperature'] as num? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'incubation_temperature': incubationTemperature,
    };
  }
}

class CultivationLog {
  final String type; // "vivo" | "vitro"
  final Map<String, dynamic> characteristics;
  final String additionalInfo;

  CultivationLog({
    required this.type,
    required this.characteristics,
    required this.additionalInfo,
  });

  factory CultivationLog.fromJson(Map<String, dynamic> json) {
    return CultivationLog(
      type: json['type']?.toString() ?? 'vivo',
      characteristics: (json['characteristics'] is Map<String, dynamic>)
          ? json['characteristics'] as Map<String, dynamic>
          : {},
      additionalInfo: json['additional_info']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'characteristics': characteristics,
      'additional_info': additionalInfo,
    };
  }
}
