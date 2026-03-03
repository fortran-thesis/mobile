import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moldify/core/features/authentication/logic/auth_bloc.dart';
import 'package:moldify/core/features/authentication/services/auth_service.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:provider/provider.dart';
import '../misc/colors.dart';
import '../misc/textboxes/textboxes.dart';
import '../../core/constants/route_names.dart';
import '../../core/utils/route_utils.dart';
import '../../providers/auth_provider.dart';

/// This is the login screen of the app.
/// It allows users to log in with their username and password.
/// It also provides options for forgotten username and password,
/// as well as a continue with Google option.

class LoginScreen extends StatefulWidget {
  String? userRole;

  LoginScreen({super.key, this.userRole});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  late final AuthBloc _loginBloc = AuthBloc(_authService);

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  //String? errorMessage;

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed from the widget tree
    usernameController.dispose();
    passwordController.dispose();
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

  Future<void> _handleGoogleSignIn() async {
    setState(() => isLoading = true);
    final result = await _loginBloc.loginWithGoogle();
    setState(() => isLoading = false);

    if (result['success']) {
      if (!context.mounted) return;
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      if (result['sessionValue'] != null) {
        await authProvider.saveCookie(result['sessionValue']);
      }
      Navigator.of(context).pushReplacementNamed(RouteNames.main);
    } else {
      final error = result['error'];
      if (error != null) {
        _showErrorSnackBar(error.toString());
      }
    }
  }

  Future<void> _handleUsernamePasswordSignIn() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      _showErrorSnackBar('Please enter your username and password.');
      return;
    }

    setState(() => isLoading = true);
    final result = await _loginBloc.loginWithUsernamePassword(
      usernameController.text,
      passwordController.text,
    );
    setState(() => isLoading = false);

    if (!result['success']) {
      _showErrorSnackBar('Invalid username or password.');
      return;
    }

    if (!result['success']) {
      final error = result['error'];
      if (error != null) {
        _showErrorSnackBar(error);
      }
      return;
    }

    if (!context.mounted) return;
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    if (result['sessionValue'] != null) {
      await authProvider.saveCookie(result['sessionValue']);
    }
    Navigator.of(context).pushNamedAndRemoveUntil(
        RouteNames.main, (route) => false);
  }

  // Wrapper function to handle button press and loading state
  void _onLoginPressed() {
    if (!isLoading) {
      _handleUsernamePasswordSignIn();
    }
  }

  // Wrapper function for Google Sign-In
  void _onGoogleSignInPressed() {
    if (!isLoading) {
      _handleGoogleSignIn();
    }
  }


  @override
  Widget build(BuildContext context) {
    final bool isMycologist = widget.userRole?.toLowerCase() == 'mycologist';
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
                          child: AutoSizeText.rich(
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
                                    fontSize: 14,
                                    color: MoldifyColors.backgroundColor,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.start,
                            maxLines: 3,
                            minFontSize: 10,
                            overflow: TextOverflow.visible,
                            softWrap: true,
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
                          onTap: () => navigateTo(context, RouteNames.emailRecoverAccount, arguments: {'pageTitle': 'Forgot Username'}),
                          borderRadius: BorderRadius.circular(8),
                          splashColor: MoldifyColors.primaryColor.withValues(alpha: 0.2),
                          highlightColor: MoldifyColors.primaryColor.withValues(alpha: 0.2),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                            child: AutoSizeText(
                              'Forgot Username?',
                              style: TextStyle(
                                fontFamily: 'Bricolage-Grotesque-Regular',
                                fontSize: 12,
                                color: MoldifyColors.MoldifyBlack,
                              ),
                              maxLines: 1,
                              minFontSize: 10,
                            ),
                          ),
                        ),
                      ),

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
                          onTap: () => navigateTo(context, RouteNames.emailRecoverAccount, arguments: {'pageTitle': 'Forgot Password'}),
                          borderRadius: BorderRadius.circular(8),
                          splashColor: MoldifyColors.primaryColor.withValues(alpha: 0.2),
                          highlightColor: MoldifyColors.primaryColor.withValues(alpha: 0.2),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 6),
                            child: AutoSizeText(
                              'Forgot Password?',
                              style: TextStyle(
                                fontFamily: 'Bricolage-Grotesque-Regular',
                                fontSize: 12,
                                color: MoldifyColors.MoldifyBlack,
                              ),
                              maxLines: 1,
                              minFontSize: 8,
                            ),
                          ),
                        ),
                      ),

                      /// Login Button
                      Padding(
                        padding: const EdgeInsets.only(top: 50.0, bottom: 3.0),
                        child: BuildButton(
                            buttonText: 'Log In',
                            onPressed: _onLoginPressed,
                            backgroundColor: MoldifyColors.primaryColor,
                            textColor: MoldifyColors.backgroundColor,
                            buttonHeight: 45,
                            buttonWidth: MediaQuery.of(context).size.width,
                            buttonRadius: 10
                        ),
                      ),

                      if(!isMycologist) ... [

                        /// Sign Up Message
                        Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const AutoSizeText (
                                  'Don\'t have an account?',
                                  style: TextStyle(
                                    fontFamily: 'Bricolage-Grotesque-Regular',
                                    fontSize: 14,
                                    color: MoldifyColors.MoldifyBlack,
                                  ),
                                  maxLines: 1,
                                  minFontSize: 12,
                                ),

                                /// Sign Up Button
                                InkWell(
                                  onTap: () => navigateTo(context, RouteNames.signup),
                                  borderRadius: BorderRadius.circular(8),
                                  splashColor: MoldifyColors.accentColor.withValues(alpha: 0.2),
                                  highlightColor: MoldifyColors.accentColor.withValues(alpha: 0.2),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 6),
                                    child: AutoSizeText(
                                      'Sign Up',
                                      style: TextStyle(
                                        fontFamily: 'Bricolage-Grotesque-Bold',
                                        fontSize: 14,
                                        color: MoldifyColors.primaryColor,
                                        decoration: TextDecoration.underline,
                                        decorationColor: MoldifyColors.primaryColor,
                                        decorationThickness: 2,
                                      ),
                                      maxLines: 1,
                                      minFontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            )
                        ),

                        // /// Divider with "or continue with" text
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 30.0),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       Expanded(
                        //         child: Container(
                        //           height: 2,
                        //           decoration: BoxDecoration(
                        //             color: MoldifyColors.MoldifyBlack,
                        //             borderRadius: BorderRadius.circular(2),
                        //           ),
                        //         ),
                        //       ),
                        //       const Padding(
                        //         padding: EdgeInsets.symmetric(horizontal: 16.0),
                        //         child: AutoSizeText(
                        //           'or continue with',
                        //           style: TextStyle(
                        //               fontFamily: 'Bricolage-Grotesque-Regular',
                        //               fontSize: 12,
                        //               color: MoldifyColors.MoldifyBlack
                        //           ),
                        //           maxLines: 1,
                        //           minFontSize: 10,
                        //         ),
                        //       ),
                        //       Expanded(
                        //         child: Container(
                        //           height: 2,
                        //           decoration: BoxDecoration(
                        //             color: MoldifyColors.MoldifyBlack,
                        //             borderRadius: BorderRadius.circular(2),
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),

                        // /// Google Login Button
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 30.0),
                        //   child: BuildButton(
                        //     buttonText: 'Google',
                        //     onPressed: _onGoogleSignInPressed,
                        //     backgroundColor: Colors.transparent,
                        //     textColor: MoldifyColors.primaryColor,
                        //     buttonHeight: 45,
                        //     buttonWidth: MediaQuery.of(context).size.width,
                        //     buttonRadius: 10,
                        //     borderColor: MoldifyColors.primaryColor,
                        //     svg: 'assets/icons/google-icon.svg',
                        //     svgHeight: 20,
                        //   ),
                        // ),
                        // /// End of Google Login Button

                      ],


                      /// Terms and Policy Agreement
                      /// This section provides a link to the Terms of Agreement and Privacy Policy.
                      /// It uses a TextRich with recognizers to handle taps on the links.
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 30.0),
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
                                  text: 'By proceeding you acknowledge that you have read, understood and agree to our ',
                                ),
                                TextSpan(
                                  text: 'Terms of Agreement',
                                  style: const TextStyle(
                                    fontFamily: 'Bricolage-Grotesque-Bold',
                                    color: MoldifyColors.primaryColor,
                                    decoration: TextDecoration.underline,
                                    decorationThickness: 2,
                                    decorationColor: MoldifyColors.primaryColor,
                                  ),
                                  recognizer: TapGestureRecognizer()..onTap = () {
                                    navigateTo(context, RouteNames.terms);
                                  },
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: const TextStyle(
                                    fontFamily: 'Bricolage-Grotesque-Bold',
                                    color: MoldifyColors.primaryColor,
                                    decoration: TextDecoration.underline,
                                    decorationThickness: 2,
                                    decorationColor: MoldifyColors.primaryColor,
                                  ),
                                  recognizer: TapGestureRecognizer()..onTap = () {
                                    navigateTo(context, RouteNames.privacy);
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
          if (isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(MoldifyColors.backgroundColor),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
