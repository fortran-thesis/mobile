import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/colors.dart';

class BuildDropdown extends StatefulWidget {
  final String hintText;
  final List<String> items;
  final String? initialValue;
  final ValueChanged<String?>? onChanged;

  const BuildDropdown({
    super.key,
    required this.hintText,
    required this.items,
    this.initialValue,
    this.onChanged,
  });

  @override
  State<BuildDropdown> createState() => _BuildDropdownState();
}

class _BuildDropdownState extends State<BuildDropdown> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant BuildDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        selectedValue = widget.initialValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: selectedValue != null ? MoldifyColors.MoldifyBlack : MoldifyColors.taupe,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          dropdownColor: MoldifyColors.backgroundColor,
          hint: Text(
            widget.hintText,
            style: const TextStyle(
              fontFamily: 'Bricolage-Grotesque-Regular',
              fontSize: 14,
              color: MoldifyColors.MoldifyGrey,
            ),
          ),
          style: TextStyle(
            fontFamily: 'Bricolage-Grotesque-SemiBold',
            fontSize: 14,
            color: selectedValue != null ? MoldifyColors.backgroundColor : MoldifyColors.MoldifyBlack,
            fontWeight: selectedValue != null ? FontWeight.w700 : FontWeight.w400,
          ),
          icon: const Icon(
              FontAwesomeIcons.chevronDown,
              color: MoldifyColors.accentColor,
              size: 16
          ),
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          items: widget.items.map((item) {
            final isSelected = item == selectedValue;
            return DropdownMenuItem<String>(
              value: item,
              child: Container(
                color: isSelected ? MoldifyColors.MoldifyBlack : Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  item,
                  style: TextStyle(
                    fontFamily: isSelected ? 'Bricolage-Grotesque-SemiBold' : 'Bricolage-Grotesque-Regular',
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected ? MoldifyColors.backgroundColor : MoldifyColors.MoldifyBlack,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => selectedValue = value);
            widget.onChanged?.call(value);
          },
        ),
      ),
    );
  }
}
