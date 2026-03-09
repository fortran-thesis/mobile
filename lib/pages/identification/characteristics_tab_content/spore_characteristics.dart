import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/textboxes/dropdwon.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/core/constants/morphology_schema.dart';

class SporeCharacteristicsTab extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;

  // Simplified parent-level callbacks (no string labels)
  final Function(String?)? onSporeTypeChanged;
  final Function(String?)? onSporeShapeChanged;
  final Function(String?)? onSporeColorChanged;
  final Function(String?)? onSporeSurfaceChanged;
  final Function(String?)? onSporeArrangementChanged;

  const SporeCharacteristicsTab({
    super.key,
    required this.onNext,
    this.onBack,
    this.onSporeTypeChanged,
    this.onSporeShapeChanged,
    this.onSporeColorChanged,
    this.onSporeSurfaceChanged,
    this.onSporeArrangementChanged,
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

        /// Spore Type
        _buildDropdownSection(
          label: 'Spore Type',
          child: BuildDropdown(
            hintText: 'Select spore type',
            items: MorphologySchema.getValidValues('Spore_Type') ?? [],
            onChanged: onSporeTypeChanged,
          ),
        ),

        /// Spore Shape
        _buildDropdownSection(
          label: 'Spore Shape',
          child: BuildDropdown(
            hintText: 'Select spore shape',
            items: MorphologySchema.getValidValues('Spore_Shape') ?? [],
            onChanged: onSporeShapeChanged,
          ),
        ),

        /// Spore Color
        _buildDropdownSection(
          label: 'Spore Color',
          child: BuildDropdown(
            hintText: 'Select spore color',
            items: MorphologySchema.getValidValues('Spore_Color') ?? [],
            onChanged: onSporeColorChanged,
          ),
        ),

        /// Spore Surface
        _buildDropdownSection(
          label: 'Spore Surface',
          child: BuildDropdown(
            hintText: 'Select spore surface',
            items: MorphologySchema.getValidValues('Spore_Surface') ?? [],
            onChanged: onSporeSurfaceChanged,
          ),
        ),

        /// Spore Arrangement
        _buildDropdownSection(
          label: 'Spore Arrangement',
          child: BuildDropdown(
            hintText: 'Select spore arrangement',
            items: MorphologySchema.getValidValues('Spore_Arrangement') ?? [],
            onChanged: onSporeArrangementChanged,
          ),
        ),

        _buildNavigationButtons(showBack: true),
      ],
    );
  }
}
