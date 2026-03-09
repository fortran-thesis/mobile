import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';

/// A customizable radio-style button group using PrimaryButton widgets.
class RadioButtonGroup extends StatefulWidget {
  final List<String> buttonLabels;
  final List<Color> buttonColors; // Colors for each button when selected
  final bool isClickable;
  final int initialSelectedIndex;
  final double? fontSize;
  final Function(String label, int index)? onChange;

  // 👇 Optional custom color overrides
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final Color? selectedBorderColor;
  final Color? unselectedBorderColor;

  const RadioButtonGroup({
    super.key,
    this.initialSelectedIndex = 0,
    required this.buttonLabels,
    required this.buttonColors,
    this.isClickable = true,
    this.onChange,
    this.fontSize,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.selectedBorderColor,
    this.unselectedBorderColor,
  }) : assert(
  buttonLabels.length == buttonColors.length,
  'Each button must have a corresponding color',
  );

  @override
  State<RadioButtonGroup> createState() => _RadioButtonGroupState();
}

class _RadioButtonGroupState extends State<RadioButtonGroup> {
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex;
  }

  void _onButtonPressed(int index) {
    if (!widget.isClickable) return;

    setState(() => _selectedIndex = index);
    widget.onChange?.call(widget.buttonLabels[index], index);
  }

  @override
  void didUpdateWidget(RadioButtonGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSelectedIndex != widget.initialSelectedIndex) {
      _selectedIndex = widget.initialSelectedIndex;
    }
  }

  // ---------- Color helpers ----------

  Color _getBackgroundColor(int index) {
    return _selectedIndex == index
        ? widget.buttonColors[index]
        : Colors.transparent;
  }

  Color _getTextColor(int index) {
    if (_selectedIndex == index) {
      return widget.selectedTextColor ?? Colors.white;
    }
    return widget.unselectedTextColor ?? MoldifyColors.MoldifyBlack;
  }

  Color _getBorderColor(int index) {
    if (_selectedIndex == index) {
      return widget.selectedBorderColor ?? widget.buttonColors[index];
    }
    return widget.unselectedBorderColor ?? MoldifyColors.MoldifyGrey;
  }

  // ---------- Build widget ----------

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.buttonLabels.length, (index) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: BuildButton(
              onPressed: () => _onButtonPressed(index),
              buttonText: widget.buttonLabels[index],
              backgroundColor: _getBackgroundColor(index),
              textColor: _getTextColor(index),
              borderColor: _getBorderColor(index),
              fontSize: widget.fontSize ?? 12,
              buttonHeight: 40,
              buttonWidth: 120,
              buttonRadius: 10,
              borderWidth: 1.0,
            ),
          ),
        );
      }),
    );
  }
}
