import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/colors.dart';

/// Reusable empty-state capture card for observation sections.
///
/// Parameters:
/// - [message]: Instructional text to show below the icon.
/// - [height]: Card height to support multiple layouts.
class ObservationEmptyStateCard extends StatelessWidget {
  final String message;
  final double height;

  const ObservationEmptyStateCard({
    super.key,
    required this.message,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: MoldifyColors.primaryColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MoldifyColors.primaryColor.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.biotech_outlined,
            color: MoldifyColors.primaryColor.withValues(alpha: 0.4),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: MoldifyColors.primaryColor.withValues(alpha: 0.5),
              fontFamily: 'Bricolage-Grotesque-Regular',
            ),
          ),
        ],
      ),
    );
  }
}
