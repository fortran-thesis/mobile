import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../misc/buttons/primary_button.dart';
import '../../../misc/colors.dart';

class ReportResolvedActionsRow extends StatelessWidget {
  final bool visible;
  final VoidCallback onCloseCase;
  final VoidCallback onAddFollowUp;
  final String closeCaseLabel;
  final String addFollowUpLabel;

  const ReportResolvedActionsRow({
    super.key,
    required this.visible,
    required this.onCloseCase,
    required this.onAddFollowUp,
    required this.closeCaseLabel,
    required this.addFollowUpLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          // Subdued Primary Action
          Expanded(
            child: BuildButton(
              onPressed: onCloseCase,
              buttonText: closeCaseLabel,
              fontSize: 11,
              // Using a slightly desaturated version of primary for a subtle look
              backgroundColor: MoldifyColors.primaryColor.withOpacity(0.08),
              textColor: MoldifyColors.primaryColor,
              leftIcon: FontAwesomeIcons.solidCircleCheck,
              iconSize: 11,
              iconColor: MoldifyColors.primaryColor,
              paddingIconText: 6,
              buttonHeight: 38, // Smaller and sleeker
              buttonRadius: 8,  // Minimalist radius
            ),
          ),
          
          const SizedBox(width: 8),

          // Subdued Secondary Action
          Expanded(
            child: BuildButton(
              onPressed: onAddFollowUp,
              buttonText: addFollowUpLabel,
              fontSize: 11,
              // Soft accent tint
              backgroundColor: MoldifyColors.accentColor.withOpacity(0.12),
              textColor: MoldifyColors.primaryColor,
              leftIcon: FontAwesomeIcons.plus,
              iconSize: 11,
              iconColor: MoldifyColors.primaryColor,
              paddingIconText: 6,
              buttonHeight: 38,
              buttonRadius: 8,
            ),
          ),
        ],
      ),
    );
  }
}