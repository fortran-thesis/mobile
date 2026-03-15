import 'package:auto_size_text/auto_size_text.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/identification/mold_result_content/mold_info_content.dart';
import 'package:moldify/pages/identification/mold_result_content/revised_results_content.dart';
import 'package:moldify/pages/identification/mold_result_content/result_action_section.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/functions/scrollable_tab_bar.dart';
import '../misc/appbar/primary_app_bar.dart';
import 'package:intl/intl.dart';

import '../misc/tiles/bottom_sheet.dart';
import '../misc/tiles/bottom_sheet_contents/correction_content.dart';
import 'mold_result_content/prevention_treatment_content.dart';
import 'package:moldify/core/utils/logger.dart';


class MoldResultScreen extends StatefulWidget {
  final String croppedImagePath;
  final Map<String, dynamic>? modelResult;
  final Map<String, dynamic>? moldDetails;

  const MoldResultScreen({super.key, required this.croppedImagePath, this.modelResult, this.moldDetails});

  @override
  State<MoldResultScreen> createState() => _MoldResultScreenState();
}

class _MoldResultScreenState extends State<MoldResultScreen> {
  late String confidenceLevel;
  late String moldGenus;
  final String healthContent =
    "Some Aspergillus species can cause allergic reactions, respiratory infections, and more severe diseases in immunocompromised individuals.";
  final String plantThreatContent =
    "Aspergillus can affect plants by causing diseases such as seedling blight, root rot, and fruit rot, leading to reduced crop yields.";
  final String additionalInfoContent =
    "Aspergillus species are also used in biotechnology for the production of enzymes and pharmaceuticals, showcasing their industrial significance.";

  final String fullDescription =
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

  int _selectedTabIndex = 0;

  final Map<String, String> taxonomy = {
    "Kingdom": "Fungi",
    "Phylum": "Ascomycota",
    "Class": "Eurotiomycetes",
    "Order": "Eurotiales",
    "Family": "Aspergillaceae",
    "Genus": "Aspergillus",
  };

  // Prevention tactics using structured format (pipe-delimited)
  final String treatmentsContent = 
      'MECHANICAL::Mechanical Control::Remove infected plant debris promptly using sterilized tools. Prune affected areas and ensure proper disposal of contaminated materials in sealed bags. Clean and dry surfaces thoroughly to prevent mold spread.|'
      'BIOLOGICAL::Biological Control::Apply beneficial microorganisms that compete with mold growth. Use natural antifungal agents like vinegar, hydrogen peroxide, or neem oil for surface treatment. UV light treatment can also help control surface mold.|'
      'CHEMICAL::Chemical Control::Recommended fungicides: Chlorothalonil, Mancozeb, and Copper-based fungicides. Rotate products with different active ingredients to prevent resistance. Always follow label recommendations for dosage and application frequency.|'
      'PHYSICAL::Physical Control::Improve ventilation in affected areas to reduce moisture buildup. Use dehumidifiers to maintain optimal humidity levels. Ensure proper air circulation and maintain appropriate temperature control.|'
      'CULTURAL::Cultural Control::Implement proper sanitation practices and field hygiene. Rotate crops annually to prevent soil-borne diseases. Remove and destroy contaminated materials to prevent recontamination. Monitor and record treatments for effectiveness.';

  late final Map<String, String> _recommendationSections;


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
    final predictedClass = widget.modelResult?['predicted_class']?.toString() ?? '';
    moldGenus = predictedClass.contains('_') ? predictedClass.split('_')[0] : predictedClass;
    AppLogger.d('MoldResult: Predicted class: $predictedClass, Genus: $moldGenus');
    
    // Use moldDetails if available to populate data instead of hardcoded values
    if (widget.moldDetails != null && (widget.moldDetails?.isEmpty ?? true) == false) {
      AppLogger.d('MoldResult: Using moldDetails from API');
      AppLogger.d('MoldResult: moldDetails keys: ${widget.moldDetails!.keys.toList()}');
      
      if (widget.moldDetails!.containsKey('error')) {
        AppLogger.e('MoldResult: ERROR in moldDetails: ${widget.moldDetails!['error']}');
      } else {
        AppLogger.d('MoldResult: moldDetails data structure: ${widget.moldDetails.toString().substring(0, widget.moldDetails.toString().length > 300 ? 300 : widget.moldDetails.toString().length)}...');
      }
      // TODO: Parse moldDetails and update the data variables
      // This will be used to populate healthContent, plantThreatContent, fullDescription, taxonomy, fungicides, etc.
    } else {
      AppLogger.d('MoldResult: No moldDetails provided, using hardcoded fallback data');
    }

    _recommendationSections = {
      'OVERVIEW': 'Most probably identified mold genus: $moldGenus with confidence level $confidenceLevel%.',
      'DESCRIPTION': fullDescription,
      'AFFECTED CROPS / HOSTS': plantThreatContent,
      'SYMPTOMS & SIGNS': 'This mold may present as powdery, cottony, or discolored growth with visible tissue damage depending on host and conditions.',
      'DISEASE CYCLE / SPREAD': 'Spores spread through air, tools, water splash, and contaminated surfaces, especially in moist or poorly ventilated environments.',
      'IMPACT': '$healthContent\n\n$plantThreatContent',
      'PREVENTION': 'Use integrated management controls and monitor treatment response regularly to reduce recurrence.',
    };
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String today = DateFormat('MMMM d, y').format(DateTime.now());

    final TextEditingController correctedGenusController = TextEditingController();

    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(
        title: 'Mold Result',
        rightIcon: Icon(
          Icons.flag,
        ),
        rightIconColor: MoldifyColors.MoldifyRed,
        onRightIconPressed: () {

          // Define the save logic here so it can be referenced by both onSave and onConfirm
          void onSave(String correctedText) {
            // Add your save logic here
            AppLogger.d('Corrected Text: $correctedText');
            Navigator.of(context).pop(); // This will pop the bottom sheet
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
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: BuildBottomSheet(
                  child: CorrectionBottomSheetContent(
                    correctedGenusController: correctedGenusController,
                    onClose: () {
                      Navigator.of(context).pop();
                    },
                    onSave: onSave,

                    /// This is for the confirmation dialog inside the bottom sheet
                    /// You can implement the actual logic as needed

                    /// This is the cancel action for the pop up dialog
                    onCancel: () {
                      Navigator.of(context).pop();
                    },

                    /// This is the confirm action for the pop up dialog
                    onConfirm: () {
                      onSave(correctedGenusController.text);                    },
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
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.35),
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
                        )
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
                            vertical: 15.0, horizontal: 15.0),
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
              
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: ScrollableTabBar(
                          tabs: const [
                            'Mold Info',
                            'Prevention Tactics',
                            'Revised Results',
                          ],
                          currentIndex: _selectedTabIndex,
                          onTabSelected: (index) {
                            setState(() {
                              _selectedTabIndex = index;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: IndexedStack(
                          index: _selectedTabIndex,
                          children: [
                            MoldInfoSection(
                              description: fullDescription,
                              taxonomy: taxonomy,
                              healthContent: healthContent,
                              plantThreatContent: plantThreatContent,
                              additionalInfoContent: additionalInfoContent,
                            ),
                            PreventionTreatmentContent(
                              treatmentsContent: treatmentsContent,
                            ),
                            RevisedResultsContent(
                              sections: _recommendationSections,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: ResultActionSection(
                          onSave: () {
                            Navigator.of(context).pop({
                              'imagePath': widget.croppedImagePath,
                              'identifiedMold': moldGenus,
                              'confidence': confidenceLevel,
                            });
                          },
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
    );
  }
}
