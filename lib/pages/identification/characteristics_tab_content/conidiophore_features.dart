import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/buttons/radio_button_grp.dart';
import 'package:moldify/pages/misc/textboxes/dropdwon.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/core/constants/morphology_schema.dart';

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
      child: Row(
        children: [
          if (showBack) ...[  
            Expanded(
              child: BuildButton(
                onPressed: onBack!,
                buttonText: 'Back',
                backgroundColor: MoldifyColors.taupe,
                textColor: MoldifyColors.primaryColor,
                buttonHeight: 45,
                buttonRadius: 10,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: BuildButton(
              onPressed: onNext,
              buttonText: 'Next Section',
              backgroundColor: MoldifyColors.primaryColor,
              textColor: Colors.white,
              buttonHeight: 45,
              buttonRadius: 10,
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
          child: BuildDropdown(
            hintText: 'Select conidiophore presence',
            items: MorphologySchema.getValidValues('Conidiophore_Presence') ?? [],
            onChanged: (value) {
              if (onConidiophorePresenceChanged != null && value != null) onConidiophorePresenceChanged!(value);
            },
          ),
        ),

        /// Conidiophore Branching
        _buildDropdownSection(
          label: 'Conidiophore Branching',
          child: BuildDropdown(
            hintText: 'Select conidiophore branching',
            items: MorphologySchema.getValidValues('Conidiophore_Branching') ?? [],
            onChanged: onConidiophoreBranchingChanged,
          ),
        ),

        /// Conidiophore Length
        _buildDropdownSection(
          label: 'Conidiophore Length',
          child: BuildDropdown(
            hintText: 'Select conidiophore length',
            items: MorphologySchema.getValidValues('Conidiophore_Length') ?? [],
            onChanged: onConidiophoreLengthChanged,
          ),
        ),

        /// Conidiophore Surface
        _buildDropdownSection(
          label: 'Conidiophore Surface',
          child: BuildDropdown(
            hintText: 'Select conidiophore surface',
            items: MorphologySchema.getValidValues('Conidiophore_Surface') ?? [],
            onChanged: onConidiophoreSurfaceChanged,
          ),
        ),
        _buildNavigationButtons(showBack: true),
      ],
    );
  }
}
