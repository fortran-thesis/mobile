import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/tiles/content_tile.dart';

class MoldInfoSection extends StatefulWidget {
  final String description;
  final Map<String, String> taxonomy;
  final String healthContent;
  final String plantThreatContent;
  final String additionalInfoContent;

  const MoldInfoSection({
    super.key,
    required this.description,
    required this.taxonomy,
    required this.healthContent,
    required this.plantThreatContent,
    required this.additionalInfoContent,
  });

  @override
  State<MoldInfoSection> createState() => _MoldInfoSectionState();
}

class _MoldInfoSectionState extends State<MoldInfoSection> {
  bool _showFullText = false;
  late TapGestureRecognizer _tapRecognizer;

  @override
  void initState() {
    super.initState();
    _tapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        setState(() {
          _showFullText = !_showFullText;
        });
      };
  }

  @override
  void dispose() {
    _tapRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> words = widget.description.split(' ');
    final bool isLongText = words.length > 40;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Description section
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text.rich(
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
                        : widget.description,
                  ),
                  if (isLongText)
                    TextSpan(
                      text: _showFullText ? ' Show Less' : '... Show More',
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
      
          if (isLongText) const SizedBox(height: 10),
      
          /// Taxonomy section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: MoldifyColors.backgroundColor,
                border: Border.all(
                  color: MoldifyColors.primaryColor,
                  width: 1.2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Header
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.sitemap,
                          color: MoldifyColors.accentColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Taxonomy',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Bricolage-Grotesque-SemiBold',
                            color: MoldifyColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
      
                    /// Taxonomy Key-Value Rows
                    ...widget.taxonomy.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                entry.key,
                                style: TextStyle(
                                  fontFamily: 'Bricolage-Grotesque-Regular',
                                  fontSize: 16,
                                  color: MoldifyColors.MoldifyBlack,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                entry.value,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontFamily: 'Bricolage-Grotesque-Regular',
                                  fontSize: 16,
                                  color: MoldifyColors.MoldifyBlack,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
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
              title: "Health Risk",
              content: widget.healthContent,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            child: ContentTile(
              icon: FontAwesomeIcons.plantWilt,
              title: "Threat To Plants",
              content: widget.plantThreatContent,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: ContentTile(
              icon: FontAwesomeIcons.circleInfo,
              title: "Additional Information",
              content: widget.additionalInfoContent,
            ),
          ),
      
        ],
      ),
    );
  }
}
