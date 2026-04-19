import 'package:flutter/material.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/core/constants/scan_constants.dart';
import 'package:moldify/pages/misc/functions/step_indicator.dart';
import 'package:moldify/pages/misc/functions/scrollable_tab_bar.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/overlays/loading_ui.dart';
import 'package:moldify/core/features/camera/services/camera_service.dart';
import 'package:moldify/core/constants/morphology_schema.dart';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import 'package:moldify/providers/auth_provider.dart';

// Import all the separated tab widgets
import 'characteristics_tab_content/general_structure.dart';
import 'characteristics_tab_content/reproductive_structure.dart';
import 'characteristics_tab_content/conidiophore_features.dart';
import 'characteristics_tab_content/spore_characteristics.dart';
import 'characteristics_tab_content/additional_characteristics.dart';
import 'package:moldify/core/utils/logger.dart';


class InputCharacteristicsScreen extends StatefulWidget {
  const InputCharacteristicsScreen({super.key});

  @override
  State<InputCharacteristicsScreen> createState() => _InputCharacteristicsScreenState();
}

class _InputCharacteristicsScreenState extends State<InputCharacteristicsScreen> {
  int _selectedTab = 0;

  // Use a single map to hold all form data for easier management and submission.
  final Map<String, dynamic> formData = {};

  final List<String> tabTitles = [
    "General Structure",
    "Reproductive Structure",
    "Conidiophore Features",
    "Spore Characteristics",
    "Additional Characteristics",
  ];

  late final List<Widget> tabContents;

  /// Map camelCase form field names to canonical API field names from MorphologySchema.
  /// The form collects data using camelCase keys (for convenience),
  /// but the API expects the exact canonical field names with underscores.
  /// This mapping ensures the exact match required by the model training pipeline.
  static Map<String, String> get _fieldNameMapping => {
    'hyphaePresence': 'Hyphae_Presence',
    'hyphaeSeptation': 'Hyphae_Septation',
    'hyphaeBranching': 'Hyphae_Branching',
    'hyphaeWidth': 'Hyphae_Width',
    'hyphaePigmentation': 'Hyphae_Pigmentation',
    'vesiclePresence': 'Vesicle_Presence',
    'vesicleShape': 'Vesicle_Shape',
    'sporangiumPresence': 'Sporangium_Presence',
    'sporangiophorePresence': 'Sporangiophore_Presence',
    'columellaPresence': 'Columella_Presence',
    'rhizoidPresence': 'Rhizoid_Presence',
    'conidiophorePresence': 'Conidiophore_Presence',
    'conidiophoreBranching': 'Conidiophore_Branching',
    'conidiophoreLength': 'Conidiophore_Length',
    'conidiophoreSurface': 'Conidiophore_Surface',
    'sporeType': 'Spore_Type',
    'sporeShape': 'Spore_Shape',
    'sporeColor': 'Spore_Color',
    'sporeSurface': 'Spore_Surface',
    'sporeArrangement': 'Spore_Arrangement',
    'phialideArrangement': 'Phialide_Arrangement',
    'sterigmataArrangement': 'Sterigmata_Arrangement',
  };

  /// Convert formData (camelCase keys) to API characteristics (canonical field names from schema).
  /// Only include non-empty values that are validated against MorphologySchema.
  /// This ensures 100% compatibility with the ML model endpoints.
  Map<String, dynamic> _mapFormDataToApiCharacteristics() {
    final Map<String, dynamic> apiCharacteristics = {};
    formData.forEach((key, value) {
      final canonicalFieldName = _fieldNameMapping[key];
      if (canonicalFieldName == null) {
        AppLogger.w('⚠️ Unknown form field: $key (not in mapping)');
        return;
      }

      // Skip null or empty values
      if (value == null || value.toString().trim().isEmpty) {
        return;
      }

      final valueStr = value.toString();

      // Validate the value against MorphologySchema
      if (!MorphologySchema.isValidValue(canonicalFieldName, valueStr)) {
        AppLogger.w(
          '⚠️ Invalid value for $canonicalFieldName: "$valueStr" '
          '(not in schema). Valid: ${MorphologySchema.getValidValues(canonicalFieldName)}',
        );
        // Still include it — let the API reject if it's truly invalid
      }

      apiCharacteristics[canonicalFieldName] = valueStr;
    });

    AppLogger.d('🔄 Mapped formData to API characteristics:');
    AppLogger.d('  Original keys: ${formData.keys.toList()}');
    AppLogger.d('  API keys: ${apiCharacteristics.keys.toList()}');
    AppLogger.d('  Total: ${apiCharacteristics.length}/${MorphologySchema.fieldCount} characteristics');
    return apiCharacteristics;
  }

  @override
  void initState() {
    super.initState();
    tabContents = [
      GeneralStructureTab(
        onNext: _goToNextTab,
        // Update callbacks to use the formData map
        onPresenceChanged: (v) => setState(() => formData['hyphaePresence'] = v),
        onSeptationChanged: (v) => setState(() => formData['hyphaeSeptation'] = v),
        onBranchingChanged: (v) => setState(() => formData['hyphaeBranching'] = v),
        onWidthChanged: (v) => setState(() => formData['hyphaeWidth'] = v),
        onPigmentationChanged: (v) => setState(() => formData['hyphaePigmentation'] = v),
      ),
      ReproductiveStructureTab(
        onNext: _goToNextTab,
        onBack: _goToPreviousTab,
        onVesiclePresenceChanged: (v) => setState(() => formData['vesiclePresence'] = v),
        onVesicleShapeChanged: (v) => setState(() => formData['vesicleShape'] = v),
        onSporangiumPresenceChanged: (v) => setState(() => formData['sporangiumPresence'] = v),
        onSporangiophorePresenceChanged: (v) => setState(() => formData['sporangiophorePresence'] = v),
        onColumellaPresenceChanged: (v) => setState(() => formData['columellaPresence'] = v),
        onRhizoidPresenceChanged: (v) => setState(() => formData['rhizoidPresence'] = v),
      ),
      ConidiophoreFeaturesTab(
        onNext: _goToNextTab,
        onBack: _goToPreviousTab,
        onConidiophorePresenceChanged: (v) => setState(() => formData['conidiophorePresence'] = v),
        onConidiophoreBranchingChanged: (v) => setState(() => formData['conidiophoreBranching'] = v),
        onConidiophoreLengthChanged: (v) => setState(() => formData['conidiophoreLength'] = v),
        onConidiophoreSurfaceChanged: (v) => setState(() => formData['conidiophoreSurface'] = v),
      ),
      SporeCharacteristicsTab(
        onNext: _goToNextTab,
        onBack: _goToPreviousTab,
        onSporeTypeChanged: (v) => setState(() => formData['sporeType'] = v),
        onSporeShapeChanged: (v) => setState(() => formData['sporeShape'] = v),
        onSporeColorChanged: (v) => setState(() => formData['sporeColor'] = v),
        onSporeSurfaceChanged: (v) => setState(() => formData['sporeSurface'] = v),
        onSporeArrangementChanged: (v) => setState(() => formData['sporeArrangement'] = v),
      ),
      AdditionalCharacteristicsTab(
        onSubmit: _submitCharacteristics,
        onBack: _goToPreviousTab,
        onPhialideArrangementChanged: (v) => setState(() => formData['phialideArrangement'] = v),
        onSterigmataArrangementChanged: (v) => setState(() => formData['sterigmataArrangement'] = v),
      ),
    ];
  }

  void _goToNextTab() {
    if (_selectedTab < tabTitles.length - 1) {
      setState(() => _selectedTab++);
    }
  }

  void _goToPreviousTab() {
    if (_selectedTab > 0) {
      setState(() => _selectedTab--);
    }
  }

  void _submitCharacteristics() async {
    // Retrieve data passed from ImagePreviewScreen
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      AppLogger.e("Error: No arguments received from previous screen.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Missing image data.')),
      );
      return;
    }

    final croppedImagePath = args['croppedImagePath'];
    final imageBytes = args['imageBytes'] as Uint8List?;
    final fileName = args['fileName'] as String?;
    final sourceFlow = args['sourceFlow'] as String?;
    final scanModality = args['scanModality'] as String?;
    final sourceTab = args['sourceTab'] as String?;
    final caseId = args['caseId'] as String?;

    if (imageBytes == null || fileName == null) {
      AppLogger.e("Error: Image bytes or filename missing.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Image data incomplete.')),
      );
      return;
    }

    AppLogger.d("✅ Collected formData: $formData");
    AppLogger.d("🚀 Submitting characteristics to API...");

    // Show loading indicator
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: false,
        builder: (context) => const AppLoadingDialog(
          message: 'Processing data...',
        ),
      );
    }

    try {
      // Convert camelCase formData to API snake_case characteristics
      final apiCharacteristics = _mapFormDataToApiCharacteristics();

      // Step 1: Call identifyImage API with both image AND characteristics
      AppLogger.d('🟡 InputCharacteristics: Step 1 - Calling identifyImage with characteristics');
      final cameraService = CameraService();
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final modelResult = await cameraService.identifyImage(
        imageBytes: imageBytes,
        filename: fileName,
        sessionCookie: authProvider.cookie,
        characteristics: apiCharacteristics.isNotEmpty ? apiCharacteristics : null,
      );
      AppLogger.d('📊 InputCharacteristics: identifyImage result: $modelResult');

      if (modelResult.containsKey('error')) {
        AppLogger.e('❌ InputCharacteristics: API error: ${modelResult['error']}');
        if (!mounted) return;
        if (mounted) {
          Navigator.of(context).pop(); // Dismiss loading
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Prediction failed: ${modelResult['error']}')),
          );
        }
        return;
      }

      // Step 2: Extract genus from predicted_class
      final predictedClass = modelResult['predicted_class']?.toString() ?? '';
      AppLogger.d('🟡 InputCharacteristics: Step 2 - Predicted class: $predictedClass');

      // Step 3: Fetch detailed mold information using full predicted class name
      AppLogger.d('🟡 InputCharacteristics: Step 3 - Calling getMoldDetails(moldName: $predictedClass)');
      final moldDetails = await cameraService.getMoldDetails(
        moldName: predictedClass,
        sessionCookie: authProvider.cookie,
      );

      AppLogger.d('✅ InputCharacteristics: getMoldDetails completed');
      AppLogger.d('✅ InputCharacteristics: Response preview: ${moldDetails.toString().substring(0, moldDetails.toString().length > 200 ? 200 : moldDetails.toString().length)}...');

      if (moldDetails.containsKey('error')) {
        AppLogger.e('⚠️ InputCharacteristics: Warning in moldDetails: ${moldDetails['error']}');
      } else {
        AppLogger.d('✅ InputCharacteristics: moldDetails keys: ${moldDetails.keys.toList()}');
      }

      // Dismiss loading
      if (!mounted) return;
      if (mounted) {
        Navigator.of(context).pop();

        // Route to low-confidence correction screen when AI confidence is too low
        final prob = (modelResult['probability'] as num?)?.toDouble() ?? 0.0;
        final confidencePct = prob * 100;
        final bool isLowConfidence =
            confidencePct < ScanConstants.lowConfidenceThreshold;

        AppLogger.d(
          '🚀 InputCharacteristics: confidence=$confidencePct% threshold=${ScanConstants.lowConfidenceThreshold}% lowConfidence=$isLowConfidence',
        );

        final Object routeArgs;
        final String routeName;
        if (isLowConfidence) {
          AppLogger.d(
            '🚀 InputCharacteristics: Navigating to low_confidence_correction (confidence too low)',
          );
          routeName = RouteNames.lowConfidenceCorrection;
          routeArgs = {
            'croppedImagePath': croppedImagePath,
            'modelResult': modelResult,
            'sourceFlow': sourceFlow,
            'scanModality': scanModality,
            'sourceTab': sourceTab,
            'caseId': caseId,
          };
        } else {
          AppLogger.d(
            '🚀 InputCharacteristics: Navigating to /mold_result with prediction and characteristics',
          );
          routeName = RouteNames.moldResult;
          routeArgs = {
            'croppedImagePath': croppedImagePath,
            'modelResult': modelResult,
            'moldDetails': moldDetails,
            'characteristics': apiCharacteristics,
            'sourceFlow': sourceFlow,
            'scanModality': scanModality,
            'sourceTab': sourceTab,
            'caseId': caseId,
          };
        }

        final result = await Navigator.of(context).pushNamed(
          routeName,
          arguments: routeArgs,
        );

        // Always pop so input_characteristics is never left stranded when the
        // user backs out of the result screen. Camera decides whether to stay
        // (null = keep camera open) or also pop (non-null = scan saved).
        if (!mounted) return;
        Navigator.of(context).pop(result);
      }
    } catch (e, stackTrace) {
      AppLogger.e('❌ InputCharacteristics: EXCEPTION during submit', error: e, stackTrace: stackTrace);

      // Dismiss loading
      if (!mounted) return;
      if (mounted) {
        Navigator.of(context).pop();
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(title: 'Input Characteristics'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Input Characteristics Header
              const Text(
                'Input Characteristics',
                style: TextStyle(
                  fontSize: 36,
                  fontFamily: 'Montserrat-Black',
                  color: MoldifyColors.primaryColor,
                ),
              ),
              const Text(
                'Adding more characteristics improves prediction accuracy.',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Bricolage-Grotesque-Regular',
                  color: MoldifyColors.MoldifyBlack,
                ),
              ),
              /// End of Header

              const SizedBox(height: 20),

              StepIndicator(
                totalSteps: tabTitles.length,
                currentStep: _selectedTab,
              ),
              const SizedBox(height: 20),

              ScrollableTabBar(
                tabs: tabTitles,
                currentIndex: _selectedTab,
                onTabSelected: (index) {
                  setState(() => _selectedTab = index);
                },
              ),
              const SizedBox(height: 16),


              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: IndexedStack(
                  index: _selectedTab,
                  children: tabContents.map((tab) {
                    final isActive = tabContents.indexOf(tab) == _selectedTab;
                    return Visibility(
                      visible: isActive,
                      maintainState: true,
                      child: tab,
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
