import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/colors.dart';

/// PrimaryAppBar is a custom AppBar widget used throughout the Moldify application.
/// It features a title, an optional right icon, and a callback for when the icon is pressed.
/// Parameters:
/// - [title]: The title of the AppBar.
/// - [rightIcon]: An optional icon displayed on the right side of the AppBar.
/// - [onRightIconPressed]: A callback function that is called when the right icon is pressed.
/// - [rightIconColor]: An optional color for the right icon.

class PrimaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Icon? rightIcon;
  final VoidCallback? onRightIconPressed;
  final Color? rightIconColor;

  const PrimaryAppBar({
    super.key,
    required this.title,
    this.rightIcon,
    this.onRightIconPressed,
    this.rightIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Bricolage-Grotesque-Bold',
          fontSize: 16,
          color: MoldifyColors.primaryColor,
        ),
      ),
      centerTitle: true,
      backgroundColor: MoldifyColors.taupe,
      automaticallyImplyLeading: true,
      iconTheme: IconThemeData(
        color: MoldifyColors.primaryColor,
      ),
      actions: [
        if (rightIcon != null)
          IconButton(
            icon: rightIcon!,
            onPressed: onRightIconPressed,
            color: rightIconColor ?? MoldifyColors.primaryColor,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}