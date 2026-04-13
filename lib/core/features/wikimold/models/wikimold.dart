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
  final Map<String, String> hostPathogenImpact;

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
    required this.hostPathogenImpact,
  });

  factory WikiArticle.fromJson(Map<String, dynamic> json) {
    // Extract dates from metadata object if available
    final metadata = json['metadata'] is Map<String, dynamic> 
        ? json['metadata'] as Map<String, dynamic>
        : <String, dynamic>{};
    final moldDetails = _asMap(json['mold_details']);
    final moldInfo = _asMap(moldDetails['info']);
    final moldPrevention = _asMap(moldDetails['prevention']);
    
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
      findings: _normalizeFindings(json['findings']) ?? _extractContent(
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
      treatments: _extractContentFromSources(
        [json, moldInfo, moldPrevention],
        const [
          'treatments',
          'treatment',
          'prevention',
          'prevention_summary',
          'preventionSummary',
          'stage2_content',
          'stage2Content',
          'treatment_mechanical',
          'treatment_cultural',
          'treatment_biological',
          'treatment_physical',
          'treatment_chemical',
          'chemical_content',
          'chemicalContent',
          'recommendations',
        ],
        preferTreatmentControls: true,
        sectionTitles: const [
          'prevention summary',
          'prevention',
          'preventive measures',
        ],
      ),
      author: json['author']?.toString() ?? 'Unknown',
      coverPhoto: json['cover_photo']?.toString(),
      tags: _parseTags(json['tags']),
      createdAt: _parseDate(metadata['created_at']) ?? _parseDate(json['created_at']),
      updatedAt: _parseDate(metadata['updated_at']) ?? _parseDate(json['updated_at']),
      mycologistId: json['mycologist_id']?.toString() ?? metadata['mycologist_id']?.toString(),
      approvedAt: _parseDate(metadata['approved_at']) ?? _parseDate(json['approved_at']),
      hostPathogenImpact: _extractHostPathogenImpact(
        json,
        metadata,
        moldInfo,
        moldPrevention,
      ),
    );
  }

  static Map<String, String> _extractHostPathogenImpact(
    Map<String, dynamic> json,
    Map<String, dynamic> metadata,
    Map<String, dynamic> moldInfo,
    Map<String, dynamic> moldPrevention,
  ) {
    final sources = <dynamic>[
      moldInfo,
      moldPrevention,
      json['host_pathogen_impact'],
      json['hostPathogenImpact'],
      metadata['host_pathogen_impact'],
      metadata['hostPathogenImpact'],
      json,
      metadata,
    ];

    String read(List<String> keys, {List<String> sectionTitles = const []}) {
      for (final source in sources) {
        final text = _readNestedSection(
          source,
          keys,
          sectionTitles: sectionTitles,
        );
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    final result = <String, String>{
      'affected_hosts': read([
        'affected_hosts',
        'affectedHosts',
        'hosts',
        'host_range',
        'hostRange',
        'affected_hoses',
      ], sectionTitles: const [
        'affected hosts',
        'host range',
      ]),
      'symptoms_signs': read([
        'symptoms_signs',
        'symptomsSigns',
        'symptoms_and_signs',
        'symptomsAndSigns',
        'symptoms',
        'signs',
        'symptoms_signs_and_impact',
      ], sectionTitles: const [
        'symptoms & signs',
        'symptoms and signs',
        'symptoms/signs',
        'symptoms',
        'signs',
      ]),
      'transmission_cycle': read([
        'disease_cycle',
        'diseaseCycle',
        'transmission_cycle',
        'transmissionCycle',
        'cycle_of_transmission',
        'cycleOfTransmission',
        'disease_cycle_spread_impact',
        'diseaseCycleSpreadImpact',
        'spread',
      ], sectionTitles: const [
        'disease cycle',
        'transmission cycle',
        'cycle of transmission',
        'disease cycle spread impact',
        'spread',
      ]),
      'impact_analysis': read([
        'impact_analysis',
        'impactAnalysis',
        'impact',
        'damage_analysis',
        'damageAnalysis',
        'health_risks',
        'healthRisks',
      ], sectionTitles: const [
        'impact analysis',
        'damage analysis',
        'health risks',
        'impact',
      ]),
    };

    result.removeWhere((key, value) => value.isEmpty);
    return result;
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

  static String _extractContent(
    Map<String, dynamic> json,
    List<String> keys, {
    bool preferTreatmentControls = false,
  }) {
    for (final key in keys) {
      final raw = json[key];
      if (preferTreatmentControls) {
        final structured = _normalizeTreatments(raw);
        if (structured.isNotEmpty) return structured;
      }
      final parsed = _normalizeContent(raw);
      if (parsed.isNotEmpty) return parsed;
    }
    return '';
  }

  static String _extractContentFromSources(
    List<dynamic> sources,
    List<String> keys, {
    bool preferTreatmentControls = false,
    List<String> sectionTitles = const [],
  }) {
    if (preferTreatmentControls) {
      String merged = '';
      for (final source in sources) {
        if (source is! Map) continue;
        final map = Map<String, dynamic>.from(source);

        final flatStructured = _buildFlatTreatmentSegments(map);
        if (flatStructured.isNotEmpty) {
          merged = _mergeStructuredTreatments(merged, flatStructured);
        }

        final extracted = _readNestedSection(
          map,
          keys,
          preferTreatmentControls: true,
          sectionTitles: sectionTitles,
        );
        if (extracted.isNotEmpty) {
          merged = _mergeStructuredTreatments(merged, extracted);
        }
      }
      return merged;
    }

    for (final source in sources) {
      if (source is! Map) continue;
      final map = Map<String, dynamic>.from(source);
      final extracted = _readNestedSection(
        map,
        keys,
        preferTreatmentControls: false,
        sectionTitles: sectionTitles,
      );
      if (extracted.isNotEmpty) return extracted;
    }
    return '';
  }

  static String _mergeStructuredTreatments(String current, String incoming) {
    if (current.trim().isEmpty) return incoming.trim();
    if (incoming.trim().isEmpty) return current.trim();

    final merged = <String, String>{};

    void addSegments(String source) {
      final segments = source
          .split('|')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty);

      for (final segment in segments) {
        final parts = segment.split('::');
        if (parts.length < 3) continue;
        final key = '${parts[0].trim().toUpperCase()}::${parts[1].trim().toLowerCase()}';
        if (!merged.containsKey(key)) {
          merged[key] = '${parts[0].trim()}::${parts[1].trim()}::${parts.sublist(2).join('::').trim()}';
        }
      }
    }

    addSegments(current);
    addSegments(incoming);

    return merged.values.join('|');
  }

  static String _buildFlatTreatmentSegments(Map<String, dynamic> map) {
    String readFlat(List<String> keys) {
      for (final key in keys) {
        final text = _normalizeSectionContent(map[key]);
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    final segments = <String>[];

    void addFlatSegment(String type, String title, List<String> keys) {
      final value = readFlat(keys);
      if (value.isEmpty) return;
      segments.add('$type::$title::$value');
    }

    addFlatSegment('PREVENTION', 'Prevention Summary', [
      'prevention',
      'prevention_summary',
      'preventionSummary',
    ]);
    addFlatSegment('MECHANICAL', 'Mechanical Control', [
      'treatment_mechanical',
      'mechanical',
      'mechanical_control',
      'mechanicalControl',
    ]);
    addFlatSegment('CULTURAL', 'Cultural Control', [
      'treatment_cultural',
      'cultural',
      'cultural_control',
      'culturalControl',
    ]);
    addFlatSegment('BIOLOGICAL', 'Biological Control', [
      'treatment_biological',
      'biological',
      'biological_control',
      'biologicalControl',
    ]);
    addFlatSegment('PHYSICAL', 'Physical Control', [
      'treatment_physical',
      'physical',
      'physical_control',
      'physicalControl',
    ]);
    addFlatSegment('CHEMICAL', 'Chemical Control', [
      'treatment_chemical',
      'chemical',
      'chemical_control',
      'chemicalControl',
    ]);

    return segments.join('|').trim();
  }

  static String _normalizeTreatments(dynamic raw) {
    if (raw is List) {
      final segments = <String>[];
      for (final item in raw) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          final title = _normalizeSectionContent(map['title'] ?? map['name']);
          final content = _normalizeSectionContent(map['content'] ?? map['description']);
          final sectionType = _normalizeSectionContent(
            map['type'] ?? map['section'] ?? map['control_type'],
          ).toUpperCase();
          if (title.isEmpty && content.isEmpty) continue;
          final type = sectionType.isNotEmpty ? sectionType : 'TREATMENT';
          segments.add('$type::$title::$content');
        }
      }
      return segments.join('|').trim();
    }

    if (raw is! Map) return '';

    final map = Map<String, dynamic>.from(raw);

    String read(List<String> keys) {
      for (final key in keys) {
        final text = _readNestedSection(map[key], const []);
        if (text.isNotEmpty) return text;
      }

      final nestedPrevention = _readNestedSection(
        map,
        const [],
        sectionTitles: const [
          'prevention summary',
          'prevention',
          'preventive measures',
        ],
      );
      if (nestedPrevention.isNotEmpty) return nestedPrevention;

      return '';
    }

    final segments = <String>[];
    void addSegment(String type, String title, List<String> keys) {
      final value = read(keys);
      if (value.isEmpty) return;
      segments.add('$type::$title::$value');
    }

    addSegment('PREVENTION', 'Prevention Summary', [
      'prevention_summary',
      'preventionSummary',
      'prevention',
      'preventive_measures',
      'preventiveMeasures',
    ]);

    addSegment('MECHANICAL', 'Mechanical Control', [
      'mechanical',
      'mechanicalControl',
      'mechanical_control',
      'Mechanical Control',
    ]);
    addSegment('BIOLOGICAL', 'Biological Control', [
      'biological',
      'biologicalControl',
      'biological_control',
      'Biological Control',
    ]);
    addSegment('CHEMICAL', 'Chemical Control', [
      'chemical',
      'chemicalControl',
      'chemical_control',
      'Chemical Control',
    ]);
    addSegment('PHYSICAL', 'Physical Control', [
      'physical',
      'physicalControl',
      'physical_control',
      'Physical Control',
    ]);
    addSegment('CULTURAL', 'Cultural Control', [
      'cultural',
      'culturalControl',
      'cultural_control',
      'Cultural Control',
    ]);

    return segments.join('|').trim();
  }

  static String _normalizeSectionContent(dynamic raw) {
    final normalized = _normalizeContent(raw).replaceAll(RegExp(r'<[^>]*>'), '').trim();
    if (normalized == 'no_image' || normalized == 'null' || normalized == '[]') {
      return '';
    }
    return normalized;
  }

  static Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }

  static String _readNestedSection(
    dynamic source,
    List<String> keys, {
    List<String> sectionTitles = const [],
    bool preferTreatmentControls = false,
  }) {
    if (source == null) return '';

    if (source is String || source is num || source is bool) {
      return _normalizeSectionContent(source);
    }

    if (source is List) {
      for (final item in source) {
        final text = _readNestedSection(
          item,
          keys,
          sectionTitles: sectionTitles,
        );
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    if (source is Map) {
      final map = Map<String, dynamic>.from(source);

      for (final key in keys) {
        final raw = map[key];
        if (preferTreatmentControls) {
          final structured = _normalizeTreatments(raw);
          if (structured.isNotEmpty) return structured;
        }
        final text = _normalizeSectionContent(raw);
        if (text.isNotEmpty) return text;
      }

      final title = _normalizeSectionContent(
        map['title'] ?? map['name'] ?? map['heading'] ?? map['label'],
      );
      if (sectionTitles.isNotEmpty && _matchesAnyTitle(title, sectionTitles)) {
        final text = _normalizeSectionContent(
          map['content'] ?? map['description'] ?? map['body'] ?? map['text'] ?? map['value'],
        );
        if (text.isNotEmpty) return text;
      }

      for (final value in map.values) {
        final text = _readNestedSection(
          value,
          keys,
          sectionTitles: sectionTitles,
          preferTreatmentControls: preferTreatmentControls,
        );
        if (text.isNotEmpty) return text;
      }
    }

    return '';
  }

  static bool _matchesAnyTitle(String sourceTitle, List<String> targets) {
    if (sourceTitle.isEmpty) return false;
    final normalizedSource = sourceTitle.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
    for (final target in targets) {
      final normalizedTarget = target.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
      if (normalizedTarget.isEmpty) continue;
      if (normalizedSource == normalizedTarget || normalizedSource.contains(normalizedTarget)) {
        return true;
      }
    }
    return false;
  }

  static String? _normalizeFindings(dynamic raw) {
    // Handle array of {title, content} objects from API
    if (raw is List) {
      final segments = <String>[];
      for (int i = 0; i < raw.length; i++) {
        final item = raw[i];
        if (item is Map<String, dynamic>) {
          final title = item['title']?.toString() ?? '';
          final content = item['content']?.toString() ?? '';
          if (title.isNotEmpty || content.isNotEmpty) {
            segments.add('STAGE_${i + 1}::$title::$content');
          }
        }
      }
      return segments.isNotEmpty ? segments.join('|') : null;
    }
    return null;
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