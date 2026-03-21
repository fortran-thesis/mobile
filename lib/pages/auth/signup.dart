import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:moldify/pages/auth/login.dart';
import '../misc/buttons/primary_button.dart';
import '../misc/colors.dart';
import '../misc/textboxes/textboxes.dart';
import 'package:moldify/core/features/authentication/logic/auth_bloc.dart';
import 'package:moldify/core/features/authentication/services/auth_service.dart';
import '../../core/constants/route_names.dart';

/// Custom input formatter for phone number with dashes (9XX-XXX-XXXX format)
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('-', '');

    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    if (text.length <= 3) {
      return newValue.copyWith(text: text);
    } else if (text.length <= 6) {
      final formatted = '${text.substring(0, 3)}-${text.substring(3)}';
      return newValue.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } else {
      final formatted =
          '${text.substring(0, 3)}-${text.substring(3, 6)}-${text.substring(6, 10)}';
      return newValue.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }
}

/// This is the Sign Up screen for the Moldify app.
/// It allows users to create a new account by providing their username, email, password, and confirming the password.
/// It also includes a checkbox for agreeing to the terms and conditions,
/// and options for signing up with Google.

class SignUpScreen extends StatefulWidget{
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _authService = AuthService();
  late final AuthBloc _loginBloc = AuthBloc(_authService);

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final fnameController = TextEditingController();
  final lnameController = TextEditingController();

  final addressController = TextEditingController();
  bool _agreedToTerms = false;
  bool isLoading = false;
  final phoneNumController = TextEditingController();

  String? _passwordErrorText;
  String? _phoneErrorText;

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed from the widget tree
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    fnameController.dispose();
    lnameController.dispose();
    phoneNumController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
          style: const TextStyle(
            fontFamily: 'Bricolage-Grotesque-Regular',
            fontSize: 14,
            color: MoldifyColors.backgroundColor,
          ),
        ),
        backgroundColor: MoldifyColors.MoldifyRed,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
          style: const TextStyle(
            fontFamily: 'Bricolage-Grotesque-Regular',
            fontSize: 14,
            color: MoldifyColors.backgroundColor,
          ),
        ),
        backgroundColor: MoldifyColors.primaryColor,
      ),
    );
  }

  /// Validates password meets all requirements
  String? _validatePassword(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      return 'Password must contain at least one special character';
    }
    return null; // Password is valid
  }

  /// Validates phone number (Philippine format: 10 digits)
  String? _validatePhoneNumber(String phoneNumber) {
    // Remove dashes for validation
    final digitsOnly = phoneNumber.replaceAll('-', '');
    if (digitsOnly.isEmpty) {
      return 'Phone number is required';
    }
    if (digitsOnly.length != 10) {
      return 'Phone number must be exactly 10 digits';
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(digitsOnly)) {
      return 'Phone number must contain only digits';
    }
    return null; // Phone number is valid
  }

  Future<void> _handleUserSignUp() async {
    setState(() {
      _passwordErrorText = null;
      _phoneErrorText = null;
    });

    // Check terms & conditions FIRST before any other validation
    if (!_agreedToTerms) {
      _showErrorSnackBar('You must agree to the terms and privacy policy.');
      return;
    }

    // Client-side validation
    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        fnameController.text.isEmpty ||
        lnameController.text.isEmpty ||
        phoneNumController.text.isEmpty ||
        addressController.text.isEmpty) {
      _showErrorSnackBar('All fields are required.');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showErrorSnackBar('Passwords do not match.');
      return;
    }

    // Validate phone number
    final phoneValidationError = _validatePhoneNumber(phoneNumController.text);
    if (phoneValidationError != null) {
      setState(() {
        _phoneErrorText = phoneValidationError;
      });
      return;
    }

    // Validate password meets all requirements BEFORE sending to server
    final passwordValidationError = _validatePassword(passwordController.text);
    if (passwordValidationError != null) {
      setState(() {
        _passwordErrorText =
            'Password must contain the following:\n'
            '\u2022 At least 8 characters\n'
            '\u2022 At least one lowercase letter\n'
            '\u2022 At least one uppercase letter\n'
            '\u2022 At least one number\n'
            '\u2022 At least one special character';
      });
      return;
    }

    setState(() => isLoading = true);

    final result = await _loginBloc.registerUser(
      usernameController.text,
      emailController.text,
      passwordController.text,
      fnameController.text,
      lnameController.text,
      addressController.text,
      '+63${phoneNumController.text.replaceAll('-', '')}',
    );
    setState(() => isLoading = false);

    if (result['success']) {
      if (!mounted) return;
      _showSuccessSnackBar('Account created successfully!');
      // Wait for a moment before navigating to give user time to see the message
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(RouteNames.login);
    } else {
      final error = result['error'];
      if (error != null) {
        _showErrorSnackBar(error);
      }
    }
  }

      // Wrapper function to handle button press and loading state
      void _onSignUpPressed() {
        if (!isLoading) {
          _handleUserSignUp();
        }
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          backgroundColor: MoldifyColors.backgroundColor,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// ----------- H E A D E R ------------
                    Stack(
                      children: [
                        SvgPicture.asset(
                          'assets/images/Yellow.svg',
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          fit: BoxFit.cover,
                        ),
                        SvgPicture.asset(
                          'assets/images/Green.svg',
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          fit: BoxFit.cover,
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Text.rich(
                                  TextSpan(
                                    style: TextStyle(
                                      fontFamily: 'Montserrat-ExtraBold',
                                      fontSize: 48,
                                      color: MoldifyColors.backgroundColor,
                                      height: 1,
                                    ),
                                    children: [
                                      const TextSpan(text: 'SIGN UP\n'),
                                      TextSpan(
                                        text: 'Please enter details to create an account.',
                                        style: TextStyle(
                                          fontFamily: 'Bricolage-Grotesque-Regular',
                                          fontSize: 14,
                                          color: MoldifyColors.backgroundColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.start,
                                )
                            ),
                          ),
                        ),
                      ],
                    ),

                    /// ----------- E N D  H E A D E R ------------

                    Padding(padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, bottom: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// Username Label
                          Padding(
                            padding: const EdgeInsets.only(top: 30.0),
                            child: AutoSizeText(
                              'Username',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Bricolage-Grotesque-SemiBold',
                                color: MoldifyColors.primaryColor,
                              ),
                              maxLines: 1,
                              minFontSize: 12,
                            ),
                          ),

                          /// Username TextBox
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: BuildTextBox(
                              hintText: 'Enter Username',
                              controller: usernameController,
                              showPassword: false,
                            ),
                          ),

                          /// FirstName Label
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: AutoSizeText(
                              'First Name',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Bricolage-Grotesque-SemiBold',
                                color: MoldifyColors.primaryColor,
                              ),
                              maxLines: 1,
                              minFontSize: 12,
                            ),
                          ),

                          /// FirstName TextBox
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: BuildTextBox(
                              hintText: 'Enter first name',
                              controller: fnameController,
                              showPassword: false,
                            ),
                          ),

                          /// LastName Label
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: AutoSizeText(
                              'Last Name',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Bricolage-Grotesque-SemiBold',
                                color: MoldifyColors.primaryColor,
                              ),
                              maxLines: 1,
                              minFontSize: 12,
                            ),
                          ),

                          /// LastName TextBox
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: BuildTextBox(
                              hintText: 'Enter last name',
                              controller: lnameController,
                              showPassword: false,
                            ),
                          ),

                          /// Email Label
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: AutoSizeText(
                              'Email',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Bricolage-Grotesque-SemiBold',
                                color: MoldifyColors.primaryColor,
                              ),
                              maxLines: 1,
                              minFontSize: 12,
                            ),
                          ),

                          /// Email TextBox
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: BuildTextBox(
                              hintText: 'Enter Email',
                              controller: emailController,
                              showPassword: false,
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),

                          /// Phone Number Label
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: AutoSizeText(
                              'Phone Number',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Bricolage-Grotesque-SemiBold',
                                color: MoldifyColors.primaryColor,
                              ),
                              maxLines: 1,
                              minFontSize: 12,
                            ),
                          ),

                          /// Phone Number TextBox
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: BuildTextBox(
                              hintText: '9__-___-____',
                              controller: phoneNumController,
                              showPassword: false,
                              keyboardType: TextInputType.phone,
                              showPhoneNumberPrefix: true,
                              maxLength: 12,
                              customInputFormatters: [PhoneNumberFormatter()],
                            ),
                          ),

                          if (_phoneErrorText != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                              child: AutoSizeText(
                                _phoneErrorText!,
                                style: const TextStyle(
                                  color: MoldifyColors.MoldifyRed,
                                  fontSize: 14,
                                  fontFamily: 'Bricolage-Grotesque-Regular',
                                ),
                                maxLines: 2,
                                minFontSize: 12,
                              ),
                            ),

                          /// Location Label
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: AutoSizeText(
                              'Location(City/Province)',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Bricolage-Grotesque-SemiBold',
                                color: MoldifyColors.primaryColor,
                              ),
                              maxLines: 1,
                              minFontSize: 12,
                            ),
                          ),

                          /// Location TextBox
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: BuildTextBox(
                              hintText: 'Enter location',
                              controller: addressController,
                              showPassword: false,
                            ),
                          ),

                          /// Password Label
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: AutoSizeText(
                              'Password',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Bricolage-Grotesque-SemiBold',
                                color: MoldifyColors.primaryColor,
                              ),
                              maxLines: 1,
                              minFontSize: 12,
                            ),
                          ),

                          /// Password TextBox
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: BuildTextBox(
                              hintText: 'Enter Password',
                              controller: passwordController,
                              showPassword: true,
                            ),
                          ),

                          if (_passwordErrorText != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                              child: AutoSizeText(
                                _passwordErrorText!,
                                style: const TextStyle(
                                  color: MoldifyColors.MoldifyRed,
                                  fontSize: 16,
                                  fontFamily: 'Bricolage-Grotesque-Regular',
                                ),
                                maxLines: 10,
                                minFontSize: 12,
                              ),
                            ),

                          /// Confirm Password Label
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: AutoSizeText(
                              'Confirm Password',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Bricolage-Grotesque-SemiBold',
                                color: MoldifyColors.primaryColor,
                              ),
                              maxLines: 1,
                              minFontSize: 12,
                            ),
                          ),

                          /// Confirm Password TextBox
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: BuildTextBox(
                              hintText: 'Enter Confirm Password',
                              controller: confirmPasswordController,
                              showPassword: true,
                            ),
                          ),

                          /// Signup Button
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 50.0, bottom: 3.0),
                            child: BuildButton(
                                buttonText: 'Sign Up',
                                onPressed: _onSignUpPressed,
                                backgroundColor: isLoading ? MoldifyColors
                                    .MoldifyGrey : MoldifyColors.primaryColor,
                                textColor: isLoading ? MoldifyColors
                                    .MoldifyBlack : MoldifyColors
                                    .backgroundColor,
                                buttonHeight: 45,
                                buttonWidth: MediaQuery
                                    .of(context)
                                    .size
                                    .width,
                                buttonRadius: 10
                            ),
                          ),

                          /// Log In Message
                          Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AutoSizeText (
                                  'Already have an account? ',
                                  style: TextStyle(
                                    fontFamily: 'Bricolage-Grotesque-Regular',
                                    fontSize: 14,
                                    color: MoldifyColors.MoldifyBlack,
                                  ),
                                  maxLines: 1,
                                  minFontSize: 12,
                                ),

                                /// Log In Button
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (
                                            context) => LoginScreen(),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  splashColor: MoldifyColors.accentColor
                                      .withValues(alpha: 0.2),
                                  highlightColor: MoldifyColors.accentColor
                                      .withValues(alpha: 0.2),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 4),
                                    child: AutoSizeText(
                                      'Log In',
                                      style: TextStyle(
                                        fontFamily: 'Bricolage-Grotesque-SemiBold',
                                        fontSize: 14,
                                        color: MoldifyColors.primaryColor,
                                      ),
                                      maxLines: 1,
                                      minFontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // // Divider with 'or'
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(vertical: 30.0),
                          //   child: Row(
                          //     children: [
                          //       Expanded(child: Divider(
                          //           color: MoldifyColors.MoldifyBlack)),
                          //       Padding(
                          //         padding: const EdgeInsets.symmetric(
                          //             horizontal: 10.0),
                          //         child: Text(
                          //           'or continue with',
                          //           style: TextStyle(
                          //             fontFamily: 'Bricolage-Grotesque-Regular',
                          //             fontSize: 14,
                          //             color: MoldifyColors.MoldifyBlack,
                          //           ),
                          //         ),
                          //       ),
                          //       Expanded(child: Divider(
                          //           color: MoldifyColors.MoldifyBlack)),
                          //     ],
                          //   ),
                          // ),

                          // // Google Sign-In Button
                          // BuildButton(
                          //   onPressed: _onGoogleSignInPressed,
                          //   buttonText: 'Sign Up with Google',
                          //   backgroundColor: MoldifyColors.backgroundColor,
                          //   textColor: isLoading
                          //       ? MoldifyColors.MoldifyGrey
                          //       : MoldifyColors.primaryColor,
                          //   buttonHeight: 45,
                          //   buttonWidth: MediaQuery
                          //       .of(context)
                          //       .size
                          //       .width,
                          //   buttonRadius: 10,
                          //   svg: 'assets/icons/google-icon.svg',
                          //   borderColor: MoldifyColors.primaryColor,
                          // ),

                          /// Terms and Policy Agreement
                          Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    value: _agreedToTerms,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _agreedToTerms = value ?? false;
                                      });
                                    },
                                    activeColor: MoldifyColors.primaryColor,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                        style: const TextStyle(
                                          fontFamily: 'Bricolage-Grotesque-Regular',
                                          fontSize: 12,
                                          color: MoldifyColors.MoldifyBlack,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text: 'I acknowledged that I have read, understood and agree to our ',
                                          ),
                                          TextSpan(
                                            text: 'Terms of Agreement',
                                            style: const TextStyle(
                                              fontFamily: 'Bricolage-Grotesque-Bold',
                                              color: MoldifyColors.primaryColor,
                                              decoration: TextDecoration
                                                  .underline,
                                              decorationThickness: 2,
                                              decorationColor: MoldifyColors.primaryColor,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                // Handle Terms of Agreement tap here
                                              },
                                          ),
                                          const TextSpan(text: ' and '),
                                          TextSpan(
                                            text: 'Privacy Policy',
                                            style: const TextStyle(
                                              fontFamily: 'Bricolage-Grotesque-Bold',
                                              color: MoldifyColors.primaryColor,
                                              decoration: TextDecoration
                                                  .underline,
                                              decorationThickness: 2,
                                              decorationColor: MoldifyColors.primaryColor,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                // Handle Privacy Policy tap here
                                              },
                                          ),
                                          const TextSpan(text: '.'),
                                        ],
                                      ),
                                      // textAlign: TextAlign.center, // Removed as text is now part of a row
                                    ),
                                  ),
                                ],
                              )
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        );
      }
  }
