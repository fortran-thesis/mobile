import 'package:flutter/material.dart';
import 'package:moldify/l10n/app_localizations.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:provider/provider.dart';

import '../../core/features/authentication/services/auth_service.dart';
import '../../providers/auth_provider.dart';
import '../auth/email_recover_account.dart';
import '../misc/buttons/primary_button.dart';
import '../misc/textboxes/textboxes.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final AuthService _authService = AuthService();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();


  bool _isLoading = false;

  Future<void> _changePassword() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;

    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmNewPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar(l10n.pleaseFillAllFields);
      setState(() => _isLoading = false);
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar(l10n.passwordsDoNotMatch);
      setState(() => _isLoading = false);
      return;
    }

    // Validate password complexity (must match server PasswordSchema)
    if (newPassword.length < 8) {
      _showSnackBar(l10n.passwordTooShort);
      setState(() => _isLoading = false);
      return;
    }
    if (!RegExp(r'[a-z]').hasMatch(newPassword)) {
      _showSnackBar(l10n.passwordLowercaseRequired);
      setState(() => _isLoading = false);
      return;
    }
    if (!RegExp(r'[A-Z]').hasMatch(newPassword)) {
      _showSnackBar(l10n.passwordUppercaseRequired);
      setState(() => _isLoading = false);
      return;
    }
    if (!RegExp(r'[0-9]').hasMatch(newPassword)) {
      _showSnackBar(l10n.passwordNumberRequired);
      setState(() => _isLoading = false);
      return;
    }
    if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(newPassword)) {
      _showSnackBar(l10n.passwordSpecialCharRequired);
      setState(() => _isLoading = false);
      return;
    }

    try {
      final authProvider = context.read<AppAuthProvider>();
      final sessionCookie = authProvider.cookie;

      if (sessionCookie == null || sessionCookie.isEmpty) {
        _showSnackBar(l10n.authErrorPleaseLogin);
        setState(() => _isLoading = false);
        return;
      }

      final result = await _authService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        sessionCookie: sessionCookie,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        _showSnackBar(result['data'] ?? l10n.passwordChangedSuccessfully);
        Navigator.pop(context);
      } else {
        _showSnackBar(result['error'] != null ? l10n.failedToChangePassword(result['error']) : l10n.somethingWentWrong);
      }
    } catch (e) {
      _showSnackBar(l10n.somethingWentWrong);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MoldifyColors.backgroundColor,
        appBar: PrimaryAppBar(
          title: AppLocalizations.of(context)!.changePasswordTitle,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
                child: Padding(padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0, bottom: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ----------- Edit Profile Header -----------
                      Text(
                          AppLocalizations.of(context)!.changePasswordTitle,
                          style: const TextStyle(
                            fontSize: 36,
                            fontFamily: 'Montserrat-Black',
                            color: MoldifyColors.primaryColor,
                          )
                      ),
                      Text(
                          AppLocalizations.of(context)!.changePasswordSubtitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Bricolage-Grotesque-Regular',
                            color: MoldifyColors.MoldifyBlack,
                          )
                      ),
                      /// ----------- End of Edit Profile Header -----------

                      Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Text(
                          AppLocalizations.of(context)!.oldPassword,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Bricolage-Grotesque-SemiBold',
                            color: MoldifyColors.primaryColor,
                          ),
                        ),
                      ),

                      /// Password TextBox
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 3.0),
                        child: BuildTextBox(
                          hintText: AppLocalizations.of(context)!.enterOldPassword,
                          controller: oldPasswordController,
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
                                builder: (context) => EmailRecoverAccountScreen(pageTitle: AppLocalizations.of(context)!.forgotPassword,),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          // FIX: Use .withOpacity() instead of .withValues()
                          splashColor: MoldifyColors.primaryColor.withValues(alpha: 0.2),
                          highlightColor: MoldifyColors.primaryColor.withValues(alpha: 0.2),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 6),
                            child: Text(
                              AppLocalizations.of(context)!.forgotPassword,
                              style: const TextStyle(
                                fontFamily: 'Bricolage-Grotesque-Regular',
                                fontSize: 12,
                                color: MoldifyColors.MoldifyBlack,
                              ),
                            ),
                          ),
                        ),
                      ),

                      /// New Password Label
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          AppLocalizations.of(context)!.newPassword,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Bricolage-Grotesque-SemiBold',
                            color: MoldifyColors.primaryColor,
                          ),
                        ),
                      ),

                      /// New Password TextBox
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: BuildTextBox(
                          hintText: AppLocalizations.of(context)!.enterNewPassword,
                          controller: newPasswordController,
                          showPassword: true,
                        ),
                      ),

                      /// Confirm New Password Label
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text(
                          AppLocalizations.of(context)!.confirmNewPassword,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Bricolage-Grotesque-SemiBold',
                            color: MoldifyColors.primaryColor,
                          ),
                        ),
                      ),

                      /// Confirm Password TextBox
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: BuildTextBox(
                          hintText: AppLocalizations.of(context)!.enterConfirmNewPassword,
                          controller: confirmNewPasswordController,
                          showPassword: true,
                        ),
                      ),

                      /// Save Changes Button
                      Padding(
                        padding: const EdgeInsets.only(top: 160.0),
                        child: BuildButton(
                          // UX Improvement: Show loading text and disable button
                            buttonText: _isLoading ? AppLocalizations.of(context)!.saving : AppLocalizations.of(context)!.saveChanges,
                            onPressed:  _changePassword,
                            backgroundColor: MoldifyColors.primaryColor,
                            textColor: MoldifyColors.backgroundColor,
                            buttonHeight: 45,
                            buttonWidth: MediaQuery.of(context).size.width,
                            buttonRadius: 10
                        ),
                      ),
                    ],
                  ),
                )
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(MoldifyColors.backgroundColor),
                  ),
                ),
              ),
          ],
        )
    );
  }
}