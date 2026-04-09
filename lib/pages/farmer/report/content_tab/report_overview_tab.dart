import 'package:flutter/material.dart';
import 'package:moldify/l10n/app_localizations.dart';
import '../../../misc/colors.dart';

class ReportOverviewTab extends StatelessWidget {
  /// Parsed sections from mycologist notes: {title, content}
  final List<Map<String, String>> sections;

  /// Section aliases that this tab displays
  static final Map<String, List<String>> _sectionAliases = {
    'Overview': ['overview', 'introduction', 'summary'],
    'Health Risks': ['health risks', 'health risk', 'human risk', 'risk', 'health', 'safety'],
  };

  const ReportOverviewTab({
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
    required AppLocalizations l10n,
    bool isLast = false,
  }) {
    final bool hasData = content.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 24.0 : 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Thin Header Line with Accent
          Row(
            children: [
              Container(
                width: 40,
                height: 2,
                color: MoldifyColors.accentColor,
              ),
              const SizedBox(width: 12),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 2.5,
                  fontFamily: 'Montserrat-Black',
                  color: MoldifyColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. Justified Body Text
          Text(
            hasData ? content : l10n.informationUnavailable,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 18, // Large, clear, and professional
              fontFamily: 'Bricolage-Grotesque-Regular',
              color: hasData
                  ? MoldifyColors.MoldifyBlack.withValues(alpha: 0.85)
                  : MoldifyColors.MoldifyGrey,
              height: 1.6, // Spacious line height
            ),
          ),

          // 3. Bottom Hairline Divider (except for the last section)
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
    final l10n = AppLocalizations.of(context)!;
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
          l10n: l10n,
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