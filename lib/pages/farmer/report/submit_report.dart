import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/features/user/logic/user_bloc.dart';

import '../../../core/features/mold_report/service/mold_report_services.dart';
import '../../../core/features/user/services/user_services.dart';
import '../../../providers/auth_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../misc/appbar/primary_app_bar.dart';
import '../../misc/buttons/primary_button.dart';
import '../../misc/colors.dart';
import '../../misc/overlays/modals/confirmation_dialog.dart';
import '../../misc/textboxes/textboxes.dart';
import '../../misc/tiles/photo_uploader.dart';

class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({super.key});

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final TextEditingController _caseNameController = TextEditingController();
  final TextEditingController _cropNameController = TextEditingController();
  final TextEditingController _dateFirstObservedController =
      TextEditingController();
  final TextEditingController _probDescController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      errorFormatText: 'Enter valid date',
      errorInvalidText: 'Enter date in valid range',
      fieldHintText: 'Month/Day/Year',
      fieldLabelText: 'Date Deadline',
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: const TextTheme(
              titleSmall: TextStyle(
                fontFamily: 'Bricolage-Grotesque-Regular',
                fontSize: 16,
              ),
              headlineLarge: TextStyle(
                fontFamily: 'Montserrat-Black',
                fontSize: 32,
              ),
              labelLarge: TextStyle(
                fontFamily: 'Bricolage-Grotesque-Regular',
                fontSize: 16,
              ),
              bodyLarge: TextStyle(
                fontFamily: 'Bricolage-Grotesque-Regular',
                fontSize: 16,
              ),
            ),
            colorScheme: ColorScheme.light(
              primary: MoldifyColors.primaryColor,

              onPrimary: MoldifyColors.backgroundColor, // header text color
              onSurface: MoldifyColors.primaryColor, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: MoldifyColors.primaryColor,
                textStyle: TextStyle(
                  fontFamily: 'Bricolage-Grotesque-ExtraBold',
                  fontSize: 16,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateFirstObservedController.text = DateFormat(
          'MMMM dd, yyyy',
        ).format(picked);
      });
    }
  }

  List<File> uploadedPhotos = [];
  bool _isSubmitting = false;

  void _handlePhotoChange(List<File> photos) {
    setState(() {
      uploadedPhotos = photos;
    });
  }

  bool _hasUnsavedChanges() {
    return _caseNameController.text.isNotEmpty ||
        _cropNameController.text.isNotEmpty ||
        _dateFirstObservedController.text.isNotEmpty ||
        _probDescController.text.isNotEmpty ||
        uploadedPhotos.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didpop) async {
        if (didpop) {
          return;
        }

        // Show the dialog only if a radio button is selected
        if (_hasUnsavedChanges()) {
          final shouldPop = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return BuildConfirmationDialog(
                title: 'Are you sure you want to go back?',
                subtitle: 'Going back now will lose all your progress.',
                onConfirm: () {
                  Navigator.of(context).pop(true); //Return true to allow pop
                },
                onCancel: () {
                  Navigator.of(
                    context,
                  ).pop(false); //Return false to prevent pop
                },
                cancelText: 'No',
                confirmText: 'Yes',
              );
            },
          );

          //If the user confirmed, pop the current route
          if (shouldPop != null && shouldPop) {
            Navigator.of(context).pop(true);
          }
        } else {
          //No unsaved changes, allow pop without confirmation
          Navigator.of(context).pop(true);
        }
      },
      child: Scaffold(
        backgroundColor: MoldifyColors.backgroundColor,
        appBar: PrimaryAppBar(title: 'Submit Report'),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 30.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ----------- Submit Report Header -----------
                Text(
                  'Submit Report',
                  style: TextStyle(
                    fontSize: 36,
                    fontFamily: 'Montserrat-Black',
                    color: MoldifyColors.primaryColor,
                  ),
                ),
                Text(
                  'Fill out the details below to submit your mold report.',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    color: MoldifyColors.MoldifyBlack,
                  ),
                ),

                /// ----------- End of Submit Report Header -----------

                /// Case Name Label
                Padding(
                  padding: const EdgeInsets.only(top: 30.0, bottom: 8.0),
                  child: const Text(
                    'Case Name',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Bricolage-Grotesque-SemiBold',
                      color: MoldifyColors.primaryColor,
                    ),
                  ),
                ),

                /// Case Name Textbox
                BuildTextBox(
                  hintText: 'Enter case name',
                  controller: _caseNameController,
                  showPassword: false,
                ),

                /// Crop Name Label
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
                  child: const Text(
                    'Crop Name',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Bricolage-Grotesque-SemiBold',
                      color: MoldifyColors.primaryColor,
                    ),
                  ),
                ),

                /// Crop Name Textbox.
                BuildTextBox(
                  hintText: 'Enter crop name',
                  controller: _cropNameController,
                  showPassword: false,
                ),

                /// Date First Observed Label
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
                  child: const Text(
                    'Date First Observed',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Bricolage-Grotesque-SemiBold',
                      color: MoldifyColors.primaryColor,
                    ),
                  ),
                ),

                /// Date First Observed Textbox
                BuildTextBox(
                  hintText: 'Enter date first observed',
                  controller: _dateFirstObservedController,
                  showPassword: false,
                  rightIcon: FontAwesomeIcons.solidCalendar,
                  rightIconColor: MoldifyColors.accentColor,
                  // 2. Make the text box read-only and trigger the date picker on tap
                  readOnly: true,
                  onTap: () {
                    _selectDate(context);
                  },
                ),

                /// Upload Photo Label
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
                  child: const Text(
                    'Upload Photo (Up to 5 photos)',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Bricolage-Grotesque-SemiBold',
                      color: MoldifyColors.primaryColor,
                    ),
                  ),
                ),

                /// Upload Photo Widget
                PhotoUploader(
                  photoOptionLabel: "Use Camera",
                  onPhotosChanged: _handlePhotoChange,
                ),

                /// Problem Description Label
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
                  child: const Text(
                    'Problem Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Bricolage-Grotesque-SemiBold',
                      color: MoldifyColors.primaryColor,
                    ),
                  ),
                ),

                /// Problem Description Textbox.
                BuildTextBox(
                  hintText: 'Enter problem description',
                  controller: _probDescController,
                  showPassword: false,
                  isMultiline: true,
                ),

                /// Submit Report Button
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: BuildButton(
                    onPressed: () async {
                      if (_isSubmitting) return;
                      final shouldSubmit = await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return BuildConfirmationDialog(
                            title: 'Are you sure you want to submit this report?',
                            subtitle: 'Once submitted, you will not be able to edit the report details.',
                            onConfirm: () {
                              Navigator.of(context).pop(true);
                            },
                            onCancel: () {
                              Navigator.of(context).pop(false);
                            },
                            cancelText: 'No',
                            confirmText: 'Yes',
                          );
                        },
                      );

                      if (shouldSubmit != true) return;

                      setState(() {
                        _isSubmitting = true;
                      });

                      try {
                        final authProvider = Provider.of<AppAuthProvider>(
                          context,
                          listen: false,
                        );
                        final sessionCookie = authProvider.cookie;

                        final service = MoldReportService();

                        // Build the report payload. Adjust keys to match backend DTO (snake_case).
                        // Include the current user's id when available from UserBloc
                        String? currentUserId;
                        try {
                          final userState = BlocProvider.of<UserBloc>(context).state;
                          if (userState is UserProfileLoaded) {
                            currentUserId = userState.profile.id;
                          }
                        } catch (_) {
                          // no UserBloc in context; proceed to fallback below
                        }

                        // Fallback: if we still don't have a currentUserId, try
                        // fetching the profile using the session cookie via
                        // UserService. This helps when the widget tree doesn't
                        // provide a UserBloc but we still have an auth session.
                        if (currentUserId == null && sessionCookie != null) {
                          try {
                            final userService = UserService();
                            final profileResp = await userService.getUserProfile(sessionCookie);
                            if (profileResp['success'] == true && profileResp['data'] != null) {
                              final data = profileResp['data'];
                              // data shape may be a map with id or nested under data
                              if (data is Map && data['id'] != null) {
                                currentUserId = data['id'].toString();
                              } else if (data is Map && data['data'] is Map && data['data']['id'] != null) {
                                currentUserId = data['data']['id'].toString();
                              }
                            }
                          } catch (_) {
                            // ignore failures here; we'll submit without user_id
                          }
                        }

                        // convert the user-picked date (e.g. "October 30, 2025") to ISO8601
                        String? isoDateObserved;
                        final rawDate = _dateFirstObservedController.text.trim();
                        if (rawDate.isNotEmpty) {
                          try {
                            final parsed = DateFormat('MMMM dd, yyyy').parse(rawDate);
                            isoDateObserved = parsed.toUtc().toIso8601String();
                          } catch (_) {
                            // if parsing fails, fall back to sending the raw string
                            isoDateObserved = rawDate;
                          }
                        }

                        final Map<String, dynamic> reportPayload = {
                          if (currentUserId != null) 'user_id': currentUserId,
                          // backend expects snake_case keys
                          'case_name': _caseNameController.text.trim(),
                          'host': _cropNameController.text.trim(),
                          if (isoDateObserved != null) 'date_observed': isoDateObserved,
                          // include description as a top-level field (cover_photo is sent
                          // separately as the multipart file). We no longer wrap details
                          // under `case_details`.
                          'description': _probDescController.text.trim(),
                        };

                        final File? cover = uploadedPhotos.isNotEmpty
                            ? uploadedPhotos.first
                            : null;

                        await service.createMoldReport(
                          reportPayload,
                          coverPhoto: cover,
                          sessionCookie: sessionCookie,
                        );

                        // On success, show a confirmation snackbar and pop
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Your report has been submitted successfully.',
                              style: TextStyle(
                                  fontFamily: 'Bricolage-Grotesque-Regular',
                                  color: MoldifyColors.backgroundColor
                              ),
                            ),
                            backgroundColor: MoldifyColors.primaryColor,
                          ),
                        );

                        // Close the submit screen after a short delay so the user can see the dialog
                        await Future.delayed(const Duration(milliseconds: 300));
                        Navigator.of(context).pop();
                      } catch (e) {
                        // Show error
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Failed to submit report: $e',
                                style: TextStyle(
                                fontFamily: 'Bricolage-Grotesque-Regular',
                                color: MoldifyColors.backgroundColor
                            ),
                          ),
                          backgroundColor: MoldifyColors.primaryColor,
                        ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isSubmitting = false;
                          });
                        }
                      }
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
        ),
      ),
    );
  }
}
