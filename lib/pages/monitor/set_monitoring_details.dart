// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/core/features/mold/service/mold_service.dart';
import 'package:moldify/core/features/mold_case/models/mold_case.dart';
import 'package:moldify/core/features/mold_case/service/mold_case_service.dart';
import 'package:moldify/core/features/mold_report/service/mold_report_services.dart';
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
import '../../core/utils/mutation_result.dart';
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
  final TextEditingController _dateOfObservationController =
      TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _initialSymptomsController =
      TextEditingController();
  final TextEditingController _initialCharacteristicsController =
      TextEditingController();
  final TextEditingController _initialMicroscopicController =
      TextEditingController();
  final TextEditingController _initialMacroscopicController =
      TextEditingController();
  final TextEditingController _initialMicroscopicColorController =
      TextEditingController();
  final TextEditingController _initialMicroscopicTextureController =
      TextEditingController();
  final TextEditingController _initialMacroscopicColorController =
      TextEditingController();
  final TextEditingController _initialMacroscopicTextureController =
      TextEditingController();
  final TextEditingController _initialMacroscopicSymptomsController =
      TextEditingController();
  final TextEditingController _initialMacroscopicCharacteristicsController =
      TextEditingController();
  final TextEditingController _incubationTempController =
      TextEditingController();
  final TextEditingController _environmentalTempController =
      TextEditingController();
  final TextEditingController _specimenTypeController = TextEditingController();
  final TextEditingController _specimenQuantityController =
      TextEditingController();

  final List<Map<String, String>> _specimenEntries = [];
  final List<String> _selectedSpecimenTypes = [];
  final List<String> _selectedInitialSymptoms = [];
  final List<String> _selectedInitialCharacteristics = [];
  final List<String> _scannedMicroscopicIds = [];
  final List<String> _scannedMacroscopicIds = [];

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

  static const List<String> _defaultInitialSymptomsOptions = [
    'Leaf spots',
    'Wilting',
    'Yellowing leaves',
    'Powdery growth',
    'Soft rot',
    'Stem lesions',
  ];

  static const List<String> _defaultInitialCharacteristicsOptions = [
    'Cottony',
    'Powdery',
    'Slimy',
    'Fuzzy',
    'Discolored',
    'Spreading rapidly',
  ];

  final List<String> _initialSymptomsOptions = List<String>.from(
    _defaultInitialSymptomsOptions,
  );
  final List<String> _initialCharacteristicsOptions = List<String>.from(
    _defaultInitialCharacteristicsOptions,
  );

  final MoldCaseService _service = MoldCaseService();

  String? _selectedGrowthMedium;
  String? _initialMicroscopicImagePath;
  String? _initialMacroscopicImagePath;
  String? _initialMicroscopicImageUrl;
  String? _initialMacroscopicImageUrl;
  Map<String, dynamic>? _microscopicAiSnapshot;
  bool _isLoading = false;
  int _selectedTab = 0;
  final List<String> _tabTitles = const ['Schedule', 'Specimen', 'Evidence'];

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _hydrateLatestAssignmentDates();
    _hydrateCaseReportContext();
    _loadInvestigationOptions();
  }

  Future<void> _hydrateLatestAssignmentDates() async {
    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;
      if (sessionCookie == null || sessionCookie.isEmpty) return;

      final freshCase = await _service.getMoldCaseById(
        widget.moldCase.id,
        sessionCookie: sessionCookie,
      );
      final freshEndDate = _parseDateLike(freshCase['end_date']);
      if (!mounted || freshEndDate == null) return;

      setState(() {
        _endDateController.text = DateFormat(
          'MMMM dd, yyyy',
        ).format(freshEndDate);
      });
    } catch (_) {
      // Non-blocking refresh; keep existing value when unavailable.
    }
  }

  DateTime? _parseDateLike(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    if (value is Map<String, dynamic>) {
      final seconds = value['_seconds'] ?? value['seconds'];
      if (seconds is int) {
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
    }
    return null;
  }

  bool _isLikelyRemotePath(String? value) {
    if (value == null) return false;
    final normalized = value.trim().toLowerCase();
    return normalized.startsWith('http://') ||
        normalized.startsWith('https://') ||
        normalized.startsWith('gs://') ||
        normalized.startsWith('/v0/b/');
  }

  String _displayDate(String value) {
    final parsed = _parseDateLike(value);
    if (parsed == null) return value;
    return DateFormat('MMMM dd, yyyy').format(parsed.toLocal());
  }

  String? _toIsoDateTime(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final parsedUiDate = DateFormat('MMMM dd, yyyy').tryParseStrict(trimmed);
    if (parsedUiDate != null) {
      return DateTime(
        parsedUiDate.year,
        parsedUiDate.month,
        parsedUiDate.day,
      ).toUtc().toIso8601String();
    }

    final parsedIso = DateTime.tryParse(trimmed);
    return parsedIso?.toUtc().toIso8601String();
  }

  List<String> _splitCatalogValues(String raw) {
    return raw
        .split(RegExp(r'[,;|\n]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Future<void> _loadInvestigationOptions() async {
    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final service = MoldService();
      final catalog = await service.fetchAllMoldCatalog(
        sessionCookie: authProvider.cookie,
      );

      final symptoms = <String>{..._defaultInitialSymptomsOptions};
      final characteristics = <String>{
        ..._defaultInitialCharacteristicsOptions,
      };

      for (final entry in catalog) {
        symptoms.addAll(entry.symptoms);
        symptoms.addAll(entry.signs);
        symptoms.addAll(_splitCatalogValues(entry.symptomsAndSigns));
        characteristics.addAll(entry.characteristics);
      }

      if (!mounted) return;
      setState(() {
        _initialSymptomsOptions
          ..clear()
          ..addAll(symptoms.toList()..sort((a, b) => a.compareTo(b)));
        _initialCharacteristicsOptions
          ..clear()
          ..addAll(characteristics.toList()..sort((a, b) => a.compareTo(b)));
      });
    } catch (_) {
      // Keep defaults if catalog options are unavailable.
    }
  }

  Future<void> _hydrateCaseReportContext() async {
    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;
      if (sessionCookie == null || sessionCookie.isEmpty) return;

      final reportId = widget.moldCase.moldReportId.trim().isNotEmpty
          ? widget.moldCase.moldReportId.trim()
          : widget.moldCase.id.trim();
      if (reportId.isEmpty) return;

      final reportService = MoldReportService();
      final reportResponse = await reportService.getMoldReportById(
        reportId,
        sessionCookie: sessionCookie,
      );

      final reportPayload = reportResponse['data'] is Map<String, dynamic>
          ? reportResponse['data'] as Map<String, dynamic>
          : reportResponse;

      final host = reportPayload['host']?.toString().trim() ?? '';
      final location = reportPayload['location']?.toString().trim() ?? '';
      final observedDate =
          reportPayload['date_observed']?.toString().trim() ?? '';

      if (!mounted) return;
      setState(() {
        if (host.isNotEmpty) {
          _cropNameController.text = host;
        }
        if (_locationController.text.trim().isEmpty && location.isNotEmpty) {
          _locationController.text = location;
        }
        if (_dateOfObservationController.text.trim().isEmpty &&
            observedDate.isNotEmpty) {
          _dateOfObservationController.text = _displayDate(observedDate);
        }
      });
    } catch (_) {
      // Optional hydration only; keep current defaults if unavailable.
    }
  }

  void _initializeFields() {
    // Initialize with existing data if available
    final details = widget.moldCase.cultivationDetails;

    _startDateController.text = DateFormat(
      'MMMM dd, yyyy',
    ).format(widget.moldCase.startDate);
    // Temporary default; this is replaced with report host when available.
    _cropNameController.text = widget.moldCase.name;

    if (widget.moldCase.endDate != null) {
      _endDateController.text = DateFormat(
        'MMMM dd, yyyy',
      ).format(widget.moldCase.endDate!);
    }

    if (details != null) {
      _selectedGrowthMedium = details.growthMedium;
      // Populate temperatures
      if (details.inVitroDetails != null) {
        _incubationTempController.text = details
            .inVitroDetails!
            .incubationTemperature
            .toString();
      }

      if (details.inVivoDetails != null) {
        _environmentalTempController.text = details
            .inVivoDetails!
            .environmentalTemperature
            .toString();
      }

      // Populate specimen entries (pair specimen_types and specimen_quantities)
      if (details.specimenTypes != null && details.specimenTypes!.isNotEmpty) {
        final types = details.specimenTypes!;
        final quantities = details.specimenQuantities ?? [];
        for (var i = 0; i < types.length; i++) {
          final type = types[i];
          final qty = i < quantities.length ? quantities[i] : '';
          _specimenEntries.add({'type': type, 'quantity': qty});
        }
        _specimenTypeController.text = types.join(', ');
      }

      // Populate initial symptoms & characteristics
      if (details.initialSymptoms != null &&
          details.initialSymptoms!.isNotEmpty) {
        _selectedInitialSymptoms.clear();
        _selectedInitialSymptoms.addAll(details.initialSymptoms!);
        _initialSymptomsController.text = details.initialSymptoms!.join(', ');
      }
      if (details.initialCharacteristics != null &&
          details.initialCharacteristics!.isNotEmpty) {
        _selectedInitialCharacteristics.clear();
        _selectedInitialCharacteristics.addAll(details.initialCharacteristics!);
        _initialCharacteristicsController.text = details.initialCharacteristics!
            .join(', ');
      }

      // Populate evidence and metadata
      if (details.locationGathered != null &&
          details.locationGathered!.isNotEmpty) {
        _locationController.text = details.locationGathered!;
      }
      if (details.initialMicroscopic != null &&
          details.initialMicroscopic!.isNotEmpty) {
        _initialMicroscopicController.text = details.initialMicroscopic!;
      }
      if (details.initialMacroscopic != null &&
          details.initialMacroscopic!.isNotEmpty) {
        _initialMacroscopicController.text = details.initialMacroscopic!;
      }
      if (details.initialMicroscopicColor != null &&
          details.initialMicroscopicColor!.isNotEmpty) {
        _initialMicroscopicColorController.text =
            details.initialMicroscopicColor!;
      }
      if (details.initialMicroscopicTexture != null &&
          details.initialMicroscopicTexture!.isNotEmpty) {
        _initialMicroscopicTextureController.text =
            details.initialMicroscopicTexture!;
      }
      if (details.initialMacroscopicColor != null &&
          details.initialMacroscopicColor!.isNotEmpty) {
        _initialMacroscopicColorController.text =
            details.initialMacroscopicColor!;
      }
      if (details.initialMacroscopicTexture != null &&
          details.initialMacroscopicTexture!.isNotEmpty) {
        _initialMacroscopicTextureController.text =
            details.initialMacroscopicTexture!;
      }
      if (details.initialMacroscopicSymptoms != null &&
          details.initialMacroscopicSymptoms!.isNotEmpty) {
        _initialMacroscopicSymptomsController.text =
            details.initialMacroscopicSymptoms!;
      }
      if (details.initialMacroscopicCharacteristics != null &&
          details.initialMacroscopicCharacteristics!.isNotEmpty) {
        _initialMacroscopicCharacteristicsController.text =
            details.initialMacroscopicCharacteristics!;
      }
      if (details.initialMicroscopicImageUrl != null &&
          details.initialMicroscopicImageUrl!.isNotEmpty) {
        _initialMicroscopicImageUrl = details.initialMicroscopicImageUrl;
        _initialMicroscopicImagePath = details.initialMicroscopicImageUrl;
      }
      if (details.initialMacroscopicImageUrl != null &&
          details.initialMacroscopicImageUrl!.isNotEmpty) {
        _initialMacroscopicImageUrl = details.initialMacroscopicImageUrl;
        _initialMacroscopicImagePath = details.initialMacroscopicImageUrl;
      }
      if (details.dateObservation != null &&
          details.dateObservation!.isNotEmpty) {
        _dateOfObservationController.text = _displayDate(
          details.dateObservation!,
        );
      }
      if (details.scannedMicroscopicIds != null &&
          details.scannedMicroscopicIds!.isNotEmpty) {
        _scannedMicroscopicIds
          ..clear()
          ..addAll(details.scannedMicroscopicIds!);
      }
      if (details.scannedMacroscopicIds != null &&
          details.scannedMacroscopicIds!.isNotEmpty) {
        _scannedMacroscopicIds
          ..clear()
          ..addAll(details.scannedMacroscopicIds!);
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
      AppLogger.d(
        'SetMonitoringDetails: growthMedium=$_selectedGrowthMedium, incubationTemp=$incubationTemp, environmentalTemp=$environmentalTemp',
      );

      // Build cultivation details
      final cultivationDetails = CultivationDetails(
        growthMedium: _selectedGrowthMedium ?? '',
        inVitroDetails: InVitroDetails(incubationTemperature: incubationTemp),
        inVivoDetails: InVivoDetails(
          environmentalTemperature: environmentalTemp,
        ),
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
        cultivationDetailsMap['specimen_quantities_csv'] = specimenQuantities
            .join(',');
      }
      if (_selectedInitialSymptoms.isNotEmpty) {
        cultivationDetailsMap['initial_symptoms'] = _selectedInitialSymptoms;

        ///Passes comman-separated symptoms for easier backend parsing as a fallback if array parsing fails
        cultivationDetailsMap['initial_symptoms_csv'] = _selectedInitialSymptoms
            .join(',');
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
      if (_initialMicroscopicColorController.text.trim().isNotEmpty) {
        cultivationDetailsMap['initial_microscopic_color'] =
            _initialMicroscopicColorController.text.trim();
      }
      if (_initialMicroscopicTextureController.text.trim().isNotEmpty) {
        cultivationDetailsMap['initial_microscopic_texture'] =
            _initialMicroscopicTextureController.text.trim();
      }
      if (_initialMacroscopicColorController.text.trim().isNotEmpty) {
        cultivationDetailsMap['initial_macroscopic_color'] =
            _initialMacroscopicColorController.text.trim();
      }
      if (_initialMacroscopicTextureController.text.trim().isNotEmpty) {
        cultivationDetailsMap['initial_macroscopic_texture'] =
            _initialMacroscopicTextureController.text.trim();
      }
      if (_initialMacroscopicSymptomsController.text.trim().isNotEmpty) {
        cultivationDetailsMap['initial_macroscopic_symptoms'] =
            _initialMacroscopicSymptomsController.text.trim();
      }
      if (_initialMacroscopicCharacteristicsController.text.trim().isNotEmpty) {
        cultivationDetailsMap['initial_macroscopic_characteristics'] =
            _initialMacroscopicCharacteristicsController.text.trim();
      }
      if (_initialMicroscopicImageUrl != null &&
          _initialMicroscopicImageUrl!.trim().isNotEmpty) {
        cultivationDetailsMap['initial_microscopic_image_url'] =
            _initialMicroscopicImageUrl!.trim();
      } else if (_isLikelyRemotePath(_initialMicroscopicImagePath)) {
        cultivationDetailsMap['initial_microscopic_image_url'] =
            _initialMicroscopicImagePath!.trim();
      }
      if (_initialMacroscopicImageUrl != null &&
          _initialMacroscopicImageUrl!.trim().isNotEmpty) {
        cultivationDetailsMap['initial_macroscopic_image_url'] =
            _initialMacroscopicImageUrl!.trim();
      } else if (_isLikelyRemotePath(_initialMacroscopicImagePath)) {
        cultivationDetailsMap['initial_macroscopic_image_url'] =
            _initialMacroscopicImagePath!.trim();
      }
      if (_locationController.text.trim().isNotEmpty) {
        cultivationDetailsMap['location_gathered'] = _locationController.text
            .trim();
      }
      if (_dateOfObservationController.text.trim().isNotEmpty) {
        final isoObservationDate = _toIsoDateTime(
          _dateOfObservationController.text,
        );
        if (isoObservationDate != null) {
          cultivationDetailsMap['date_observation'] = isoObservationDate;
        }
      }
      if (_microscopicAiSnapshot != null &&
          _microscopicAiSnapshot!.isNotEmpty) {
        cultivationDetailsMap['microscopic_ai_snapshot'] =
            _microscopicAiSnapshot;
      } else if (_initialMicroscopicController.text.trim().isNotEmpty) {
        cultivationDetailsMap['microscopic_ai_snapshot'] = {
          'identified_mold': _initialMicroscopicController.text.trim(),
          'model_source': 'manual_entry_fallback',
          'captured_at': DateTime.now().toUtc().toIso8601String(),
        };
      }
      if (_scannedMicroscopicIds.isNotEmpty) {
        cultivationDetailsMap['scanned_microscopic_ids'] = List<String>.from(
          _scannedMicroscopicIds,
        );
      }
      if (_scannedMacroscopicIds.isNotEmpty) {
        cultivationDetailsMap['scanned_macroscopic_ids'] = List<String>.from(
          _scannedMacroscopicIds,
        );
      }

      // Build payload for service
      final updatePayload = {'cultivation_details': cultivationDetailsMap};

      AppLogger.d('SetMonitoringDetails: updatePayload=$updatePayload');

      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;

      // Update via service - use updateCultivationDetails endpoint
      AppLogger.d(
        'SetMonitoringDetails: calling service.updateCultivationDetails()',
      );
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
        const SnackBar(
          content: Text('Monitoring details updated successfully'),
        ),
      );
      Navigator.of(context).pop(
        const MutationResult.changed(tags: [MutationTags.moldCase]).toMap(),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      AppLogger.e('Error updating mold case', error: e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
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
    final selectedSymptoms = await showSearchableSelectionModal(
      context: context,
      title: 'Select Initial Symptoms',
      options: _initialSymptomsOptions,
      currentSelections: _selectedInitialSymptoms,
      searchHint: 'Search symptoms...',
      confirmButtonText: 'Confirm',
      cancelButtonText: 'Cancel',
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
    final selectedCharacteristics = await showSearchableSelectionModal(
      context: context,
      title: 'Select Initial Characteristics',
      options: _initialCharacteristicsOptions,
      currentSelections: _selectedInitialCharacteristics,
      searchHint: 'Search characteristics...',
      confirmButtonText: 'Confirm',
      cancelButtonText: 'Cancel',
    );

    if (selectedCharacteristics != null && selectedCharacteristics.isNotEmpty) {
      setState(() {
        _selectedInitialCharacteristics
          ..clear()
          ..addAll(selectedCharacteristics);
        _initialCharacteristicsController.text = selectedCharacteristics.join(
          ', ',
        );
      });
    }
  }

  Future<void> _openInitialMicroscopicCapture() async {
    final result = await Navigator.of(context).pushNamed(
      RouteNames.mainCamera,
      arguments: {
        'showAppBar': true,
        'returnResult': true,
        'sourceFlow': 'monitoring_initial',
        'scanModality': 'microscopic',
        'caseId': widget.moldCase.id,
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
        _initialMicroscopicColorController.text =
            result['microColor']?.toString() ??
            _initialMicroscopicColorController.text;
        _initialMicroscopicTextureController.text =
            result['microTexture']?.toString() ??
            _initialMicroscopicTextureController.text;

        final confidenceDecimal = (result['confidenceDecimal'] as num?)
            ?.toDouble();
        final topPredictionsRaw = result['topPredictions'];
        final topPredictions = (topPredictionsRaw is List)
            ? topPredictionsRaw
                  .whereType<Map>()
                  .map((entry) => Map<String, dynamic>.from(entry))
                  .toList()
            : <Map<String, dynamic>>[];

        _microscopicAiSnapshot = {
          'identified_mold': _initialMicroscopicController.text.trim(),
          if (result['confidence'] != null)
            'confidence_display': result['confidence'].toString(),
          if (confidenceDecimal != null) 'confidence': confidenceDecimal,
          'model_source': result['modelSource']?.toString() ?? 'unknown',
          'used_fusion': result['usedFusion'] == true,
          'used_ann': result['usedAnn'] == true,
          'top_predictions': topPredictions,
          'captured_at': DateTime.now().toUtc().toIso8601String(),
        };

        final scanId = result['scanId']?.toString();
        if (scanId != null &&
            scanId.isNotEmpty &&
            !_scannedMicroscopicIds.contains(scanId)) {
          _scannedMicroscopicIds.add(scanId);
        }

        final savedScan = result['savedScan'];
        if (savedScan is Map<String, dynamic>) {
          final savedUrl = savedScan['image_url']?.toString();
          if (savedUrl != null && savedUrl.isNotEmpty) {
            _initialMicroscopicImageUrl = savedUrl;
            _initialMicroscopicImagePath = savedUrl;
          }

          final predictedClassName = savedScan['predicted_class_name']
              ?.toString()
              .trim();
          final currentMold = _initialMicroscopicController.text.trim();
          if ((predictedClassName?.isNotEmpty ?? false) &&
              (currentMold.isEmpty ||
                  currentMold.toLowerCase() == 'mold identified')) {
            _initialMicroscopicController.text = predictedClassName!;
          }

          if (_microscopicAiSnapshot == null ||
              _microscopicAiSnapshot!.isEmpty) {
            _microscopicAiSnapshot = {
              'identified_mold': _initialMicroscopicController.text.trim(),
              if (predictedClassName != null && predictedClassName.isNotEmpty)
                'predicted_class_name': predictedClassName,
              'model_source': 'camera_scan_fallback',
              'captured_at': DateTime.now().toUtc().toIso8601String(),
            };
          }
        }

        if ((_initialMicroscopicImageUrl == null ||
                _initialMicroscopicImageUrl!.isEmpty) &&
            _isLikelyRemotePath(_initialMicroscopicImagePath)) {
          _initialMicroscopicImageUrl = _initialMicroscopicImagePath;
        }
      } else {
        _initialMicroscopicController.text =
            _initialMicroscopicController.text.isEmpty
            ? 'Captured via mold scanner'
            : _initialMicroscopicController.text;
      }
    });

    if (!mounted || result is! Map<String, dynamic>) return;
    final confidence = (result['confidenceDecimal'] as num?)?.toDouble();
    if (confidence != null && confidence < 0.70) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Low AI confidence detected. Consider adding more observations before final verdict.',
          ),
        ),
      );
    }
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
        'sourceFlow': 'monitoring_initial',
        'scanModality': 'macroscopic',
        'returnResult': true,
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

        final scanId = result['scanId']?.toString();
        if (scanId != null &&
            scanId.isNotEmpty &&
            !_scannedMacroscopicIds.contains(scanId)) {
          _scannedMacroscopicIds.add(scanId);
        }

        final savedScan = result['savedScan'];
        if (savedScan is Map<String, dynamic>) {
          final savedUrl = savedScan['image_url']?.toString();
          if (savedUrl != null && savedUrl.isNotEmpty) {
            _initialMacroscopicImageUrl = savedUrl;
            _initialMacroscopicImagePath = savedUrl;
          }
        }

        if ((_initialMacroscopicImageUrl == null ||
                _initialMacroscopicImageUrl!.isEmpty) &&
            _isLikelyRemotePath(_initialMacroscopicImagePath)) {
          _initialMacroscopicImageUrl = _initialMacroscopicImagePath;
        }
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
  /// If selecting a start date, validates it does not exceed the end date.
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController targetController,
  ) async {
    // Determine if this is for start date or another date
    final isStartDate = targetController == _startDateController;

    // If setting start date and end date is set, use end date as the max
    DateTime lastDateForPicker = DateTime(2101);
    if (isStartDate && _endDateController.text.isNotEmpty) {
      try {
        final endDate = DateFormat(
          'MMMM dd, yyyy',
        ).parse(_endDateController.text);
        lastDateForPicker = endDate;
      } catch (e) {
        AppLogger.e('Failed to parse end date: $e');
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: lastDateForPicker,
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
        onSelectDateObservation: () =>
            _selectDate(context, _dateOfObservationController),
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
        onRemoveSpecimen: (index) =>
            setState(() => _specimenEntries.removeAt(index)),
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
        macroCharacteristicsController:
            _initialMacroscopicCharacteristicsController,
        microscopicImagePath: _initialMicroscopicImagePath,
        macroscopicImagePath: _initialMacroscopicImagePath,
        onCaptureMicro: _openInitialMicroscopicCapture,
        onCaptureMacro: _openInitialMacroscopicCapture,
        onSubmit: _submitData,
        isSaving: _isLoading,
        onBack: () => setState(() => _selectedTab = 1),
      ),
    ];
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: const PrimaryAppBar(title: 'Setup Monitoring'),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 30.0,
              ),
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
                    ),
                  ),
                  Text(
                    'Adjust the schedule and setup for your mold case.',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Bricolage-Grotesque-Regular',
                      color: MoldifyColors.MoldifyBlack,
                    ),
                  ),

                  /// ----------- End of Identification History Header -----------
                  const SizedBox(height: 20),
                  StepIndicator(
                    totalSteps: _tabTitles.length,
                    currentStep: _selectedTab,
                  ),
                  const SizedBox(height: 20),
                  ScrollableTabBar(
                    tabs: _tabTitles,
                    currentIndex: _selectedTab,
                    onTabSelected: (index) =>
                        setState(() => _selectedTab = index),
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
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.35),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: MoldifyColors.primaryColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
