import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/colors.dart';

/// A custom text box widget for Moldify, designed for use in input fields.
///
/// Parameters:
/// - [hintText]: The placeholder text displayed when the text field is empty.
/// - [controller]: Controls the text being edited. Required for managing the input.
/// - [showPassword]: If true, displays an eye icon to toggle password visibility.
/// - [rightIcon]: An optional icon displayed on the right side of the text box (if not using password toggle).
/// - [isMultiline]: If true, the text field allows multiple lines of input; otherwise, it's single-line.
/// - [textAlign]: The alignment of the text within the text box.
/// - [keyboardType]: The type of keyboard to display (e.g., text, number).
/// - [maxLength]: The maximum number of characters allowed in the text field.
/// - [autoFocus]: If true, the text field will automatically gain focus when the widget is built.
/// - [focusNode]: An optional focus node to manage focus state.
/// - [onChanged]: A callback function that is called when the text in the text box changes.


class BuildTextBox extends StatefulWidget {
  final String hintText;
  final bool showPassword;
  final TextEditingController controller;
  final IconData? rightIcon;
  final bool? isMultiline;
  final TextAlign? textAlign;
  final TextInputType? keyboardType;
  final int? maxLength;
  final double? textboxHeight, fontSize ;
  final bool? autoFocus;
  final FocusNode? focusNode;
  final Function(String)? onChanged;

  const BuildTextBox({
    super.key,
    required this.hintText,
    required this.controller,
    required this.showPassword,
    this.rightIcon,
    this.isMultiline,
    this.textAlign,
    this.keyboardType,
    this.maxLength,
    this.onChanged,
    this.autoFocus,
    this.focusNode,
    this.textboxHeight,
    this.fontSize,
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
      keyboardType: widget.keyboardType ?? TextInputType.text,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      focusNode: widget.focusNode,
      autofocus: widget.autoFocus ?? false,
      style: TextStyle(
        fontSize: widget.fontSize ?? 14,
        color: MoldifyColors.MoldifyBlack,
        fontFamily: 'Bricolage-Grotesque-Regular',
      ),
      maxLines: widget.isMultiline == true ? null : 1,
      minLines: widget.isMultiline == true ? 7 : 1,
      decoration: InputDecoration(
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
            : widget.rightIcon != null
            ? Icon(
            widget.rightIcon,
            color: MoldifyColors.primaryColor,
            size: 8.0,
        )
            : null,
      ),
    );

  }
}
