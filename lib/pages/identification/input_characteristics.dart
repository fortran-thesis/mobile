import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/functions/step_indicator.dart';
import 'package:moldify/pages/misc/functions/scrollable_tab_bar.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/colors.dart';

// Import all the separated tab widgets
import 'characteristics_tab_content/general_structure.dart';
import 'characteristics_tab_content/reproductive_structure.dart';
import 'characteristics_tab_content/conidiophore_features.dart';
import 'characteristics_tab_content/spore_characteristics.dart';
import 'characteristics_tab_content/additional_characteristics.dart';


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

  void _submitCharacteristics() {
    // Retrieve data passed from ImagePreviewScreen
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      print("Error: No arguments received from previous screen.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Missing image data.')),
      );
      return;
    }

    final croppedImagePath = args['croppedImagePath'];
    final modelResult = args['modelResult'];

    print("Collected formData: $formData");

    // Navigate directly to Mold Result screen (same behavior as ImagePreviewScreen)
    Navigator.pushNamed(
      context,
      '/mold_result',
      arguments: {
        'croppedImagePath': croppedImagePath,
        'modelResult': modelResult,
        'characteristics': formData,
      },
    );
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
