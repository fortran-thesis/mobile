import 'dart:io';

import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/textboxes/textboxes.dart';
import 'package:moldify/pages/misc/overlays/modals/chip_selection_modal.dart';

import '../misc/appbar/primary_app_bar.dart';
import '../misc/buttons/primary_button.dart';
import '../misc/colors.dart';
import '../misc/overlays/modals/confirmation_dialog.dart';

class AddLogScreen extends StatefulWidget {
  // 1. Add parameters for imagePath and the new sourceTab
  final String imagePath;
  final String sourceTab;
  final String caseId; // Add caseId for API call
  final bool includeSize;

  // 2. Update the constructor to require them
  const AddLogScreen({
    super.key,
    required this.imagePath,
    required this.sourceTab,
    required this.caseId,
    this.includeSize = true,
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
  final TextEditingController _characteristicsController = TextEditingController();
  bool _isSaving = false;

  final List<String> _selectedSymptoms = [];
  final List<String> _selectedCharacteristics = [];

  static const List<String> _symptomOptions = [
    'Leaf spots',
    'Wilting',
    'Yellowing',
    'Soft rot',
    'Stem lesions',
    'Necrosis',
  ];

  static const List<String> _characteristicOptions = [
    'Cottony',
    'Powdery',
    'Slimy',
    'Fuzzy',
    'Water-soaked',
    'Rapid spreading',
  ];

  late final String _sizeLabel;
  late final String _sizeHint;
  late final String _colorLabel;
  late final String _colorHint;
  late final String _textureLabel;
  late final String _textureHint;

  // Evidence-style mode (color/texture + symptoms + characteristics)
  // should apply to both in-vivo and in-vitro when includeSize is disabled.
  bool get _isInitialMacroscopicMode => !widget.includeSize;

  @override
  void initState() {
    super.initState();

    // Keep role-specific labels while making the values user-editable.
    if (widget.sourceTab == 'in-vivo') {
      _sizeLabel = 'Lesion Size (mm)';
      _sizeHint = 'Enter lesion size in mm';
      _colorLabel = 'Lesion Color';
      _colorHint = 'Enter lesion color';
      _textureLabel = 'Lesion Texture';
      _textureHint = 'Enter lesion texture';

      // Dummy defaults for now (no backend fetch).
      _sizeController.text = '4';
      _colorController.text = 'Brown';
      _textureController.text = 'Rough';
    } else {
      _sizeLabel = 'Colony Diameter (mm)';
      _sizeHint = 'Enter colony diameter in mm';
      _colorLabel = 'Colony Color';
      _colorHint = 'Enter colony color';
      _textureLabel = 'Colony Texture';
      _textureHint = 'Enter colony texture';

      // Dummy defaults for now (no backend fetch).
      _sizeController.text = '4';
      _colorController.text = 'Black';
      _textureController.text = 'Powdery';
    }
  }

  @override
  void dispose() {
    _sizeController.dispose();
    _colorController.dispose();
    _textureController.dispose();
    _logNotesController.dispose();
    _symptomsController.dispose();
    _characteristicsController.dispose();
    super.dispose();
  }

  Future<void> _pickSymptoms() async {
    final selected = await showMultiChipSelectionModal(
      context: context,
      title: 'Select Symptoms',
      options: _symptomOptions,
      currentSelections: _selectedSymptoms,
      customInputHint: 'Add custom symptom(s), comma-separated',
      othersLabel: 'Others/Iba pa',
      isMultiLine: true,
    );

    if (selected == null || selected.isEmpty) return;
    setState(() {
      _selectedSymptoms
        ..clear()
        ..addAll(selected);
      _symptomsController.text = selected.join(', ');
    });
  }

  Future<void> _pickCharacteristics() async {
    final selected = await showMultiChipSelectionModal(
      context: context,
      title: 'Select Characteristics',
      options: _characteristicOptions,
      currentSelections: _selectedCharacteristics,
      customInputHint: 'Add custom characteristic(s), comma-separated',
      othersLabel: 'Others/Iba pa',
      isMultiLine: true,
    );

    if (selected == null || selected.isEmpty) return;
    setState(() {
      _selectedCharacteristics
        ..clear()
        ..addAll(selected);
      _characteristicsController.text = selected.join(', ');
    });
  }

  Future<void> _saveCultivationLog() async {
    try {
      setState(() => _isSaving = true);

      if (!mounted) return;
      setState(() => _isSaving = false);

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
        result['characteristics'] = List<String>.from(_selectedCharacteristics);
        result['symptomsDisplay'] = _symptomsController.text.trim();
        result['characteristicsDisplay'] = _characteristicsController.text.trim();
      }

      Navigator.of(context).pop(result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to prepare log: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String dateTime = 'October 2, 2025 • 09:14 PM';

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
                            const SizedBox.shrink(),
                          ],
                        ),

                        if (widget.includeSize) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
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
                          padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
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
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
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
                        ),

                        if (_isInitialMacroscopicMode) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
                            child: const Text(
                              'Symptoms',
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
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
                            child: const Text(
                              'Characteristics',
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
                          ),
                        ] else ...[
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
                        ],

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