import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/core/features/camera/services/camera_service.dart';
import 'package:moldify/core/features/mold/service/mold_detail_adapter.dart';
import 'package:moldify/core/features/mold/service/mold_service.dart';
import 'package:moldify/core/utils/logger.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/textboxes/dropdwon.dart';
import 'package:moldify/providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// Shown automatically when the AI scan result confidence is below
/// [ScanConstants.lowConfidenceThreshold].
///
/// The user must select the correct genus from the full mold catalog (or add a
/// new one). On confirmation the app navigates to [MoldResultScreen] with the
/// corrected data already loaded.
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
  final Map<String, MoldCatalogEntry> _moldCatalogByName = {};
  final Map<String, MoldCatalogEntry> _moldCatalogById = {};
  final List<String> _genusOptions = [];
  int _dropdownKey = 0;
  bool _isLoadingMoldOptions = false;
  String? _selectedGenus;
  String? _moldOptionsError;
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

    _loadMoldOptions();
  }

  Future<void> _loadMoldOptions() async {
    setState(() {
      _isLoadingMoldOptions = true;
      _moldOptionsError = null;
    });

    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final service = MoldService();
      final catalog = await service.fetchAllMoldCatalog(
        sessionCookie: authProvider.cookie,
      );

      if (!mounted) return;

      setState(() {
        _moldCatalogByName.clear();
        _moldCatalogById.clear();

        for (final mold in catalog) {
          if (mold.name.trim().isEmpty) continue;
          final key = mold.name.toLowerCase();
          _moldCatalogByName[key] = mold;
          if (mold.id.trim().isNotEmpty) {
            _moldCatalogById[mold.id.trim()] = mold;
          }
        }

        _genusOptions
          ..clear()
          ..addAll(
            _moldCatalogByName.values.map((e) => e.name).toList()
              ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())),
          )
          ..add('+ Add New Mold');

        if (_selectedGenus != null && !_genusOptions.contains(_selectedGenus)) {
          _selectedGenus = null;
        }

        if (_genusOptions.isEmpty) {
          _moldOptionsError =
              'No mold options available. Seed mold data first.';
        }

        _isLoadingMoldOptions = false;
      });
    } catch (e) {
      if (!mounted) return;
      final errorText = e.toString().toLowerCase();
      setState(() {
        _isLoadingMoldOptions = false;
        _moldOptionsError = errorText.contains('http 404')
            ? 'No mold options found. Seed mold records first.'
            : 'Unable to load mold options right now.';
      });
    }
  }

  Future<void> _navigateToCreateMold() async {
    setState(() => _dropdownKey++);

    final result = await Navigator.of(context).pushNamed(RouteNames.createMold);
    if (result is! MoldCatalogEntry || !mounted) return;

    setState(() {
      final entry = result;
      final key = entry.name.toLowerCase();
      _moldCatalogByName[key] = entry;
      if (entry.id.trim().isNotEmpty) _moldCatalogById[entry.id.trim()] = entry;

      _genusOptions
        ..clear()
        ..addAll(
          _moldCatalogByName.values.map((e) => e.name).toList()
            ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())),
        )
        ..add('+ Add New Mold');

      _selectedGenus = entry.name;
      _dropdownKey++;
    });
  }

  void _handleMoldSelectionChanged(String? selectedName) {
    if (selectedName == '+ Add New Mold') {
      _navigateToCreateMold();
      return;
    }
    setState(() {
      _selectedGenus = selectedName;
    });
  }

  bool get _canConfirm =>
      _selectedGenus != null &&
      _selectedGenus!.trim().isNotEmpty &&
      !_isConfirming;

  Future<void> _onConfirm() async {
    final genus = _selectedGenus?.trim() ?? '';
    if (genus.isEmpty) return;

    setState(() => _isConfirming = true);

    final entry = _moldCatalogByName[genus.toLowerCase()];
    if (entry == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selected mold not found in catalog. Please retry.'),
          ),
        );
      }
      setState(() => _isConfirming = false);
      return;
    }

    final correctedModelResult = Map<String, dynamic>.from(widget.modelResult);
    correctedModelResult['predicted_class'] = entry.name;
    correctedModelResult['moldId'] = entry.id;
    correctedModelResult['moldName'] = entry.name;

    Map<String, dynamic> moldDetails = {'error': 'not_found'};

    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final cameraService = CameraService();
      final fetched = await cameraService.getMoldDetailsById(
        moldId: entry.id,
        sessionCookie: authProvider.cookie,
      );
      final resolved = MoldDetailAdapter.unwrapPayload(fetched);
      if (resolved.isNotEmpty && !resolved.containsKey('error')) {
        moldDetails = fetched;
      }
    } catch (error, stackTrace) {
      AppLogger.e(
        'LowConfidenceCorrection: Failed to fetch mold details by id',
        error: error,
        stackTrace: stackTrace,
      );
    }

    if (!mounted) return;

    setState(() => _isConfirming = false);

    // Push (instead of replacement) so callers awaiting this route only resume
    // after the result screen is finished; then forward the result upstream.
    final result = await Navigator.of(context).pushNamed(
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

    if (!mounted) return;
    Navigator.of(context).pop(result);
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

            // --- Dropdown: full mold catalog ---
            if (_isLoadingMoldOptions)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: LinearProgressIndicator(
                  minHeight: 3,
                  color: MoldifyColors.primaryColor,
                  backgroundColor: MoldifyColors.taupe,
                ),
              )
            else if (_genusOptions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: MoldifyColors.taupe,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _moldOptionsError ?? 'No mold options available.',
                        style: const TextStyle(
                          fontFamily: 'Bricolage-Grotesque-Regular',
                          fontSize: 13,
                          color: MoldifyColors.MoldifyGrey,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadMoldOptions,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else
              BuildDropdown(
                key: ValueKey(_dropdownKey),
                hintText: 'Select Genus',
                items: _genusOptions,
                initialValue: _selectedGenus,
                onChanged: _handleMoldSelectionChanged,
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
