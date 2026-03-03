import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/textboxes/dropdwon.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';

class AdditionalCharacteristicsTab extends StatelessWidget {
  final VoidCallback onSubmit;


  // Parent-level callbacks
  final Function(String?)? onPhialideArrangementChanged;
  final Function(String?)? onSterigmataArrangementChanged;

  const AdditionalCharacteristicsTab({
    super.key,
    required this.onSubmit,
    this.onPhialideArrangementChanged,
    this.onSterigmataArrangementChanged,
  });

  Widget _buildDropdownSection({
    required String label,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Bricolage-Grotesque-SemiBold',
              color: MoldifyColors.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildNavigationButtons({bool showBack = false, bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Row(
        children: [
          if (showBack)
          Expanded(
            child: BuildButton(
              onPressed: onSubmit,
              buttonText: 'Submit Characteristics',
              backgroundColor: MoldifyColors.primaryColor,
              textColor: MoldifyColors.backgroundColor,
              buttonHeight: 45,
              buttonRadius: 10,
              buttonWidth: double.infinity,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header
        const Text(
          'Additional Characteristics',
          style: TextStyle(
            fontFamily: 'Montserrat-Black',
            fontSize: 20,
            color: MoldifyColors.primaryColor,
          ),
        ),
        const Text(
          'Select the additional characteristics of the mold.',
          style: TextStyle(
            fontFamily: 'Bricolage-Grotesque-Regular',
            fontSize: 12,
            color: MoldifyColors.MoldifyGrey,
          ),
        ),
        const SizedBox(height: 10),

        /// Phialide Arrangement
        _buildDropdownSection(
          label: 'Phialide Arrangement',
          child: BuildDropdown(
            hintText: 'Select phialide arrangement',
            items: const [
              "Biseriate (Phialides on Metulae)",
              "Metulae and Phialides (Penicillate Structure)",
              "Brush-like",
              "Radial",
              "Terminal",
              "Present (Not Brush-like)",
              "Absent",
              "Cannot Assess Clearly / N/A",
            ],
            onChanged: onPhialideArrangementChanged,
          ),
        ),

        /// Sterigmata Arrangement
        _buildDropdownSection(
          label: 'Sterigmata Arrangement',
          child: BuildDropdown(
            hintText: 'Select sterigmata arrangement',
            items: const [
              "Radiate/Covering entire vesicle",
              "Verticillate/Penicillate",
              "Absent",
              "Cannot Assess Clearly",
            ],
            onChanged: onSterigmataArrangementChanged,
          ),
        ),

        /// Navigation buttons (Back + Submit)
        _buildNavigationButtons(showBack: true, isLast: true),
      ],
    );
  }
}