import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';

class ResultActionSection extends StatelessWidget {
  final VoidCallback onSave;

  const ResultActionSection({
    super.key,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Disclaimer: This app only suggests possible mold genus based on image analysis. This should not replace expert advice or laboratory confirmation.',
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Bricolage-Grotesque-Regular',
            color: MoldifyColors.MoldifyGrey,
          ),
        ),
        const SizedBox(height: 24),
        BuildButton(
          onPressed: onSave,
          buttonText: 'Save Result',
          backgroundColor: MoldifyColors.primaryColor,
          textColor: MoldifyColors.backgroundColor,
          buttonHeight: 45,
          buttonWidth: double.infinity,
          buttonRadius: 10,
        ),
      ],
    );
  }
}
