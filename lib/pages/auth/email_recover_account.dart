import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/core/utils/route_utils.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import '../misc/appbar/secondary_appbar.dart';
import '../misc/functions/step_indicator.dart';
import '../misc/textboxes/textboxes.dart';
import 'package:moldify/core/features/authentication/logic/auth_bloc.dart';
import 'package:moldify/core/features/authentication/services/auth_service.dart';

/// EmailRecoverAccountScreen is a screen for recovering accounts via email.
/// It allows users to enter their email address to recover their username or password.
/// The screen displays a step indicator, an email input field, and a button to send a
/// recovery code.

class EmailRecoverAccountScreen extends StatefulWidget{
  /// The title of the page, which can be 'Forgot Username' or 'Forgot Password'.
  /// This title is used to determine the functionality of the screen.
  /// For example, if the title is 'Forgot Username', the screen will handle username recovery,
  /// and if the title is 'Forgot Password', it will handle password recovery.
  final String pageTitle;

  const EmailRecoverAccountScreen({
    super.key,
    required this.pageTitle
  });

  @override
  State<EmailRecoverAccountScreen> createState() => _EmailRecoverAccountScreenState();
}
class _EmailRecoverAccountScreenState extends State<EmailRecoverAccountScreen> {
  final emailController = TextEditingController();
  final AuthBloc _authBloc = AuthBloc(AuthService());
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;
  /// currentStep keeps track of the current step in the recovery process.
  int currentStep = 0;
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

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed from the widget tree
    emailController.dispose();
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
              /// -------- Email Recovery Header Image --------
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: SvgPicture.asset(
                  'assets/images/email_phone_curve.svg',
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
              ),
              /// -------- End of Email Recovery Header Image --------

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

                    /// -------- Mail Address Header --------
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        'MAIL ADDRESS HERE',
                        style: TextStyle(
                          fontSize: 32,
                          fontFamily: 'Montserrat-Black',
                          color: MoldifyColors.primaryColor,
                        )
                      ),
                    ),
                    Text(
                      'Please enter the email associated to your account.',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        color: MoldifyColors.MoldifyBlack,
                      )
                    ),
                    /// -------- End of Mail Address Header --------

                    /// Email Label
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: const Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Bricolage-Grotesque-SemiBold',
                          color: MoldifyColors.primaryColor,
                        ),
                      ),
                    ),

                    /// Email TextBox
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 50.0),
                      child: BuildTextBox(
                        hintText: 'Enter Email',
                        controller: emailController,
                        showPassword: false,
                      ),
                    ),

                    /// Send Code Button
                    BuildButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                          errorMessage = null;
                          successMessage = null;
                        });
                        final email = emailController.text.trim();
                        if (email.isEmpty) {
                          setState(() {
                            isLoading = false;
                            errorMessage = 'Please enter your email.';
                          });
                          return;
                        }
                        Map<String, dynamic> result;
                        if (title == 'Forgot Username') {
                          result = await _authBloc.authService.forgotUsername(email);
                        } else if (title == 'Forgot Password') {
                          result = await _authBloc.authService.forgotPassword(email);
                        } else {
                          setState(() {
                            isLoading = false;
                            errorMessage = 'Unknown recovery type.';
                          });
                          return;
                        }
                        setState(() {
                          isLoading = false;
                          if (result['success'] == true) {
                            successMessage = result['message'] ?? 'Recovery email sent!';
                            errorMessage = null;
                            navigateTo(context, RouteNames.codeRecoverAccount, arguments: {
                              'email': email,
                              'pageTitle': title,
                            });
                          } else {
                            errorMessage = result['error'] ?? 'Failed to send recovery email.';
                            successMessage = null;
                          }
                        });
                      },
                      buttonText: isLoading ? 'Sending...' : 'Send Code',
                      backgroundColor: MoldifyColors.primaryColor,
                      textColor: MoldifyColors.backgroundColor,
                      buttonHeight: 45,
                      buttonWidth: MediaQuery.of(context).size.width,
                      buttonRadius: 10,
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          errorMessage!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    if (successMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          successMessage!,
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                  ],
                )
              ),
            ],
        ),
      ),
    );
  }
}