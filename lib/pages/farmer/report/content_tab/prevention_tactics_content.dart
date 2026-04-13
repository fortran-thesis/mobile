import 'package:flutter/material.dart';
import 'package:moldify/l10n/app_localizations.dart';
import '../../../misc/colors.dart';

class PreventionTacticsContent extends StatelessWidget {
  final String treatmentsContent;
  
  // Parsing delimiters for structured data (same as WikiMold)
  static const String _stageDelimiter = '|';
  static const String _fieldDelimiter = '::';

  const PreventionTacticsContent({
    super.key,
    required this.treatmentsContent,
  });

  List<Map<String, String>> _parseStructuredTreatments(String content) {
    if (!content.contains(_fieldDelimiter)) return const [];

    final treatments = content
        .split(_stageDelimiter)
        .where((s) => s.trim().isNotEmpty)
        .toList();

    final entries = <Map<String, String>>[];
    final seenKeys = <String>{};
    for (final treatment in treatments) {
      final parts = treatment.split(_fieldDelimiter);
      if (parts.length < 3) continue;

      final type = parts[0].toUpperCase().trim();
      final title = parts[1].trim();
      final desc = parts.sublist(2).join(_fieldDelimiter).trim();
      if (title.isEmpty || desc.isEmpty) continue;

      final key = '$type::${title.toLowerCase()}';
      if (!seenKeys.add(key)) continue;

      entries.add({
        'type': type,
        'title': title,
        'desc': desc,
      });
    }
    return entries;
  }

  List<Map<String, String>> _orderedSections(String content) {
    final structured = _parseStructuredTreatments(content);
    if (structured.isEmpty) {
      final fallback = content.trim();
      if (fallback.isEmpty) return const [];
      return [
        {
          'title': 'Prevention & Treatment',
          'content': fallback,
        },
      ];
    }

    final preferredOrder = <String>[
      'PREVENTION',
      'MECHANICAL',
      'CULTURAL',
      'BIOLOGICAL',
      'PHYSICAL',
      'CHEMICAL',
    ];

    final byType = <String, Map<String, String>>{};
    final extras = <Map<String, String>>[];

    for (final item in structured) {
      final type = (item['type'] ?? '').toUpperCase();
      final title = (item['title'] ?? '').trim();
      final contentText = (item['desc'] ?? '').trim();
      if (title.isEmpty || contentText.isEmpty) continue;

      final section = <String, String>{
        'title': title,
        'content': contentText,
      };

      if (preferredOrder.contains(type)) {
        byType.putIfAbsent(type, () => section);
      } else {
        extras.add(section);
      }
    }

    final ordered = <Map<String, String>>[];
    for (final type in preferredOrder) {
      final item = byType[type];
      if (item != null) ordered.add(item);
    }
    ordered.addAll(extras);
    return ordered;
  }

  Widget _buildSection({
    required String title,
    required String content,
    required AppLocalizations l10n,
    bool isLast = false,
  }) {
    final hasData = content.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 24.0 : 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 2,
                color: MoldifyColors.accentColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 2.2,
                    fontFamily: 'Montserrat-Black',
                    color: MoldifyColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            hasData ? content : l10n.noPreventionTacticsAvailable,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Bricolage-Grotesque-Regular',
              color: hasData
                  ? MoldifyColors.MoldifyBlack.withValues(alpha: 0.85)
                  : MoldifyColors.MoldifyGrey,
              height: 1.6,
            ),
          ),
          if (!isLast)
            Divider(
              color: MoldifyColors.taupe.withValues(alpha: 0.2),
              thickness: 1,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sections = _orderedSections(treatmentsContent);
    final widgets = <Widget>[];

    if (sections.isEmpty) {
      widgets.add(
        _buildSection(
          title: 'Prevention & Treatment',
          content: '',
          l10n: l10n,
          isLast: true,
        ),
      );
    } else {
      for (int i = 0; i < sections.length; i++) {
        final section = sections[i];
        widgets.add(
          _buildSection(
            title: section['title'] ?? '',
            content: section['content'] ?? '',
            l10n: l10n,
            isLast: i == sections.length - 1,
          ),
        );
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 60.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }
}