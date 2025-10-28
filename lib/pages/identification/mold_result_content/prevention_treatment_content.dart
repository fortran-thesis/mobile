import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart'; // use Material instead of Cupertino for TextStyle & Column
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../misc/colors.dart';
import '../../misc/tiles/content_tile.dart';

class PreventionTreatmentContent extends StatefulWidget {
  final List<String> recommendedFungicides;
  final String resistanceContent;
  final String alternativeMethodsContent;
  final String additionalInfoTreatmentContent;

  const PreventionTreatmentContent({
    super.key,
    required this.recommendedFungicides,
    required this.resistanceContent,
    required this.alternativeMethodsContent,
    required this.additionalInfoTreatmentContent,
  });

  @override
  State<PreventionTreatmentContent> createState() =>
      _PreventionTreatmentContentState();
}

class _PreventionTreatmentContentState
    extends State<PreventionTreatmentContent> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Add some breathing room
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Recommended Fungicides Section
            if (widget.recommendedFungicides.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: const AutoSizeText(
                  'Recommended Fungicides:',
                  style: TextStyle(
                    fontFamily: 'Bricolage-Grotesque-SemiBold',
                    fontSize: 16,
                    color: MoldifyColors.primaryColor,
                  ),
                  minFontSize: 10,
                ),
              ),
              const SizedBox(height: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.recommendedFungicides.map((fungicide) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 15, right:15, bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(fontSize: 15, height: 1.4),
                        ),
                        Expanded(
                          child: AutoSizeText(
                            fungicide,
                            style: const TextStyle(
                              height: 1.4,
                              fontFamily: 'Bricolage-Grotesque-Regular',
                              fontSize: 16,
                              color: MoldifyColors.MoldifyBlack,
                            ),
                            minFontSize: 10,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Divider(
                  color: MoldifyColors.MoldifySoftGrey,
                  height: 20,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: ContentTile(
                  icon: Icons.health_and_safety,
                  title: "Resistance/Risk Notes",
                  content: widget.resistanceContent,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                child: ContentTile(
                  icon: FontAwesomeIcons.plantWilt,
                  title: "Alternative/Biological Methods",
                  content: widget.alternativeMethodsContent,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: ContentTile(
                  icon: FontAwesomeIcons.circleInfo,
                  title: "Additional Information",
                  content: widget.additionalInfoTreatmentContent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
