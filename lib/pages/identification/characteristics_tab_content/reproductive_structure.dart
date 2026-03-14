import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/buttons/radio_button_grp.dart';
import 'package:moldify/pages/misc/textboxes/dropdwon.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/core/constants/morphology_schema.dart';

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
          child: BuildDropdown(
            hintText: 'Select vesicle presence',
            items: MorphologySchema.getValidValues('Vesicle_Presence') ?? [],
            onChanged: (value) {
              if (onVesiclePresenceChanged != null && value != null) onVesiclePresenceChanged!(value);
            },
          ),
        ),

        /// Vesicle Shape
        _buildDropdownSection(
          label: 'Vesicle Shape',
          child: BuildDropdown(
            hintText: 'Select vesicle shape',
            items: MorphologySchema.getValidValues('Vesicle_Shape') ?? [],
            onChanged: onVesicleShapeChanged,
          ),
        ),

        /// Sporangium Presence
        _buildDropdownSection(
          label: 'Sporangium Presence',
          child: BuildDropdown(
            hintText: 'Select sporangium presence',
            items: MorphologySchema.getValidValues('Sporangium_Presence') ?? [],
            onChanged: (value) {
              if (onSporangiumPresenceChanged != null && value != null) onSporangiumPresenceChanged!(value);
            },
          ),
        ),

        /// Sporangiophore Presence
        _buildDropdownSection(
          label: 'Sporangiophore Presence',
          child: BuildDropdown(
            hintText: 'Select sporangiophore presence',
            items: MorphologySchema.getValidValues('Sporangiophore_Presence') ?? [],
            onChanged: (value) {
              if (onSporangiophorePresenceChanged != null && value != null) {
                onSporangiophorePresenceChanged!(value);
              }
            },
          ),
        ),

        /// Columella Presence
        _buildDropdownSection(
          label: 'Columella Presence',
          child: BuildDropdown(
            hintText: 'Select columella presence',
            items: MorphologySchema.getValidValues('Columella_Presence') ?? [],
            onChanged: (value) {
              if (onColumellaPresenceChanged != null && value != null) onColumellaPresenceChanged!(value);
            },
          ),
        ),

        /// Rhizoid Presence
        _buildDropdownSection(
          label: 'Rhizoid Presence',
          child: BuildDropdown(
            hintText: 'Select rhizoid presence',
            items: MorphologySchema.getValidValues('Rhizoid_Presence') ?? [],
            onChanged: (value) {
              if (onRhizoidPresenceChanged != null && value != null) onRhizoidPresenceChanged!(value);
            },
          ),
        ),

        _buildNavigationButtons(showBack: true),
      ],
    );
  }
}
