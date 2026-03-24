import '../../../core/features/mold/service/mold_service.dart';

/// Utility parser/formatter used by the report view layer.
///
/// This class centralizes transformation logic so UI widgets can stay focused
/// on rendering rather than parsing text formats or normalizing section names.
class ReportViewParser {
  /// Converts a confidence value into a percentage string with one decimal.
  ///
  /// Accepts numeric or string-like values (for example, `87.45` or `"87.45"`)
  /// and returns values like `"87.5%"`.
  ///
  /// Returns an empty string when [value] is null or cannot be parsed.
  static String formatConfidence(dynamic value) {
    if (value == null) return '';
    if (value is num) {
      return '${value.toStringAsFixed(1)}%';
    }
    final parsed = double.tryParse(value.toString());
    if (parsed == null) return '';
    return '${parsed.toStringAsFixed(1)}%';
  }

  /// Parses raw mycologist notes into a list of `{title, content}` sections.
  ///
  /// Supported input styles:
  /// - Delimited style: `TYPE::Title::Content|TYPE::Title::Content`
  /// - Inline style: `Title: Content`
  /// - Block style with headings ending in `:` followed by content lines
  ///
  /// If no structured pattern is detected, this returns a single
  /// `General Notes` section.
  ///
  /// Parameters:
  /// - [rawNotes]: Unstructured or semi-structured note text.
  ///
  /// Returns:
  /// - A non-empty list of maps containing `title` and `content`.
  static List<Map<String, String>> parseMycologistNoteSections(String rawNotes) {
    final notes = rawNotes.trim();
    if (notes.isEmpty) {
      return const [
        {
          'title': 'General Notes',
          'content': 'No recommendation notes from mycologist yet.',
        }
      ];
    }

    if (notes.contains('::') && notes.contains('|')) {
      final sections = notes
          .split('|')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .map((part) {
            final pieces = part.split('::');
            final title = pieces.length > 1 && pieces[1].trim().isNotEmpty
                ? pieces[1].trim()
                : 'General Notes';
            final content = pieces.length > 2
                ? pieces.sublist(2).join('::').trim()
                : (pieces.length == 2 ? pieces[1].trim() : part);
            return {
              'title': title,
              'content': content,
            };
          })
          .where((section) => (section['content'] ?? '').isNotEmpty)
          .toList();

      if (sections.isNotEmpty) return sections;
    }

    final lines = notes
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final inlineSections = <Map<String, String>>[];
    final inlinePattern = RegExp(r'^([A-Za-z][A-Za-z\s/&()\-]{1,40}):\s+(.+)$');
    for (final line in lines) {
      final match = inlinePattern.firstMatch(line);
      if (match != null) {
        inlineSections.add({
          'title': match.group(1)!.trim(),
          'content': match.group(2)!.trim(),
        });
      }
    }
    if (inlineSections.length >= 2) return inlineSections;

    final headingPattern = RegExp(r'^[A-Za-z][A-Za-z\s/&()\-]{1,40}:$');
    final sectionList = <Map<String, String>>[];
    String currentTitle = 'General Notes';
    final buffer = <String>[];

    void flushSection() {
      if (buffer.isEmpty) return;
      sectionList.add({
        'title': currentTitle,
        'content': buffer.join('\n').trim(),
      });
      buffer.clear();
    }

    for (final line in lines) {
      if (headingPattern.hasMatch(line)) {
        flushSection();
        currentTitle = line.substring(0, line.length - 1).trim();
      } else {
        buffer.add(line);
      }
    }
    flushSection();

    if (sectionList.isNotEmpty) return sectionList;

    return [
      {
        'title': 'General Notes',
        'content': notes,
      }
    ];
  }

  /// Normalizes a section key for tolerant matching.
  ///
  /// Converts to lowercase and removes non-alphanumeric characters, so titles
  /// with punctuation/spacing differences can still be matched reliably.
  static String normalizeSectionKey(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  /// Finds the first matching section content using alias-based title matching.
  ///
  /// Parameters:
  /// - [sections]: Parsed sections where each item has `title` and `content`.
  /// - [aliases]: Candidate names for a logical section (for example,
  ///   Overview aliases from backend variations).
  ///
  /// Matching is tolerant and accepts exact or partial normalized matches.
  /// Returns an empty string if no match is found.
  static String findSectionContent(
    List<Map<String, String>> sections,
    List<String> aliases,
  ) {
    final normalizedAliases = aliases.map(normalizeSectionKey).toList();

    for (final section in sections) {
      final title = section['title'] ?? '';
      final titleKey = normalizeSectionKey(title);
      if (titleKey.isEmpty) continue;

      final matches = normalizedAliases.any(
        (alias) => titleKey == alias || titleKey.contains(alias) || alias.contains(titleKey),
      );
      if (matches) {
        return (section['content'] ?? '').trim();
      }
    }
    return '';
  }

  /// Returns true if [title] represents prevention/control content.
  ///
  /// Recognized titles include `Prevention` and the five control categories:
  /// mechanical, cultural, biological, physical, and chemical.
  static bool isPreventionControlSectionTitle(String title) {
    final normalized = title.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    return normalized == 'prevention' ||
        normalized == 'mechanicalcontrol' ||
        normalized == 'culturalcontrol' ||
        normalized == 'biologicalcontrol' ||
        normalized == 'physicalcontrol' ||
        normalized == 'chemicalcontrol';
  }

        /// Maps a human-readable control section title to a canonical type token.
        ///
        /// Returns one of: `MECHANICAL`, `CULTURAL`, `BIOLOGICAL`, `PHYSICAL`,
        /// `CHEMICAL`, or `PREVENTION` (fallback).
  static String sectionTypeFromTitle(String title) {
    final normalized = title.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (normalized == 'mechanicalcontrol') return 'MECHANICAL';
    if (normalized == 'culturalcontrol') return 'CULTURAL';
    if (normalized == 'biologicalcontrol') return 'BIOLOGICAL';
    if (normalized == 'physicalcontrol') return 'PHYSICAL';
    if (normalized == 'chemicalcontrol') return 'CHEMICAL';
    return 'PREVENTION';
  }

  /// Builds a serialized treatments string from parsed control sections.
  ///
  /// This method:
  /// - Filters empty entries
  /// - Deduplicates by control type (first seen wins)
  /// - Orders output consistently for stable UI rendering
  ///
  /// Output format: `TYPE::Title::Content|TYPE::Title::Content`.
  static String buildTreatmentsFromControlSections(List<Map<String, String>> sections) {
    final byType = <String, Map<String, String>>{};
    for (final section in sections) {
      final title = (section['title'] ?? '').trim();
      final content = (section['content'] ?? '').trim();
      if (title.isEmpty || content.isEmpty) continue;
      final type = sectionTypeFromTitle(title);
      byType.putIfAbsent(type, () => {
            'title': title,
            'content': content,
          });
    }

    final order = <String>[
      'PREVENTION',
      'MECHANICAL',
      'BIOLOGICAL',
      'CHEMICAL',
      'PHYSICAL',
      'CULTURAL',
    ];

    final segments = <String>[];
    for (final type in order) {
      final section = byType[type];
      if (section == null) continue;
      segments.add('$type::${section['title']}::${section['content']}');
    }

    return segments.join('|');
  }

  /// Creates serialized prevention/control content from a mold catalog record.
  ///
  /// Reads known prevention keys from [mold.prevention], converts them to the
  /// same serialized format expected by report UI components, and keeps a stable
  /// control ordering.
  ///
  /// Parameters:
  /// - [mold]: Catalog entry containing prevention/control text.
  /// - [defaultContent]: Fallback text to use when no prevention values exist.
  ///
  /// Returns:
  /// - Serialized treatment segments, or [defaultContent] if no segments exist.
  static String buildPreventionContentFromMold(
    MoldCatalogEntry mold,
    String defaultContent,
  ) {
    final prevention = mold.prevention;

    String segment(String type, String title, String key) {
      final text = prevention[key]?.trim() ?? '';
      if (text.isEmpty) return '';
      return '$type::$title::$text';
    }

    final segments = <String>[
      segment('MECHANICAL', 'Mechanical Control', 'Mechanical Control'),
      segment('BIOLOGICAL', 'Biological Control', 'Biological Control'),
      segment('CHEMICAL', 'Chemical Control', 'Chemical Control'),
      segment('PHYSICAL', 'Physical Control', 'Physical Control'),
      segment('CULTURAL', 'Cultural Control', 'Cultural Control'),
    ].where((s) => s.isNotEmpty).toList();

    if (segments.isEmpty) return defaultContent;
    return segments.join('|');
  }
}
