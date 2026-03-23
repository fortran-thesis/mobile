import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// A customizable button widget for Moldify that can display text, an icon, or an SVG image.
///
/// Parameters:
/// - [buttonText]: The text displayed inside the button.
/// - [onPressed]: Callback function triggered when the button is pressed.
/// - [backgroundColor]: The button's background color.
/// - [textColor]: The color of the button text.
/// - [buttonHeight]: The height of the button.
/// - [buttonWidth]: The width of the button.
/// - [buttonRadius]: The border radius of the button's corners.
/// - [borderColor]: Optional border color; defaults to transparent.
/// - [leftIcon]: Optional Material icon displayed before the text.
/// - [rightIcon]: Optional Material icon displayed after the text.
/// - [svg]: Optional SVG asset path displayed before the text.
/// - [iconColor]: Optional color to tint the icon or SVG.
/// - [rightIconColor]: Optional color to tint the right icon (defaults to iconColor).
/// - [paddingIconText]: Optional horizontal padding between icon/svg and text (default 24.0).
/// - [iconSize]: Optional size for the icon.
/// - [rightIconSize]: Optional size for the right icon (defaults to iconSize).
/// - [svgHeight]: Optional height for the SVG asset.
/// - [fontSize]: Optional font size for the button text (default 16.0).

class BuildButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final Color? borderColor;
  final Color textColor, backgroundColor;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final String? svg;
  final Color? iconColor;
  final Color? rightIconColor;
  final double? paddingIconText, iconSize, rightIconSize, svgHeight, fontSize, borderWidth, buttonWidth;
  final double buttonHeight, buttonRadius;

  const BuildButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    required this.buttonHeight,
    required this.buttonRadius,
    this.buttonWidth,
    this.borderColor,
    this.leftIcon,
    this.rightIcon,
    this.svg,
    this.iconColor,
    this.rightIconColor,
    this.paddingIconText,
    this.iconSize,
    this.rightIconSize,
    this.svgHeight,
    this.fontSize,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: buttonHeight,
      width: buttonWidth,
      child: TextButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonRadius),
              side: BorderSide(
                color: borderColor ?? Colors.transparent,
                width: borderWidth ?? 2.0,
              )
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leftIcon != null)
              Padding(
                padding: EdgeInsets.only(right: paddingIconText ?? 24.0),
                child: Icon(
                  leftIcon,
                  color: iconColor,
                  size: iconSize,
                ),
              ),

            if (svg != null)
              Padding(
                padding: EdgeInsets.only(right: paddingIconText ?? 24.0),
                child: SvgPicture.asset(
                  svg!,
                  height: svgHeight,
                ),
              ),

            AutoSizeText(
              buttonText,
              style: TextStyle(
                overflow: TextOverflow.visible,
                fontFamily: 'Bricolage-Grotesque-Bold',
                fontSize: fontSize ?? 16.0,
                color: textColor,
              ),
              maxLines: 1,
              minFontSize: 8,
              overflow: TextOverflow.ellipsis,
            ),

            if (rightIcon != null)
              Padding(
                padding: EdgeInsets.only(left: paddingIconText ?? 12.0),
                child: Icon(
                  rightIcon,
                  color: rightIconColor ?? iconColor,
                  size: rightIconSize ?? iconSize,
                ),
              ),
          ],
        ),
      ),
    );
  }
}