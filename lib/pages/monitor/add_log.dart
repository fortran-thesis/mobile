import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/textboxes/textboxes.dart';
import 'package:provider/provider.dart';
import 'package:moldify/core/features/mold_case/service/mold_case_service.dart';
import 'package:moldify/providers/auth_provider.dart';

import '../misc/appbar/primary_app_bar.dart';
import '../misc/buttons/primary_button.dart';
import '../misc/colors.dart';
import '../misc/images/cover_image.dart';
import '../misc/overlays/modals/confirmation_dialog.dart';

class AddLogScreen extends StatefulWidget {
  // 1. Add parameters for imagePath and the new sourceTab
  final String imagePath;
  final String sourceTab;
  final String caseId; // Add caseId for API call

  // 2. Update the constructor to require them
  const AddLogScreen({
    super.key,
    required this.imagePath,
    required this.sourceTab,
    required this.caseId,
  });

  @override
  State<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends State<AddLogScreen> {
  final TextEditingController _logNotesController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _logNotesController.dispose();
    super.dispose();
  }

  Future<void> _saveCultivationLog() async {
    try {
      setState(() => _isSaving = true);

      final service = MoldCaseService();
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;

      // Build log data based on sourceTab
      final logData = {
        'type': widget.sourceTab == 'in-vivo' ? 'vivo' : 'vitro',
        'characteristics': widget.sourceTab == 'in-vivo'
            ? {'lesion_size': 0, 'lesion_color': 'Unknown'}
            : {'colony_diameter': 0, 'colony_color': 'Unknown'},
        'additional_info': _logNotesController.text,
      };

      // Call service to add cultivation log with image file
      await service.addCultivationLog(
        widget.caseId,
        logData,
        imagePath: widget.imagePath,
        sessionCookie: sessionCookie,
      );

      if (!mounted) return;
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cultivation log saved successfully!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save log: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String dateTime = 'October 2, 2025 • 09:14 PM';
    String size = '4mm';
    String color = 'Black';
    String labelSize;
    String labelColor;

    // 3. Set the labels based on the sourceTab from the widget
    if (widget.sourceTab == 'in-vivo') {
      labelSize = "Lesion Size";
      labelColor = "Lesion Color";
    } else {
      labelSize = "Colony Diameter";
      labelColor = "Colony Color";
    }


    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(
        title: 'Add New Log',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: Stack(
            children: [
              /// 1. Image captured by the user
              Image.file(
                File(widget.imagePath),
                height: MediaQuery.of(context).size.height * 0.4,
                width: double.infinity,
                fit: BoxFit.cover,
              ),

              /// 2. Size, Color, and Notes Container
              Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.35),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: MoldifyColors.backgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateTime,
                          style: TextStyle(
                            fontFamily: 'Bricolage-Grotesque-Regular',
                            fontSize: 10,
                            color: MoldifyColors.MoldifyGrey,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),

                                /// Size Label
                                Text(
                                  labelSize,
                                  style: TextStyle(
                                    fontFamily: 'Bricolage-Grotesque-Regular',
                                    fontSize: 12,
                                    color: MoldifyColors.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                /// Size Value
                                Text(
                                  size,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat-Black',
                                    fontSize: 16,
                                    color: MoldifyColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),

                                /// Color Label
                                Text(
                                  labelColor,
                                  style: TextStyle(
                                    fontFamily: 'Bricolage-Grotesque-Regular',
                                    fontSize: 12,
                                    color: MoldifyColors.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                /// Color Value
                                Text(
                                  color,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat-Black',
                                    fontSize: 16,
                                    color: MoldifyColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        /// Additional Notes Label
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
                          child: const Text(
                            'Additional Notes:',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Bricolage-Grotesque-SemiBold',
                              color: MoldifyColors.primaryColor,
                            ),
                          ),
                        ),
                        /// Additional Notes TextBox
                        BuildTextBox(
                            hintText: 'Enter additional details about the log here...',
                            controller: _logNotesController,
                            isMultiline: true,
                            showPassword: false
                        ),

                        /// Save Log Button
                        Padding(
                          padding: const EdgeInsets.only(top: 70.0),
                          child: BuildButton(
                              onPressed: _isSaving ? () {} : () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return BuildConfirmationDialog(
                                      title: 'Save Log?',
                                      subtitle: 'Are you sure you want to save log?',
                                      onConfirm: () {
                                        Navigator.of(context).pop();
                                        _saveCultivationLog();
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
                              buttonText: _isSaving ? 'Saving...' : 'Save Log',
                              backgroundColor: MoldifyColors.primaryColor,
                              textColor: MoldifyColors.backgroundColor,
                              buttonHeight: 45,
                              buttonWidth: MediaQuery.of(context).size.width,
                              buttonRadius: 10
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}