import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/buttons/radio_button_grp.dart';
import 'package:moldify/pages/misc/textboxes/dropdwon.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';

class ReproductiveStructureTab extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;

  // Simplified parent-level callbacks (no string labels)
  final Function(String)? onVesiclePresenceChanged;
  final Function(String?)? onVesicleShapeChanged;
  final Function(String)? onSporangiumPresenceChanged;
  final Function(String)? onSporangiophorePresenceChanged;
  final Function(String)? onColumellaPresenceChanged;
  final Function(String)? onRhizoidPresenceChanged;

  const ReproductiveStructureTab({
    super.key,
    required this.onNext,
    this.onBack,
    this.onVesiclePresenceChanged,
    this.onVesicleShapeChanged,
    this.onSporangiumPresenceChanged,
    this.onSporangiophorePresenceChanged,
    this.onColumellaPresenceChanged,
    this.onRhizoidPresenceChanged,
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
          'Reproductive Structure',
          style: TextStyle(
            fontFamily: 'Montserrat-Black',
            fontSize: 20,
            color: MoldifyColors.primaryColor,
          ),
        ),
        Text(
          'Select the reproductive structural characteristics of the mold.',
          style: TextStyle(
            fontFamily: 'Bricolage-Grotesque-Regular',
            fontSize: 12,
            color: MoldifyColors.MoldifyGrey,
          ),
        ),
        const SizedBox(height: 10),

        /// Vesicle Presence
        _buildDropdownSection(
          label: 'Vesicle Presence',
          child: RadioButtonGroup(
            buttonLabels: ['Present', 'Absent'],
            buttonColors: [MoldifyColors.primaryColor, MoldifyColors.primaryColor],
            selectedTextColor: MoldifyColors.backgroundColor,
            selectedBorderColor: MoldifyColors.primaryColor,
            fontSize: 14,
            onChange: (label, index) {
              if (onVesiclePresenceChanged != null) onVesiclePresenceChanged!(label);
            },
          ),
        ),

        /// Vesicle Shape
        _buildDropdownSection(
          label: 'Vesicle Shape',
          child: BuildDropdown(
            hintText: 'Select vesicle shape',
            items: [
              'Spherical',
              'Globose to Subglobose',
              'Globose',
              'Subglobose',
              'Absent',
              'Cannot assess clearly',
            ],
            onChanged: onVesicleShapeChanged,
          ),
        ),

        /// Sporangium Presence
        _buildDropdownSection(
          label: 'Sporangium Presence',
          child: RadioButtonGroup(
            buttonLabels: ['Present', 'Absent'],
            buttonColors: [MoldifyColors.primaryColor, MoldifyColors.primaryColor],
            selectedTextColor: MoldifyColors.backgroundColor,
            selectedBorderColor: MoldifyColors.primaryColor,
            fontSize: 14,
            onChange: (label, index) {
              if (onSporangiumPresenceChanged != null) onSporangiumPresenceChanged!(label);
            },
          ),
        ),

        /// Sporangiophore Presence
        _buildDropdownSection(
          label: 'Sporangiophore Presence',
          child: RadioButtonGroup(
            buttonLabels: ['Present', 'Absent'],
            buttonColors: [MoldifyColors.primaryColor, MoldifyColors.primaryColor],
            selectedTextColor: MoldifyColors.backgroundColor,
            selectedBorderColor: MoldifyColors.primaryColor,
            fontSize: 14,
            onChange: (label, index) {
              if (onSporangiophorePresenceChanged != null) {
                onSporangiophorePresenceChanged!(label);
              }
            },
          ),
        ),

        /// Columella Presence
        _buildDropdownSection(
          label: 'Columella Presence',
          child: RadioButtonGroup(
            buttonLabels: ['Present', 'Absent'],
            buttonColors: [MoldifyColors.primaryColor, MoldifyColors.primaryColor],
            selectedTextColor: MoldifyColors.backgroundColor,
            selectedBorderColor: MoldifyColors.primaryColor,
            fontSize: 14,
            onChange: (label, index) {
              if (onColumellaPresenceChanged != null) onColumellaPresenceChanged!(label);
            },
          ),
        ),

        /// Rhizoid Presence
        _buildDropdownSection(
          label: 'Rhizoid Presence',
          child: RadioButtonGroup(
            buttonLabels: ['Present', 'Absent'],
            buttonColors: [MoldifyColors.primaryColor, MoldifyColors.primaryColor],
            selectedTextColor: MoldifyColors.backgroundColor,
            selectedBorderColor: MoldifyColors.primaryColor,
            fontSize: 14,
            onChange: (label, index) {
              if (onRhizoidPresenceChanged != null) onRhizoidPresenceChanged!(label);
            },
          ),
        ),

        _buildNavigationButtons(showBack: true),
      ],
    );
  }
}
