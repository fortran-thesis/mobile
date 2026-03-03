import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/textboxes/textboxes.dart';

import '../misc/appbar/primary_app_bar.dart';
import '../misc/buttons/primary_button.dart';
import '../misc/colors.dart';
import '../misc/overlays/modals/confirmation_dialog.dart';

class AddTreatmentScreen extends StatefulWidget {
  const AddTreatmentScreen({super.key});

  @override
  State<AddTreatmentScreen> createState() => _AddTreatmentScreenState();
}

class _AddTreatmentScreenState extends State<AddTreatmentScreen> {
  final TextEditingController _notesTreatController = TextEditingController();
  // 1. Use a list to hold controllers for each textbox
  final List<TextEditingController> _fungicideControllers = [];

  @override
  void initState() {
    super.initState();
    // 2. Add the initial textbox when the screen loads
    _addFungicideField();
  }

  @override
  void dispose() {
    // 3. Important: Dispose all controllers to free up resources
    for (final controller in _fungicideControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Function to add a new controller and update the UI
  void _addFungicideField() {
    setState(() {
      _fungicideControllers.add(TextEditingController());
    });
  }

  // Function to remove a controller and its textbox
  void _removeFungicideField(int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BuildConfirmationDialog(
          title: 'Delete Textbox?',
          subtitle: 'Are you sure you want to delete this textbox?',
          onConfirm: () {
            Navigator.of(context).pop(); // Close the dialog first
            setState(() {
              _fungicideControllers[index].dispose();
              _fungicideControllers.removeAt(index);
            });
          },
          onCancel: () {
            Navigator.of(context).pop(); // Just close the dialog
          },
          cancelText: 'No',
          confirmText: 'Yes',
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MoldifyColors.backgroundColor,
        appBar: PrimaryAppBar(
          title: 'Add Treatment',
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ----------- Add Treatment Header -----------
                  Text('Add Treatment',
                      style: TextStyle(
                        fontSize: 36,
                        fontFamily: 'Montserrat-Black',
                        color: MoldifyColors.primaryColor,
                      )),
                  Text('Add the details of the treatment below.',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        color: MoldifyColors.MoldifyBlack,
                      )),

                  /// ----------- End of Add Treatment Header -----------

                  /// Recommended Fungicides Label
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0, bottom: 8.0),
                    child: Text(
                      'Recommended Fungicides',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Bricolage-Grotesque-SemiBold',
                        color: MoldifyColors.primaryColor,
                      ),
                    ),
                  ),

                  // 4. Use a Column to dynamically build the list of textboxes
                  Column(
                    children: List.generate(_fungicideControllers.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: BuildTextBox(
                          hintText: 'Enter recommended fungicide',
                          controller: _fungicideControllers[index],
                          showPassword: false,
                          // 5. Pass the delete button to the suffixIcon property
                          suffixIcon: index > 0
                              ? IconButton(
                                  icon: Icon(
                                    FontAwesomeIcons.solidTrashCan,
                                    color: MoldifyColors.MoldifyRed,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      _removeFungicideField(index),
                                )
                              : null, // No icon for the first item
                        ),
                      );
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: _addFungicideField,
                        borderRadius: BorderRadius.circular(8),
                        splashColor:
                            MoldifyColors.primaryColor.withAlpha(50),
                        highlightColor:
                            MoldifyColors.primaryColor.withAlpha(50),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 6),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Icon(
                                    FontAwesomeIcons.plus,
                                    size: 12,
                                    color: MoldifyColors.primaryColor,
                                  ),
                                ),
                                TextSpan(
                                  text: "    Add Fungicide",
                                  style: TextStyle(
                                    color: MoldifyColors.primaryColor,
                                    fontSize: 10,
                                    fontFamily: 'Bricolage-Grotesque-SemiBold',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
                    child: const Text(
                      'Additional Notes',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Bricolage-Grotesque-SemiBold',
                        color: MoldifyColors.primaryColor,
                      ),
                    ),
                  ),
                  /// Additional Notes Textbox.
                  BuildTextBox(
                    hintText: 'Enter additional notes here',
                    controller: _notesTreatController,
                    showPassword: false,
                    isMultiline: true,
                  ),

                  /// Save Button
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: BuildButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return BuildConfirmationDialog(
                                title: 'Submit Treatment?',
                                subtitle: 'Are you sure you want to submit this treatment?',
                                onConfirm: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
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
                        buttonText: 'Submit Treatment',
                        backgroundColor: MoldifyColors.primaryColor,
                        textColor: MoldifyColors.backgroundColor,
                        buttonHeight: 45,
                        buttonWidth: MediaQuery.of(context).size.width,
                        buttonRadius: 10
                    ),
                  ),
                ],
              )
          ),
        )
    );
  }
}
