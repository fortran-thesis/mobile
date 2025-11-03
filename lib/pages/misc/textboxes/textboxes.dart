import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moldify/pages/misc/colors.dart';

/// A custom text box widget for Moldify, designed for use in input fields.
///
/// Parameters:
/// - [hintText]: The placeholder text displayed when the text field is empty.
/// - [controller]: Controls the text being edited. Required for managing the input.
/// - [showPassword]: If true, displays an eye icon to toggle password visibility.
/// - [rightIcon]: An optional icon displayed on the right side of the text box (if not using password toggle).
/// - [suffixIcon]: An optional widget to be displayed at the end of the text field. Overrides [rightIcon].
/// - [isMultiline]: If true, the text field allows multiple lines of input; otherwise, it's single-line.
/// - [textAlign]: The alignment of the text within the text box.
/// - [keyboardType]: The type of keyboard to display (e.g., text, number). Is overridden by [showPhoneNumberPrefix].
/// - [maxLength]: The maximum number of characters allowed in the text field.
/// - [autoFocus]: If true, the text field will automatically gain focus when the widget is built.
/// - [focusNode]: An optional focus node to manage focus state.
/// - [onChanged]: A callback function that is called when the text in the text box changes.
/// - [onTap]: A callback function that is called when the text box is tapped.
/// - [readOnly]: If true, the text field is not editable via the keyboard.
/// - [showPhoneNumberPrefix]: If true, shows a "+63 |" prefix and enables numeric-only input.


class BuildTextBox extends StatefulWidget {
  final String hintText;
  final bool showPassword;
  final TextEditingController controller;
  final IconData? rightIcon;
  final Widget? suffixIcon; // New property for a custom widget
  final bool? isMultiline;
  final TextAlign? textAlign;
  final TextInputType? keyboardType;
  final int? maxLength;
  final double? textboxHeight, fontSize ;
  final bool? autoFocus;
  final FocusNode? focusNode;
  final Color? rightIconColor;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool showPhoneNumberPrefix;


  const BuildTextBox({
    super.key,
    required this.hintText,
    required this.controller,
    required this.showPassword,
    this.rightIcon,
    this.suffixIcon,
    this.isMultiline,
    this.textAlign,
    this.keyboardType,
    this.maxLength,
    this.onChanged,
    this.autoFocus,
    this.focusNode,
    this.textboxHeight,
    this.fontSize,
    this.rightIconColor,
    this.onTap,
    this.readOnly = false,
    this.showPhoneNumberPrefix = false,
  });

  @override
  State<BuildTextBox> createState() => _BuildTextBoxState();
}

class _BuildTextBoxState extends State<BuildTextBox> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {

    return TextFormField(
      controller: widget.controller,
      obscureText: widget.showPassword ? _obscureText : false,
      textAlign: widget.textAlign ?? TextAlign.start,
      keyboardType: widget.showPhoneNumberPrefix ? TextInputType.number : (widget.keyboardType ?? TextInputType.text),
      inputFormatters: widget.showPhoneNumberPrefix
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      focusNode: widget.focusNode,
      autofocus: widget.autoFocus ?? false,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      style: TextStyle(
        fontSize: widget.fontSize ?? 14,
        color: MoldifyColors.MoldifyBlack,
        fontFamily: 'Bricolage-Grotesque-Regular',
      ),
      maxLines: widget.isMultiline == true ? null : 1,
      minLines: widget.isMultiline == true ? 7 : 1,
      decoration: InputDecoration(
        prefixIcon: widget.showPhoneNumberPrefix
            ? Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '+63',
                style: TextStyle(
                  fontSize: widget.fontSize ?? 14,
                  color: MoldifyColors.primaryColor,
                  fontFamily: 'Bricolage-Grotesque-Bold',
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 24,
                width: 1,
                color: MoldifyColors.MoldifyGrey.withValues(alpha:0.5),
              ),
            ],
          ),
        )
            : null,
        counterText: '',
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none
        ),
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          fontSize: 14,
          color: MoldifyColors.MoldifyGrey,
          fontFamily: 'Bricolage-Grotesque-Regular',
        ),
        filled: true,
        fillColor: MoldifyColors.taupe,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 10.0,
        ),
        // Updated logic to prioritize suffixIcon
        suffixIcon: widget.showPassword
            ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: MoldifyColors.primaryColor,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        )
            : widget.suffixIcon ?? // Use the custom widget if provided
            (widget.rightIcon != null
                ? Icon(
              widget.rightIcon,
              color: widget.rightIconColor ?? MoldifyColors.primaryColor,
              size: 16.0,
            )
                : null),
      ),
    );

  }
}