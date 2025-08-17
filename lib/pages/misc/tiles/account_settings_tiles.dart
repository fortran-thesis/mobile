import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/colors.dart';

/// This widget builds a tile for account settings with an icon on the left, a title in the center, and an icon on the right.
/// It is designed to be used in a settings page where users can tap on the tile to navigate to different account settings options.
/// Parameters:
/// - [leftIcon]: The icon displayed on the left side of the tile.
/// - [rightIcon]: The icon displayed on the right side of the tile.
/// - [title]: The title text displayed in the center of the tile.
/// - [onTap]: A callback function that is triggered when the tile is tapped.

class BuildAccountSettingsTiles extends StatelessWidget {
  final IconData leftIcon, rightIcon;
  final String title;
  final VoidCallback onTap;

  const BuildAccountSettingsTiles({
        super.key,
        required this.leftIcon,
        required this.rightIcon,
        required this.title,
    required this.onTap
      });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10.0),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: MoldifyColors.taupe,
        ),
        child: Row(
          children: [
            Icon(
              leftIcon,
              color: MoldifyColors.accentColor,
              size: 16,
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Bricolage-Grotesque-Bold',
                color: MoldifyColors.primaryColor,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Icon(
              rightIcon,
              color: MoldifyColors.accentColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}