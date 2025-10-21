import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../misc/appbar/primary_app_bar.dart';
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
  final TextEditingController _dateFirstObservedController = TextEditingController();
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
                  )
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateFirstObservedController.text = DateFormat('MMMM dd, yyyy').format(picked);
      });
    }
  }

  List<File> uploadedPhotos = [];

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
                  Navigator.of(context).pop(false); //Return false to prevent pop
                },
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
          appBar: PrimaryAppBar(
            title: 'Set Monitoring Details',
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ----------- Submit Report Header -----------
                  Text('Submit Report',
                      style: TextStyle(
                        fontSize: 36,
                        fontFamily: 'Montserrat-Black',
                        color: MoldifyColors.primaryColor,
                      )),
                  Text('Fill out the details below to submit your mold report.',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        color: MoldifyColors.MoldifyBlack,
                      )),

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
                ],
              ),
            ),
          )
      ),
    );
  }
}