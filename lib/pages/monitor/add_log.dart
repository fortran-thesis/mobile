import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/textboxes/textboxes.dart';

import '../misc/appbar/primary_app_bar.dart';
import '../misc/buttons/primary_button.dart';
import '../misc/colors.dart';
import '../misc/images/cover_image.dart';
import '../misc/overlays/modals/confirmation_dialog.dart';

class AddLogScreen extends StatefulWidget {
  // 1. Add parameters for imagePath and the new sourceTab
  final String imagePath;
  final String sourceTab;

  // 2. Update the constructor to require them
  const AddLogScreen({
    super.key,
    required this.imagePath,
    required this.sourceTab,
  });

  @override
  State<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends State<AddLogScreen> {
  final TextEditingController _logNotesController = TextEditingController();

  @override
  void dispose() {
    _logNotesController.dispose();
    super.dispose();
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
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return BuildConfirmationDialog(
                                      title: 'Save Log?',
                                      subtitle: 'Are you sure you want to save log?',
                                      onConfirm: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                      onCancel: (){
                                        Navigator.of(context).pop();
                                      },
                                    );
                                  },
                                );
                              },
                              buttonText: 'Save Log',
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