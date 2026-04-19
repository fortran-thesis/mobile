import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/colors.dart';

class RevisedResultsContent extends StatelessWidget {
  final Map<String, String> sections;

  const RevisedResultsContent({
    super.key,
    required this.sections,
  });

  String _sanitizeDisplayText(String raw) {
    var value = raw.trim();
    if (value.isEmpty) return value;

    value = value.replaceAll(r'\"', '"').replaceAll(r"\'", "'");

    while (value.length >= 2 &&
        ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'")))) {
      value = value.substring(1, value.length - 1).trim();
    }

    return value;
  }

  Widget _buildTextSection(String label, String body) {
    final normalizedBody = _sanitizeDisplayText(body);
    final showWarningStyle =
        label == 'HEALTH RISKS' && normalizedBody != 'No data available yet.';

    final paragraphs = normalizedBody
        .split(RegExp(r'\n\s*\n'))
        .map((line) => _sanitizeDisplayText(line))
        .where((line) => line.isNotEmpty)
        .toList();

    final resolvedParagraphs = paragraphs.isEmpty
        ? <String>[_sanitizeDisplayText(normalizedBody)]
        : paragraphs;

    List<String> parseBulletItems() {
      if (normalizedBody.trim().isEmpty ||
          normalizedBody.trim() == 'No data available yet.') {
        return const <String>[];
      }

      if (label == 'AFFECTED CROPS / HOSTS') {
        return normalizedBody
            .split(RegExp(r'[,;\n]+'))
            .map((item) => _sanitizeDisplayText(item))
            .where((item) => item.isNotEmpty)
            .toList();
      }

      if (label == 'HEALTH RISKS' || label == 'SYMPTOMS & SIGNS') {
        final lines = normalizedBody
            .split(RegExp(r'\n+'))
            .map((line) => _sanitizeDisplayText(line))
            .where((line) => line.isNotEmpty)
            .map((line) => line.replaceFirst(RegExp(r'^[-*•]\s*'), '').trim())
            .map((line) => _sanitizeDisplayText(line))
            .where((line) => line.isNotEmpty)
            .toList();

        if (lines.length > 1) return lines;

        return normalizedBody
            .split(RegExp(r'\s+-\s+|;|\n'))
            .map((item) => _sanitizeDisplayText(item))
            .where((item) => item.isNotEmpty)
            .toList();
      }

      return const <String>[];
    }

    final bulletItems = parseBulletItems();
    final showBullets = bulletItems.length > 1;
    final isAffectedSection = label == 'AFFECTED CROPS / HOSTS';
    final affectedCount = isAffectedSection ? bulletItems.length : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Bricolage-Grotesque-Bold',
                  fontSize: 16,
                  letterSpacing: 1.2,
                  color: showWarningStyle
                      ? MoldifyColors.MoldifyRed
                      : MoldifyColors.primaryColor,
                ),
              ),
              if (showWarningStyle) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: MoldifyColors.MoldifyRed,
                ),
              ],
            ],
          ),
          if (isAffectedSection)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Affected crops: $affectedCount',
                style: TextStyle(
                  fontFamily: 'Bricolage-Grotesque-SemiBold',
                  fontSize: 16,
                  color: MoldifyColors.MoldifyBlack.withValues(alpha: 0.5),
                ),
              ),
            ),
          const SizedBox(height: 10),
          if (showBullets)
            ...bulletItems.asMap().entries.map(
              (entry) => Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key == bulletItems.length - 1 ? 0 : 10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, right: 10.0),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: MoldifyColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontFamily: 'Bricolage-Grotesque-Regular',
                          fontSize: 16,
                          height: 1.65,
                          color: MoldifyColors.MoldifyBlack.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...resolvedParagraphs.asMap().entries.map(
              (entry) => Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key == resolvedParagraphs.length - 1 ? 0 : 12,
                ),
                child: Text(
                  entry.value,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    fontSize: 16,
                    height: 1.65,
                    color: MoldifyColors.MoldifyBlack.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayEntries = sections.entries
        .where((entry) => entry.key != 'PREVENTION')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: displayEntries
          .map((entry) {
            final body = entry.value.isNotEmpty
                ? entry.value
                : 'No data available yet.';
            return _buildTextSection(entry.key, body);
          })
          .toList(),
    );
  }
}
