import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/buttons/icon_button.dart';
import 'package:moldify/pages/misc/colors.dart';

import '../../buttons/primary_button.dart';
import '../../overlays/modals/confirmation_dialog.dart';
import '../../textboxes/textboxes.dart';


/// Content widget for correcting a flagged mold name.
///
/// To be used as a child of [BuildBottomSheet].
/// The controller must be created and disposed of in the parent widget.
///
/// Parameters:
/// - [correctedGenusController]: The TextEditingController for the input field.
/// - [onClose]: Callback for the close button.
/// - [onSave]: Callback that passes the corrected text from the text field.
class CorrectionBottomSheetContent extends StatelessWidget {
  final TextEditingController correctedGenusController;
  final VoidCallback? onClose;
  final Function(String)? onSave;

  const CorrectionBottomSheetContent({
    super.key,
    required this.correctedGenusController,
    this.onClose,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Expanded(
              child: Center(
                child: Text(
                  'Flag Mold',
                  style: TextStyle(
                    fontFamily: 'Bricolage-Grotesque-ExtraBold',
                    color: MoldifyColors.primaryColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            /// Close Button
            BuildIconButton(
              icon: FontAwesomeIcons.xmark,
              color: MoldifyColors.MoldifyRed,
              onPressed: () {
                onClose?.call();
              },
            )
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 30.0, bottom: 8.0),
          child: Text(
            'Please enter the correct mold genus name',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Bricolage-Grotesque-SemiBold',
              color: MoldifyColors.primaryColor,
            ),
          ),
        ),
        /// Correct Genus Name.
        BuildTextBox(
          hintText: 'Enter correct genus name',
          controller: correctedGenusController,
          showPassword: false,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'This helps us train the model and improve future identification.',
            style: TextStyle(
              fontFamily: "Bricolage-Grotesque-Regular",
              fontSize: 10,
              color: MoldifyColors.MoldifyGrey,
            ),
          ),
        ),
        const SizedBox(height: 200),
        /// Save Log Button
        BuildButton(
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return BuildConfirmationDialog(
                    title: 'Submit Correction?',
                    subtitle: 'Are you sure you want to submit correction?',
                    onConfirm: () {
                      onSave?.call(correctedGenusController.text);
                    },
                    onCancel: (){
                      Navigator.of(context).pop();
                    },
                  );
                },
              );
            },
            buttonText: 'Submit Correction',
            backgroundColor: MoldifyColors.primaryColor,
            textColor: MoldifyColors.backgroundColor,
            buttonHeight: 45,
            buttonWidth: MediaQuery.of(context).size.width,
            buttonRadius: 10
        ),
      ],
    );
  }
}