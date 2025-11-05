import 'package:auto_size_text/auto_size_text.dart';
import 'package:moldify/core/features/camera/models/camera_model_result.dart';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/identification/mold_result_content/mold_info_content.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/functions/tab_bar.dart';
import '../misc/appbar/primary_app_bar.dart';
import 'package:intl/intl.dart';

import '../misc/buttons/primary_button.dart';
import '../misc/overlays/modals/confirmation_dialog.dart';
import '../misc/tiles/bottom_sheet.dart';
import '../misc/tiles/bottom_sheet_contents/correction_content.dart';
import 'mold_result_content/prevention_treatment_content.dart';


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

  bool _showFullText = false;
  late TapGestureRecognizer _tapRecognizer;

  final Map<String, String> taxonomy = {
    "Kingdom": "Fungi",
    "Phylum": "Ascomycota",
    "Class": "Eurotiomycetes",
    "Order": "Eurotiales",
    "Family": "Aspergillaceae",
    "Genus": "Aspergillus",
  };

  final List<String> recommendedFungicides = [
    "Chlorothalonil",
    "Mancozeb",
    "Copper-based fungicides",
  ];

  final String resistanceContent = "To minimize the risk of mold developing "
      "resistance to fungicides, rotate products that contain different active "
      "ingredients or modes of action. Avoid repeated use of the same fungicide "
      "type across multiple treatments. Always follow label recommendations for dosage "
      "and application frequency. Overuse or incorrect application can reduce fungicide "
      "effectiveness and contribute to resistance in future mold outbreaks.";

  final String alternativeMethodsContent = "Implement non-chemical control methods alongside "
      "fungicide use for best results. Improve ventilation in affected areas to reduce "
      "moisture buildup, and use a dehumidifier where possible. Clean and dry surfaces "
      "thoroughly, and remove contaminated materials to prevent further spread. UV light "
      "treatment and natural antifungal agents like vinegar or hydrogen peroxide can help "
      "control surface mold growth.";

  final String additionalInfoTreatmentContent = "Always wear protective gloves and a mask "
      "when handling mold or applying treatments. Dispose of contaminated "
      "materials properly to prevent recontamination. For large or recurring "
      "infestations, contact a certified mold remediation specialist. "
      "Local regulations may require professional cleanup for certain mold species or "
      "in public spaces. Keep records of treatments and observations to help monitor "
      "mold recurrence and treatment effectiveness.";


  @override
  void initState() {
    super.initState();
    print('MoldResult: initState called');
    print('MoldResult: modelResult = ${widget.modelResult}');
    print('MoldResult: moldDetails = ${widget.moldDetails}');
    
    _tapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        setState(() {
          _showFullText = !_showFullText;
        });
      };
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
      print('MoldResult: Confidence level calculated: $confidenceLevel%');
    } else {
      confidenceLevel = '';
      print('MoldResult: No probability found in modelResult');
    }
    // Extract only the genus from 'genus_spp' format
    final predictedClass = widget.modelResult?['predicted_class']?.toString() ?? '';
    moldGenus = predictedClass.contains('_') ? predictedClass.split('_')[0] : predictedClass;
    print('MoldResult: Predicted class: $predictedClass, Genus: $moldGenus');
    
    // Use moldDetails if available to populate data instead of hardcoded values
    if (widget.moldDetails != null && (widget.moldDetails?.isEmpty ?? true) == false) {
      print('MoldResult: Using moldDetails from API');
      print('MoldResult: moldDetails keys: ${widget.moldDetails!.keys.toList()}');
      
      if (widget.moldDetails!.containsKey('error')) {
        print('MoldResult: ERROR in moldDetails: ${widget.moldDetails!['error']}');
      } else {
        print('MoldResult: moldDetails data structure: ${widget.moldDetails.toString().substring(0, widget.moldDetails.toString().length > 300 ? 300 : widget.moldDetails.toString().length)}...');
      }
      // TODO: Parse moldDetails and update the data variables
      // This will be used to populate healthContent, plantThreatContent, fullDescription, taxonomy, fungicides, etc.
    } else {
      print('MoldResult: No moldDetails provided, using hardcoded fallback data');
    }
  }

  @override
  void dispose() {
    _tapRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String today = DateFormat('MMMM d, y').format(DateTime.now());

    final List<String> words = fullDescription.split(' ');
    final bool isLongText = words.length > 40;

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
            print('Corrected Text: $correctedText');
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
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
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
              
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: BuildTabBar(
                            tabs: ['Mold Info', 'Prevention Tactics'],
                            tabContents: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 15.0),
                                child: MoldInfoSection(
                                    description: fullDescription,
                                    taxonomy: taxonomy,
                                  healthContent: healthContent,
                                  plantThreatContent: plantThreatContent,
                                  additionalInfoContent: additionalInfoContent,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 15.0),
                                child: PreventionTreatmentContent(
                                  recommendedFungicides: recommendedFungicides,
                                  resistanceContent: resistanceContent,
                                  alternativeMethodsContent: alternativeMethodsContent,
                                  additionalInfoTreatmentContent: additionalInfoContent,
                                ),
                              ),
                            ]
                        ),
                      ),

                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text(
                          'Disclaimer: This app only suggests possible mold genus based on image analysis. This should not replace expert advice or laboratory confirmation.',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Bricolage-Grotesque-Regular',
                            color: MoldifyColors.MoldifyGrey,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: BuildButton(
                          onPressed: () {
                            ///To do: Implement Save Result Functionality
                          },
                          buttonText: 'Save Result',
                          backgroundColor: MoldifyColors.primaryColor,
                          textColor: MoldifyColors.backgroundColor,
                          buttonHeight: 45,
                          buttonWidth: double.infinity,
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
    );
  }
}
