import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/textboxes/dropdwon.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/core/constants/morphology_schema.dart';

class GeneralStructureTab extends StatelessWidget {
  final VoidCallback onNext;

  // Simplified callbacks
  final Function(String)? onPresenceChanged;
  final Function(String?)? onSeptationChanged;
  final Function(String?)? onBranchingChanged;
  final Function(String?)? onWidthChanged;
  final Function(String?)? onPigmentationChanged;

  const GeneralStructureTab({
    super.key,
    required this.onNext,
    this.onPresenceChanged,
    this.onSeptationChanged,
    this.onBranchingChanged,
    this.onWidthChanged,
    this.onPigmentationChanged,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'General Structure',
          style: TextStyle(
            fontFamily: 'Montserrat-Black',
            fontSize: 20,
            color: MoldifyColors.primaryColor,
          ),
        ),
        Text(
          'Select the general structural characteristics of the mold.',
          style: TextStyle(
            fontFamily: 'Bricolage-Grotesque-Regular',
            fontSize: 12,
            color: MoldifyColors.MoldifyGrey,
          ),
        ),
        const SizedBox(height: 10),

        _buildDropdownSection(
          label: 'Hyphae Presence',
          child: BuildDropdown(
            hintText: 'Select hyphae presence',
            items: MorphologySchema.getValidValues('Hyphae_Presence') ?? [],
            onChanged: (value) {
              if (onPresenceChanged != null && value != null) onPresenceChanged!(value);
            },
          ),
        ),

        _buildDropdownSection(
          label: 'Hyphae Septation',
          child: BuildDropdown(
            hintText: 'Select hyphae septation',
            items: MorphologySchema.getValidValues('Hyphae_Septation') ?? [],
            onChanged: onSeptationChanged,
          ),
        ),

        _buildDropdownSection(
          label: 'Hyphae Branching',
          child: BuildDropdown(
            hintText: 'Select hyphae branching',
            items: MorphologySchema.getValidValues('Hyphae_Branching') ?? [],
            onChanged: onBranchingChanged,
          ),
        ),

        _buildDropdownSection(
          label: 'Hyphae Width',
          child: BuildDropdown(
            hintText: 'Select hyphae width',
            items: MorphologySchema.getValidValues('Hyphae_Width') ?? [],
            onChanged: onWidthChanged,
          ),
        ),

        _buildDropdownSection(
          label: 'Hyphae Pigmentation',
          child: BuildDropdown(
            hintText: 'Select hyphae pigmentation',
            items: MorphologySchema.getValidValues('Hyphae_Pigmentation') ?? [],
            onChanged: onPigmentationChanged,
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: BuildButton(
            onPressed: onNext,
            buttonText: 'Next Section',
            backgroundColor: MoldifyColors.primaryColor,
            textColor: Colors.white,
            buttonHeight: 45,
            buttonRadius: 10,
            buttonWidth: double.infinity,
          ),
        ),
      ],
    );
  }
}
