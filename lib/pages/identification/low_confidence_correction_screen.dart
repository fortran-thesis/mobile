import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/core/constants/scan_constants.dart';
import 'package:moldify/core/features/camera/services/camera_service.dart';
import 'package:moldify/core/features/mold/service/mold_detail_adapter.dart';
import 'package:moldify/core/utils/logger.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/textboxes/textboxes.dart';
import 'package:moldify/providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// Shown automatically when the AI scan result confidence is below
/// [ScanConstants.lowConfidenceThreshold].
///
/// The user must select the correct genus from the supported 6 (dropdown),
/// or enter a different genus manually (text field). On confirmation the app
/// navigates to [MoldResultScreen] with the corrected data already loaded.
class LowConfidenceCorrectionScreen extends StatefulWidget {
  final String croppedImagePath;
  final Map<String, dynamic> modelResult;
  final String? sourceFlow;
  final String? scanModality;
  final String? sourceTab;
  final String? caseId;

  const LowConfidenceCorrectionScreen({
    super.key,
    required this.croppedImagePath,
    required this.modelResult,
    this.sourceFlow,
    this.scanModality,
    this.sourceTab,
    this.caseId,
  });

  @override
  State<LowConfidenceCorrectionScreen> createState() =>
      _LowConfidenceCorrectionScreenState();
}

class _LowConfidenceCorrectionScreenState
    extends State<LowConfidenceCorrectionScreen> {
  // --- Fallback genus list (identical to MoldResultScreen) ---
  static const Map<String, String> _fallbackSupportedCorrectionMap = {
    'alternaria': 'Alternaria_spp',
    'aspergillus flavi': 'Aspergillus_section_Flavi',
    'aspergillus section flavi': 'Aspergillus_section_Flavi',
    'aspergillus section nigri': 'Aspergillus_section_Nigri',
    'fusarium': 'Fusarium_spp',
    'penicillium': 'Penicillium_spp',
    'rhizopus': 'Rhizopus_spp',
  };

  static const List<String> _fallbackPresetGenusOptions = [
    'Alternaria',
    'Aspergillus Flavi',
    'Aspergillus Section Nigri',
    'Fusarium',
    'Penicillium',
    'Rhizopus',
  ];

  Map<String, String> _supportedCorrectionMap =
      Map<String, String>.from(_fallbackSupportedCorrectionMap);
  List<String> _presetGenusOptions =
      List<String>.from(_fallbackPresetGenusOptions);

  String? _selectedDropdownGenus;
  final TextEditingController _customGenusController = TextEditingController();
  bool _isConfirming = false;

  // Derived display values from modelResult
  late String _confidenceDisplay;
  late String _aiPredictedGenus;

  @override
  void initState() {
    super.initState();

    final prob = widget.modelResult['probability'];
    double percent = 0.0;
    if (prob is String) {
      percent = double.tryParse(prob) ?? 0.0;
    } else if (prob is num) {
      percent = prob.toDouble();
    }
    _confidenceDisplay = (percent * 100).toStringAsFixed(1);

    final predictedClass =
        widget.modelResult['predicted_class']?.toString() ?? '';
    _aiPredictedGenus = predictedClass.contains('_')
        ? predictedClass.split('_')[0]
        : predictedClass;

    _customGenusController.addListener(_onTextChanged);
    _loadSupportedCorrectionOptions();
  }

  @override
  void dispose() {
    _customGenusController.removeListener(_onTextChanged);
    _customGenusController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    // When the user types in the custom field, clear the dropdown selection
    if (_customGenusController.text.isNotEmpty && _selectedDropdownGenus != null) {
      setState(() {
        _selectedDropdownGenus = null;
      });
    } else {
      setState(() {}); // rebuild to re-evaluate button enabled state
    }
  }

  String _normalizeCorrectionKey(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<void> _loadSupportedCorrectionOptions() async {
    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final cameraService = CameraService();
      final response = await cameraService.getSupportedCorrectionGenera(
        sessionCookie: authProvider.cookie,
      );

      if (response['error'] != null) return;

      final rawGenera = response['genera'];
      if (rawGenera is! List) return;

      final nextMap = <String, String>{};
      final nextOptions = <String>[];

      for (final item in rawGenera) {
        if (item is! Map) continue;
        final data = Map<String, dynamic>.from(item);
        var displayName = data['display_name']?.toString().trim() ?? '';
        final predictedClassName =
            data['predicted_class_name']?.toString().trim() ?? '';
        final normalizedKeyRaw =
            data['normalized_key']?.toString().trim() ?? '';

        if (displayName.isEmpty || predictedClassName.isEmpty) continue;

        final normalizedKey = normalizedKeyRaw.isNotEmpty
            ? _normalizeCorrectionKey(normalizedKeyRaw)
            : _normalizeCorrectionKey(displayName);

        if (normalizedKey == 'aspergillus section flavi' ||
            normalizedKey == 'aspergillus flavi') {
          displayName = 'Aspergillus Flavi';
        }

        nextMap[normalizedKey] = predictedClassName;
        if (normalizedKey == 'aspergillus section flavi') {
          nextMap['aspergillus flavi'] = predictedClassName;
        }
        if (!nextOptions.contains(displayName)) nextOptions.add(displayName);
      }

      if (!mounted || nextMap.isEmpty) return;
      setState(() {
        _supportedCorrectionMap = nextMap;
        if (nextOptions.isNotEmpty) _presetGenusOptions = nextOptions;
      });
    } catch (error, stackTrace) {
      AppLogger.e(
        'LowConfidenceCorrection: Failed to load supported genera',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  bool get _canConfirm {
    final dropdownSelected =
        _selectedDropdownGenus != null && _selectedDropdownGenus!.isNotEmpty;
    final customEntered = _customGenusController.text.trim().isNotEmpty;
    return (dropdownSelected || customEntered) && !_isConfirming;
  }

  String get _effectiveGenus {
    if (_selectedDropdownGenus != null && _selectedDropdownGenus!.isNotEmpty) {
      return _selectedDropdownGenus!;
    }
    return _customGenusController.text.trim();
  }

  Future<void> _onConfirm() async {
    final genus = _effectiveGenus;
    if (genus.isEmpty) return;

    setState(() => _isConfirming = true);

    final normalized = _normalizeCorrectionKey(genus);
    final predictedClassName = _supportedCorrectionMap[normalized];

    // Build the updated modelResult with the corrected class name
    final correctedModelResult = Map<String, dynamic>.from(widget.modelResult);
    if (predictedClassName != null) {
      correctedModelResult['predicted_class'] = predictedClassName;
    }

    Map<String, dynamic> moldDetails = {'error': 'not_found'};

    if (predictedClassName != null) {
      try {
        final authProvider =
            Provider.of<AppAuthProvider>(context, listen: false);
        final cameraService = CameraService();
        final fetched = await cameraService.getMoldDetails(
          moldName: predictedClassName,
          sessionCookie: authProvider.cookie,
        );
        final resolved = MoldDetailAdapter.unwrapPayload(fetched);
        if (resolved.isNotEmpty && !resolved.containsKey('error')) {
          moldDetails = fetched;
        }
      } catch (error, stackTrace) {
        AppLogger.e(
          'LowConfidenceCorrection: Failed to fetch mold details',
          error: error,
          stackTrace: stackTrace,
        );
      }
    } else {
      // Unknown genus — show "not in database" state in MoldResultScreen
      AppLogger.d(
        'LowConfidenceCorrection: Genus "$genus" not in supported map — flagging as not found',
      );
    }

    if (!mounted) return;

    setState(() => _isConfirming = false);

    await Navigator.of(context).pushReplacementNamed(
      RouteNames.moldResult,
      arguments: {
        'croppedImagePath': widget.croppedImagePath,
        'modelResult': correctedModelResult,
        'moldDetails': moldDetails,
        'sourceFlow': widget.sourceFlow,
        'scanModality': widget.scanModality,
        'sourceTab': widget.sourceTab,
        'caseId': widget.caseId,
        'correctedGenus': genus,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(title: 'Low Confidence Result'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Scan image ---
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(widget.croppedImagePath),
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // --- Warning banner ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: MoldifyColors.MoldifyLightYellow.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: MoldifyColors.accentColor,
                  width: 1.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    FontAwesomeIcons.triangleExclamation,
                    color: MoldifyColors.accentColor,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Confidence too low ($_confidenceDisplay%) — '
                      'please verify the mold genus before proceeding.',
                      style: const TextStyle(
                        fontFamily: 'Bricolage-Grotesque-SemiBold',
                        fontSize: 13,
                        color: MoldifyColors.MoldifyBlack,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // --- AI prediction (informational only) ---
            if (_aiPredictedGenus.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: MoldifyColors.taupe,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Model predicted: $_aiPredictedGenus (not confirmed)',
                  style: TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    fontSize: 13,
                    color: MoldifyColors.MoldifyGrey,
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // --- Section label ---
            const Text(
              'Select the correct mold genus',
              style: TextStyle(
                fontFamily: 'Bricolage-Grotesque-SemiBold',
                fontSize: 15,
                color: MoldifyColors.primaryColor,
              ),
            ),
            const SizedBox(height: 10),

            // --- Dropdown: supported 6 genera ---
            DropdownButtonFormField<String>(
              value: _selectedDropdownGenus,
              decoration: InputDecoration(
                labelText: 'Select from supported genera',
                labelStyle: const TextStyle(
                  fontFamily: 'Bricolage-Grotesque-Regular',
                  color: MoldifyColors.MoldifyGrey,
                  fontSize: 13,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: MoldifyColors.primaryColor,
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: MoldifyColors.taupe,
              ),
              style: const TextStyle(
                fontFamily: 'Bricolage-Grotesque-Regular',
                fontSize: 14,
                color: MoldifyColors.MoldifyBlack,
              ),
              items: _presetGenusOptions
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null || value.trim().isEmpty) return;
                setState(() {
                  _selectedDropdownGenus = value;
                  _customGenusController.clear();
                });
              },
            ),
            const SizedBox(height: 16),

            // --- Divider with "or" label ---
            Row(
              children: [
                const Expanded(child: Divider(thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or enter manually',
                    style: TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Regular',
                      fontSize: 12,
                      color: MoldifyColors.MoldifyGrey,
                    ),
                  ),
                ),
                const Expanded(child: Divider(thickness: 1)),
              ],
            ),
            const SizedBox(height: 12),

            // --- Custom genus text field ---
            BuildTextBox(
              hintText: 'Enter genus name (if not in list)',
              controller: _customGenusController,
              showPassword: false,
            ),

            const SizedBox(height: 6),
            Text(
              'If the genus is not in the supported list, '
              'the system will flag it as not yet in the database.',
              style: TextStyle(
                fontFamily: 'Bricolage-Grotesque-Regular',
                fontSize: 11,
                color: MoldifyColors.MoldifyGrey,
              ),
            ),

            const SizedBox(height: 32),

            // --- Confirm button ---
            _isConfirming
                ? const Center(child: CircularProgressIndicator())
                : BuildButton(
                    buttonText: 'Confirm Genus',
                    onPressed: _canConfirm ? _onConfirm : () {},
                    backgroundColor: _canConfirm
                        ? MoldifyColors.primaryColor
                        : MoldifyColors.MoldifyGrey,
                    textColor: MoldifyColors.backgroundColor,
                    buttonHeight: 48,
                    buttonWidth: double.infinity,
                    buttonRadius: 10,
                  ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
