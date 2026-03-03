import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../misc/appbar/primary_app_bar.dart';
import '../../misc/buttons/primary_button.dart';
import '../../misc/colors.dart';
import '../../misc/overlays/modals/confirmation_dialog.dart';
import '../../misc/textboxes/textboxes.dart';
import '../../misc/tiles/photo_uploader.dart';
import '../../../core/features/mold_report/service/mold_report_services.dart';
import '../../../providers/auth_provider.dart';

class AddFollowUpScreen extends StatefulWidget {
  const AddFollowUpScreen({super.key});

  @override
  State<AddFollowUpScreen> createState() => _AddFollowUpScreenState();
}

class _AddFollowUpScreenState extends State<AddFollowUpScreen> {
  final TextEditingController _descController = TextEditingController();
  List<File> uploadedPhotos = [];
  bool _isSubmitting = false;

  void _handlePhotoChange(List<File> photos) {
    setState(() {
      uploadedPhotos = photos;
    });
  }

  bool _hasUnsavedChanges() {
    return _descController.text.isNotEmpty ||
        uploadedPhotos.isNotEmpty;
  }

  Future<void> _submitFollowUp() async {
    try {
      setState(() => _isSubmitting = true);

      final args = ModalRoute.of(context)?.settings.arguments;
      String? reportId;
      if (args is Map<String, dynamic>) {
        reportId = args['id']?.toString();
      } else if (args is String) {
        reportId = args;
      }

      if (reportId == null || reportId.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Report ID not found')),
        );
        return;
      }

      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;

      final reportService = MoldReportService();

      // Prepare case detail data
      final detailData = {
        'description': _descController.text,
        'metadata': {
          'created_at': DateTime.now().toIso8601String(),
        },
        'cover_photo': uploadedPhotos.isNotEmpty
            ? uploadedPhotos.map((f) => f.path).toList()
            : [],
      };

      await reportService.addCaseDetailToReport(
        reportId,
        detailData,
        sessionCookie: sessionCookie,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Follow-up submitted successfully!')),
      );

      // Pop twice: once for AddFollowUpScreen, once for ViewReportScreen
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit follow-up: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                title: 'Are you sure you want to go back?',
                subtitle: 'Going back now will lose all your progress.',
                onConfirm: () {
                  Navigator.of(context).pop(true); //Return true to allow pop
                },
                onCancel: () {
                  Navigator.of(context).pop(false); //Return false to prevent pop
                },
                cancelText: 'No',
                confirmText: 'Yes',
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
          appBar: PrimaryAppBar(
            title: 'Add Follow Up',
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ----------- Add Follow Up Header -----------
                  Text('Add Follow Up',
                      style: TextStyle(
                        fontSize: 36,
                        fontFamily: 'Montserrat-Black',
                        color: MoldifyColors.primaryColor,
                      )),
                  Text('Provide additional details to help us assist you better.',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        color: MoldifyColors.MoldifyBlack,
                      )),

                  /// ----------- End of Add Follow Up Header -----------

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
                      'What’s Still Happening?',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Bricolage-Grotesque-SemiBold',
                        color: MoldifyColors.primaryColor,
                      ),
                    ),
                  ),
                  /// Problem Description Textbox.
                  BuildTextBox(
                    hintText: 'Enter description of the current problem...',
                    controller: _descController,
                    showPassword: false,
                    isMultiline: true,
                  ),

                  /// Submit Report Button
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: BuildButton(
                        onPressed: _isSubmitting ? () {} : () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return BuildConfirmationDialog(
                                title: 'Are you sure you want to submit this follow up?',
                                subtitle: 'Once submitted, you will not be able to edit it.',
                                onConfirm: () {
                                  Navigator.of(context).pop();
                                  _submitFollowUp();
                                },
                                onCancel: (){
                                  Navigator.of(context).pop();
                                },
                                cancelText: 'No',
                                confirmText: 'Yes',
                              );
                            },
                          );
                        },
                        buttonText: _isSubmitting ? 'Submitting...' : 'Submit Follow Up',
                        backgroundColor: MoldifyColors.primaryColor,
                        textColor: MoldifyColors.backgroundColor,
                        buttonHeight: 45,
                        buttonWidth: MediaQuery.of(context).size.width,
                        buttonRadius: 10
                    ),
                  )
                ],
              ),
            ),
          )
      ),
    );
  }
}