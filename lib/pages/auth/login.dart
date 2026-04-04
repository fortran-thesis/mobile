import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moldify/core/features/authentication/logic/auth_bloc.dart';
import 'package:moldify/core/features/authentication/services/auth_service.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/language_toggle.dart';
import 'package:moldify/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../misc/colors.dart';
import '../misc/overlays/app_feedback.dart';
import '../misc/overlays/loading_ui.dart';
import '../misc/textboxes/textboxes.dart';
import '../../core/constants/route_names.dart';
import '../../core/utils/auth_navigation.dart';
import '../../core/utils/route_utils.dart';
import '../../providers/auth_provider.dart';

/// This is the login screen of the app.
/// It allows users to log in with their username and password.
/// It also provides options for forgotten username and password,
/// as well as a continue with Google option.

class LoginScreen extends StatefulWidget {
  final String? userRole;

  const LoginScreen({super.key, this.userRole});

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

  String _normalizeLoginError(dynamic rawError) {
    final message = rawError?.toString().trim().toLowerCase() ?? '';

    if (message.isEmpty) {
      return 'Invalid username or password.';
    }

    if (message.contains('invalid credential') ||
        message.contains('invalid username') ||
        message.contains('invalid password') ||
        message.contains('unauthorized') ||
        message.contains('incorrect') ||
        message.contains('password too long')) {
      return 'Invalid username or password.';
    }

    if (message.contains('network') ||
        message.contains('socket') ||
        message.contains('timeout') ||
        message.contains('connection')) {
      return 'Unable to connect. Please check your internet and try again.';
    }

    return 'Login failed. Please try again.';
  }

  void _showUnifiedLoginError(dynamic rawError) {
    AppFeedback.showError(context, _normalizeLoginError(rawError));
  }

  Future<void> _handleUsernamePasswordSignIn() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      AppFeedback.showError(context, 'Username and password are required.');
      return;
    }

    setState(() {
      isLoading = true;
    });
    try {
      final result = await _loginBloc.loginWithUsernamePassword(
        usernameController.text,
        passwordController.text,
      );

      if (!result['success']) {
        _showUnifiedLoginError(result['error']);
        return;
      }

      if (!mounted) return;
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      if (result['sessionValue'] != null) {
        await authProvider.saveCookie(result['sessionValue']);
      }
      if (!mounted) return;
      AuthNavigation.resetToMainFromContext(context);
    } catch (e) {
      _showUnifiedLoginError(e);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // Wrapper function to handle button press and loading state
  void _onLoginPressed() {
    if (!isLoading) {
      _handleUsernamePasswordSignIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMycologist = widget.userRole?.toLowerCase() == 'mycologist';
    final l10n = AppLocalizations.of(context)!;

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
                                TextSpan(text: '${l10n.logIn}\n'),
                                TextSpan(
                                  text: l10n.loginSubtitle,
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
                          ),
                        ),
                      ),
                    ),
                    /// Language Toggle (Top Right of header)
                    Positioned(
                      top: 10,
                      right: 15,
                      child: LanguageToggle(
                        color: MoldifyColors.backgroundColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                /// ----------- E N D  H E A D E R ------------
                Padding(
                  padding: const EdgeInsets.only(
                    left: 15.0,
                    right: 15.0,
                    bottom: 30.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: AutoSizeText(
                          l10n.username,
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
                          hintText: l10n.enterUsername,
                          controller: usernameController,
                          showPassword: false,
                        ),
                      ),

                      /// Forgot Username Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () => navigateTo(
                            context,
                            RouteNames.emailRecoverAccount,
                            arguments: {'pageTitle': l10n.forgotUsername},
                          ),
                          borderRadius: BorderRadius.circular(8),
                          splashColor: MoldifyColors.primaryColor.withValues(
                            alpha: 0.2,
                          ),
                          highlightColor: MoldifyColors.primaryColor.withValues(
                            alpha: 0.2,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 6,
                            ),
                            child: AutoSizeText(
                              l10n.forgotUsername,
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
                          l10n.passwordLabel,
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
                          hintText: l10n.enterPasswordHint,
                          controller: passwordController,
                          showPassword: true,
                        ),
                      ),

                      /// Forgot Password Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () => navigateTo(
                            context,
                            RouteNames.emailRecoverAccount,
                            arguments: {'pageTitle': l10n.forgotPassword},
                          ),
                          borderRadius: BorderRadius.circular(8),
                          splashColor: MoldifyColors.primaryColor.withValues(
                            alpha: 0.2,
                          ),
                          highlightColor: MoldifyColors.primaryColor.withValues(
                            alpha: 0.2,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 6,
                            ),
                            child: AutoSizeText(
                              l10n.forgotPassword,
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
                          buttonText: l10n.logIn,
                          onPressed: _onLoginPressed,
                          backgroundColor: MoldifyColors.primaryColor,
                          textColor: MoldifyColors.backgroundColor,
                          buttonHeight: 45,
                          buttonWidth: MediaQuery.of(context).size.width,
                          buttonRadius: 10,
                        ),
                      ),

                      if (!isMycologist) ...[
                        /// Sign Up Message
                        Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AutoSizeText(
                                l10n.dontHaveAccount,
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
                                onTap: () =>
                                    navigateTo(context, RouteNames.signup),
                                borderRadius: BorderRadius.circular(8),
                                splashColor: MoldifyColors.accentColor
                                    .withValues(alpha: 0.2),
                                highlightColor: MoldifyColors.accentColor
                                    .withValues(alpha: 0.2),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 6,
                                  ),
                                  child: AutoSizeText(
                                    l10n.signUpLink,
                                    style: TextStyle(
                                      fontFamily: 'Bricolage-Grotesque-Bold',
                                      fontSize: 14,
                                      color: MoldifyColors.primaryColor,
                                      decoration: TextDecoration.underline,
                                      decorationColor:
                                          MoldifyColors.primaryColor,
                                      decorationThickness: 2,
                                    ),
                                    maxLines: 1,
                                    minFontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                          padding: const EdgeInsets.only(
                            left: 8.0,
                            right: 8.0,
                            top: 30.0,
                          ),
                          child: Text.rich(
                            TextSpan(
                              style: const TextStyle(
                                fontFamily: 'Bricolage-Grotesque-Regular',
                                fontSize: 12,
                                color: MoldifyColors.MoldifyBlack,
                              ),
                              children: [
                                TextSpan(
                                  text: l10n.loginTermsText,
                                ),
                                TextSpan(
                                  text: l10n.termsOfAgreement,
                                  style: const TextStyle(
                                    fontFamily: 'Bricolage-Grotesque-Bold',
                                    color: MoldifyColors.primaryColor,
                                    decoration: TextDecoration.underline,
                                    decorationThickness: 2,
                                    decorationColor: MoldifyColors.primaryColor,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      navigateTo(context, RouteNames.terms);
                                    },
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: l10n.privacyPolicy,
                                  style: const TextStyle(
                                    fontFamily: 'Bricolage-Grotesque-Bold',
                                    color: MoldifyColors.primaryColor,
                                    decoration: TextDecoration.underline,
                                    decorationThickness: 2,
                                    decorationColor: MoldifyColors.primaryColor,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      navigateTo(context, RouteNames.privacy);
                                    },
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      /// End of Terms and Policy Agreement
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            const AppLoadingOverlay(
              message: 'Logging you in...',
            ),
        ],
      ),
    );
  }
}
