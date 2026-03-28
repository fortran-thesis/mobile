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
        preferTreatmentControls: true,
      ),
      author: json['author']?.toString() ?? 'Unknown',
      coverPhoto: json['cover_photo']?.toString(),
      tags: _parseTags(json['tags']),
      createdAt: _parseDate(metadata['created_at']) ?? _parseDate(json['created_at']),
      updatedAt: _parseDate(metadata['updated_at']) ?? _parseDate(json['updated_at']),
      mycologistId: json['mycologist_id']?.toString() ?? metadata['mycologist_id']?.toString(),
      approvedAt: _parseDate(metadata['approved_at']) ?? _parseDate(json['approved_at']),
      hostPathogenImpact: _extractHostPathogenImpact(json, metadata),
    );
  }

  static Map<String, String> _extractHostPathogenImpact(
    Map<String, dynamic> json,
    Map<String, dynamic> metadata,
  ) {
    final containers = <Map<String, dynamic>>[];

    Map<String, dynamic>? asStringMap(dynamic raw) {
      if (raw is Map<String, dynamic>) return raw;
      if (raw is Map) return Map<String, dynamic>.from(raw);
      return null;
    }

    final fromRoot = asStringMap(json['host_pathogen_impact']) ?? asStringMap(json['hostPathogenImpact']);
    final fromMeta = asStringMap(metadata['host_pathogen_impact']) ?? asStringMap(metadata['hostPathogenImpact']);
    if (fromRoot != null) containers.add(fromRoot);
    if (fromMeta != null) containers.add(fromMeta);
    containers.add(json);
    containers.add(metadata);

    String read(List<String> keys) {
      for (final container in containers) {
        for (final key in keys) {
          final text = _normalizeContent(container[key]).replaceAll(RegExp(r'<[^>]*>'), '').trim();
          if (text.isNotEmpty) return text;
        }
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
      ]),
      'symptoms_signs': read([
        'symptoms_signs',
        'symptomsSigns',
        'symptoms_and_signs',
        'symptomsAndSigns',
        'symptoms',
        'signs',
      ]),
      'transmission_cycle': read([
        'transmission_cycle',
        'transmissionCycle',
        'cycle_of_transmission',
        'cycleOfTransmission',
        'spread',
      ]),
      'impact_analysis': read([
        'impact_analysis',
        'impactAnalysis',
        'impact',
        'damage_analysis',
        'damageAnalysis',
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

  static String _normalizeTreatments(dynamic raw) {
    if (raw is! Map) return '';

    final map = Map<String, dynamic>.from(raw);

    String read(List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        final text = _normalizeContent(value)
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .trim();
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    final segments = <String>[];
    void addSegment(String type, String title, List<String> keys) {
      final value = read(keys);
      if (value.isEmpty) return;
      segments.add('$type::$title::$value');
    }

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