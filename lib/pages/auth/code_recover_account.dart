import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:moldify/pages/auth/set_new_password.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/textboxes/textboxes.dart';
import '../misc/appbar/secondary_appbar.dart';
import '../misc/buttons/primary_button.dart';
import '../misc/functions/step_indicator.dart';

class CodeRecoverAccountScreen extends StatefulWidget {
  final String pageTitle;

  const CodeRecoverAccountScreen({
    super.key,
    required this.pageTitle
  });

  @override
  State<CodeRecoverAccountScreen> createState() => _CodeRecoverAccountScreenState();
}
class _CodeRecoverAccountScreenState extends State<CodeRecoverAccountScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  /// currentStep keeps track of the current step in the recovery process.
  int currentStep = 1;
  /// totalSteps is the total number of steps in the recovery process.
  late final int totalSteps;
  /// title is the app bar title of the page, which is set based on the pageTitle passed to the widget.
  /// It can be 'Forgot Username', 'Forgot Password'.
  late final String title;

  /// It initializes the title and totalSteps based on the pageTitle passed to the widget.
  /// If the pageTitle is 'Forgot Username', it sets the title to 'Forgot Username' and totalSteps to 2.
  /// If the pageTitle is 'Forgot Password', it sets the title to 'Forgot Password' and totalSteps to 3.
  @override
  void initState() {
    super.initState();
    if(widget.pageTitle == 'Forgot Username'){
      title = 'Forgot Username';
      totalSteps = 2;
    } else if(widget.pageTitle == 'Forgot Password'){
      title = 'Forgot Password';
      totalSteps = 3;
    } else {
      title = widget.pageTitle;
      totalSteps = 0;
    }
  }

  /// This method is called when the OTP input changes.
  /// It checks the value of the input and moves the focus to the next or previous input field based on the index.
  /// If the value is not empty and the index is less than 3, it moves the focus to the next input field.
  /// If the value is empty and the index is greater than 0, it moves the focus to the previous input field.
  /// This allows for a smooth user experience when entering the OTP code, as the focus automatically shifts to the next field when a digit is entered,
  /// and back to the previous field when a digit is deleted.
  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 3) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  /// This method builds the OTP input boxes.
  /// It generates a list of `Expanded` widgets, each containing a `BuildTextBox` for the OTP input.
  Widget _buildOtpBox(int index) {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: BuildTextBox(
          hintText: '',
          controller: _controllers[index],
          showPassword: false,
          focusNode: _focusNodes[index],
          autoFocus: index == 0,
          maxLength: 1,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          fontSize: 16,
          isMultiline: false,
          onChanged: (value) => _onOtpChanged(value, index),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of all TextEditingControllers
    for (var controller in _controllers) {
      controller.dispose();
    }
    // Dispose of all FocusNodes
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: SecondaryAppBar(
        title: title,
        color: MoldifyColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// -------- Input Code Header Image --------
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: SvgPicture.asset(
                'assets/images/code_phone_curve.svg',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ),
            /// -------- Input Code Header Image --------

            Padding(padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.0),
                  /// Step Indicator
                  /// This widget displays the current step in the recovery process
                  /// and the total number of steps.
                  /// It helps users understand their progress in the recovery process.
                  StepIndicator(
                    totalSteps: totalSteps,
                    currentStep: currentStep,
                  ),

                  /// -------- Get Code Header --------
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                        'GET YOUR CODE',
                        style: TextStyle(
                          fontSize: 32,
                          fontFamily: 'Montserrat-Black',
                          color: MoldifyColors.primaryColor,
                        )
                    ),
                  ),
                  Text(
                      'Please enter the 4-digit code sent to your email.',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        color: MoldifyColors.MoldifyBlack,
                      )
                  ),
                  /// -------- End Get Code Address Header --------

                  /// -------- OTP Input Boxes --------
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0, bottom: 10.0),
                    child: Row(
                      children: List.generate(4, _buildOtpBox),
                    ),
                  ),
                  /// -------- End of OTP Input Boxes --------

                  /// Resend Message
                  Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text (
                            'If you did not receive the code,',
                            style: TextStyle(
                              fontFamily: 'Bricolage-Grotesque-SemiBold',
                              fontSize: 12,
                              color: MoldifyColors.MoldifyBlack,
                            ),
                          ),

                          /// Resend Button
                          InkWell(
                            onTap: () {

                            },
                            borderRadius: BorderRadius.circular(8),
                            splashColor: MoldifyColors.accentColor.withValues(alpha: 0.2),
                            highlightColor: MoldifyColors.accentColor.withValues(alpha: 0.2),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 6),
                              child: Text(
                                'Resend',
                                style: TextStyle(
                                  fontFamily: 'Bricolage-Grotesque-ExtraBold',
                                  fontSize: 12,
                                  color: MoldifyColors.accentColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                  ),

                  /// Verify Code Button
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: BuildButton(
                        onPressed: () {
                          if (widget.pageTitle == 'Forgot Username') {
                            // Handle forgot username logic

                          } else if (widget.pageTitle == 'Forgot Password') {
                            //Handle forgot password logic
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SetNewPasswordScreen(),
                              ),
                            );
                          }
                        },
                        buttonText: 'Verify Code',
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
          ],
        )
      )
    );
  }
}