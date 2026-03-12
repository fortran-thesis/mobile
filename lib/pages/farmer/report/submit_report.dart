import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:moldify/l10n/app_localizations.dart';
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
import '../../misc/overlays/modals/chip_selection_modal.dart';
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
  final TextEditingController _addressController = TextEditingController();

  /// Predefined crop options for the chip selection modal
  final List<String> _cropOptions = [
    'Tomato',
    'Potato',
    'Garlic',
    'Onion',
    'Cabbage',
    'Carrot',
    'Lettuce',
    'Eggplant',
    'Bell Pepper',
    'Cucumber',
  ];

  /// Predefined mold problem descriptions for the chip selection modal
  /// Using farmer-friendly, non-scientific terms
  final List<String> _problemDescriptionOptions = [
    'May white cotton-like na tumutubo sa dahon',
    'May itim na mantsa sa bunga',
    'May kulay abo/gray na bubog sa dahon o bunga',
    'Nangingitim at nangingisay ang dahon',
    'May kulay brown/kayumanggi na mantsa sa dahon',
    'Nabulok ang bunga at may mabahong amoy',
    'May white powder na parang talcum sa dahon',
    'May orange o yellow na mantsa sa dahon',
    'Tumutuyo at nanlalanta ang halaman',
    'May kulay brown na guhit sa tangkay',
  ];

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
        _addressController.text.isNotEmpty ||
        uploadedPhotos.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didpop, dynamic result) async {
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
                title: l10n.goBackTitle,
                subtitle: l10n.goBackSubtitle,
                onConfirm: () {
                  Navigator.of(context).pop(true); //Return true to allow pop
                },
                onCancel: () {
                  Navigator.of(
                    context,
                  ).pop(false); //Return false to prevent pop
                },
                cancelText: l10n.no,
                confirmText: l10n.yes,
              );
            },
          );

          if (!context.mounted) return;
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
        appBar: PrimaryAppBar(title: l10n.submitReport),
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
                Builder(builder: (_) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                Text(
                  l10n.submitReport,
                  style: TextStyle(
                    fontSize: 36,
                    fontFamily: 'Montserrat-Black',
                    color: MoldifyColors.primaryColor,
                  ),
                ),
                Text(
                  l10n.submitReportSubtitle,
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
                  child: Text(
                    l10n.caseName,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Bricolage-Grotesque-SemiBold',
                      color: MoldifyColors.primaryColor,
                    ),
                  ),
                ),

                /// Case Name Textbox
                BuildTextBox(
                  hintText: l10n.enterCaseName,
                  controller: _caseNameController,
                  showPassword: false,
                ),

                /// Crop Name Label
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
                  child: Text(
                    l10n.cropName,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Bricolage-Grotesque-SemiBold',
                      color: MoldifyColors.primaryColor,
                    ),
                  ),
                ),

                /// Crop Name Textbox - Opens chip selection modal on tap
                BuildTextBox(
                  hintText: l10n.enterCropName,
                  controller: _cropNameController,
                  showPassword: false,
                  readOnly: true,
                  onTap: () async {
                    final selectedCrop = await showChipSelectionModal(
                      context: context,
                      title: l10n.selectCropName,
                      options: _cropOptions,
                      currentSelection: _cropNameController.text,
                      customInputHint: l10n.customCropInputHint,
                      othersLabel: l10n.othersLabel,
                      isMultiLine: false,
                    );

                    if (selectedCrop != null && selectedCrop.isNotEmpty) {
                      setState(() {
                        _cropNameController.text = selectedCrop;
                      });
                    }
                  },
                ),

                /// Location Label
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: AutoSizeText(
                    l10n.location,
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
                    hintText: l10n.enterLocation,
                    controller: _addressController,
                    showPassword: false,
                  ),
                ),

                /// Date First Observed Label
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
                  child: Text(
                    l10n.dateFirstObserved,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Bricolage-Grotesque-SemiBold',
                      color: MoldifyColors.primaryColor,
                    ),
                  ),
                ),

                /// Date First Observed Textbox
                BuildTextBox(
                  hintText: l10n.enterDateFirstObserved,
                  controller: _dateFirstObservedController,
                  showPassword: false,
                  rightIcon: FontAwesomeIcons.solidCalendar,
                  rightIconColor: MoldifyColors.accentColor,
                  readOnly: true,
                  onTap: () {
                    _selectDate(context);
                  },
                ),

                /// Upload Photo Label
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
                  child: Text(
                    l10n.uploadPhoto,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Bricolage-Grotesque-SemiBold',
                      color: MoldifyColors.primaryColor,
                    ),
                  ),
                ),

                /// Upload Photo Widget
                PhotoUploader(
                  photoOptionLabel: l10n.useCamera,
                  onPhotosChanged: _handlePhotoChange,
                ),

                /// Problem Description Label
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
                  child: Text(
                    l10n.problemDescription,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Bricolage-Grotesque-SemiBold',
                      color: MoldifyColors.primaryColor,
                    ),
                  ),
                ),

                /// Problem Description Textbox - Opens chip selection modal on tap
                BuildTextBox(
                  hintText: l10n.enterProblemDescription,
                  controller: _probDescController,
                  showPassword: false,
                  isMultiline: true,
                  readOnly: true,
                  onTap: () async {
                    final selectedProblem = await showChipSelectionModal(
                      context: context,
                      title: l10n.selectProblemDescription,
                      options: _problemDescriptionOptions,
                      currentSelection: _probDescController.text,
                      customInputHint: l10n.customProblemInputHint,
                      othersLabel: l10n.othersLabel,
                      isMultiLine: true,
                    );

                    if (selectedProblem != null && selectedProblem.isNotEmpty) {
                      setState(() {
                        _probDescController.text = selectedProblem;
                      });
                    }
                  },
                ),
                    ],
                  );
                }),

                /// Submit Report Button
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: BuildButton(
                    onPressed: () async {
                      if (_isSubmitting) return;

                      // Validate required fields
                      if (_caseNameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.caseNameRequired,
                              style: TextStyle(
                                fontFamily: 'Bricolage-Grotesque-Regular',
                                color: MoldifyColors.backgroundColor,
                              ),
                            ),
                            backgroundColor: MoldifyColors.primaryColor,
                          ),
                        );
                        return;
                      }

                      if (_cropNameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.cropNameRequired,
                              style: TextStyle(
                                fontFamily: 'Bricolage-Grotesque-Regular',
                                color: MoldifyColors.backgroundColor,
                              ),
                            ),
                            backgroundColor: MoldifyColors.primaryColor,
                          ),
                        );
                        return;
                      }

                      if (_addressController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.locationRequired,
                              style: TextStyle(
                                fontFamily: 'Bricolage-Grotesque-Regular',
                                color: MoldifyColors.backgroundColor,
                              ),
                            ),
                            backgroundColor: MoldifyColors.primaryColor,
                          ),
                        );
                        return;
                      }

                      if (_dateFirstObservedController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.dateFirstObservedRequired,
                              style: TextStyle(
                                fontFamily: 'Bricolage-Grotesque-Regular',
                                color: MoldifyColors.backgroundColor,
                              ),
                            ),
                            backgroundColor: MoldifyColors.primaryColor,
                          ),
                        );
                        return;
                      }

                      if (_probDescController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.problemDescriptionRequired,
                              style: TextStyle(
                                fontFamily: 'Bricolage-Grotesque-Regular',
                                color: MoldifyColors.backgroundColor,
                              ),
                            ),
                            backgroundColor: MoldifyColors.primaryColor,
                          ),
                        );
                        return;
                      }

                      final shouldSubmit = await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return BuildConfirmationDialog(
                            title: l10n.submitReportConfirmTitle,
                            subtitle: l10n.submitReportConfirmSubtitle,
                            onConfirm: () {
                              Navigator.of(context).pop(true);
                            },
                            onCancel: () {
                              Navigator.of(context).pop(false);
                            },
                            cancelText: l10n.no,
                            confirmText: l10n.yes,
                          );
                        },
                      );

                      if (shouldSubmit != true) return;
                      if (!context.mounted) return;

                      setState(() {
                        _isSubmitting = true;
                      });

                      // Show loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return PopScope(
                            canPop: false,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(20.0),
                                decoration: BoxDecoration(
                                  color: MoldifyColors.backgroundColor,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    CircularProgressIndicator(
                                      color: MoldifyColors.primaryColor,
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      'Submitting your report...',
                                      style: TextStyle(
                                        fontFamily: 'Bricolage-Grotesque-SemiBold',
                                        fontSize: 16,
                                        color: MoldifyColors.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );

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
                          'location': _addressController.text.trim(),
                        };

                        final File? cover = uploadedPhotos.isNotEmpty
                            ? uploadedPhotos.first
                            : null;

                        // If multiple photos are uploaded, pass them all; otherwise use legacy single photo
                        if (uploadedPhotos.length > 1) {
                          await service.createMoldReport(
                            reportPayload,
                            coverPhotos: uploadedPhotos,
                            sessionCookie: sessionCookie,
                          );
                        } else {
                          await service.createMoldReport(
                            reportPayload,
                            coverPhoto: cover,
                            sessionCookie: sessionCookie,
                          );
                        }

                        // Close loading dialog
                        if (!context.mounted) return;
                        Navigator.of(context).pop(); // Close loading dialog

                        // On success, show a confirmation snackbar and pop
                        if (!context.mounted) return;
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

                        // Close the submit screen after a short delay so the user can see the message
                        await Future.delayed(const Duration(milliseconds: 300));
                        if (!context.mounted) return;
                        Navigator.of(context).pop(true); // Signal success so caller can refresh
                      } catch (e) {
                        // Close loading dialog
                        if (!context.mounted) return;
                        Navigator.of(context).pop(); // Close loading dialog

                        // Show error
                        if (!context.mounted) return;
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
                    buttonText: l10n.submitReport,
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
