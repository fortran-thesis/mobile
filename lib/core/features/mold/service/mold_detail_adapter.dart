class MoldDetailAdapter {
  static const Map<String, List<String>> canonicalAliases = {
    'overview': ['overview'],
    'health_risks': ['health risks', 'health risk', 'risk'],
    'affected_hosts': ['affected hosts', 'affected crops', 'hosts', 'host'],
    'symptoms_and_signs': [
      'symptoms and signs',
      'symptoms & signs',
      'symptoms signs',
      'symptoms',
      'signs',
    ],
    'disease_cycle_spread_impact': [
      'disease cycle spread impact',
      'disease cycle spread',
      'disease cycle',
      'spread',
      'impact',
    ],
    'prevention_summary': ['prevention summary', 'prevention'],
  };

  static Map<String, dynamic> asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static String normalizeLabel(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  }

  static Map<String, dynamic> unwrapPayload(Map<String, dynamic>? payload) {
    if (payload == null) return <String, dynamic>{};

    final firstData = payload['data'];
    if (firstData is Map<String, dynamic>) {
      final nestedData = firstData['data'];
      if (nestedData is Map<String, dynamic>) return nestedData;
      return firstData;
    }

    return payload;
  }

  static Map<String, dynamic> extractInfo(Map<String, dynamic>? payload) {
    final root = unwrapPayload(payload);
    final moldDetails = asMap(root['mold_details']);
    final info = asMap(moldDetails['info']);
    if (info.isNotEmpty) return info;

    return asMap(root['info']);
  }

  static Map<String, dynamic> extractPrevention(Map<String, dynamic>? payload) {
    final root = unwrapPayload(payload);
    final moldDetails = asMap(root['mold_details']);
    final prevention = asMap(moldDetails['prevention']);
    if (prevention.isNotEmpty) return prevention;

    return asMap(root['prevention']);
  }

  static String additionalInfoValue(
    Map<String, dynamic> info,
    List<String> aliases,
  ) {
    final rowsRaw = info['additional_info'];
    if (rowsRaw is! List) return '';

    final normalizedAliases = aliases.map(normalizeLabel).toList();
    for (final item in rowsRaw) {
      final row = asMap(item);
      final title = normalizeLabel((row['title'] ?? '').toString());
      final description = (row['description'] ?? row['content'] ?? '')
          .toString()
          .trim();
      if (title.isEmpty || description.isEmpty) continue;

      for (final alias in normalizedAliases) {
        if (title == alias || title.contains(alias) || alias.contains(title)) {
          return description;
        }
      }
    }

    return '';
  }

  static String readField(
    Map<String, dynamic>? payload,
    String key, {
    String fallback = '',
  }) {
    final info = extractInfo(payload);
    if (info.isEmpty) return fallback;

    final directValue = (info[key] ?? info[key.replaceAll('_', '')] ?? '')
        .toString()
        .trim();
    if (directValue.isNotEmpty) return directValue;

    final aliases = canonicalAliases[key] ?? [key];
    final legacyValue = additionalInfoValue(info, aliases);
    if (legacyValue.isNotEmpty) return legacyValue;

    return fallback;
  }

  static String readPreventionControl(
    Map<String, dynamic>? payload,
    List<String> keys,
  ) {
    final prevention = extractPrevention(payload);
    for (final key in keys) {
      final text = (prevention[key] ?? '').toString().trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }
}
