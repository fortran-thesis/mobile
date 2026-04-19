import 'dart:io';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:moldify/core/features/camera/services/camera_service.dart';
import 'package:moldify/core/features/mold/service/mold_service.dart';
import 'package:moldify/core/features/mold_case/service/mold_case_service.dart';
import 'package:moldify/pages/misc/textboxes/textboxes.dart';
import 'package:moldify/pages/misc/overlays/modals/chip_selection_modal.dart';
import 'package:moldify/pages/misc/overlays/loading_ui.dart';
import 'package:moldify/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../misc/appbar/primary_app_bar.dart';
import '../misc/buttons/primary_button.dart';
import '../misc/colors.dart';
import '../misc/overlays/modals/confirmation_dialog.dart';
import 'package:moldify/core/utils/logger.dart';

class AddLogScreen extends StatefulWidget {
  // 1. Add parameters for imagePath and the new sourceTab
  final String imagePath;
  final String sourceTab;
  final String caseId; // Add caseId for API call
  final bool includeSize;
  final String? sourceFlow;
  final String? scanModality;
  final String? selectedCultureId;
  final String? selectedCultureName;

  // 2. Update the constructor to require them
  const AddLogScreen({
    super.key,
    required this.imagePath,
    required this.sourceTab,
    required this.caseId,
    this.includeSize = true,
    this.sourceFlow,
    this.scanModality,
    this.selectedCultureId,
    this.selectedCultureName,
  });

  @override
  State<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends State<AddLogScreen> {
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _textureController = TextEditingController();
  final TextEditingController _logNotesController = TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _signsController = TextEditingController();
  final TextEditingController _characteristicsController =
      TextEditingController();
  bool _isSaving = false;

  final List<String> _selectedSymptoms = [];
  final List<String> _selectedSigns = [];
  final List<String> _selectedCharacteristics = [];
  
  String _selectedColor = '';
  String _selectedTexture = '';

  static const List<String> _defaultSymptomOptions = [
    'Leaf spots',
    'Wilting',
    'Yellowing',
    'Soft rot',
    'Stem lesions',
    'Necrosis',
  ];

  static const List<String> _defaultSignOptions = [
    'White mycelial growth',
    'Powdery residue',
    'Dark sporulation',
    'Water-soaked lesion edge',
    'Foul odor',
    'Slimy exudate',
  ];

  static const List<String> _defaultCharacteristicOptions = [
    'Cotton-like',
    'Powder-like',
    'Slime-like',
    'Fuzzy-like',
    'Velvety-like',
    'Smooth-like',
    'Rough-like',
    'Water-soaked-like',
  ];

  static const List<String> _defaultColorOptions = [
    'White',
    'Green',
    'Black',
    'Brown',
    'Yellow',
    'Orange',
    'Pink',
    'Purple',
    'Red',
  ];

  static const List<String> _defaultTextureOptions = [
    'Cotton-like',
    'Powder-like',
    'Slime-like',
    'Fuzzy-like',
    'Velvety-like',
    'Smooth-like',
    'Rough-like',
    'Water-soaked-like',
  ];

  final List<String> _symptomOptions = List<String>.from(
    _defaultSymptomOptions,
  );
  final List<String> _signOptions = List<String>.from(_defaultSignOptions);
  final List<String> _characteristicOptions = List<String>.from(
    _defaultCharacteristicOptions,
  );
  final List<String> _colorOptions = List<String>.from(_defaultColorOptions);
  final List<String> _textureOptions = List<String>.from(
    _defaultTextureOptions,
  );

  late final String _sizeLabel;
  late final String _sizeHint;
  late final String _colorLabel;
  late final String _colorHint;
  late final String _textureLabel;
  late final String _textureHint;

  // Evidence-style mode (color/texture + symptoms + characteristics)
  // should apply to both in-vivo and in-vitro when includeSize is disabled.
  bool get _isInitialMacroscopicMode => !widget.includeSize;

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

      final symptoms = <String>{..._defaultSymptomOptions};
      final signs = <String>{..._defaultSignOptions};
      final characteristics = <String>{..._defaultCharacteristicOptions};

      for (final entry in catalog) {
        symptoms.addAll(entry.symptoms);
        signs.addAll(entry.signs);
        final fallbackCombined = _splitCatalogValues(entry.symptomsAndSigns);
        if (entry.symptoms.isEmpty) {
          symptoms.addAll(fallbackCombined);
        }
        if (entry.signs.isEmpty) {
          signs.addAll(fallbackCombined);
        }
        characteristics.addAll(entry.characteristics);
      }

      if (!mounted) return;
      setState(() {
        _symptomOptions
          ..clear()
          ..addAll(symptoms.toList()..sort((a, b) => a.compareTo(b)));
        _signOptions
          ..clear()
          ..addAll(signs.toList()..sort((a, b) => a.compareTo(b)));
        _characteristicOptions
          ..clear()
          ..addAll(characteristics.toList()..sort((a, b) => a.compareTo(b)));
      });
    } catch (_) {
      // Keep defaults if catalog options are unavailable.
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInvestigationOptions();

    // Keep role-specific labels while making the values user-editable.
    if (widget.sourceTab == 'in-vivo') {
      _sizeLabel = 'Lesion Size (mm)';
      _sizeHint = 'Enter lesion size in mm';
      _colorLabel = 'Lesion Color';
      _colorHint = 'Enter lesion color';
      _textureLabel = 'Lesion Texture';
      _textureHint = 'Enter lesion texture';

      // Keep fields blank by default for manual evidence entry.
      _sizeController.clear();
      _colorController.clear();
      _textureController.clear();
    } else {
      _sizeLabel = 'Colony Diameter (mm)';
      _sizeHint = 'Enter colony diameter in mm';
      _colorLabel = 'Colony Color';
      _colorHint = 'Enter colony color';
      _textureLabel = 'Colony Texture';
      _textureHint = 'Enter colony texture';

      // Keep fields blank by default for manual evidence entry.
      _sizeController.clear();
      _colorController.clear();
      _textureController.clear();
    }
  }

  @override
  void dispose() {
    _sizeController.dispose();
    _colorController.dispose();
    _textureController.dispose();
    _logNotesController.dispose();
    _symptomsController.dispose();
    _signsController.dispose();
    _characteristicsController.dispose();
    super.dispose();
  }

  Future<void> _pickSymptoms() async {
    final selected = await showSearchableSelectionModal(
      context: context,
      title: 'Select Symptoms',
      options: _symptomOptions,
      currentSelections: _selectedSymptoms,
      searchHint: 'Search symptoms...',
      confirmButtonText: 'Confirm',
      cancelButtonText: 'Cancel',
      allowCustomOption: true,
      addCustomLabel: 'Add symptom',
    );

    if (selected == null || selected.isEmpty) return;
    setState(() {
      for (final item in selected) {
        if (!_symptomOptions.contains(item)) {
          _symptomOptions.add(item);
        }
      }
      _symptomOptions.sort((a, b) => a.compareTo(b));
      _selectedSymptoms
        ..clear()
        ..addAll(selected);
      _symptomsController.text = selected.join(', ');
    });
  }

  Future<void> _pickCharacteristics() async {
    final selected = await showSearchableSelectionModal(
      context: context,
      title: 'Select Characteristics',
      options: _characteristicOptions,
      currentSelections: _selectedCharacteristics,
      searchHint: 'Search characteristics...',
      confirmButtonText: 'Confirm',
      cancelButtonText: 'Cancel',
      allowCustomOption: true,
      addCustomLabel: 'Add characteristic',
    );

    if (selected == null || selected.isEmpty) return;
    setState(() {
      for (final item in selected) {
        if (!_characteristicOptions.contains(item)) {
          _characteristicOptions.add(item);
        }
      }
      _characteristicOptions.sort((a, b) => a.compareTo(b));
      _selectedCharacteristics
        ..clear()
        ..addAll(selected);
      _characteristicsController.text = selected.join(', ');
    });
  }

  Future<void> _pickColor() async {
    final selected = await showSearchableSelectionModal(
      context: context,
      title: 'Select Color',
      options: _colorOptions,
      currentSelections: _selectedColor.isEmpty ? [] : [_selectedColor],
      searchHint: 'Search or add color...',
      confirmButtonText: 'Confirm',
      cancelButtonText: 'Cancel',
      allowCustomOption: true,
      multiSelect: false,
      addCustomLabel: 'Add color',
    );

    if (selected == null || selected.isEmpty) return;
    setState(() {
      final color = selected.first;
      if (!_colorOptions.contains(color)) {
        _colorOptions.add(color);
        _colorOptions.sort((a, b) => a.compareTo(b));
      }
      _selectedColor = color;
      _colorController.text = color;
    });
  }

  Future<void> _pickTexture() async {
    final selected = await showSearchableSelectionModal(
      context: context,
      title: 'Select Texture',
      options: _textureOptions,
      currentSelections: _selectedTexture.isEmpty ? [] : [_selectedTexture],
      searchHint: 'Search or add texture...',
      confirmButtonText: 'Confirm',
      cancelButtonText: 'Cancel',
      allowCustomOption: true,
      multiSelect: false,
      addCustomLabel: 'Add texture',
    );

    if (selected == null || selected.isEmpty) return;
    setState(() {
      final texture = selected.first;
      if (!_textureOptions.contains(texture)) {
        _textureOptions.add(texture);
        _textureOptions.sort((a, b) => a.compareTo(b));
      }
      _selectedTexture = texture;
      _textureController.text = texture;
    });
  }

  Future<void> _pickSigns() async {
    final selected = await showSearchableSelectionModal(
      context: context,
      title: 'Select Signs',
      options: _signOptions,
      currentSelections: _selectedSigns,
      searchHint: 'Search signs...',
      confirmButtonText: 'Confirm',
      cancelButtonText: 'Cancel',
      allowCustomOption: true,
      addCustomLabel: 'Add sign',
    );

    if (selected == null || selected.isEmpty) return;
    setState(() {
      for (final item in selected) {
        if (!_signOptions.contains(item)) {
          _signOptions.add(item);
        }
      }
      _signOptions.sort((a, b) => a.compareTo(b));
      _selectedSigns
        ..clear()
        ..addAll(selected);
      _signsController.text = selected.join(', ');
    });
  }

  Future<void> _saveCultivationLog() async {
    try {
      setState(() => _isSaving = true);

      final sourceFlow =
          widget.sourceFlow ??
          (_isInitialMacroscopicMode
              ? 'monitoring_initial'
              : 'cultivation_log');
      final scanModality = widget.scanModality ?? 'macroscopic';
      final scannedResults = {'confidence_score': 0, 'flagged': false};
      final cultivationType = _resolveCultivationType(widget.sourceTab);
      final selectedCultureId = widget.selectedCultureId?.trim();
      final selectedCultureName = widget.selectedCultureName?.trim();

      final isCultivationLogFlow = sourceFlow == 'cultivation_log';
      if (isCultivationLogFlow &&
          ((selectedCultureId ?? '').isEmpty ||
              (selectedCultureName ?? '').isEmpty)) {
        if (!mounted) return;
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please assign a culture first in Add Log Choices.'),
          ),
        );
        return;
      }

      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final cameraService = CameraService();
      final moldCaseService = MoldCaseService();
      final pathSegments = widget.imagePath.split('.');
      final imageFormat = pathSegments.length > 1
          ? pathSegments.last.toLowerCase()
          : 'png';
      final scanRes = await cameraService.createScannedMold(
        imagePath: widget.imagePath,
        imageFormat: imageFormat,
        scanModality: scanModality,
        sourceFlow: sourceFlow,
        sourceTab: widget.sourceTab,
        moldCaseId: widget.caseId,
        capturedAt: DateTime.now().toUtc().toIso8601String(),
        scannedResults: scannedResults,
        sessionCookie: authProvider.cookie,
      );

      // Local-only return payload (dummy-friendly, no backend write).
      final result = <String, dynamic>{
        'imagePath': widget.imagePath,
        'sourceTab': widget.sourceTab,
        'color': _colorController.text.trim(),
        'texture': _textureController.text.trim(),
        'additional': _isInitialMacroscopicMode
            ? ''
            : _logNotesController.text.trim(),
      };
      if (widget.includeSize) {
        result['size'] = _sizeController.text.trim();
      }
      if (_isInitialMacroscopicMode) {
        result['symptoms'] = List<String>.from(_selectedSymptoms);
        result['signs'] = List<String>.from(_selectedSigns);
        result['characteristics'] = List<String>.from(_selectedCharacteristics);
        result['symptomsDisplay'] = _symptomsController.text.trim();
        result['signsDisplay'] = _signsController.text.trim();
        result['characteristicsDisplay'] = _characteristicsController.text
            .trim();
      }
      if ((selectedCultureId ?? '').isNotEmpty) {
        result['cultureId'] = selectedCultureId;
      }
      if ((selectedCultureName ?? '').isNotEmpty) {
        result['cultureName'] = selectedCultureName;
      }

      if (scanRes['error'] != null) {
        result['scanSaveError'] = scanRes['error'];
        AppLogger.e(
          'AddLog: Failed to persist macroscopic scan: ${scanRes['error']}',
        );
      } else {
        final data = scanRes['data'];
        if (data is Map<String, dynamic>) {
          final scanId = data['id']?.toString();
          result['scanId'] = scanId;
          result['savedScan'] = data;

          if (scanId != null && scanId.isNotEmpty) {
            try {
              await _persistScannedMoldIdToCase(
                moldCaseService: moldCaseService,
                sessionCookie: authProvider.cookie,
                scanId: scanId,
                scanModality: scanModality,
              );
              result['scanAssociatedToCase'] = true;
            } catch (e) {
              result['scanAssociationError'] = e.toString();
              AppLogger.e(
                'AddLog: scan was saved but failed to associate scanId=$scanId '
                'to caseId=${widget.caseId}',
                error: e,
              );
            }
          }
        }
      }

      if (isCultivationLogFlow) {
        final characteristics = _buildNormalizedCharacteristics();
        final payload = <String, dynamic>{
          'type': cultivationType,
          'characteristics': characteristics,
          'additional_info': _logNotesController.text.trim(),
        };

        AppLogger.d(
          'AddLog: saving cultivation log '
          'caseId=${widget.caseId} sourceTab=${widget.sourceTab} type=$cultivationType '
          'characteristicsKeys=${characteristics.keys.toList()}',
        );

        try {
          final logResponse = await moldCaseService.addCultivationLog(
            widget.caseId,
            payload,
            imagePath: widget.imagePath,
            sessionCookie: authProvider.cookie,
          );

          final logData = logResponse['data'];
          result['cultivationLogSaved'] = true;
          if (logData is Map<String, dynamic>) {
            result['cultivationLog'] = logData;
          }

          AppLogger.d(
            'AddLog: cultivation log persisted '
            'caseId=${widget.caseId} sourceTab=${widget.sourceTab} '
            'logId=${(logData is Map<String, dynamic>) ? logData['id'] : null}',
          );
        } catch (e) {
          AppLogger.e(
            'AddLog: cultivation log save failed '
            'caseId=${widget.caseId} sourceTab=${widget.sourceTab} type=$cultivationType',
            error: e,
          );

          if (!mounted) return;
          setState(() => _isSaving = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to save cultivation log: $e')),
            );
          }
          return;
        }
      }

      if (!mounted) return;
      setState(() => _isSaving = false);

      Navigator.of(context).pop(result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to prepare log: $e')),
        );
      }
    }
  }

  String _resolveCultivationType(String sourceTab) {
    if (sourceTab == 'in-vivo') return 'vivo';
    return 'vitro';
  }

  Map<String, dynamic> _buildNormalizedCharacteristics() {
    final size = widget.includeSize ? _sizeController.text.trim() : '';
    final color = _colorController.text.trim();
    final texture = _textureController.text.trim();
    final symptomsDisplay = _symptomsController.text.trim();
    final signsDisplay = _signsController.text.trim();
    final characteristicsDisplay = _characteristicsController.text.trim();
    final symptoms = List<String>.from(_selectedSymptoms);
    final signs = List<String>.from(_selectedSigns);
    final characteristics = List<String>.from(_selectedCharacteristics);
    final selectedCultureId = widget.selectedCultureId?.trim();
    final selectedCultureName = widget.selectedCultureName?.trim();

    final map = <String, dynamic>{
      'size': size,
      'color': color,
      'texture': texture,
      'symptoms': symptoms.isNotEmpty ? symptoms : symptomsDisplay,
      'signs': signs.isNotEmpty ? signs : signsDisplay,
      'characteristics': characteristics.isNotEmpty
          ? characteristics
          : characteristicsDisplay,
      if ((selectedCultureId ?? '').isNotEmpty) 'culture_id': selectedCultureId,
      if ((selectedCultureName ?? '').isNotEmpty)
        'culture_name': selectedCultureName,
    };

    if (widget.sourceTab == 'in-vivo') {
      map['lesion_size'] = size;
      map['lesion_color'] = color;
      map['lesion_texture'] = texture;
    } else {
      map['colony_diameter'] = size;
      map['colony_color'] = color;
      map['colony_texture'] = texture;
    }

    return map;
  }

  List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return <String>[];
  }

  Future<void> _persistScannedMoldIdToCase({
    required MoldCaseService moldCaseService,
    required String? sessionCookie,
    required String scanId,
    required String scanModality,
  }) async {
    final caseData = await moldCaseService.getMoldCaseById(
      widget.caseId,
      sessionCookie: sessionCookie,
    );

    final existingDetails =
        (caseData['cultivation_details'] is Map<String, dynamic>)
        ? Map<String, dynamic>.from(
            caseData['cultivation_details'] as Map<String, dynamic>,
          )
        : <String, dynamic>{};

    final microscopicIds = _toStringList(
      existingDetails['scanned_microscopic_ids'],
    );
    final macroscopicIds = _toStringList(
      existingDetails['scanned_macroscopic_ids'],
    );

    if (scanModality == 'microscopic') {
      if (!microscopicIds.contains(scanId)) microscopicIds.add(scanId);
    } else {
      if (!macroscopicIds.contains(scanId)) macroscopicIds.add(scanId);
    }

    existingDetails['scanned_microscopic_ids'] = microscopicIds;
    existingDetails['scanned_macroscopic_ids'] = macroscopicIds;

    await moldCaseService.updateCultivationDetails(widget.caseId, {
      'cultivation_details': existingDetails,
    }, sessionCookie: sessionCookie);

    AppLogger.d(
      'AddLog: associated scanned mold id to case '
      'caseId=${widget.caseId} scanId=$scanId modality=$scanModality '
      'microscopicCount=${microscopicIds.length} macroscopicCount=${macroscopicIds.length}',
    );
  }

  @override
  Widget build(BuildContext context) {
    String dateTime = 'October 2, 2025 • 09:14 PM';

    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(title: 'Add New Log'),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
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
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.35,
                    ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 20.0,
                        ),
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
                              children: [const SizedBox.shrink()],
                            ),

                            if (widget.includeSize) ...[
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  bottom: 8.0,
                                ),
                                child: Text(
                                  _sizeLabel,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Bricolage-Grotesque-SemiBold',
                                    color: MoldifyColors.primaryColor,
                                  ),
                                ),
                              ),
                              BuildTextBox(
                                hintText: _sizeHint,
                                controller: _sizeController,
                                showPassword: false,
                                keyboardType: TextInputType.number,
                              ),
                            ],

                            Padding(
                              padding: const EdgeInsets.only(
                                top: 20.0,
                                bottom: 8.0,
                              ),
                              child: Text(
                                _colorLabel,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Bricolage-Grotesque-SemiBold',
                                  color: MoldifyColors.primaryColor,
                                ),
                              ),
                            ),
                            BuildTextBox(
                              hintText: _colorHint,
                              controller: _colorController,
                              showPassword: false,
                              readOnly: true,
                              onTap: _pickColor,
                              rightIcon: FontAwesomeIcons.angleRight,
                              rightIconColor: MoldifyColors.accentColor,
                            ),

                            Padding(
                              padding: const EdgeInsets.only(
                                top: 20.0,
                                bottom: 8.0,
                              ),
                              child: Text(
                                _textureLabel,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Bricolage-Grotesque-SemiBold',
                                  color: MoldifyColors.primaryColor,
                                ),
                              ),
                            ),
                            BuildTextBox(
                              hintText: _textureHint,
                              controller: _textureController,
                              showPassword: false,
                              readOnly: true,
                              onTap: _pickTexture,
                              rightIcon: FontAwesomeIcons.angleRight,
                              rightIconColor: MoldifyColors.accentColor,
                            ),

                            if (_isInitialMacroscopicMode) ...[
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 20.0,
                                  bottom: 8.0,
                                ),
                                child: const Text(
                                  'Select Symptoms',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Bricolage-Grotesque-SemiBold',
                                    color: MoldifyColors.primaryColor,
                                  ),
                                ),
                              ),
                              BuildTextBox(
                                hintText: 'Select symptom(s)',
                                controller: _symptomsController,
                                showPassword: false,
                                isMultiline: true,
                                readOnly: true,
                                onTap: _pickSymptoms,
                                rightIcon: FontAwesomeIcons.angleRight,
                                rightIconColor: MoldifyColors.accentColor,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 20.0,
                                  bottom: 8.0,
                                ),
                                child: const Text(
                                  'Select Signs',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Bricolage-Grotesque-SemiBold',
                                    color: MoldifyColors.primaryColor,
                                  ),
                                ),
                              ),
                              BuildTextBox(
                                hintText: 'Select sign(s)',
                                controller: _signsController,
                                showPassword: false,
                                isMultiline: true,
                                readOnly: true,
                                onTap: _pickSigns,
                                rightIcon: FontAwesomeIcons.angleRight,
                                rightIconColor: MoldifyColors.accentColor,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 20.0,
                                  bottom: 8.0,
                                ),
                                child: const Text(
                                  'Select Characteristics',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Bricolage-Grotesque-SemiBold',
                                    color: MoldifyColors.primaryColor,
                                  ),
                                ),
                              ),
                              BuildTextBox(
                                hintText: 'Select characteristic(s)',
                                controller: _characteristicsController,
                                showPassword: false,
                                isMultiline: true,
                                readOnly: true,
                                onTap: _pickCharacteristics,
                                rightIcon: FontAwesomeIcons.angleRight,
                                rightIconColor: MoldifyColors.accentColor,
                              ),
                            ] else ...[
                              /// Additional Notes Label
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 20.0,
                                  bottom: 8.0,
                                ),
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
                                hintText:
                                    'Enter additional details about the log here...',
                                controller: _logNotesController,
                                isMultiline: true,
                                showPassword: false,
                              ),
                            ],

                            /// Save Log Button
                            Padding(
                              padding: const EdgeInsets.only(top: 70.0),
                              child: BuildButton(
                                onPressed: _isSaving
                                    ? () {}
                                    : () {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return BuildConfirmationDialog(
                                              title: 'Save Log?',
                                              subtitle:
                                                  'Are you sure you want to save log?',
                                              onConfirm: () {
                                                Navigator.of(context).pop();
                                                _saveCultivationLog();
                                              },
                                              onCancel: () {
                                                Navigator.of(context).pop();
                                              },
                                              cancelText: 'No',
                                              confirmText: 'Yes',
                                            );
                                          },
                                        );
                                      },
                                buttonText: 'Save Log',
                                backgroundColor: MoldifyColors.primaryColor,
                                textColor: MoldifyColors.backgroundColor,
                                buttonHeight: 45,
                                buttonWidth: MediaQuery.of(context).size.width,
                                buttonRadius: 10,
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
          // Full-screen loading overlay
          if (_isSaving)
            Positioned.fill(
              child: const AppLoadingOverlay(
                message: 'Saving log...',
                barrierColor: MoldifyColors.backgroundColor,
              ),
            ),
        ],
      ),
    );
  }
}
