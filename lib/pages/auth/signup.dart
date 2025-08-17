import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:moldify/pages/auth/login.dart';
import '../misc/buttons/primary_button.dart';
import '../misc/colors.dart';
import '../misc/textboxes/textboxes.dart';
import 'package:moldify/core/features/authentication/logic/auth_bloc.dart';
import 'package:moldify/core/features/authentication/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../../core/constants/route_names.dart';
import '../../providers/auth_provider.dart';

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
  bool _agreedToTerms = false;
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed from the widget tree
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => isLoading = true);
    final result = await _loginBloc.loginWithGoogle();
    setState(() => isLoading = false);
    if (!result['success']) {
      setState(() => errorMessage = result['error']);
      return;
    }
    if (!context.mounted) return;
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    if (result['sessionValue'] != null) {
      await authProvider.saveCookie(result['sessionValue']);
    }
    Navigator.of(context).pushReplacementNamed(RouteNames.main);
  }

  Future<void> _handleUserSignUp() async {
    setState(() => isLoading = true);
    if( usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      setState(() {
        errorMessage = 'All fields are required.';
        isLoading = false;
      });
      return;
    }
    if( passwordController.text != confirmPasswordController.text) {
      setState(() {
        errorMessage = 'Passwords do not match.';
        isLoading = false;
      });
      return;
    }
    final result = await _loginBloc.registerUser(
      usernameController.text,
      emailController.text,
      passwordController.text,
    );
    setState(() => isLoading = false);
    if (!result['success']) {
      setState(() => errorMessage = result['error']);
      return;
    }
    if (!context.mounted) return;
    Navigator.of(context).pushReplacementNamed(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ----------- H E A D E R ------------
            Stack(
              children: [
                SvgPicture.asset(
                  'assets/images/Yellow.svg',
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
                SvgPicture.asset(
                  'assets/images/Green.svg',
                  width: MediaQuery.of(context).size.width,
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

            Padding(padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// Username Label
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: const Text(
                      'Username',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Bricolage-Grotesque-SemiBold',
                        color: MoldifyColors.primaryColor,
                      ),
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

                  /// Email Label
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
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
                    padding: const EdgeInsets.only(top: 8.0),
                    child: BuildTextBox(
                      hintText: 'Enter Email',
                      controller: emailController,
                      showPassword: false,
                    ),
                  ),

                  /// Password Label
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Bricolage-Grotesque-SemiBold',
                        color: MoldifyColors.primaryColor,
                      ),
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

                  /// Confirm Password Label
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: const Text(
                      'Confirm Password',
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
                      hintText: 'Enter Confirm Password',
                      controller: confirmPasswordController,
                      showPassword: true,
                    ),
                  ),

                  /// Signup Button
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0, bottom: 3.0),
                    child: BuildButton(
                        buttonText: 'Sign Up',
                        onPressed: _handleUserSignUp,
                        backgroundColor: MoldifyColors.primaryColor,
                        textColor: MoldifyColors.backgroundColor,
                        buttonHeight: 45,
                        buttonWidth: MediaQuery.of(context).size.width,
                        buttonRadius: 10
                    ),
                  ),

                  /// Log In Message
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text (
                          'Already have an account? ',
                          style: TextStyle(
                            fontFamily: 'Bricolage-Grotesque-Regular',
                            fontSize: 14,
                            color: MoldifyColors.MoldifyBlack,
                          ),
                        ),

                        /// Sign Up Button
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          splashColor: MoldifyColors.accentColor.withValues(alpha: 0.2),
                          highlightColor: MoldifyColors.accentColor.withValues(alpha: 0.2),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 6),
                            child: Text(
                              'Log In',
                              style: TextStyle(
                                fontFamily: 'Bricolage-Grotesque-Bold',
                                fontSize: 14,
                                color: MoldifyColors.accentColor,
                                decoration: TextDecoration.underline,
                                decorationColor: MoldifyColors.accentColor,
                                decorationThickness: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ),

                  /// Divider with "or continue with" text
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: MoldifyColors.MoldifyBlack,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'or continue with',
                            style: TextStyle(
                                fontFamily: 'Bricolage-Grotesque-Regular',
                                fontSize: 12,
                                color: MoldifyColors.MoldifyBlack
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: MoldifyColors.MoldifyBlack,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Google Login Button
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0, bottom: 30.0),
                    child: BuildButton(
                        buttonText: 'Google',
                        onPressed: _handleGoogleSignIn,
                        backgroundColor: Colors.transparent,
                        textColor: MoldifyColors.primaryColor,
                        buttonHeight: 45,
                        buttonWidth: MediaQuery.of(context).size.width,
                        buttonRadius: 10,
                        borderColor: MoldifyColors.primaryColor,
                        svg: 'assets/icons/google-icon.svg',
                        svgHeight: 20,
                    ),
                  ),
                  /// End of Google Login Button

                  /// Terms and Policy Agreement
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// Checkbox for Terms and Conditions
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
                        /// Terms and Conditions Text
                        /// Using Text.rich to allow for clickable links
                        /// and to maintain the same style as the rest of the text
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
                                    color: MoldifyColors.accentColor,
                                    decoration: TextDecoration.underline,
                                    decorationThickness: 2,
                                    decorationColor: MoldifyColors.accentColor,
                                  ),
                                  recognizer: TapGestureRecognizer()..onTap = () {
                                    // Handle Terms of Agreement tap here
                                  },
                                ),
                                const TextSpan(text: ' and '),
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
                            // textAlign: TextAlign.center, // Removed as text is now part of a row
                          ),
                        ),
                      ],
                    )
                  )
                  /// End of Terms and Policy Agreement
                ],
              )
            ),
          ],
        )
      ),
    );
  }
}
