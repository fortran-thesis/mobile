import 'package:moldify/core/features/camera/models/camera_model_result.dart';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/colors.dart';
import '../misc/appbar/primary_app_bar.dart';
import 'package:intl/intl.dart';

import '../misc/buttons/primary_button.dart';
import '../misc/overlays/modals/confirmation_dialog.dart';
import '../misc/tiles/bottom_sheet.dart';
import '../misc/tiles/bottom_sheet_contents/correction_content.dart';


class MoldResultScreen extends StatefulWidget {
  final String croppedImagePath;
  final Map<String, dynamic>? modelResult;

  const MoldResultScreen({super.key, required this.croppedImagePath, this.modelResult});

  @override
  State<MoldResultScreen> createState() => _MoldResultScreenState();
}

class _MoldResultScreenState extends State<MoldResultScreen> {
  late String confidenceLevel;
  late String moldGenus;

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

  @override
  void initState() {
    super.initState();
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
  } else {
    confidenceLevel = '';
  }
  // Extract only the genus from 'genus_spp' format
  final predictedClass = widget.modelResult?['predicted_class']?.toString() ?? '';
  moldGenus = predictedClass.contains('_') ? predictedClass.split('_')[0] : predictedClass;
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
                    onSave: (correctedText) {
                      // Add your save logic here
                      print('Corrected Text: $correctedText');
                      Navigator.of(context).pop();
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
                      // Verified Information Banner
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text(
                          'Most probably identified mold genus:',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Bricolage-Grotesque-Regular',
                            color: MoldifyColors.MoldifyGrey,
                          ),
                        )
                      ),
              
                      /// This is the Mold Genus Name
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          moldGenus,
                          style: TextStyle(
                            fontSize: 40,
                            fontFamily: 'Montserrat-Black',
                            color: MoldifyColors.primaryColor,
                          ),
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
                            RichText(
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Icon(
                                      FontAwesomeIcons.solidCalendar,
                                      size: 16,
                                      color: MoldifyColors.accentColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "			$today",
                                    style: TextStyle(
                                      color: MoldifyColors.primaryColor,
                                      fontSize: 12,
                                      fontFamily:
                                      'Bricolage-Grotesque-Regular',
                                    ),
                                  ),
                                ],
                              ),
                            ),
              
                            /// Confidence Level
                            RichText(
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Icon(
                                      FontAwesomeIcons.chartSimple,
                                      size: 16,
                                      color: MoldifyColors.accentColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                    "			Confidence level: $confidenceLevel%",
                                    style: TextStyle(
                                      color: MoldifyColors.primaryColor,
                                      fontSize: 12,
                                      fontFamily:
                                      'Bricolage-Grotesque-Regular',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              
                      Divider(color: MoldifyColors.MoldifySoftGrey),
              
                      /// Mold Description
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text.rich(

                          /// This is the description of the mold genus
                          TextSpan(
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Bricolage-Grotesque-Regular',
                              color: MoldifyColors.MoldifyBlack,
                              height: 1.5,
                            ),
                            children: [
                              TextSpan(
                                text: (isLongText && !_showFullText)
                                    ? words.take(40).join(' ')
                                    : fullDescription,
                              ),

                              /// Tappable "Learn More" or "Show Less"
                              if (isLongText)
                                TextSpan(
                                  text: _showFullText
                                      ? ' Show Less'
                                      : '... Show More',
                                  style: TextStyle(
                                    color: MoldifyColors.MoldifyBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: _tapRecognizer,
                                ),
                            ],
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),


                      /// Taxonomy Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: MoldifyColors.backgroundColor,
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                            border: Border.all(
                              color: MoldifyColors.primaryColor,
                              width: 2,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                /// Taxonomy Header
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Icon(
                                          FontAwesomeIcons.sitemap,
                                          size: 20,
                                          color: MoldifyColors.accentColor,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "			Taxonomy",
                                        style: TextStyle(
                                          color: MoldifyColors.primaryColor,
                                          fontSize: 16,
                                          fontFamily:
                                          'Bricolage-Grotesque-Bold',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                /// Taxonomy Details
                                /// Using a Column to list each taxonomy level
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: taxonomy.entries.map((entry) {
                                      bool isFirst = taxonomy.keys.first == entry.key;
                                      return buildTaxonomyRow(entry.key, entry.value, withPadding: !isFirst);
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0, left: 15.0, right: 15.0),
                        child: Text(
                          "Disclaimer: This app only suggests possible mold genus based on image analysis. This should not replace expert advice or laboratory confirmation.",
                          style: TextStyle(
                              fontFamily: "Bricolage-Grotesque-Regular",
                              fontSize: 12,
                              color: MoldifyColors.MoldifyGrey,
                          ),
                        ),
                      ),

                      /// Save Log Button
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 15.0, right: 15.0),
                        child: BuildButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return BuildConfirmationDialog(
                                    title: 'Save Result?',
                                    subtitle: 'Are you sure you want to save result?',
                                    onConfirm: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    },
                                    onCancel: (){
                                      Navigator.of(context).pop();
                                    },
                                  );
                                },
                              );
                            },
                            buttonText: 'Save Result',
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
    );
  }

  /// A helper method to build a row for taxonomy information.
  /// Parameters:
  /// - [label]: The label for the taxonomy level (e.g., "Kingdom").
  /// - [value]: The corresponding value for the taxonomy level (e.g., "Fungi").
  /// - [withPadding]: A boolean indicating whether to add top padding to the row.
  Widget buildTaxonomyRow(String label, String value, {bool withPadding = false}) {
    return Padding(
      padding: EdgeInsets.only(top: withPadding ? 8.0 : 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: MoldifyColors.primaryColor,
              fontSize: 16,
              fontFamily: 'Bricolage-Grotesque-Bold',
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: MoldifyColors.MoldifyBlack,
              fontSize: 16,
              fontFamily: 'Bricolage-Grotesque-Regular',
            ),
          ),
        ],
      ),
    );
  }
}
