import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:moldify/pages/misc/appbar/secondary_appbar.dart';
import 'package:moldify/pages/misc/colors.dart';
import '../misc/buttons/primary_button.dart';
import '../misc/functions/step_indicator.dart';
import '../misc/textboxes/textboxes.dart';
import 'package:moldify/core/features/authentication/logic/auth_bloc.dart';
import 'package:moldify/core/features/authentication/services/auth_service.dart';
import 'package:moldify/core/utils/auth_navigation.dart';

/// SetNewPasswordScreen is a screen for setting a new password during the account recovery process.
/// It allows users to enter a new password and confirm it.

class SetNewPasswordScreen extends StatefulWidget {
  final String token;
  const SetNewPasswordScreen({super.key, required this.token});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();
  final AuthBloc _authBloc = AuthBloc(AuthService());

  /// currentStep keeps track of the current step in the recovery process.
  int currentStep = 2;

  /// totalSteps is the total number of steps in the recovery process.
  late final int totalSteps = 3;

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed from the widget tree
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmNewPasswordController.text;
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Validate password complexity (must match server PasswordSchema)
    if (newPassword.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must be at least 8 characters long'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!RegExp(r'[a-z]').hasMatch(newPassword)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must contain at least one lowercase letter'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!RegExp(r'[A-Z]').hasMatch(newPassword)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must contain at least one uppercase letter'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!RegExp(r'[0-9]').hasMatch(newPassword)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must contain at least one number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(newPassword)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must contain at least one special character'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final result = await _authBloc.verifiedForgotPassword(
      widget.token,
      newPassword,
    );
    if (!mounted) return;
    if (!result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Failed to reset password'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password changed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      AuthNavigation.resetToLoginFromContext(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: SecondaryAppBar(
        title: 'Forgot Password',
        color: MoldifyColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// -------- New Password Header Image --------
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: SvgPicture.asset(
                'assets/images/new_password_curve.svg',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ),

            /// -------- New Password Header Image --------
            Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
                bottom: 30.0,
              ),
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

                  /// -------- Set New Password Header --------
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      'SET NEW PASSWORD',
                      style: TextStyle(
                        fontSize: 32,
                        fontFamily: 'Montserrat-Black',
                        color: MoldifyColors.primaryColor,
                      ),
                    ),
                  ),
                  Text(
                    'Please enter your new password to update account.',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Bricolage-Grotesque-Regular',
                      color: MoldifyColors.MoldifyBlack,
                    ),
                  ),

                  /// -------- End Set New Password Header --------

                  /// New Password Label
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: const Text(
                      'New Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Bricolage-Grotesque-SemiBold',
                        color: MoldifyColors.primaryColor,
                      ),
                    ),
                  ),

                  /// New Password TextBox
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: BuildTextBox(
                      hintText: 'Enter New Password',
                      controller: newPasswordController,
                      showPassword: true,
                    ),
                  ),

                  /// Confirm New Password Label
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: const Text(
                      'Confirm New Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Bricolage-Grotesque-SemiBold',
                        color: MoldifyColors.primaryColor,
                      ),
                    ),
                  ),

                  /// Confirm Password TextBox
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: BuildTextBox(
                      hintText: 'Enter Confirm New Password',
                      controller: confirmNewPasswordController,
                      showPassword: true,
                    ),
                  ),

                  /// Verify Code Button
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: BuildButton(
                      onPressed: _handleChangePassword,
                      buttonText: 'Change Password',
                      backgroundColor: MoldifyColors.primaryColor,
                      textColor: MoldifyColors.backgroundColor,
                      buttonHeight: 45,
                      buttonWidth: MediaQuery.of(context).size.width,
                      buttonRadius: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
