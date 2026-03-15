import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/colors.dart';

class RevisedResultsContent extends StatelessWidget {
  final Map<String, String> sections;

  const RevisedResultsContent({
    super.key,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Bold',
                      fontSize: 12,
                      letterSpacing: 1.0,
                      color: MoldifyColors.primaryColor.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.value.isNotEmpty ? entry.value : 'No data available yet.',
                    style: TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Regular',
                      fontSize: 16,
                      height: 1.6,
                      color: MoldifyColors.MoldifyBlack.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
