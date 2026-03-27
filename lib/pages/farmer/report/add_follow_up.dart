import 'dart:io';

import 'package:flutter/material.dart';
import 'package:moldify/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../misc/appbar/primary_app_bar.dart';
import '../../misc/buttons/primary_button.dart';
import '../../misc/colors.dart';
import '../../misc/overlays/modals/confirmation_dialog.dart';
import '../../misc/textboxes/textboxes.dart';
import '../../misc/tiles/photo_uploader.dart';
import '../../../core/features/mold_report/service/mold_report_services.dart';
import '../../../core/utils/mutation_result.dart';
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
    final l10n = AppLocalizations.of(context)!;
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
        final l10nLocal = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10nLocal.errorReportIdNotFound)),
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
        SnackBar(content: Text(l10n.followUpSubmitted)),
      );

      // Pop twice: once for AddFollowUpScreen, once for ViewReportScreen.
      // Pass a typed mutation result on the second pop so callers can detect refresh intent.
      Navigator.of(context).pop();
      Navigator.of(context).pop(
        const MutationResult.changed(tags: [MutationTags.moldReport]).toMap(),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.failedToSubmitFollowUp(e.toString()))),
      );
    }
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
                  Navigator.of(context).pop(false); //Return false to prevent pop
                },
                cancelText: l10n.no,
                confirmText: l10n.yes,
              );
            },
          );

          if (!context.mounted) return;
          //If the user confirmed, pop the current route
          if (shouldPop != null && shouldPop) {
            Navigator.of(context).pop(const MutationResult.unchanged().toMap());
          }
        } else {
          //No unsaved changes, allow pop without confirmation
          Navigator.of(context).pop(const MutationResult.unchanged().toMap());
        }
      },
      child: Scaffold(
          backgroundColor: MoldifyColors.backgroundColor,
          appBar: PrimaryAppBar(
            title: l10n.addFollowUpTitle,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ----------- Add Follow Up Header -----------
                  Text(l10n.addFollowUpTitle,
                      style: TextStyle(
                        fontSize: 36,
                        fontFamily: 'Montserrat-Black',
                        color: MoldifyColors.primaryColor,
                      )),
                  Text(l10n.addFollowUpSubtitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        color: MoldifyColors.MoldifyBlack,
                      )),

                  /// ----------- End of Add Follow Up Header -----------

                  /// Upload Photo Label
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
                    child: Text(
                      l10n.uploadPhotoLimit,
                      style: const TextStyle(
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
                      l10n.whatsStillHappening,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Bricolage-Grotesque-SemiBold',
                        color: MoldifyColors.primaryColor,
                      ),
                    ),
                  ),
                  /// Problem Description Textbox.
                  BuildTextBox(
                    hintText: l10n.enterFollowUpDescription,
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
                                title: l10n.confirmSubmitFollowUpTitle,
                                subtitle: l10n.confirmSubmitFollowUpSubtitle,
                                onConfirm: () {
                                  Navigator.of(context).pop();
                                  _submitFollowUp();
                                },
                                onCancel: (){
                                  Navigator.of(context).pop();
                                },
                                cancelText: l10n.no,
                                confirmText: l10n.yes,
                              );
                            },
                          );
                        },
                        buttonText: _isSubmitting ? l10n.submitting : l10n.submitFollowUp,
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