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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: MoldifyColors.taupe,
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
              color: Colors.black54,
            ),
          ),
          icon: const Icon(
              FontAwesomeIcons.chevronDown,
              color: MoldifyColors.accentColor,
              size: 16
          ),
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          items: widget.items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Container(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    fontSize: 14,
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
