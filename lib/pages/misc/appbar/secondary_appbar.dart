import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/colors.dart';

/// A secondary app bar widget that displays a title and a background color.
/// This app bar is typically used for authentication or account settings screens.
/// Parameters:
/// - [title]: The title text to display in the app bar.
/// - [color]: The background color of the app bar title text.
/// - [themeColor]: An optional color for the app bar icon theme, defaults to primary color if not provided.

class SecondaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color color;
  final Color? themeColor;

  const SecondaryAppBar({
    Key? key,
    required this.title,
    required this.color,
    this.themeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Bricolage-Grotesque-Bold',
            fontSize: 16,
            color:color,
          ),
      ),
      centerTitle: true,
      automaticallyImplyLeading: true,
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(
          color: themeColor ?? MoldifyColors.primaryColor
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}