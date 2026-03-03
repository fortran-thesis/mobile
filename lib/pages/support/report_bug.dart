// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../core/constants/route_names.dart';
import '../../core/features/systemRequest/service/system_request_service.dart';
import '../../core/features/user/logic/user_bloc.dart';
import '../../core/utils/route_utils.dart';
import '../../providers/auth_provider.dart';
import '../misc/appbar/secondary_appbar.dart';
import '../misc/buttons/primary_button.dart';
import '../misc/colors.dart';
import '../misc/overlays/modals/confirmation_dialog.dart';
import '../misc/textboxes/textboxes.dart';
import 'package:moldify/core/utils/logger.dart';

class ReportBugScreen extends StatefulWidget {
  const ReportBugScreen({super.key});

  @override
  _ReportBugScreenState createState() => _ReportBugScreenState();
}

class _ReportBugScreenState extends State<ReportBugScreen> {
  final TextEditingController reportBugController = TextEditingController();
  final SystemRequestService _service = SystemRequestService();
  bool _isLoading = false;

  Future<void> _submitReport() async {

    if (_isLoading) {
      return;
    }

    if (reportBugController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the bug')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get session cookie
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;


      if (sessionCookie == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not authenticated')),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Get userId from UserBloc
      final userState = context.read<UserBloc>().state;

      String? userId;
      if (userState is UserProfileLoaded) {
        userId = userState.profile.id;
      } else {
      }

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not loaded yet')),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Call the service
      final response = await _service.submitRequest(
        sessionCookie: sessionCookie,
        type: 'bug',
        userId: userId,
        message: reportBugController.text.trim(),
      );

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bug report submitted successfully!'),
              backgroundColor: MoldifyColors.primaryColor,
            ),
          );
          reportBugController.clear();
          Navigator.pop(context);
        }
      } else {
        AppLogger.e('Failed. Error: ${response.error}');
        // Show the actual error from the API
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ?? 'Failed to submit report'),
              backgroundColor: MoldifyColors.MoldifyRed,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      // This catches actual exceptions (network errors, parsing errors, etc.)
      AppLogger.e('Exception caught', error: e);
      AppLogger.e('Stack trace', error: stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: ${e.toString()}'),
            backgroundColor: MoldifyColors.MoldifyRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: SecondaryAppBar(
        title: 'Report A Bug',
        color: MoldifyColors.primaryColor,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: SvgPicture.asset(
                    'assets/images/bug_phone_curve.svg',
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20.0),
                      const Text(
                        'SUBMIT BUG REPORT',
                        style: TextStyle(
                          fontSize: 32,
                          fontFamily: 'Montserrat-Black',
                          color: MoldifyColors.primaryColor,
                        ),
                      ),
                      const Text(
                        'Encountering app issues or errors? Report them now!',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Bricolage-Grotesque-Regular',
                          color: MoldifyColors.MoldifyBlack,
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      const Text(
                        'Describe what happened, and what you expected instead.',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Bricolage-Grotesque-SemiBold',
                          color: MoldifyColors.primaryColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: BuildTextBox(
                          hintText: 'Please add your report detail here',
                          controller: reportBugController,
                          showPassword: false,
                          isMultiline: true,
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text.rich(
                            TextSpan(
                              style: const TextStyle(
                                fontFamily: 'Bricolage-Grotesque-Regular',
                                fontSize: 12,
                                color: MoldifyColors.MoldifyBlack,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Submitting this form indicates your agreement to Moldify’s data processing as stated in our ',
                                ),
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
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 50.0),
                        child: BuildButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return BuildConfirmationDialog(
                                  title: 'Are you sure you want to submit your bug report?',
                                  subtitle: 'Once submitted, your bug report cannot be changed.',
                                  confirmText: 'Save',
                                  cancelText: 'Cancel',
                                  onCancel: () => Navigator.of(context).pop(),
                                  onConfirm: () {
                                    Navigator.of(context).pop();
                                    _submitReport();
                                  },
                                );
                              },
                            );
                          },
                          buttonText: 'Submit Report',
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
          if (_isLoading)
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.4),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: MoldifyColors.backgroundColor,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
