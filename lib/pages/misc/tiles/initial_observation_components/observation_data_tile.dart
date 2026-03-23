import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/colors.dart';

/// Reusable tonal tile for observation metadata such as color and texture.
///
/// Parameters:
/// - [label]: Field title displayed in uppercase.
/// - [value]: Field value; shows fallback when blank.
/// - [icon]: Leading icon describing the field.
/// - [fallbackValue]: Text shown when [value] is empty.
class ObservationDataTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String fallbackValue;

  const ObservationDataTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.fallbackValue = '---',
  });

  @override
  Widget build(BuildContext context) {
    final normalized = value.trim();
    final displayValue = normalized.isNotEmpty ? normalized : fallbackValue;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: MoldifyColors.primaryColor.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: MoldifyColors.primaryColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: MoldifyColors.primaryColor),
            const SizedBox(height: 8),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                color: MoldifyColors.primaryColor.withValues(alpha: 0.5),
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              displayValue,
              style: const TextStyle(
                fontFamily: 'Bricolage-Grotesque-SemiBold',
                fontSize: 14,
                color: MoldifyColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
