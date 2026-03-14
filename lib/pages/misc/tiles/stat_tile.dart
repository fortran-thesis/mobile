import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:moldify/pages/misc/colors.dart';

class StatisticTile extends StatelessWidget {
  final IconData icon;
  final Color statusColor; 
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 170;
        final tilePadding = isCompact ? 12.0 : 16.0;
        final iconPadding = isCompact ? 9.0 : 12.0;
        final iconSize = isCompact ? 15.0 : 18.0;
        final valueFontSize = isCompact ? 17.0 : 20.0;
        final labelFontSize = isCompact ? 11.0 : 12.0;
        final labelMaxLines = isCompact ? 1 : 2;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(tilePadding),
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
                  padding: EdgeInsets.all(iconPadding),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: statusColor,
                    size: iconSize,
                  ),
                ),
                SizedBox(width: isCompact ? 10 : 14),
                // Text Section
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        value,
                        maxLines: 1,
                        minFontSize: 9,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: valueFontSize,
                          fontFamily: 'Montserrat-Black',
                          fontWeight: FontWeight.bold,
                          color: MoldifyColors.primaryColor,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AutoSizeText(
                        label,
                        maxLines: labelMaxLines,
                        minFontSize: 8,
                        overflow: TextOverflow.ellipsis,
                        wrapWords: false,
                        style: TextStyle(
                          fontSize: labelFontSize,
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
      },
    );
  }
}