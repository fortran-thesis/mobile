import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/buttons/radio_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/textboxes/textboxes.dart';

import '../misc/buttons/primary_button.dart';
import '../misc/overlays/modals/confirmation_dialog.dart';

class ReportACuratorScreen extends StatefulWidget {

  const ReportACuratorScreen({
    super.key,
  });

  @override
  State<ReportACuratorScreen> createState() => _ReportACuratorScreenState();
}
class _ReportACuratorScreenState extends State<ReportACuratorScreen> {
  final detailsController = TextEditingController();

  int selectedRadio = -1;

  void _radioButtonSelected(int index) {
    setState(() {
      selectedRadio = index;
    });
    if (selectedRadio == 0) {
      print('You selected 1st option');
    }
    else if (selectedRadio == 1) {
      print('You selected 2nd option');
    }
    else if (selectedRadio == 2) {
      print('You selected 3rd option');
    }
    else if (selectedRadio == 3) {
      print('You selected 4th option');
    }
    else if (selectedRadio == 4) {
      print('You selected 5th option');
    }
    else if (selectedRadio == 5) {
      print('You selected 6th option');
    }
    else if (selectedRadio == 6) {
      print('You selected 7th option');
    }
    else {
      print('Please choose among the options!');
    }
  }

  bool _hasUnsavedChanges() {
    return detailsController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didpop) async {
        if (didpop) {
          return;
        }

        // Show the dialog only if a radio button is selected
        if (selectedRadio != -1 || _hasUnsavedChanges()) {
          final shouldPop = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return BuildConfirmationDialog(
                title: 'Are you sure you want to go back?',
                subtitle: 'Going back now will lose all your progress.',
                onConfirm: () {
                  Navigator.of(context).pop(true); //Return true to allow pop
                },
                onCancel: () {
                  Navigator.of(context).pop(false); //Return false to prevent pop
                },
              );
            },
          );

          //If the user confirmed, pop the current route
          if (shouldPop != null && shouldPop) {
            Navigator.of(context).pop(true);
          }
        } else {
          //No unsaved changes, allow pop without confirmation
          Navigator.of(context).pop(true);
        }
      },

      child: Scaffold(
        backgroundColor: MoldifyColors.backgroundColor,
        appBar: PrimaryAppBar(
          title: 'Report a Problem',
        ),
        body: SingleChildScrollView(
          child: Padding(padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0, bottom: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ----------- Report A Problem Header -----------
                Text(
                    'Report A Problem',
                    style: TextStyle(
                      fontSize: 36,
                      fontFamily: 'Montserrat-Black',
                      color: MoldifyColors.primaryColor,
                    )
                ),
                Text(
                    'Report a user for violating community guidelines.',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Bricolage-Grotesque-Regular',
                      color: MoldifyColors.MoldifyBlack,
                    )
                ),
                /// ----------- End of Report A Problem Header -----------

                Padding(padding: const EdgeInsets.only(top: 20, bottom: 10.0),
                  child: Text(
                    'Why are you reporting this curator?',
                    style: TextStyle(
                      fontFamily: 'Montserrat-Black',
                      fontSize: 16,
                      color: MoldifyColors.primaryColor,
                    ),
                  ),
                ),

                /// ----------- Radio Buttons for Reporting Curator -----------
                BuildRadioButton(
                    numberOfButtons: 7,
                    buttonLabels: const [
                      'Misleading or Unverified Information',
                      'Offensive or Inappropriate Language',
                      'Intellectual Property Violation',
                      'Graphic or Violent Content',
                      'Sexual or Harassing Content',
                      'Regulated or Restricted Content',
                      'Something Else'
                    ],
                    buttonSubtexts: const [
                      'The curator shared vague, promotional, or '
                          'potentially confusing information.',
                      'The curator had used disrespectful, hateful, or a'
                          'busive language that violates professional and ethical standards.',
                      'The curator  appears to share plagiarized text, copyrighted images, '
                          'or material taken without proper permission.',
                      'The curator shared violent, disturbing, or harmful imagery or '
                          'descriptions that are inappropriate for this platform.',
                      'The curator shared sexually explicit material, suggestive remarks, '
                          'or any form of harassment that makes the content unprofessional or harmful.',
                      'The curator shared information that may be illegal, classified, or '
                          'related to controlled substances, making it inappropriate for public display.',
                      'Select this option if your concern is not listed above. Please provide details.'
                    ],
                    onButtonSelected: _radioButtonSelected
                ),
                /// ----------- End Radio Buttons for Reporting Curator -----------

                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
                  child: Text(
                    'Please provide additional details about your report.',
                    style: TextStyle(
                      fontFamily: 'Montserrat-Black',
                      fontSize: 16,
                      color: MoldifyColors.primaryColor,
                    ),
                  ),
                ),

                /// Additional Details Text Box
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: BuildTextBox(
                      hintText: 'Enter additional details here',
                      controller: detailsController,
                      showPassword: false,
                      isMultiline: true,
                  ),
                ),

                /// Privacy Policy Agreement
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child:
                      Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Bricolage-Grotesque-Regular',
                            fontSize: 12,
                            color: MoldifyColors.MoldifyBlack,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Submitting this form indicates your agreement to Moldify’s data processing as stated in our ',
                            ),
                            /// Privacy Policy link
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(
                                fontFamily: 'Bricolage-Grotesque-Bold',
                                color: MoldifyColors.accentColor,
                                decoration: TextDecoration.underline,
                                decorationThickness: 2,
                                decorationColor: MoldifyColors.accentColor,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () {
                                // Handle TPrivacy Policy tap here
                              },
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      )
                  ),
                ),
                /// Submit Button
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: BuildButton(
                    onPressed: () {
                      if (selectedRadio == -1 ) {
                        // Show a snackbar if no option is selected
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Please select a reason for reporting.'),
                            duration: const Duration(seconds: 3),
                            action: SnackBarAction(
                              label: 'OK',
                              textColor: MoldifyColors.backgroundColor,
                              onPressed: () {
                                // Dismiss the snackbar when "OK" is pressed
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              },
                            ),
                          ),
                        );
                        return;
                      }
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return BuildConfirmationDialog(
                            title: 'Are you sure you want to submit this report?',
                            subtitle: 'This will alert our team to review the curator\'s content.',
                            onConfirm: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            onCancel: (){
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      );
                    },
                    buttonText: 'Submit Report',
                    backgroundColor: MoldifyColors.primaryColor,
                    textColor: MoldifyColors.backgroundColor,
                    buttonHeight: 45,
                    buttonWidth: MediaQuery.of(context).size.width,
                    buttonRadius: 10
                  ),
                )
            ],
          ),
        ),
        )
      ),
    );
  }
}