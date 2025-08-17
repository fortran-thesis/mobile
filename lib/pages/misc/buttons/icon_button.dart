import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/colors.dart';

/// BuildIconButton is a reusable widget that creates an icon button with a specific style.
/// It is designed to be used in various parts of the application where an icon button is needed
/// Parameters:
/// - [icon]: The icon to be displayed on the button.
/// - [onPressed]: The callback function that is called when the button is pressed.
/// - [color]: The color of the icon. If not provided, it defaults to MoldifyColors.white.

class BuildIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  const BuildIconButton({
    required this.icon,
    required this.onPressed,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
          color: MoldifyColors.backgroundColor,
          borderRadius: BorderRadius.circular(25),
          ),
      child: IconButton(
        icon: Icon(
            icon,
            color: color,
            size: 12.0,
        ),
        onPressed: onPressed,
      ),
    );
  }
}