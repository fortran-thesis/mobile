import 'package:auto_size_text/auto_size_text.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/identification/mold_result_content/revised_results_content.dart';
import 'package:moldify/pages/identification/mold_result_content/result_action_section.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/tiles/control_management_tile.dart';
import '../misc/appbar/primary_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:moldify/core/features/camera/services/camera_service.dart';
import 'package:moldify/core/constants/scan_constants.dart';
import 'package:moldify/core/features/mold/service/mold_detail_adapter.dart';
import 'package:moldify/core/features/flag_report/services/flag_report_service.dart';
import 'package:moldify/providers/auth_provider.dart';

import '../misc/tiles/bottom_sheet.dart';
import '../misc/tiles/bottom_sheet_contents/correction_content.dart';
import 'package:moldify/core/utils/logger.dart';

class MoldResultScreen extends StatefulWidget {
  final String croppedImagePath;
  final Map<String, dynamic>? modelResult;
  final Map<String, dynamic>? moldDetails;
  final String? sourceFlow;
  final String? scanModality;
  final String? sourceTab;
  final String? caseId;
  /// When non-null the result was pre-corrected by [LowConfidenceCorrectionScreen].
  /// The genus is pre-populated and the flag button is hidden.
  final String? correctedGenus;

  const MoldResultScreen({
    super.key,
    required this.croppedImagePath,
    this.modelResult,
    this.moldDetails,
    this.sourceFlow,
    this.scanModality,
    this.sourceTab,
    this.caseId,
    this.correctedGenus,
  });

  @override
  State<MoldResultScreen> createState() => _MoldResultScreenState();
}

class _MoldResultScreenState extends State<MoldResultScreen> {
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

  Map<String, String> _supportedCorrectionMap = Map<String, String>.from(
    _fallbackSupportedCorrectionMap,
  );
  List<String> _presetGenusOptions = List<String>.from(
    _fallbackPresetGenusOptions,
  );

  late String confidenceLevel;
  late String moldGenus;
  bool _isSavingResult = false;
  bool _isMoldNotFound = false; // Flag to detect when mold not in database
  String? _correctedGenus;
  String? _correctedPredictedClassName;
  String? _correctedAtIso;
  late String healthContent;
  late String plantThreatContent;
  late String fullDescription;

  String _readMoldDetailField(
    Map<String, dynamic>? details,
    String key,
    String fallback,
  ) {
    return MoldDetailAdapter.readField(details, key, fallback: fallback);
  }

  String _readMoldDetailSymptoms(Map<String, dynamic>? details) {
    return _readMoldDetailField(
      details,
      'symptoms_and_signs',
      'This mold may present as powdery, cottony, or discolored growth with visible tissue damage depending on host and conditions.',
    );
  }

  String _readMoldDetailSpread(Map<String, dynamic>? details) {
    return _readMoldDetailField(
      details,
      'disease_cycle_spread_impact',
      'Spores spread through air, tools, water splash, and contaminated surfaces, especially in moist or poorly ventilated environments.',
    );
  }

  String _readMoldDetailImpact(Map<String, dynamic>? details) {
    final spread = _readMoldDetailField(
      details,
      'disease_cycle_spread_impact',
      '',
    );
    if (spread.isNotEmpty) return spread;
    return 'Impact varies widely and can include reduced crop yields and human health risks.';
  }

  String _readMoldDetailPrevention(Map<String, dynamic>? details) {
    return _readMoldDetailField(
      details,
      'prevention_summary',
      'Use integrated management controls and monitor treatment response regularly to reduce recurrence.',
    );
  }

  String _buildTreatmentsContent(Map<String, dynamic>? details) {
    final prevention = MoldDetailAdapter.extractPrevention(details);
    if (prevention.isEmpty) return _fallbackTreatmentsContent;

    String read(List<String> keys) {
      for (final key in keys) {
        final text = (prevention[key] ?? '').toString().trim();
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    final segments = <String>[];
    void push(String type, String title, List<String> keys) {
      final content = read(keys);
      if (content.isEmpty) return;
      segments.add('$type::$title::$content');
    }

    push('MECHANICAL', 'Mechanical Control', [
      'mechanicalControl',
      'mechanical_control',
    ]);
    push('BIOLOGICAL', 'Biological Control', [
      'biologicalControl',
      'biological_control',
    ]);
    push('CHEMICAL', 'Chemical Control', [
      'chemicalControl',
      'chemical_control',
    ]);
    push('PHYSICAL', 'Physical Control', [
      'physicalControl',
      'physical_control',
    ]);
    push('CULTURAL', 'Cultural Control', [
      'culturalControl',
      'cultural_control',
    ]);

    return segments.isNotEmpty
        ? segments.join('|')
        : _fallbackTreatmentsContent;
  }

  final String defaultDescription =
      "Aspergillus is a genus of common molds that can be found in various environments, "
      "both indoors and outdoors. While many species of Aspergillus are harmless, some can cause a "
      "Aspergillus is a genus of common molds that can be found in various environments, "
      "both indoors and outdoors. While many species of Aspergillus are harmless, some can cause a "
      "range of health issues in humans, particularly those with weakened immune systems or pre-existing lung "
      "conditions. These issues can range from allergic reactions and respiratory infections to more severe, "
      "systemic infections. Aspergillus molds are characterized by their distinct, often fluffy or powdery, "
      "appearance and can vary in color, including green, yellow, black, or brown. They reproduce through "
      "airborne spores, which can be easily inhaled. In homes, Aspergillus is often found in damp or "
      "water-damaged areas, such as basements, bathrooms, and around leaky pipes. It can grow on a "
      "variety of materials, including walls, insulation, and stored food items. Proper ventilation "
      "and moisture control are key to preventing its growth. Some species, like Aspergillus niger, "
      "are also used commercially for the production of citric acid and other enzymes, highlighting "
      "the genus's dual role as both a potential pathogen and a useful industrial microorganism.";

  // Prevention tactics using structured format (pipe-delimited)
  final String _fallbackTreatmentsContent =
      'MECHANICAL::Mechanical Control::Remove infected plant debris promptly using sterilized tools. Prune affected areas and ensure proper disposal of contaminated materials in sealed bags. Clean and dry surfaces thoroughly to prevent mold spread.|'
      'BIOLOGICAL::Biological Control::Apply beneficial microorganisms that compete with mold growth. Use natural antifungal agents like vinegar, hydrogen peroxide, or neem oil for surface treatment. UV light treatment can also help control surface mold.|'
      'CHEMICAL::Chemical Control::Recommended fungicides: Chlorothalonil, Mancozeb, and Copper-based fungicides. Rotate products with different active ingredients to prevent resistance. Always follow label recommendations for dosage and application frequency.|'
      'PHYSICAL::Physical Control::Improve ventilation in affected areas to reduce moisture buildup. Use dehumidifiers to maintain optimal humidity levels. Ensure proper air circulation and maintain appropriate temperature control.|'
      'CULTURAL::Cultural Control::Implement proper sanitation practices and field hygiene. Rotate crops annually to prevent soil-borne diseases. Remove and destroy contaminated materials to prevent recontamination. Monitor and record treatments for effectiveness.';

  late final Map<String, String> _recommendationSections;
  late final List<Map<String, String>> _managementControls;

  @override
  void initState() {
    super.initState();
    AppLogger.d('MoldResult: initState called');
    AppLogger.d('MoldResult: modelResult = ${widget.modelResult}');
    AppLogger.d('MoldResult: moldDetails = ${widget.moldDetails}');

    // Initialize from modelResult argument
    // Convert probability from decimal to percentage string
    final prob = widget.modelResult?['probability'];
    if (prob != null) {
      double percent = 0.0;
      if (prob is String) {
        percent = double.tryParse(prob) ?? 0.0;
      } else if (prob is num) {
        percent = prob.toDouble();
      }
      confidenceLevel = (percent * 100).toStringAsFixed(2);
      AppLogger.d('MoldResult: Confidence level calculated: $confidenceLevel%');
    } else {
      confidenceLevel = '';
      AppLogger.d('MoldResult: No probability found in modelResult');
    }
    // Extract only the genus from 'genus_spp' format
    final predictedClass =
        widget.modelResult?['predicted_class']?.toString() ?? '';
    moldGenus = predictedClass.contains('_')
        ? predictedClass.split('_')[0]
        : predictedClass;
    AppLogger.d(
      'MoldResult: Predicted class: $predictedClass, Genus: $moldGenus',
    );

    // Detect if mold was found in database
    final resolvedDetails = MoldDetailAdapter.unwrapPayload(widget.moldDetails);
    final moldStatus = resolvedDetails['status']?.toString();
    _isMoldNotFound =
        resolvedDetails.isEmpty ||
        resolvedDetails.containsKey('error') ||
        moldStatus == 'draft';
    AppLogger.d(
      'MoldResult: Mold found/reviewed: ${!_isMoldNotFound} (status: $moldStatus)',
    );

    // Use moldDetails if available to populate data instead of hardcoded values
    if (!_isMoldNotFound) {
      AppLogger.d('MoldResult: Using moldDetails from API');
      AppLogger.d(
        'MoldResult: moldDetails keys: ${widget.moldDetails!.keys.toList()}',
      );

      if (widget.moldDetails!.containsKey('error')) {
        AppLogger.e(
          'MoldResult: ERROR in moldDetails: ${widget.moldDetails!['error']}',
        );
      } else {
        AppLogger.d(
          'MoldResult: moldDetails data structure: ${widget.moldDetails.toString().substring(0, widget.moldDetails.toString().length > 300 ? 300 : widget.moldDetails.toString().length)}...',
        );
      }

      final details = resolvedDetails;
      healthContent = _readMoldDetailField(
        details,
        'health_risks',
        'Some Aspergillus species can cause allergic reactions, respiratory infections, and more severe diseases in immunocompromised individuals.',
      );
      plantThreatContent = _readMoldDetailField(
        details,
        'affected_hosts',
        'Aspergillus can affect plants by causing diseases such as seedling blight, root rot, and fruit rot, leading to reduced crop yields.',
      );
      fullDescription = _readMoldDetailField(
        details,
        'overview',
        'Aspergillus is a genus of common molds that can be found in various environments, both indoors and outdoors. While many species of Aspergillus are harmless, some can cause a range of health issues in humans, particularly those with weakened immune systems or pre-existing lung conditions.',
      );

      final String symptoms = _readMoldDetailSymptoms(details);
      final String spread = _readMoldDetailSpread(details);
      final String impact = _readMoldDetailImpact(details);
      final String prevention = _readMoldDetailPrevention(details);

      _recommendationSections = {
        'OVERVIEW':
            'Most probably identified mold genus: $moldGenus with confidence level $confidenceLevel%.',
        'DESCRIPTION': fullDescription,
        'HEALTH RISKS': healthContent,
        'AFFECTED CROPS / HOSTS': plantThreatContent,
        'SYMPTOMS & SIGNS': symptoms,
        'DISEASE CYCLE / SPREAD': spread,
        'IMPACT': impact,
        'PREVENTION': prevention,
      };
    } else {
      AppLogger.d(
        'MoldResult: Mold not found in database, using model result only',
      );
      healthContent =
          'Some Aspergillus species can cause allergic reactions, respiratory infections, and more severe diseases in immunocompromised individuals.';
      plantThreatContent =
          'Aspergillus can affect plants by causing diseases such as seedling blight, root rot, and fruit rot, leading to reduced crop yields.';
      fullDescription =
          'Aspergillus is a genus of common molds that can be found in various environments, both indoors and outdoors. While many species of Aspergillus are harmless, some can cause a range of health issues in humans, particularly those with weakened immune systems or pre-existing lung conditions.';

      // Update OVERVIEW to indicate mold not in database
      final overviewText = _isMoldNotFound
          ? 'Most probably identified: $moldGenus ($confidenceLevel%) — Not in Mold Database'
          : 'Most probably identified mold genus: $moldGenus with confidence level $confidenceLevel%.';

      _recommendationSections = {
        'OVERVIEW': overviewText,
        'DESCRIPTION': fullDescription,
        'HEALTH RISKS': healthContent,
        'AFFECTED CROPS / HOSTS': plantThreatContent,
        'SYMPTOMS & SIGNS':
            'This mold may present as powdery, cottony, or discolored growth with visible tissue damage depending on host and conditions.',
        'DISEASE CYCLE / SPREAD':
            'Spores spread through air, tools, water splash, and contaminated surfaces, especially in moist or poorly ventilated environments.',
        'IMPACT': '$healthContent\n\n$plantThreatContent',
        'PREVENTION':
            'Use integrated management controls and monitor treatment response regularly to reduce recurrence.',
      };
    }

    _managementControls = _parseManagementControls(
      _buildTreatmentsContent(resolvedDetails),
    );

    // Pre-populate corrected genus when arriving from LowConfidenceCorrectionScreen
    if (widget.correctedGenus != null && widget.correctedGenus!.isNotEmpty) {
      moldGenus = widget.correctedGenus!;
      _correctedGenus = widget.correctedGenus;
      _correctedAtIso = DateTime.now().toUtc().toIso8601String();
      AppLogger.d(
        'MoldResult: Pre-corrected genus from low-confidence flow: $_correctedGenus',
      );
    }

    _loadSupportedCorrectionOptions();
  }

  List<Map<String, dynamic>> _buildTopPredictions() {
    final dynamic raw = widget.modelResult?['all_probabilities'];
    if (raw is! Map) return [];

    final entries = <Map<String, dynamic>>[];
    raw.forEach((key, value) {
      if (key == null) return;
      final className = key.toString();
      final probability = (value as num?)?.toDouble() ?? 0.0;
      entries.add({'class': className, 'probability': probability});
    });

    entries.sort(
      (a, b) =>
          ((b['probability'] as double).compareTo(a['probability'] as double)),
    );
    return entries.take(3).toList();
  }

  String _inferImageFormat(String path) {
    final dotIndex = path.lastIndexOf('.');
    final extension = dotIndex >= 0
        ? path.substring(dotIndex + 1).toLowerCase()
        : '';
    if (extension.isNotEmpty) return extension;
    return 'png';
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 24, 15, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Bricolage-Grotesque-Bold',
              fontSize: 18,
              letterSpacing: 0.5,
              color: MoldifyColors.primaryColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(thickness: 1.5, color: MoldifyColors.primaryColor),
        ],
      ),
    );
  }

  Widget _buildSectionBody(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: child,
    );
  }

  List<Map<String, String>> _parseManagementControls(String content) {
    final entries = content
        .split('|')
        .where((part) => part.trim().isNotEmpty)
        .map((part) => part.split('::'))
        .where((parts) => parts.length >= 3)
        .map(
          (parts) => {
            'type': parts[0].trim(),
            'title': parts[1].trim(),
            'content': parts[2].trim(),
          },
        )
        .toList();

    return entries;
  }

  IconData _iconForControlType(String type) {
    switch (type.toUpperCase()) {
      case 'MECHANICAL':
        return Icons.settings_suggest_outlined;
      case 'BIOLOGICAL':
        return Icons.biotech_outlined;
      case 'CHEMICAL':
        return Icons.science_outlined;
      case 'PHYSICAL':
        return Icons.build_outlined;
      case 'CULTURAL':
        return Icons.agriculture_outlined;
      default:
        return Icons.medical_services_outlined;
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

      if (response['error'] != null) {
        AppLogger.e(
          'MoldResult: Failed to load supported correction genera: ${response['error']}',
        );
        return;
      }

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
        if (!nextOptions.contains(displayName)) {
          nextOptions.add(displayName);
        }
      }

      if (!mounted || nextMap.isEmpty) return;

      setState(() {
        _supportedCorrectionMap = nextMap;
        if (nextOptions.isNotEmpty) {
          _presetGenusOptions = nextOptions;
        }
      });
    } catch (error, stackTrace) {
      AppLogger.e(
        'MoldResult: Exception while loading supported correction genera',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _applyCorrectedGenus(String correctedText) async {
    final corrected = correctedText.trim();
    if (corrected.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter or select a corrected genus.'),
        ),
      );
      return;
    }

    final normalized = _normalizeCorrectionKey(corrected);
    final predictedClassName = _supportedCorrectionMap[normalized];

    setState(() {
      moldGenus = corrected;
      _correctedGenus = corrected;
      _correctedPredictedClassName = predictedClassName;
      _correctedAtIso = DateTime.now().toUtc().toIso8601String();
    });

    if (predictedClassName == null) {
      setState(() {
        _isMoldNotFound = true;
        _recommendationSections['OVERVIEW'] =
            'Most probably identified: $moldGenus ($confidenceLevel%) — Not in Mold Database';
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mold genus information does not exist in the system yet.',
          ),
        ),
      );
      return;
    }

    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final cameraService = CameraService();
      final details = await cameraService.getMoldDetails(
        moldName: predictedClassName,
        sessionCookie: authProvider.cookie,
      );

      if (details['error'] != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Correction saved, but mold details are unavailable.',
            ),
          ),
        );
        return;
      }

      final resolved = MoldDetailAdapter.unwrapPayload(details);
      if (resolved.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Correction saved, but mold details are unavailable.',
            ),
          ),
        );
        return;
      }

      final symptoms = _readMoldDetailSymptoms(resolved);
      final spread = _readMoldDetailSpread(resolved);
      final impact = _readMoldDetailImpact(resolved);
      final prevention = _readMoldDetailPrevention(resolved);

      setState(() {
        _isMoldNotFound = false;
        healthContent = _readMoldDetailField(
          resolved,
          'health_risks',
          healthContent,
        );
        plantThreatContent = _readMoldDetailField(
          resolved,
          'affected_hosts',
          plantThreatContent,
        );
        fullDescription = _readMoldDetailField(
          resolved,
          'overview',
          fullDescription,
        );

        _recommendationSections['OVERVIEW'] =
            'Most probably identified mold genus: $moldGenus with confidence level $confidenceLevel%.';
        _recommendationSections['DESCRIPTION'] = fullDescription;
        _recommendationSections['HEALTH RISKS'] = healthContent;
        _recommendationSections['AFFECTED CROPS / HOSTS'] = plantThreatContent;
        _recommendationSections['SYMPTOMS & SIGNS'] = symptoms;
        _recommendationSections['DISEASE CYCLE / SPREAD'] = spread;
        _recommendationSections['IMPACT'] = impact;
        _recommendationSections['PREVENTION'] = prevention;

        _managementControls
          ..clear()
          ..addAll(_parseManagementControls(_buildTreatmentsContent(resolved)));
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mold information has been updated.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correction saved, but failed to fetch mold details.'),
        ),
      );
    }
  }

  Widget _buildManagementControls() {
    if (_managementControls.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'No recommendation available yet.',
          style: TextStyle(
            fontFamily: 'Bricolage-Grotesque-Regular',
            fontSize: 16,
            color: MoldifyColors.MoldifyGrey,
          ),
        ),
      );
    }

    return Column(
      children: _managementControls
          .map(
            (item) => ControlManagementTile(
              title: item['title'] ?? '',
              description: (item['content'] ?? '').isNotEmpty
                  ? item['content']!
                  : 'No recommendation available yet.',
              icon: _iconForControlType(item['type'] ?? ''),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String today = DateFormat('MMMM d, y').format(DateTime.now());

    final TextEditingController correctedGenusController =
        TextEditingController();

    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(
        title: 'Mold Result',
        // Hide the flag button when genus was already corrected upstream
        rightIcon: widget.correctedGenus != null ? null : Icon(Icons.flag),
        rightIconColor: MoldifyColors.MoldifyRed,
        onRightIconPressed: widget.correctedGenus != null ? null : () {
          // Define the save logic here so it can be referenced by both onSave and onConfirm
          void onSave(String correctedText) {
            AppLogger.d('Corrected Text: $correctedText');
            _applyCorrectedGenus(correctedText);
          }

          showModalBottomSheet(
            context: context,
            // Make it non-dismissible
            isDismissible: false,
            // Use true to prevent the keyboard from covering the text field
            isScrollControlled: true,
            builder: (context) {
              return Padding(
                // Add padding to account for the keyboard
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: BuildBottomSheet(
                  child: CorrectionBottomSheetContent(
                    correctedGenusController: correctedGenusController,
                    presetGenusOptions: _presetGenusOptions,
                    onClose: () {
                      Navigator.of(context).pop();
                    },
                    onSave: onSave,

                    /// This is for the confirmation dialog inside the bottom sheet
                    /// You can implement the actual logic as needed

                    /// This is the cancel action for the pop up dialog
                    onCancel: () {
                      AppLogger.d('MoldResult: Correction cancelled by user');
                    },

                    /// This is the confirm action for the pop up dialog
                    onConfirm: () {
                      Navigator.of(context).pop();
                      onSave(correctedGenusController.text);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            /// 1. The image uploaded bu the user
            Image.file(
              File(widget.croppedImagePath),
              height: MediaQuery.of(context).size.height * 0.4,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            /// 2. The content container, padded from the top to create the overlap.
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.35,
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: MoldifyColors.backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: AutoSizeText(
                          'Most probably identified mold genus:',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Bricolage-Grotesque-Regular',
                            color: MoldifyColors.MoldifyGrey,
                          ),
                          maxLines: 1,
                          minFontSize: 10,
                        ),
                      ),

                      /// This is the Mold Genus Name
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: AutoSizeText(
                          moldGenus,
                          style: TextStyle(
                            fontSize: 40,
                            fontFamily: 'Montserrat-Black',
                            color: MoldifyColors.primaryColor,
                          ),
                          maxLines: 1,
                          minFontSize: 24,
                        ),
                      ),

                      /// Date and Confidence Level
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 15.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /// Date
                            Row(
                              children: [
                                Icon(
                                  FontAwesomeIcons.solidCalendar,
                                  size: 16,
                                  color: MoldifyColors.accentColor,
                                ),
                                SizedBox(width: 6),
                                AutoSizeText(
                                  today,
                                  style: TextStyle(
                                    color: MoldifyColors.primaryColor,
                                    fontSize: 12,
                                    fontFamily: 'Bricolage-Grotesque-Regular',
                                  ),
                                  maxLines: 1,
                                  minFontSize: 8,
                                ),
                              ],
                            ),

                            /// Confidence Level
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  FontAwesomeIcons.chartSimple,
                                  size: 16,
                                  color: MoldifyColors.accentColor,
                                ),
                                SizedBox(width: 6),
                                AutoSizeText(
                                  "Confidence level: $confidenceLevel%",
                                  style: TextStyle(
                                    color: MoldifyColors.primaryColor,
                                    fontSize: 12,
                                    fontFamily: 'Bricolage-Grotesque-Regular',
                                  ),
                                  maxLines: 1,
                                  minFontSize: 8,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      _buildSectionHeader('OVERVIEW ANALYSIS'),
                      _buildSectionBody(
                        RevisedResultsContent(
                          sections: _recommendationSections,
                        ),
                      ),

                      _buildSectionHeader('TREATMENT MANAGEMENT CONTROLS'),
                      _buildSectionBody(_buildManagementControls()),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: ResultActionSection(
                          onSave: () async {
                            if (_isSavingResult) return;

                            // Show confirmation dialog if mold is not in database
                            if (_isMoldNotFound) {
                              final shouldProceed =
                                  await showDialog<bool>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext dialogContext) {
                                      return AlertDialog(
                                        title: const Text(
                                          'Mold Not in Database',
                                          style: TextStyle(
                                            fontFamily: 'Montserrat-Bold',
                                            fontSize: 18,
                                          ),
                                        ),
                                        content: const Text(
                                          'This mold is not in our database. Would you like to save this result and help us add it?',
                                          style: TextStyle(
                                            fontFamily:
                                                'Bricolage-Grotesque-Regular',
                                            fontSize: 14,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(
                                              dialogContext,
                                              false,
                                            ),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(
                                              dialogContext,
                                              true,
                                            ),
                                            child: const Text(
                                              'Save & Report',
                                              style: TextStyle(
                                                color:
                                                    MoldifyColors.accentColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ) ??
                                  false;

                              if (!shouldProceed) {
                                AppLogger.d(
                                  'MoldResult: User cancelled save for unknown mold',
                                );
                                return;
                              }
                              AppLogger.d(
                                'MoldResult: User confirmed save for unknown mold',
                              );
                            }

                            setState(() => _isSavingResult = true);
                            final topPredictions = _buildTopPredictions();
                            final confidenceDecimal =
                                (widget.modelResult?['probability'] as num?)
                                    ?.toDouble() ??
                                0.0;
                            final predictedClassName = widget
                                .modelResult?['predicted_class']
                                ?.toString();
                            final nowIso = DateTime.now()
                                .toUtc()
                                .toIso8601String();
                            final thresholdDecimal =
                              ScanConstants.lowConfidenceThreshold / 100;

                            final savePayload = <String, dynamic>{
                              'imagePath': widget.croppedImagePath,
                              'identifiedMold': moldGenus,
                              'confidence': confidenceLevel,
                              // Backward-compatible additions for mycologist decision support
                              'confidenceDecimal': confidenceDecimal,
                              'topPredictions': topPredictions,
                              'modelSource':
                                  widget.modelResult?['model_source'],
                              'usedFusion':
                                  widget.modelResult?['used_fusion'] ?? false,
                              'usedAnn':
                                  widget.modelResult?['used_ann'] ?? false,
                              'scanModality':
                                  widget.scanModality ?? 'microscopic',
                              'sourceFlow':
                                  widget.sourceFlow ?? 'identification',
                              'sourceTab': widget.sourceTab,
                              'moldCaseId': widget.caseId,
                              'predictedClassName': predictedClassName,
                              'correctedGenus': _correctedGenus,
                              'correctedPredictedClassName':
                                  _correctedPredictedClassName,
                              'correctedAt': _correctedAtIso,
                              'isMoldNotFound':
                                  _isMoldNotFound, // Flag for backend tracking
                            };

                            try {
                              final authProvider = Provider.of<AppAuthProvider>(
                                context,
                                listen: false,
                              );
                              final cameraService = CameraService();

                              final scanRes = await cameraService
                                  .createScannedMold(
                                    imagePath: widget.croppedImagePath,
                                    imageFormat: _inferImageFormat(
                                      widget.croppedImagePath,
                                    ),
                                    scanModality:
                                        (widget.scanModality ?? 'microscopic'),
                                    sourceFlow:
                                        (widget.sourceFlow ?? 'identification'),
                                    sourceTab: widget.sourceTab,
                                    moldCaseId: widget.caseId,
                                    predictedClassName: predictedClassName,
                                    correctedGenus: _correctedGenus,
                                    correctedPredictedClassName:
                                        _correctedPredictedClassName,
                                    correctedAt: _correctedAtIso,
                                    capturedAt: nowIso,
                                    scannedResults: {
                                      'confidence_score': confidenceDecimal,
                                      'flagged': confidenceDecimal <
                                          thresholdDecimal,
                                    },
                                    sessionCookie: authProvider.cookie,
                                  );

                              if (scanRes['error'] != null) {
                                AppLogger.e(
                                  'MoldResult: Failed to persist scan: ${scanRes['error']}',
                                );
                                savePayload['scanSaveError'] = scanRes['error'];
                              } else {
                                final data = scanRes['data'];
                                if (data is Map<String, dynamic>) {
                                  savePayload['scanId'] = data['id']
                                      ?.toString();
                                  savePayload['savedScan'] = data;

                                  // Create flag report if scan was auto-flagged (low confidence)
                                  if (confidenceDecimal < thresholdDecimal) {
                                    try {
                                      final flagReportService =
                                          FlagReportService();
                                      await flagReportService.createFlagReport(
                                        payload: {
                                          'content_id': data['id'],
                                          'content_type': 'mold_scan',
                                          'reason': 'low_confidence_auto_flag',
                                          'details': confidenceDecimal
                                              .toString(),
                                        },
                                        sessionCookie: authProvider.cookie,
                                      );
                                      AppLogger.d(
                                        'MoldResult: Flag report created for low-confidence scan',
                                      );
                                    } catch (e, s) {
                                      AppLogger.e(
                                        'MoldResult: Failed to create flag report',
                                        error: e,
                                        stackTrace: s,
                                      );
                                    }
                                  }

                                  if (_correctedGenus != null &&
                                      (_correctedPredictedClassName == null ||
                                          _correctedPredictedClassName!
                                              .trim()
                                              .isEmpty)) {
                                    try {
                                      final flagReportService =
                                          FlagReportService();
                                      await flagReportService.createFlagReport(
                                        payload: {
                                          'content_id': data['id'],
                                          'content_type': 'mold_scan',
                                          'reason': 'corrected_genus_not_found',
                                          'details': _correctedGenus,
                                        },
                                        sessionCookie: authProvider.cookie,
                                      );
                                      AppLogger.d(
                                        'MoldResult: Flag report created for unsupported corrected genus',
                                      );
                                    } catch (e, s) {
                                      AppLogger.e(
                                        'MoldResult: Failed to create unsupported-genus flag report',
                                        error: e,
                                        stackTrace: s,
                                      );
                                    }
                                  }
                                }
                              }
                            } catch (e, s) {
                              AppLogger.e(
                                'MoldResult: Exception while persisting scan',
                                error: e,
                                stackTrace: s,
                              );
                              savePayload['scanSaveError'] = e.toString();
                            } finally {
                              if (mounted) {
                                setState(() => _isSavingResult = false);
                              }
                            }

                            if (!context.mounted) return;
                            if (context.mounted) {
                              Navigator.of(context).pop(savePayload);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isSavingResult)
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
      ),
    );
  }
}
