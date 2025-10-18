import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../misc/appbar/secondary_appbar.dart';
import '../misc/buttons/primary_button.dart';
import '../misc/colors.dart';
import '../misc/textboxes/textboxes.dart';

/// ReportBugScreen is a screen that allows users to report bugs in the application.

class ReportBugScreen extends StatefulWidget {
  const ReportBugScreen({Key? key}) : super(key: key);

  @override
  _ReportBugScreenState createState() => _ReportBugScreenState();
}

class _ReportBugScreenState extends State<ReportBugScreen> {
  final TextEditingController reportBugController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: SecondaryAppBar(
        title: 'Report A Bug',
        color: MoldifyColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// -------- Report Bug Header Image --------
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: SvgPicture.asset(
                'assets/images/bug_phone_curve.svg',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ),
            /// -------- End of Report Bug Header Image --------
            Padding(padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 30.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.0),
                    /// -------- Report Bug Header --------
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                          'SUBMIT BUG REPORT',
                          style: TextStyle(
                            fontSize: 32,
                            fontFamily: 'Montserrat-Black',
                            color: MoldifyColors.primaryColor,
                          )
                      ),
                    ),
                    Text(
                        'Encountering app issues or errors? Report them now!',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Bricolage-Grotesque-Regular',
                          color: MoldifyColors.MoldifyBlack,
                        )
                    ),
                    /// -------- End of Report Bug Header --------

                    /// Feedback Label
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: const Text(
                        'Describe what happened, and what you expected instead.',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Bricolage-Grotesque-SemiBold',
                          color: MoldifyColors.primaryColor,
                        ),
                      ),
                    ),

                    /// Feedback TextBox
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: BuildTextBox(
                        hintText: 'Please add your report detail here',
                        controller: reportBugController,
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
                                    // Handle Privacy Policy tap here
                                  },
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          )
                      ),
                    ),

                    /// Send Code Button
                    Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: BuildButton(
                          onPressed: () {

                          },
                          buttonText: 'Submit Report',
                          backgroundColor: MoldifyColors.primaryColor,
                          textColor: MoldifyColors.backgroundColor,
                          buttonHeight: 45,
                          buttonWidth: MediaQuery.of(context).size.width,
                          buttonRadius: 10
                      ),
                    )
                  ]
              ),
            ),
          ],
        ),
      ),
    );
  }
}