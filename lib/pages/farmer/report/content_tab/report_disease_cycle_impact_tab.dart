import 'package:flutter/material.dart';
import '../../../misc/colors.dart';

class ReportDiseaseCycleImpactTab extends StatelessWidget {
  /// Parsed sections from mycologist notes: {title, content}
  final List<Map<String, String>> sections;

  /// Section aliases that this tab displays
  static final Map<String, List<String>> _sectionAliases = {
    'Disease Cycle / Spread': ['disease cycle', 'cycle', 'spread', 'transmission'],
    'Infection Mechanism': ['infection mechanism', 'mechanism', 'infection'],
    'Soil Inoculum Details': ['soil inoculum', 'inoculum', 'soil'],
    'Peanut-Specific Impact': ['on peanuts specifically', 'peanuts', 'peanut'],
    'Mycotoxin Risk Assessment': ['mycotoxin risk', 'mycotoxin', 'toxin'],
    'Overall Impact': ['impact', 'consequence', 'implications'],
  };

  const ReportDiseaseCycleImpactTab({
    super.key,
    required this.sections,
  });

  /// Normalize text for case-insensitive matching
  static String _normalizeKey(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  /// Find content for a section using alias matching
  String _findSectionContent(String displayTitle, List<String> aliases) {
    final normalizedAliases = aliases.map(_normalizeKey).toList();
    
    for (final section in sections) {
      final title = section['title'] ?? '';
      if (normalizedAliases.contains(_normalizeKey(title))) {
        return section['content'] ?? '';
      }
    }
    return '';
  }

  Widget _buildSection({
    required String title,
    required String content,
    bool isLast = false,
  }) {
    final bool hasData = content.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 40.0 : 48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Architectural Accent Header
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

          // 2. High-Readability Justified Content
          Text(
            hasData ? content : 'Scientific data pending review...',
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

          // 3. Section Separation Line
          if (!isLast) ...[
            Divider(
              color: MoldifyColors.taupe.withValues(alpha: 0.2),
              thickness: 1,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sectionTitles = _sectionAliases.keys.toList();
    final displayedSections = <Widget>[];

    for (int i = 0; i < sectionTitles.length; i++) {
      final displayTitle = sectionTitles[i];
      final aliases = _sectionAliases[displayTitle]!;
      final content = _findSectionContent(displayTitle, aliases);

      displayedSections.add(
        _buildSection(
          title: displayTitle,
          content: content,
          isLast: i == sectionTitles.length - 1,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 60.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: displayedSections,
      ),
    );
  }
}