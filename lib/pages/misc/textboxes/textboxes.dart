import 'package:flutter/material.dart';

class BuildTextBox extends StatefulWidget{
  final String? hintText;
  final bool showPassword;
  final IconData? rightIcon;


  const BuildTextBox({
    super.key,
    this.hintText,
    required this.showPassword,
    this.rightIcon,

  });

  @override
  State<BuildTextBox> createState() => _BuildTextBoxState();
}
class _BuildTextBoxState extends State<BuildTextBox> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(

    );
  }
}