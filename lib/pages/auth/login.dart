import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moldify/main.dart';
import 'package:moldify/pages/auth/email_recover_account.dart';
import 'package:moldify/pages/auth/signup.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import '../misc/colors.dart';
import '../misc/textboxes/textboxes.dart';

/// This is the login screen of the app.
/// It allows users to log in with their username and password.
/// It also provides options for forgotten username and password,
/// as well as a continue with Google option.

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed from the widget tree
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
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
                            const TextSpan(text: 'LOG IN\n'),
                            TextSpan(
                              text: 'Please enter username and password.',
                              style: TextStyle(
                                fontFamily: 'Bricolage-Grotesque-Regular',
                                fontSize: 12,
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
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: const Text(
                      'Username',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Bricolage-Grotesque-SemiBold',
                        color: MoldifyColors.primaryColor,
                      ),
                    ),
                  ),

                  /// Username TextBox
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 3.0),
                    child: BuildTextBox(
                      hintText: 'Enter Username',
                      controller: usernameController,
                      showPassword: false,
                    ),
                  ),

                  /// Forgot Username Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const EmailRecoverAccountScreen(pageTitle: 'Forgot Username',),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      splashColor: MoldifyColors.primaryColor.withValues(alpha: 0.2),
                      highlightColor: MoldifyColors.primaryColor.withValues(alpha: 0.2),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                        child: Text(
                          'Forgot Username?',
                          style: TextStyle(
                            fontFamily: 'Bricolage-Grotesque-Regular',
                            fontSize: 12,
                            color: MoldifyColors.MoldifyBlack,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Bricolage-Grotesque-SemiBold',
                        color: MoldifyColors.primaryColor,
                      ),
                    ),
                  ),

                  /// Password TextBox
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 3.0),
                    child: BuildTextBox(
                      hintText: 'Enter Password',
                      controller: passwordController,
                      showPassword: true,
                    ),
                  ),

                  /// Forgot Password Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const EmailRecoverAccountScreen(pageTitle: 'Forgot Password',),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      splashColor: MoldifyColors.primaryColor.withValues(alpha: 0.2),
                      highlightColor: MoldifyColors.primaryColor.withValues(alpha: 0.2),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 4, horizontal: 6),
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontFamily: 'Bricolage-Grotesque-Regular',
                            fontSize: 12,
                            color: MoldifyColors.MoldifyBlack,
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// Login Button
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0, bottom: 3.0),
                    child: BuildButton(
                        buttonText: 'Log In',
                        onPressed: () {
                          // Handle login logic here
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const MainPage(),
                            ),
                          );
                        },
                        backgroundColor: MoldifyColors.primaryColor,
                        textColor: MoldifyColors.backgroundColor,
                        buttonHeight: 45,
                        buttonWidth: MediaQuery.of(context).size.width,
                        buttonRadius: 10
                    ),
                  ),

                  /// Sign Up Message
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text (
                          'Don\'t have an account?',
                          style: TextStyle(
                            fontFamily: 'Bricolage-Grotesque-Regular',
                            fontSize: 12,
                            color: MoldifyColors.MoldifyBlack,
                          ),
                        ),

                        /// Sign Up Button
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
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
                              'Sign Up',
                              style: TextStyle(
                                fontFamily: 'Bricolage-Grotesque-Bold',
                                fontSize: 12,
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
                                fontSize: 10,
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
                        onPressed: () {
                          // Handle Google login logic here
                        },
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
                  /// This section provides a link to the Terms of Agreement and Privacy Policy.
                  /// It uses a TextRich with recognizers to handle taps on the links.
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child:
                      Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Bricolage-Grotesque-Regular',
                            fontSize: 10,
                            color: MoldifyColors.MoldifyBlack,
                          ),
                          children: [
                            const TextSpan(
                              text: 'By proceeding you acknowledge that you have read, understood and agree to our ',
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
                        textAlign: TextAlign.center,
                      )
                    ),
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
