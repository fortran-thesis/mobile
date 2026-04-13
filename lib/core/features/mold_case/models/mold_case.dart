import 'dart:convert';

class MoldCase {
  final String id;
  final String mycologistId;
  final String name;
  final String? cropName;
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
    this.cropName,
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
      cropName: _parseCropName(json),
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
                : (json['is_archived'].toString() == '1' ||
                      json['is_archived'].toString().toLowerCase() == 'true')),
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

  static String? _parseCropName(Map<String, dynamic> raw) {
    final direct = raw['crop_name']?.toString().trim();
    if (direct != null && direct.isNotEmpty) return direct;

    final host = raw['host']?.toString().trim();
    if (host != null && host.isNotEmpty) return host;

    final report = raw['mold_report'];
    if (report is Map<String, dynamic>) {
      final reportHost = report['host']?.toString().trim();
      if (reportHost != null && reportHost.isNotEmpty) return reportHost;
    }

    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mycologist_id': mycologistId,
      'name': name,
      if (cropName != null) 'crop_name': cropName,
      'mold_report_id': moldReportId,
      'photo_url': photoUrl,
      'priority': priority,
      'start_date': startDate.toUtc().toIso8601String(),
      'end_date': endDate?.toUtc().toIso8601String(),
      if (cultivationDetails != null)
        'cultivation_details': cultivationDetails!.toJson(),
      if (cultivationLogs != null)
        'cultivation_logs': cultivationLogs!.map((e) => e.toJson()).toList(),
      'is_archived': isArchived,
    };
  }
}

class CultivationDetails {
  final String growthMedium;
  final InVivoDetails? inVivoDetails;
  final InVitroDetails? inVitroDetails;
  final List<String>? specimenTypes;
  final List<String>? specimenQuantities;
  final List<String>? initialSymptoms;
  final List<String>? initialSigns;
  final List<String>? initialCharacteristics;
  final String? locationGathered;
  final String? initialMicroscopic;
  final String? initialMacroscopic;
  final String? initialMicroscopicColor;
  final String? initialMicroscopicTexture;
  final String? initialMacroscopicColor;
  final String? initialMacroscopicTexture;
  final String? initialMacroscopicSymptoms;
  final String? initialMacroscopicCharacteristics;
  final String? initialMicroscopicImageUrl;
  final String? initialMacroscopicImageUrl;
  final String? dateObservation;
  final Map<String, dynamic>? microscopicAiSnapshot;
  final List<String>? scannedMicroscopicIds;
  final List<String>? scannedMacroscopicIds;

  CultivationDetails({
    required this.growthMedium,
    this.inVivoDetails,
    this.inVitroDetails,
    this.specimenTypes,
    this.specimenQuantities,
    this.initialSymptoms,
    this.initialSigns,
    this.initialCharacteristics,
    this.locationGathered,
    this.initialMicroscopic,
    this.initialMacroscopic,
    this.initialMicroscopicColor,
    this.initialMicroscopicTexture,
    this.initialMacroscopicColor,
    this.initialMacroscopicTexture,
    this.initialMacroscopicSymptoms,
    this.initialMacroscopicCharacteristics,
    this.initialMicroscopicImageUrl,
    this.initialMacroscopicImageUrl,
    this.dateObservation,
    this.microscopicAiSnapshot,
    this.scannedMicroscopicIds,
    this.scannedMacroscopicIds,
  });

  factory CultivationDetails.empty() {
    return CultivationDetails(
      growthMedium: '',
      specimenTypes: null,
      specimenQuantities: null,
      initialSymptoms: null,
      initialSigns: null,
      initialCharacteristics: null,
      locationGathered: null,
      initialMicroscopic: null,
      initialMacroscopic: null,
      initialMicroscopicColor: null,
      initialMicroscopicTexture: null,
      initialMacroscopicColor: null,
      initialMacroscopicTexture: null,
      initialMacroscopicSymptoms: null,
      initialMacroscopicCharacteristics: null,
      initialMicroscopicImageUrl: null,
      initialMacroscopicImageUrl: null,
      dateObservation: null,
      microscopicAiSnapshot: null,
      scannedMicroscopicIds: null,
      scannedMacroscopicIds: null,
    );
  }

  factory CultivationDetails.fromJson(Map<String, dynamic> json) {
    InVivoDetails? inVivo;
    InVitroDetails? inVitro;

    if (json['in_vivo_details'] is Map<String, dynamic>) {
      inVivo = InVivoDetails.fromJson(
        json['in_vivo_details'] as Map<String, dynamic>,
      );
    }

    if (json['in_vitro_details'] is Map<String, dynamic>) {
      inVitro = InVitroDetails.fromJson(
        json['in_vitro_details'] as Map<String, dynamic>,
      );
    }

    // Parse specimen types and quantities
    final List<String>? specimenTypes = (json['specimen_types'] is List)
        ? List<String>.from(json['specimen_types'] as List)
        : null;
    final List<String>? specimenQuantities =
        (json['specimen_quantities'] is List)
        ? List<String>.from(json['specimen_quantities'] as List)
        : null;

    // Parse initial symptoms and characteristics
    final List<String>? initialSymptoms = (json['initial_symptoms'] is List)
        ? List<String>.from(json['initial_symptoms'] as List)
        : null;
    final List<String>? initialSigns = (json['initial_signs'] is List)
      ? List<String>.from(json['initial_signs'] as List)
      : null;
    final List<String>? initialCharacteristics =
        (json['initial_characteristics'] is List)
        ? List<String>.from(json['initial_characteristics'] as List)
        : null;

    final String? initialMicroscopic = json['initial_microscopic']?.toString();
    final String? initialMacroscopic = json['initial_macroscopic']?.toString();
    final String? initialMicroscopicColor = json['initial_microscopic_color']
        ?.toString();
    final String? initialMicroscopicTexture =
        json['initial_microscopic_texture']?.toString();
    final String? initialMacroscopicColor = json['initial_macroscopic_color']
        ?.toString();
    final String? initialMacroscopicTexture =
        json['initial_macroscopic_texture']?.toString();
    final String? initialMacroscopicSymptoms =
        json['initial_macroscopic_symptoms']?.toString();
    final String? initialMacroscopicCharacteristics =
        json['initial_macroscopic_characteristics']?.toString();
    final String? initialMicroscopicImageUrl =
        json['initial_microscopic_image_url']?.toString();
    final String? initialMacroscopicImageUrl =
        json['initial_macroscopic_image_url']?.toString();
    final String? dateObservation = json['date_observation']?.toString();
    final Map<String, dynamic>? microscopicAiSnapshot =
        (json['microscopic_ai_snapshot'] is Map<String, dynamic>)
        ? Map<String, dynamic>.from(
            json['microscopic_ai_snapshot'] as Map<String, dynamic>,
          )
        : null;
    final List<String>? scannedMicroscopicIds =
        (json['scanned_microscopic_ids'] is List)
        ? List<String>.from(json['scanned_microscopic_ids'] as List)
        : null;
    final List<String>? scannedMacroscopicIds =
        (json['scanned_macroscopic_ids'] is List)
        ? List<String>.from(json['scanned_macroscopic_ids'] as List)
        : null;

    return CultivationDetails(
      growthMedium: json['growth_medium']?.toString() ?? '',
      inVivoDetails: inVivo,
      inVitroDetails: inVitro,
      specimenTypes: specimenTypes,
      specimenQuantities: specimenQuantities,
      initialSymptoms: initialSymptoms,
      initialSigns: initialSigns,
      initialCharacteristics: initialCharacteristics,
      locationGathered: json['location_gathered']?.toString(),
      initialMicroscopic: initialMicroscopic,
      initialMacroscopic: initialMacroscopic,
      initialMicroscopicColor: initialMicroscopicColor,
      initialMicroscopicTexture: initialMicroscopicTexture,
      initialMacroscopicColor: initialMacroscopicColor,
      initialMacroscopicTexture: initialMacroscopicTexture,
      initialMacroscopicSymptoms: initialMacroscopicSymptoms,
      initialMacroscopicCharacteristics: initialMacroscopicCharacteristics,
      initialMicroscopicImageUrl: initialMicroscopicImageUrl,
      initialMacroscopicImageUrl: initialMacroscopicImageUrl,
      dateObservation: dateObservation,
      microscopicAiSnapshot: microscopicAiSnapshot,
      scannedMicroscopicIds: scannedMicroscopicIds,
      scannedMacroscopicIds: scannedMacroscopicIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'growth_medium': growthMedium,
      if (inVivoDetails != null) 'in_vivo_details': inVivoDetails!.toJson(),
      if (inVitroDetails != null) 'in_vitro_details': inVitroDetails!.toJson(),
      if (specimenTypes != null) 'specimen_types': specimenTypes,
      if (specimenQuantities != null) 'specimen_quantities': specimenQuantities,
      if (initialSymptoms != null) 'initial_symptoms': initialSymptoms,
      if (initialSigns != null) 'initial_signs': initialSigns,
      if (initialCharacteristics != null)
        'initial_characteristics': initialCharacteristics,
      if (locationGathered != null) 'location_gathered': locationGathered,
      if (initialMicroscopic != null) 'initial_microscopic': initialMicroscopic,
      if (initialMacroscopic != null) 'initial_macroscopic': initialMacroscopic,
      if (initialMicroscopicColor != null)
        'initial_microscopic_color': initialMicroscopicColor,
      if (initialMicroscopicTexture != null)
        'initial_microscopic_texture': initialMicroscopicTexture,
      if (initialMacroscopicColor != null)
        'initial_macroscopic_color': initialMacroscopicColor,
      if (initialMacroscopicTexture != null)
        'initial_macroscopic_texture': initialMacroscopicTexture,
      if (initialMacroscopicSymptoms != null)
        'initial_macroscopic_symptoms': initialMacroscopicSymptoms,
      if (initialMacroscopicCharacteristics != null)
        'initial_macroscopic_characteristics':
            initialMacroscopicCharacteristics,
      if (initialMicroscopicImageUrl != null)
        'initial_microscopic_image_url': initialMicroscopicImageUrl,
      if (initialMacroscopicImageUrl != null)
        'initial_macroscopic_image_url': initialMacroscopicImageUrl,
      if (dateObservation != null) 'date_observation': dateObservation,
      if (microscopicAiSnapshot != null)
        'microscopic_ai_snapshot': microscopicAiSnapshot,
      if (scannedMicroscopicIds != null)
        'scanned_microscopic_ids': scannedMicroscopicIds,
      if (scannedMacroscopicIds != null)
        'scanned_macroscopic_ids': scannedMacroscopicIds,
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
    return {'environmental_temperature': environmentalTemperature};
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
    return {'incubation_temperature': incubationTemperature};
  }
}

class CultivationLog {
  final String id;
  final String type; // "vivo" | "vitro"
  final Map<String, dynamic> characteristics;
  final String additionalInfo;
  final String imageUrl;
  final DateTime? createdAt;

  CultivationLog({
    required this.id,
    required this.type,
    required this.characteristics,
    required this.additionalInfo,
    required this.imageUrl,
    this.createdAt,
  });

  factory CultivationLog.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> parseCharacteristics(dynamic raw) {
      if (raw is Map<String, dynamic>) return raw;
      if (raw is String) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) return decoded;
        } catch (_) {
          return <String, dynamic>{};
        }
      }
      return <String, dynamic>{};
    }

    DateTime? parseDate(dynamic raw) {
      if (raw == null) return null;
      if (raw is DateTime) return raw.toUtc();
      if (raw is String) {
        try {
          return DateTime.parse(raw).toUtc();
        } catch (_) {
          return null;
        }
      }
      if (raw is Map<String, dynamic>) {
        final seconds = raw['_seconds'] ?? raw['seconds'];
        if (seconds is int) {
          return DateTime.fromMillisecondsSinceEpoch(
            seconds * 1000,
            isUtc: true,
          );
        }
      }
      return null;
    }

    String parseAdditionalInfo(dynamic raw) {
      if (raw == null) return '';
      if (raw is String) return raw.trim();

      if (raw is List) {
        final parts = <String>[];
        for (final item in raw) {
          if (item is Map<String, dynamic>) {
            final title = item['title']?.toString().trim() ?? '';
            final description =
                (item['description'] ?? item['content'])?.toString().trim() ??
                '';
            if (title.isNotEmpty && description.isNotEmpty) {
              parts.add('$title: $description');
            } else if (description.isNotEmpty) {
              parts.add(description);
            }
          } else if (item != null) {
            final text = item.toString().trim();
            if (text.isNotEmpty) parts.add(text);
          }
        }
        return parts.join('\n\n');
      }

      if (raw is Map<String, dynamic>) {
        final title = raw['title']?.toString().trim() ?? '';
        final description =
            (raw['description'] ?? raw['content'])?.toString().trim() ?? '';
        if (title.isNotEmpty && description.isNotEmpty) {
          return '$title: $description';
        }
        if (description.isNotEmpty) return description;
      }

      return raw.toString().trim();
    }

    final metadata = (json['metadata'] is Map<String, dynamic>)
        ? json['metadata'] as Map<String, dynamic>
        : null;

    return CultivationLog(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'vivo',
      characteristics: parseCharacteristics(json['characteristics']),
      additionalInfo: parseAdditionalInfo(json['additional_info']),
      imageUrl: json['image_url']?.toString() ?? '',
      createdAt:
          parseDate(json['created_at']) ?? parseDate(metadata?['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'characteristics': characteristics,
      'additional_info': additionalInfo,
      'image_url': imageUrl,
      'created_at': createdAt?.toUtc().toIso8601String(),
    };
  }
}
