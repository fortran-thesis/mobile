import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? iconColor;
  final TextStyle? textStyle;
  final double? height;

  const EmptyState({
    super.key,
    required this.message,
    this.icon = FontAwesomeIcons.boxOpen,
    this.iconColor,
    this.textStyle,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 60,
            color: iconColor ?? Colors.grey[400],
          ),
          const SizedBox(height: 10),
          AutoSizeText(
            message,
            style: textStyle ??
                TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontFamily: 'Bricolage-Grotesque-Regular',
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            minFontSize: 10,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (height != null) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: content,
      );
    } else {
      return Container(
        width: double.infinity,
        color: Colors.transparent,
        child: content,
      );
    }
  }
}
