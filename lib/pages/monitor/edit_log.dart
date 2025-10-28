import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:moldify/pages/misc/colors.dart';
import '../misc/appbar/primary_app_bar.dart';
import '../misc/buttons/primary_button.dart';
import '../misc/functions/reminder_Interval_picker.dart';
import '../misc/overlays/modals/confirmation_dialog.dart';
import '../misc/textboxes/dropdwon.dart';
import '../misc/textboxes/textboxes.dart';

class EditLogScreen extends StatefulWidget {
  final String tabName;
  EditLogScreen({super.key, required this.tabName});

  @override
  _EditLogScreenState createState() =>
      _EditLogScreenState();
}

class _EditLogScreenState extends State<EditLogScreen> {
  final TextEditingController _diameterController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  late final String diameterLabel;
  late final String diameterHintText;
  late final String colorLabel;
  late final String colorHintText;

  @override
  void initState() {
    super.initState();
    if(widget.tabName == 'In Vivo'){
      diameterLabel = 'Lesion Size (mm)';
      diameterHintText = 'Enter lesion size in mm';
      colorLabel = 'Lesion Color';
      colorHintText = 'Enter lesion color';
    } else if(widget.tabName == 'In Vitro'){
      diameterLabel = 'Colony Diameter (mm)';
      diameterHintText = 'Enter colony diameter in mm';
      colorLabel = 'Colony Color';
      colorHintText = 'Enter colony color';
    } else {
      diameterLabel = widget.tabName;
      diameterHintText = 'Enter $diameterLabel';
      colorLabel = 'Color';
      colorHintText = 'Enter $colorLabel';
    }
  }

  @override
  void dispose() {
    _diameterController.dispose();
    _colorController.dispose();
    _notesController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MoldifyColors.backgroundColor,
        appBar: PrimaryAppBar(
          title: 'Set Monitoring Details',
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ----------- Edit Log Header -----------
                  Text(
                      'Edit Log',
                      style: TextStyle(
                        fontSize: 36,
                        fontFamily: 'Montserrat-Black',
                        color: MoldifyColors.primaryColor,
                      )),
                  Text(
                      'Edit the fields below to update the monitoring log.',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        color: MoldifyColors.MoldifyBlack,
                      )),

                  /// ----------- End of Edit Log Header -----------

                  /// Diameter Label
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0, bottom: 8.0),
                    child:  Text(
                      diameterLabel,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Bricolage-Grotesque-SemiBold',
                        color: MoldifyColors.primaryColor,
                      ),
                    ),
                  ),
                  /// Diameter Textbox
                  BuildTextBox(
                    hintText: diameterHintText,
                    controller: _diameterController,
                    showPassword: false,
                  ),

                  /// Color Label
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
                    child: Text(
                      colorLabel,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Bricolage-Grotesque-SemiBold',
                        color: MoldifyColors.primaryColor,
                      ),
                    ),
                  ),

                  /// Color Textbox.
                  BuildTextBox(
                    hintText: colorHintText,
                    controller: _colorController,
                    showPassword: false,
                  ),

                  /// Additional Notes Label
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
                    controller: _notesController,
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
                                title: 'Apply Changes?',
                                subtitle: 'Are you sure you want to save these changes?',
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
                        buttonText: 'Save Changes',
                        backgroundColor: MoldifyColors.primaryColor,
                        textColor: MoldifyColors.backgroundColor,
                        buttonHeight: 45,
                        buttonWidth: MediaQuery.of(context).size.width,
                        buttonRadius: 10
                    ),
                  )
                ],
              )
          ),
        )
    );
  }
}

