import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/colors.dart';

class StatisticTile extends StatelessWidget {
  final IconData icon;
  final Color statusColor; // e.g., MoldifyRed for Rejected, primaryColor for Resolved
  final String value;
  final String label;
  final VoidCallback? onTap;

  const StatisticTile({
    super.key,
    required this.icon,
    required this.statusColor,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MoldifyColors.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          // Subtle border to define the shape against the app background
          border: Border.all(
            color: MoldifyColors.MoldifySoftGrey.withAlpha(80),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: MoldifyColors.MoldifyBlack.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Section: Dynamic background tint matching the icon color
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: statusColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            // Text Section
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Wrap the value in a FittedBox
                  FittedBox(
                    fit: BoxFit.scaleDown, // Shrinks text if too wide, keeps size if small
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'Montserrat-Black',
                        fontWeight: FontWeight.bold,
                        color: MoldifyColors.primaryColor,
                        height: 1.1,
                      ),
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Bricolage-Grotesque-Regular',
                      fontWeight: FontWeight.w600,
                      color: MoldifyColors.MoldifyGrey,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}