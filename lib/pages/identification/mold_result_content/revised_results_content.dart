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
            (entry) {
              final label = entry.key;
              final body = entry.value.isNotEmpty ? entry.value : 'No data available yet.';
              final isWarning = label == 'HEALTH RISKS' && body != 'No data available yet.';

              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: 'Bricolage-Grotesque-Bold',
                            fontSize: 12,
                            letterSpacing: 1.0,
                            color: isWarning
                                ? Colors.redAccent.withValues(alpha: 0.8)
                                : MoldifyColors.primaryColor.withValues(alpha: 0.7),
                          ),
                        ),
                        if (isWarning) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.redAccent),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      body,
                      style: TextStyle(
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        fontSize: 16,
                        height: 1.6,
                        color: MoldifyColors.MoldifyBlack.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              );
            },
          )
          .toList(),
    );
  }
}
