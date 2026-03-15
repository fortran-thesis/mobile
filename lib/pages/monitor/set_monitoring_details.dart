// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/core/features/mold_case/models/mold_case.dart';
import 'package:moldify/core/features/mold_case/service/mold_case_service.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/pages/misc/functions/scrollable_tab_bar.dart';
import 'package:moldify/pages/misc/functions/step_indicator.dart';
import 'package:moldify/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'set_monitor_details_tab/evidence_tab.dart';
import 'set_monitor_details_tab/schedule_tab.dart';
import 'set_monitor_details_tab/specimen_tab.dart';
import '../misc/appbar/primary_app_bar.dart';
import '../misc/overlays/modals/chip_selection_modal.dart';
import '../misc/overlays/modals/confirmation_dialog.dart';
import 'package:moldify/core/utils/logger.dart';

class SetMonitoringDetailsScreen extends StatefulWidget {
  final MoldCase moldCase;

  const SetMonitoringDetailsScreen({required this.moldCase, super.key});

  @override
  _SetMonitoringDetailsScreenState createState() =>
      _SetMonitoringDetailsScreenState();
}

class _SetMonitoringDetailsScreenState
    extends State<SetMonitoringDetailsScreen> {
    final TextEditingController _startDateController = TextEditingController();
    final TextEditingController _endDateController = TextEditingController();
    final TextEditingController _cropNameController = TextEditingController();
    final TextEditingController _dateOfObservationController = TextEditingController();
    final TextEditingController _locationController = TextEditingController();
    final TextEditingController _initialSymptomsController = TextEditingController();
    final TextEditingController _initialCharacteristicsController = TextEditingController();
    final TextEditingController _initialMicroscopicController = TextEditingController();
    final TextEditingController _initialMacroscopicController = TextEditingController();
    final TextEditingController _initialMicroscopicColorController = TextEditingController();
    final TextEditingController _initialMicroscopicTextureController = TextEditingController();
    final TextEditingController _initialMacroscopicColorController = TextEditingController();
    final TextEditingController _initialMacroscopicTextureController = TextEditingController();
    final TextEditingController _initialMacroscopicSymptomsController = TextEditingController();
    final TextEditingController _initialMacroscopicCharacteristicsController = TextEditingController();
    final TextEditingController _incubationTempController = TextEditingController();
    final TextEditingController _environmentalTempController = TextEditingController();
    final TextEditingController _specimenTypeController = TextEditingController();
    final TextEditingController _specimenQuantityController = TextEditingController();

    final List<Map<String, String>> _specimenEntries = [];
  final List<String> _selectedSpecimenTypes = [];
  final List<String> _selectedInitialSymptoms = [];
  final List<String> _selectedInitialCharacteristics = [];

    final List<String> _specimenTypeOptions = [
      'Leaf',
      'Stem',
      'Root',
      'Fruit',
      'Flower',
      'Whole plant',
      'Soil sample',
      'Water sample',
    ];

    final List<String> _initialSymptomsOptions = [
      'Leaf spots',
      'Wilting',
      'Yellowing leaves',
      'Powdery growth',
      'Soft rot',
      'Stem lesions',
    ];

    final List<String> _initialCharacteristicsOptions = [
      'Cottony',
      'Powdery',
      'Slimy',
      'Fuzzy',
      'Discolored',
      'Spreading rapidly',
    ];

    final MoldCaseService _service = MoldCaseService();
    
    String? _selectedGrowthMedium;
    String? _initialMicroscopicImagePath;
    String? _initialMacroscopicImagePath;
    bool _isLoading = false;
    int _selectedTab = 0;
    final List<String> _tabTitles = const ['Schedule', 'Specimen', 'Evidence'];

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
        
        AppLogger.d('SetMonitoringDetails: updating case ${widget.moldCase.id}');
        AppLogger.d('SetMonitoringDetails: growthMedium=$_selectedGrowthMedium, incubationTemp=$incubationTemp, environmentalTemp=$environmentalTemp');
        
        // Build cultivation details
        final cultivationDetails = CultivationDetails(
          growthMedium: _selectedGrowthMedium ?? '',
          inVitroDetails: InVitroDetails(incubationTemperature: incubationTemp),
          inVivoDetails: InVivoDetails(environmentalTemperature: environmentalTemp),
        );

        final specimenTypes = _specimenEntries
            .map((entry) => entry['type'] ?? '')
            .where((value) => value.isNotEmpty)
            .toList();
        final specimenQuantities = _specimenEntries
            .map((entry) => entry['quantity'] ?? '')
            .where((value) => value.isNotEmpty)
            .toList();

        // Backend parameter mapping under `cultivation_details`:
        // specimen_types/specimen_quantities: structured array values from UI pairs
        // specimen_types_csv/specimen_quantities_csv: comma-separated mirror values
        // initial_symptoms/initial_characteristics: multi-select arrays from chips
        // initial_*_csv: comma-separated values for easier fallback parsing
        // initial_microscopic/initial_macroscopic: capture source placeholders/values
        // location_gathered/date_observation: monitoring context fields
        final cultivationDetailsMap = cultivationDetails.toJson();
        if (specimenTypes.isNotEmpty) {
          cultivationDetailsMap['specimen_types'] = specimenTypes;
          cultivationDetailsMap['specimen_quantities'] = specimenQuantities;
          cultivationDetailsMap['specimen_types_csv'] = specimenTypes.join(',');
          cultivationDetailsMap['specimen_quantities_csv'] =
              specimenQuantities.join(',');
        }
        if (_selectedInitialSymptoms.isNotEmpty) {
          cultivationDetailsMap['initial_symptoms'] = _selectedInitialSymptoms;

          ///Passes comman-separated symptoms for easier backend parsing as a fallback if array parsing fails
          cultivationDetailsMap['initial_symptoms_csv'] =
              _selectedInitialSymptoms.join(',');
        }
        if (_selectedInitialCharacteristics.isNotEmpty) {
          cultivationDetailsMap['initial_characteristics'] =
              _selectedInitialCharacteristics;

          ///Passes comman-separated symptoms for easier backend parsing as a fallback if array parsing fails
          cultivationDetailsMap['initial_characteristics_csv'] =
              _selectedInitialCharacteristics.join(',');
        }
        if (_initialMicroscopicController.text.trim().isNotEmpty) {
          cultivationDetailsMap['initial_microscopic'] =
              _initialMicroscopicController.text.trim();
        }
        if (_initialMacroscopicController.text.trim().isNotEmpty) {
          cultivationDetailsMap['initial_macroscopic'] =
              _initialMacroscopicController.text.trim();
        }
        if (_locationController.text.trim().isNotEmpty) {
          cultivationDetailsMap['location_gathered'] =
              _locationController.text.trim();
        }
        if (_dateOfObservationController.text.trim().isNotEmpty) {
          cultivationDetailsMap['date_observation'] =
              _dateOfObservationController.text.trim();
        }
        
        // Build payload for service
        final updatePayload = {
          'cultivation_details': cultivationDetailsMap,
        };
        
        AppLogger.d('SetMonitoringDetails: updatePayload=$updatePayload');
        
        final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
        final sessionCookie = authProvider.cookie;
        
        // Update via service - use updateCultivationDetails endpoint
        AppLogger.d('SetMonitoringDetails: calling service.updateCultivationDetails()');
        await _service.updateCultivationDetails(
          widget.moldCase.id,
          updatePayload,
          sessionCookie: sessionCookie,
        );
        
        AppLogger.d('SetMonitoringDetails: case updated successfully');
        
        if (!mounted) return;
        setState(() => _isLoading = false);
        
        // Show success and pop
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Monitoring details updated successfully')),
        );
        Navigator.of(context).pop(true);
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        
        AppLogger.e('Error updating mold case', error: e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _cropNameController.dispose();
    _dateOfObservationController.dispose();
    _locationController.dispose();
    _initialSymptomsController.dispose();
    _initialCharacteristicsController.dispose();
    _initialMicroscopicController.dispose();
    _initialMacroscopicController.dispose();
    _initialMicroscopicColorController.dispose();
    _initialMicroscopicTextureController.dispose();
    _initialMacroscopicColorController.dispose();
    _initialMacroscopicTextureController.dispose();
    _initialMacroscopicSymptomsController.dispose();
    _initialMacroscopicCharacteristicsController.dispose();
    _incubationTempController.dispose();
    _environmentalTempController.dispose();
    _specimenTypeController.dispose();
    _specimenQuantityController.dispose();
    super.dispose();
  }

  Future<void> _pickSpecimenType() async {
    final selectedTypes = await showMultiChipSelectionModal(
      context: context,
      title: 'Select Specimen Type(s)',
      options: _specimenTypeOptions,
      currentSelections: _selectedSpecimenTypes,
      customInputHint: 'Add custom specimen type(s), comma-separated',
      othersLabel: 'Others/Iba pa',
      isMultiLine: true,
    );

    if (selectedTypes != null && selectedTypes.isNotEmpty) {
      setState(() {
        _selectedSpecimenTypes
          ..clear()
          ..addAll(selectedTypes);
        _specimenTypeController.text = selectedTypes.join(', ');
      });
    }
  }

  Future<void> _pickInitialSymptoms() async {
    final selectedSymptoms = await showMultiChipSelectionModal(
      context: context,
      title: 'Select Initial Symptoms',
      options: _initialSymptomsOptions,
      currentSelections: _selectedInitialSymptoms,
      customInputHint: 'Add custom symptom(s), comma-separated',
      othersLabel: 'Others/Iba pa',
      isMultiLine: true,
    );

    if (selectedSymptoms != null && selectedSymptoms.isNotEmpty) {
      setState(() {
        _selectedInitialSymptoms
          ..clear()
          ..addAll(selectedSymptoms);
        _initialSymptomsController.text = selectedSymptoms.join(', ');
      });
    }
  }

  Future<void> _pickInitialCharacteristics() async {
    final selectedCharacteristics = await showMultiChipSelectionModal(
      context: context,
      title: 'Select Initial Characteristics',
      options: _initialCharacteristicsOptions,
      currentSelections: _selectedInitialCharacteristics,
      customInputHint: 'Add custom characteristic(s), comma-separated',
      othersLabel: 'Others/Iba pa',
      isMultiLine: true,
    );

    if (selectedCharacteristics != null && selectedCharacteristics.isNotEmpty) {
      setState(() {
        _selectedInitialCharacteristics
          ..clear()
          ..addAll(selectedCharacteristics);
        _initialCharacteristicsController.text =
            selectedCharacteristics.join(', ');
      });
    }
  }

  Future<void> _openInitialMicroscopicCapture() async {
    final result = await Navigator.of(context).pushNamed(
      RouteNames.mainCamera,
      arguments: {
        'showAppBar': true,
        'returnResult': true,
      },
    );
    if (!mounted) return;
    setState(() {
      if (result is Map<String, dynamic>) {
        _initialMicroscopicImagePath = result['imagePath']?.toString();
        _initialMicroscopicColorController.clear();
        _initialMicroscopicTextureController.clear();
        _initialMicroscopicController.text =
            result['identifiedMold']?.toString() ?? 'Mold identified';
      } else {
        _initialMicroscopicController.text =
            _initialMicroscopicController.text.isEmpty
                ? 'Captured via mold scanner'
                : _initialMicroscopicController.text;
      }
    });
  }

  Future<void> _openInitialMacroscopicCapture() async {
    final result = await Navigator.of(context).pushNamed(
      RouteNames.addLogInstructions,
      arguments: {
        'sourceTab': 'in-vivo',
        'caseId': widget.moldCase.id.toString(),
        'pageTitle': 'Initial Macroscopic',
        'pageSubtitle':
            'Submit a macroscopic image of the initial mold sample.',
        'includeSize': false,
      },
    );
    if (!mounted) return;
    setState(() {
      if (result is Map<String, dynamic>) {
        _initialMacroscopicImagePath = result['imagePath']?.toString();
        _initialMacroscopicColorController.text =
            result['color']?.toString() ?? '';
        _initialMacroscopicTextureController.text =
            result['texture']?.toString() ?? '';
        _initialMacroscopicSymptomsController.text =
          result['symptomsDisplay']?.toString() ?? '';
        _initialMacroscopicCharacteristicsController.text =
          result['characteristicsDisplay']?.toString() ?? '';
        _initialMacroscopicController.text =
          (result['additional']?.toString().isNotEmpty ?? false)
            ? result['additional'].toString()
            : 'Captured via add log instructions';
      } else {
        _initialMacroscopicController.text =
            _initialMacroscopicController.text.isEmpty
                ? 'Captured via add log instructions'
                : _initialMacroscopicController.text;
      }
    });
  }

  Future<void> _submitData() async {
    if (_isLoading) return;

    final shouldSubmit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BuildConfirmationDialog(
          title: 'Apply Monitoring Setup?',
          subtitle: 'Are you sure you want to apply these monitoring details?',
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

    if (shouldSubmit == true) {
      await _updateMoldCase();
    }
  }

  void _addSpecimenEntry() {
    final type = _specimenTypeController.text.trim();
    final quantity = _specimenQuantityController.text.trim();

    if (type.isEmpty || quantity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both specimen type and quantity'),
        ),
      );
      return;
    }

    final duplicate = _specimenEntries.any(
      (entry) => entry['type'] == type && entry['quantity'] == quantity,
    );
    if (duplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This specimen and quantity pair is already added'),
        ),
      );
      return;
    }

    setState(() {
      _specimenEntries.add({'type': type, 'quantity': quantity});
      _specimenTypeController.clear();
      _specimenQuantityController.clear();
    });
  }

  /// Shows a date picker and writes the selected date into [targetController].
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController targetController,
  ) async {
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
        targetController.text = DateFormat('MMMM dd, yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabContents = [
      ScheduleTab(
        startDateController: _startDateController,
        endDateController: _endDateController,
        dateObservationController: _dateOfObservationController,
        onSelectStartDate: () => _selectDate(context, _startDateController),
        onSelectDateObservation: () => _selectDate(context, _dateOfObservationController),
        onNext: () => setState(() => _selectedTab = 1),
      ),
      SpecimenTab(
        cropNameController: _cropNameController,
        typeController: _specimenTypeController,
        qtyController: _specimenQuantityController,
        symptomsController: _initialSymptomsController,
        charController: _initialCharacteristicsController,
        specimenEntries: _specimenEntries,
        onAddSpecimen: _addSpecimenEntry,
        onPickType: _pickSpecimenType,
        onPickSymptoms: _pickInitialSymptoms,
        onPickCharacteristics: _pickInitialCharacteristics,
        onRemoveSpecimen: (index) => setState(() => _specimenEntries.removeAt(index)),
        onNext: () => setState(() => _selectedTab = 2),
        onBack: () => setState(() => _selectedTab = 0),
      ),
      EvidenceTab(
        locationController: _locationController,
        microController: _initialMicroscopicController,
        macroController: _initialMacroscopicController,
        microColorController: _initialMicroscopicColorController,
        microTextureController: _initialMicroscopicTextureController,
        macroColorController: _initialMacroscopicColorController,
        macroTextureController: _initialMacroscopicTextureController,
        macroSymptomsController: _initialMacroscopicSymptomsController,
        macroCharacteristicsController: _initialMacroscopicCharacteristicsController,
        microscopicImagePath: _initialMicroscopicImagePath,
        macroscopicImagePath: _initialMacroscopicImagePath,
        onCaptureMicro: _openInitialMicroscopicCapture,
        onCaptureMacro: _openInitialMacroscopicCapture,
        onSubmit: _submitData,
        onBack: () => setState(() => _selectedTab = 1),
      ),
    ];
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: const PrimaryAppBar(title: 'Setup Monitoring'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ----------- Identification History Header -----------
              Text(
                  'Set Monitoring Details',
                  style: TextStyle(
                    fontSize: 36,
                    fontFamily: 'Montserrat-Black',
                    color: MoldifyColors.primaryColor,
                  )
              ),
              Text(
                  'Adjust the schedule and setup for your mold case.',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    color: MoldifyColors.MoldifyBlack,
                  )
              ),
              /// ----------- End of Identification History Header -----------
              const SizedBox(height: 20),
              StepIndicator(totalSteps: _tabTitles.length, currentStep: _selectedTab),
              const SizedBox(height: 20),
              ScrollableTabBar(
                tabs: _tabTitles,
                currentIndex: _selectedTab,
                onTabSelected: (index) => setState(() => _selectedTab = index),
              ),
              const SizedBox(height: 24),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: IndexedStack(
                  index: _selectedTab,
                  children: tabContents.asMap().entries.map((e) {
                    return Visibility(
                      visible: e.key == _selectedTab,
                      maintainState: true,
                      child: e.value,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

