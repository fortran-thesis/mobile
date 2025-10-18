import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/colors.dart';

class ReminderIntervalPicker extends StatefulWidget {
  final int initialNumber;
  final String initialUnit;
  final int maxNumber;
  final ValueChanged<(int, String)>? onChanged;

  const ReminderIntervalPicker({
    super.key,
    this.initialNumber = 1,
    this.initialUnit = 'days',
    this.maxNumber = 7,
    this.onChanged,
  });

  @override
  State<ReminderIntervalPicker> createState() => _ReminderIntervalPickerState();
}

class _ReminderIntervalPickerState extends State<ReminderIntervalPicker> {
  late int selectedNumber;
  late int selectedUnitIndex;
  final List<String> units = ['days', 'weeks', 'months'];

  @override
  void initState() {
    super.initState();
    selectedNumber = widget.initialNumber;
    selectedUnitIndex = units.indexOf(widget.initialUnit);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 16),
      decoration: BoxDecoration(
        color: MoldifyColors.taupe,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    FontAwesomeIcons.repeat,
                    size: 12,
                    color: MoldifyColors.MoldifyGrey,
                  ),
                ),
                TextSpan(
                  text: "			Repeat",
                  style: TextStyle(
                    color: MoldifyColors.MoldifyGrey,
                    fontSize: 12,
                    fontFamily: 'Bricolage-Grotesque-Regular',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: MoldifyColors.primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                // The pickers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      'Every',
                      style: TextStyle(
                        fontFamily: 'Bricolage-Grotesque-SemiBold',
                        fontSize: 16,
                        color: MoldifyColors.primaryColor,
                      ),
                    ),
            
                    // Number picker
                    SizedBox(
                      height: 120,
                      width: 60,
                      child: CupertinoPicker(
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedNumber - 1,
                        ),
                        selectionOverlay:
                        const SizedBox.shrink(), // disable default highlight
                        onSelectedItemChanged: (index) {
                          setState(() => selectedNumber = index + 1);
                          widget.onChanged?.call(
                            (selectedNumber, units[selectedUnitIndex]),
                          );
                        },
                        children: List.generate(widget.maxNumber, (index) {
                          final isSelected = index + 1 == selectedNumber;
                          return Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Bricolage-Grotesque-SemiBold',
                                color: isSelected
                                    ? MoldifyColors.primaryColor
                                    : MoldifyColors.primaryColor.withValues(alpha: 0.5),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
            
                    // Unit picker (days, weeks, months)
                    SizedBox(
                      height: 120,
                      width: 100,
                      child: CupertinoPicker(
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedUnitIndex,
                        ),
                        selectionOverlay:
                        const SizedBox.shrink(),
                        onSelectedItemChanged: (index) {
                          setState(() => selectedUnitIndex = index);
                          widget.onChanged?.call(
                            (selectedNumber, units[selectedUnitIndex]),
                          );
                        },
                        children: units.map((u) {
                          final isSelected = units[selectedUnitIndex] == u;
                          return Center(
                            child: Text(
                              u,
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Bricolage-Grotesque-SemiBold',
                                fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? MoldifyColors.primaryColor
                                    : MoldifyColors.primaryColor.withValues(alpha: 0.5),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
