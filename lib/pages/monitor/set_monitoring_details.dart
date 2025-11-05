import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/core/features/mold_case/models/mold_case.dart';
import 'package:moldify/core/features/mold_case/repository/mold_case_repository.dart';
import 'package:moldify/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../misc/appbar/primary_app_bar.dart';
import '../misc/buttons/primary_button.dart';
import '../misc/functions/reminder_Interval_picker.dart';
import '../misc/overlays/modals/confirmation_dialog.dart';
import '../misc/textboxes/dropdwon.dart';
import '../misc/textboxes/textboxes.dart';

class SetMonitoringDetailsScreen extends StatefulWidget {
  final MoldCase moldCase;

  SetMonitoringDetailsScreen({required this.moldCase, super.key});

  @override
  _SetMonitoringDetailsScreenState createState() =>
      _SetMonitoringDetailsScreenState();
}

class _SetMonitoringDetailsScreenState
    extends State<SetMonitoringDetailsScreen> {
    final TextEditingController _startDateController = TextEditingController();
    final TextEditingController _endDateController = TextEditingController();
    final TextEditingController _incubationTempController = TextEditingController();
    final TextEditingController _environmentalTempController = TextEditingController();
    
    final MoldCaseRepository _repository = MoldCaseRepository();
    
    String? _selectedGrowthMedium;
    bool _isLoading = false;

    @override
    void initState() {
      super.initState();
      _initializeFields();
    }
    
    void _initializeFields() {
      // Initialize with existing data if available
      final details = widget.moldCase.cultivationDetails;
      
      _startDateController.text = DateFormat('MMMM dd, yyyy').format(widget.moldCase.startDate);
      
      if (widget.moldCase.endDate != null) {
        _endDateController.text = DateFormat('MMMM dd, yyyy').format(widget.moldCase.endDate!);
      }
      
      if (details != null) {
        _selectedGrowthMedium = details.growthMedium;
        
        if (details.inVitroDetails != null) {
          _incubationTempController.text = details.inVitroDetails!.incubationTemperature.toString();
        }
        
        if (details.inVivoDetails != null) {
          _environmentalTempController.text = details.inVivoDetails!.environmentalTemperature.toString();
        }
      }
    }
    
    Future<void> _updateMoldCase() async {
      try {
        setState(() => _isLoading = true);
        
        // Parse temperatures
        final incubationTemp = _incubationTempController.text.isNotEmpty 
            ? double.tryParse(_incubationTempController.text) ?? 0
            : 0;
        final environmentalTemp = _environmentalTempController.text.isNotEmpty
            ? double.tryParse(_environmentalTempController.text) ?? 0
            : 0;
        
        print('SetMonitoringDetails: updating case ${widget.moldCase.id}');
        print('SetMonitoringDetails: growthMedium=$_selectedGrowthMedium, incubationTemp=$incubationTemp, environmentalTemp=$environmentalTemp');
        
        // Build cultivation details
        final cultivationDetails = CultivationDetails(
          growthMedium: _selectedGrowthMedium ?? '',
          inVitroDetails: InVitroDetails(incubationTemperature: incubationTemp),
          inVivoDetails: InVivoDetails(environmentalTemperature: environmentalTemp),
        );
        
        // Build ONLY the cultivation details payload (PATCH request - backend expects key 'details')
        final updatePayload = {
          'details': cultivationDetails.toJson(),
        };
        
        print('SetMonitoringDetails: updatePayload=$updatePayload');
        
        final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
        final sessionCookie = authProvider.cookie;
        
        // Update via repository - use PATCH /:id endpoint
        print('SetMonitoringDetails: calling repository.updateMoldCase()');
        await _repository.updateMoldCase(
          widget.moldCase.id,
          updatePayload,
          sessionCookie: sessionCookie,
        );
        
        print('SetMonitoringDetails: case updated successfully');
        
        if (!mounted) return;
        setState(() => _isLoading = false);
        
        // Show success and pop
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Monitoring details updated successfully')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        
        print('Error updating mold case: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _incubationTempController.dispose();
    _environmentalTempController.dispose();
    super.dispose();
  }

  /// 1. Function to show the date picker
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
        _startDateController.text = DateFormat('MMMM dd, yyyy').format(picked);
      });
    }
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
                  /// ----------- Edit Monitoring Details Header -----------
                  Text('Set Monitoring Details',
                      style: TextStyle(
                        fontSize: 36,
                        fontFamily: 'Montserrat-Black',
                        color: MoldifyColors.primaryColor,
                      )),
                  Text('Adjust the schedule and setup for your mold case.',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        color: MoldifyColors.MoldifyBlack,
                      )),

                  /// ----------- End of Monitoring Details Header -----------

                  /// Start Date Label
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0, bottom: 8.0),
                    child: const Text(
                      'Start Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Bricolage-Grotesque-SemiBold',
                        color: MoldifyColors.primaryColor,
                      ),
                    ),
                  ),
                  /// Start Date Textbox
                  BuildTextBox(
                    hintText: 'Enter start date',
                    controller: _startDateController,
                    showPassword: false,
                    rightIcon: FontAwesomeIcons.solidCalendar,
                    rightIconColor: MoldifyColors.accentColor,
                    // 2. Make the text box read-only and trigger the date picker on tap
                    readOnly: true,
                    onTap: () {
                      _selectDate(context);
                    },
                  ),

                  /// End Date Label
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
                    child: const Text(
                      'End Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Bricolage-Grotesque-SemiBold',
                        color: MoldifyColors.primaryColor,
                      ),
                    ),
                  ),
                  /// End Date Textbox.
                  /// This will be uneditable as this has been set by the administrator.
                  /// It is only here for mycologist's reference when setting the start date.
                  BuildTextBox(
                    hintText: 'Enter end date',
                    controller: _endDateController,
                    showPassword: false,
                    rightIcon: FontAwesomeIcons.solidCalendar,
                    rightIconColor: MoldifyColors.accentColor,
                    readOnly: true,
                  ),

                  /// Reminder Interval Label
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
                    child: const Text(
                      'Reminder Interval',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Bricolage-Grotesque-SemiBold',
                        color: MoldifyColors.primaryColor,
                      ),
                    ),
                  ),
                  /// Reminder Interval Picker
                  ReminderIntervalPicker(
                    initialNumber: 4,
                    initialUnit: 'days',
                    maxNumber: 60,
                    onChanged: (value) {
                      final (num, unit) = value;
                      print('Selected: Every $num $unit');
                    },
                  ),

                  /// Growth Medium Label
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
                    child: const Text(
                      'Growth Medium',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Bricolage-Grotesque-SemiBold',
                        color: MoldifyColors.primaryColor,
                      ),
                    ),
                  ),
                  /// Growth Medium Dropdown
                  BuildDropdown(
                    hintText: 'Select growth medium',
                    items: [
                      'PDA (Potato Dextrose Agar)',
                      'MEA (Malt Extract Agar)',
                      'CYA (Czapek Yeast Extract Agar)',
                      'SDA (Sabouraud Dextrose Agar)',
                      'Other',
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGrowthMedium = value;
                      });
                    },
                  ),

                  /// Incubation Temperature Label
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
                    child: const Text(
                      'Incubation Temperature (°C)',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Bricolage-Grotesque-SemiBold',
                        color: MoldifyColors.primaryColor,
                      ),
                    ),
                  ),
                  /// Incubation Temperature TextBox.
                  BuildTextBox(
                    hintText: 'Enter incubation temperature',
                    controller: _incubationTempController,
                    showPassword: false,
                  ),

                  /// Environmental Temperature Label
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
                    child: const Text(
                      'Environmental Temperature (°C)',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Bricolage-Grotesque-SemiBold',
                        color: MoldifyColors.primaryColor,
                      ),
                    ),
                  ),
                  /// Incubation Temperature TextBox.
                  BuildTextBox(
                    hintText: 'Enter environmental temperature',
                    controller: _environmentalTempController,
                    showPassword: false,
                  ),

                  /// Save Button
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: BuildButton(
                        onPressed: () {
                          if (_isLoading) return;
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return BuildConfirmationDialog(
                                title: 'Apply Monitoring Setup?',
                                subtitle: 'Are you sure you want to apply these monitoring details?',
                                onConfirm: () {
                                  Navigator.of(context).pop();
                                  _updateMoldCase();
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
                        buttonText: _isLoading ? 'Saving...' : 'Save Changes',
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

