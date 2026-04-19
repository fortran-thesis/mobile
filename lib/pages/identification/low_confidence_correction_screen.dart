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
import 'package:moldify/pages/misc/overlays/loading_ui.dart';
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

    final correctedModelResult = <String, dynamic>{
      'predicted_class': entry.name,
      'moldId': entry.id,
      'mold_id': entry.id,
      'moldName': entry.name,
      // Keep only prediction metadata required downstream so stale sections
      // from a previous mold do not leak into the corrected flow.
      if (widget.modelResult.containsKey('probability'))
        'probability': widget.modelResult['probability'],
      if (widget.modelResult.containsKey('all_probabilities'))
        'all_probabilities': widget.modelResult['all_probabilities'],
      if (widget.modelResult.containsKey('model_source'))
        'model_source': widget.modelResult['model_source'],
      if (widget.modelResult.containsKey('used_fusion'))
        'used_fusion': widget.modelResult['used_fusion'],
      if (widget.modelResult.containsKey('used_ann'))
        'used_ann': widget.modelResult['used_ann'],
    };

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
    return Stack(
      children: [
        Scaffold(
          backgroundColor: MoldifyColors.backgroundColor,
          appBar: PrimaryAppBar(title: 'Low Confidence Result'),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Feature Image: Refined shadow and border ---
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.file(
                        File(widget.croppedImagePath),
                        width: double.infinity,
                        height: 280,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // --- Info Section: Translucent Material Design ---
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    // Using a very faint tint of the accent color instead of flat white
                    color: MoldifyColors.accentColor.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: MoldifyColors.accentColor.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            FontAwesomeIcons.circleExclamation,
                            color: MoldifyColors.accentColor,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'VERIFICATION REQUIRED',
                            style: TextStyle(
                              fontFamily: 'Bricolage-Grotesque-Bold',
                              fontSize: 13,
                              letterSpacing: 1.2,
                              color: MoldifyColors.accentColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Our AI is only $_confidenceDisplay% confident in this result. Please verify the genus manually to ensure safety.',
                        style: TextStyle(
                          fontFamily: 'Bricolage-Grotesque-Regular',
                          fontSize: 15,
                          height: 1.5,
                          color: MoldifyColors.MoldifyBlack.withOpacity(0.7),
                        ),
                      ),

                      // AI Prediction "Readout" - Styled like a diagnostic tag
                      if (_aiPredictedGenus.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: MoldifyColors.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: MoldifyColors.MoldifyGrey.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                FontAwesomeIcons.bacterium,
                                size: 14,
                                color: MoldifyColors.primaryColor,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Identified:',
                                style: TextStyle(
                                  fontFamily: 'Bricolage-Grotesque-SemiBold',
                                  fontSize: 14,
                                  color: MoldifyColors.MoldifyGrey,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _aiPredictedGenus,
                                style: const TextStyle(
                                  fontFamily: 'Bricolage-Grotesque-Bold',
                                  fontSize: 16,
                                  color: MoldifyColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // --- Action Header: Clean and Minimal ---
                Row(
                  children: [
                    const SizedBox(width: 4),
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: MoldifyColors.primaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Select Correct Genus',
                      style: TextStyle(
                        fontFamily: 'Bricolage-Grotesque-SemiBold',
                        fontSize: 18,
                        letterSpacing: -0.3,
                        color: MoldifyColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // --- Dropdown Section ---
                if (_isLoadingMoldOptions)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: AppLoadingSpinner(size: 32),
                    ),
                  )
                else if (_genusOptions.isEmpty)
                  _buildErrorState()
                else
                  // Wrapped in a subtle shadow container for depth
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: BuildDropdown(
                      key: ValueKey(_dropdownKey),
                      hintText: 'Search the mold catalog...',
                      items: _genusOptions,
                      initialValue: _selectedGenus,
                      onChanged: _handleMoldSelectionChanged,
                    ),
                  ),

                const SizedBox(height: 48),

                // --- Confirmation Action: Elevated Modern Button ---
                BuildButton(
                  buttonText: 'Confirm Identification',
                  onPressed: _canConfirm ? _onConfirm : () {},
                  backgroundColor: _canConfirm
                      ? MoldifyColors.primaryColor
                      : MoldifyColors.MoldifyGrey.withOpacity(0.2),
                  textColor: _canConfirm
                      ? MoldifyColors.backgroundColor
                      : MoldifyColors.MoldifyGrey,
                  buttonHeight: 62,
                  buttonWidth: double.infinity,
                  buttonRadius: 18,
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
        // Full-page loading overlay when confirming
        if (_isConfirming)
          const AppLoadingOverlay(
            message: 'Processing...',
            barrierColor: MoldifyColors.backgroundColor,
          ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MoldifyColors.taupe.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            size: 20,
            color: MoldifyColors.MoldifyGrey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _moldOptionsError ?? 'No options found.',
              style: TextStyle(
                fontFamily: 'Bricolage-Grotesque-Regular',
                fontSize: 13,
                color: MoldifyColors.MoldifyGrey,
              ),
            ),
          ),
          TextButton(onPressed: _loadMoldOptions, child: const Text('Retry')),
        ],
      ),
    );
  }
}
