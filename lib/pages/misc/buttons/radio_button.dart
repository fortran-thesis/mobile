import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/colors.dart';

/// BuildRadioButton is a custom widget that creates a group of radio buttons.
/// It allows users to select one option from a list of options.
/// Parameters:
/// - [numberOfButtons]: The number of radio buttons to display.
/// - [buttonLabels]: A list of labels for each radio button.
/// - [buttonSubtexts]: A list of subtexts for each radio button.
/// - [onButtonSelected]: A callback function that is called when a radio button is selected.
/// - [selectedIndex]: The index of the initially selected radio button (optional).

class BuildRadioButton extends StatefulWidget {
  final int numberOfButtons;
  final List<String> buttonLabels;
  final List<String> buttonSubtexts;
  final Function(int) onButtonSelected;
  final int? selectedIndex;

  BuildRadioButton({
    required this.numberOfButtons,
    required this.buttonLabels,
    required this.buttonSubtexts,
    required this.onButtonSelected,
    this.selectedIndex,
  });

  @override
  _BuildRadioButtonState createState() => _BuildRadioButtonState();
}

class _BuildRadioButtonState extends State<BuildRadioButton> {
  int? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(widget.numberOfButtons, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedValue = index;
            });
            widget.onButtonSelected(index);
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Radio<int>(
                  value: index,
                  groupValue: selectedValue,
                  onChanged: (int? value) {
                    setState(() {
                      selectedValue = value;
                    });
                    widget.onButtonSelected(index);
                  },
                  activeColor: MoldifyColors.accentColor,
                  fillColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) =>
                    states.contains(WidgetState.selected)
                        ? MoldifyColors.accentColor
                        : MoldifyColors.accentColor,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.buttonLabels[index],
                        style: TextStyle(
                          fontFamily: 'Montserrat-Black',
                          fontSize: 16,
                          color: MoldifyColors.primaryColor,
                        ),
                        softWrap: true,
                      ),
                      if (widget.buttonSubtexts[index].isNotEmpty)
                        Text(
                          widget.buttonSubtexts[index],
                          style: TextStyle(
                            fontFamily: 'Bricolage-Grotesque-Regular',
                            fontSize: 14,
                            color: MoldifyColors.MoldifyBlack,
                          ),
                          softWrap: true,
                          textAlign: TextAlign.justify,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
