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


class BuildTextBox extends StatefulWidget {
  final String hintText;
  final bool showPassword;
  final IconData? rightIcon;
  final bool? isMultiline;
  final TextEditingController controller;

  const BuildTextBox({
    super.key,
    required this.hintText,
    required this.controller,
    required this.showPassword,
    this.rightIcon,
    this.isMultiline,
  });

  @override
  State<BuildTextBox> createState() => _BuildTextBoxState();
}

class _BuildTextBoxState extends State<BuildTextBox> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: TextFormField(
        autofocus: false,
        controller: widget.controller,
        obscureText: widget.showPassword ? _obscureText : false,
        style: const TextStyle(
          fontSize: 12,
          color: MoldifyColors.MoldifyBlack,
          fontFamily: 'Bricolage-Grotesque-Regular',
        ),
        maxLines: widget.isMultiline == true ? null : 1,
        minLines: widget.isMultiline == true ? 4 : 1,
        decoration: InputDecoration(
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
            fontSize: 12,
            color: MoldifyColors.MoldifyGrey,
            fontFamily: 'Bricolage-Grotesque-Regular',
          ),
          filled: true,
          fillColor: MoldifyColors.taupe,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 5.0,
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
              ? Icon(widget.rightIcon,
              color: MoldifyColors.primaryColor)
              : null,
        ),
      ),
    );
  }
}
