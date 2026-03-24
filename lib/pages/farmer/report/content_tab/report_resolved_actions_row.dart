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
      padding: const EdgeInsets.only(top: 14.0),
      child: Row(
        children: [
          BuildButton(
            onPressed: onCloseCase,
            buttonText: closeCaseLabel,
            fontSize: 12,
            backgroundColor: MoldifyColors.primaryColor,
            textColor: MoldifyColors.backgroundColor,
            leftIcon: FontAwesomeIcons.solidCircleCheck,
            iconSize: 12,
            iconColor: MoldifyColors.backgroundColor,
            paddingIconText: 10,
            buttonHeight: 30,
            buttonWidth: 120,
            buttonRadius: 7,
          ),
          const SizedBox(width: 5),
          BuildButton(
            onPressed: onAddFollowUp,
            buttonText: addFollowUpLabel,
            fontSize: 12,
            backgroundColor: MoldifyColors.accentColor,
            textColor: MoldifyColors.MoldifyBlack,
            leftIcon: FontAwesomeIcons.plus,
            iconSize: 12,
            iconColor: MoldifyColors.MoldifyBlack,
            paddingIconText: 10,
            buttonHeight: 30,
            buttonWidth: 120,
            buttonRadius: 7,
          ),
        ],
      ),
    );
  }
}
