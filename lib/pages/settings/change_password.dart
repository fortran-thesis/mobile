import 'package:flutter/material.dart';
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

    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmNewPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar('Please fill in all fields');
      setState(() => _isLoading = false);
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar('New passwords do not match');
      setState(() => _isLoading = false);
      return;
    }

    // Validate password complexity (must match server PasswordSchema)
    if (newPassword.length < 8) {
      _showSnackBar('Password must be at least 8 characters long');
      setState(() => _isLoading = false);
      return;
    }
    if (!RegExp(r'[a-z]').hasMatch(newPassword)) {
      _showSnackBar('Password must contain at least one lowercase letter');
      setState(() => _isLoading = false);
      return;
    }
    if (!RegExp(r'[A-Z]').hasMatch(newPassword)) {
      _showSnackBar('Password must contain at least one uppercase letter');
      setState(() => _isLoading = false);
      return;
    }
    if (!RegExp(r'[0-9]').hasMatch(newPassword)) {
      _showSnackBar('Password must contain at least one number');
      setState(() => _isLoading = false);
      return;
    }
    if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(newPassword)) {
      _showSnackBar('Password must contain at least one special character');
      setState(() => _isLoading = false);
      return;
    }

    try {
      final authProvider = context.read<AppAuthProvider>();
      final sessionCookie = authProvider.cookie;

      if (sessionCookie == null || sessionCookie.isEmpty) {
        _showSnackBar('User not authenticated. Please log in again.');
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
        _showSnackBar(result['data'] ?? 'Password changed successfully');
        Navigator.pop(context);
      } else {
        _showSnackBar(result['error'] ?? 'Failed to change password');
      }
    } catch (e) {
      _showSnackBar('Something went wrong. Please try again.');
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
          title: 'Change Password',
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
                          'Change Password',
                          style: TextStyle(
                            fontSize: 36,
                            fontFamily: 'Montserrat-Black',
                            color: MoldifyColors.primaryColor,
                          )
                      ),
                      Text(
                          'Type a new password to update your account.',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Bricolage-Grotesque-Regular',
                            color: MoldifyColors.MoldifyBlack,
                          )
                      ),
                      /// ----------- End of Edit Profile Header -----------

                      const Padding(
                        padding: EdgeInsets.only(top: 40.0),
                        child: Text(
                          'Old Password',
                          style: TextStyle(
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
                          hintText: 'Enter Old Password',
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
                                builder: (context) => const EmailRecoverAccountScreen(pageTitle: 'Forgot Password',),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          // FIX: Use .withOpacity() instead of .withValues()
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

                      /// New Password Label
                      const Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(
                          'New Password',
                          style: TextStyle(
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
                          hintText: 'Enter New Password',
                          controller: newPasswordController,
                          showPassword: true,
                        ),
                      ),

                      /// Confirm New Password Label
                      const Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Text(
                          'Confirm New Password',
                          style: TextStyle(
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
                          hintText: 'Enter Confirm New Password',
                          controller: confirmNewPasswordController,
                          showPassword: true,
                        ),
                      ),

                      /// Save Changes Button
                      Padding(
                        padding: const EdgeInsets.only(top: 160.0),
                        child: BuildButton(
                          // UX Improvement: Show loading text and disable button
                            buttonText: _isLoading ? 'Saving...' : 'Save Changes',
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