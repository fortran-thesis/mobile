import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/buttons/radio_button_grp.dart';
import 'package:moldify/pages/misc/textboxes/dropdwon.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';

class ConidiophoreFeaturesTab extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;

  // Simplified parent-level callbacks (no string labels)
  final Function(String)? onConidiophorePresenceChanged;
  final Function(String?)? onConidiophoreBranchingChanged;
  final Function(String?)? onConidiophoreLengthChanged;
  final Function(String?)? onConidiophoreSurfaceChanged;

  const ConidiophoreFeaturesTab({
    super.key,
    required this.onNext,
    this.onBack,
    this.onConidiophorePresenceChanged,
    this.onConidiophoreBranchingChanged,
    this.onConidiophoreLengthChanged,
    this.onConidiophoreSurfaceChanged,
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

  Widget _buildNavigationButtons({bool showBack = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Column(
        children: [
          if (showBack)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Expanded(
                child: BuildButton(
                  onPressed: onBack!,
                  buttonText: 'Go Back',
                  backgroundColor: MoldifyColors.backgroundColor,
                  textColor: MoldifyColors.primaryColor,
                  buttonHeight: 45,
                  buttonRadius: 10,
                  borderColor: MoldifyColors.primaryColor,
                  buttonWidth: double.infinity,
                ),
              ),
            ),
          if (showBack) const SizedBox(width: 10),
          BuildButton(
            onPressed: onNext,
            buttonText: 'Next Section',
            backgroundColor: MoldifyColors.primaryColor,
            textColor: MoldifyColors.backgroundColor,
            buttonHeight: 45,
            buttonRadius: 10,
            buttonWidth: double.infinity,
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
        Text(
          'Conidiophore Features',
          style: TextStyle(
            fontFamily: 'Montserrat-Black',
            fontSize: 20,
            color: MoldifyColors.primaryColor,
          ),
        ),
        Text(
          'Select the conidiophore features of the mold.',
          style: TextStyle(
            fontFamily: 'Bricolage-Grotesque-Regular',
            fontSize: 12,
            color: MoldifyColors.MoldifyGrey,
          ),
        ),
        /// End of Header
        const SizedBox(height: 10),

        /// Conidiophore Presence
        _buildDropdownSection(
          label: 'Conidiophore Presence',
          child: RadioButtonGroup(
            buttonLabels: ['Present', 'Absent'],
            buttonColors: [MoldifyColors.primaryColor, MoldifyColors.primaryColor],
            selectedTextColor: MoldifyColors.backgroundColor,
            selectedBorderColor: MoldifyColors.primaryColor,
            fontSize: 14,
            onChange: (label, index) {
              if (onConidiophorePresenceChanged != null) onConidiophorePresenceChanged!(label);
            },
          ),
        ),

        /// Conidiophore Branching
        _buildDropdownSection(
          label: 'Conidiophore Branching',
          child: BuildDropdown(
            hintText: 'Select conidiophore branching',
            items: [
              'Simple',
              'Variable',
              'Branched',
              'Slightly Branched',
              'Unbranched',
              'Cannot assess clearly'
            ],
            onChanged: onConidiophoreBranchingChanged,
          ),
        ),

        /// Conidiophore Length
        _buildDropdownSection(
          label: 'Conidiophore Length',
          child: BuildDropdown(
            hintText: 'Select conidiophore length',
            items: [
              'Short',
              'Medium',
              'Long',
              'Short-Medium',
              'Medium-Long',
              'Cannot assess clearly',
            ],
            onChanged: onConidiophoreLengthChanged,
          ),
        ),

        /// Conidiophore Surface
        _buildDropdownSection(
          label: 'Conidiophore Surface',
          child: BuildDropdown(
            hintText: 'Select conidiophore surface',
            items: [
              'Smooth',
              'Rough',
              'Smooth to Rough',
            ],
            onChanged: onConidiophoreSurfaceChanged,
          ),
        ),
        _buildNavigationButtons(showBack: true),
      ],
    );
  }
}
