// ignore_for_file: library_private_types_in_public_api
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../colors.dart';

class FlagHistoryTile extends StatefulWidget {
  final String systemPredicted;
  final String correctedGenus;
  final String dateFlagged;
  final String? imageUrl;
  // final VoidCallback onTap;

  const FlagHistoryTile({
    super.key,
    this.imageUrl,
    required this.systemPredicted,
    required this.correctedGenus,
    required this.dateFlagged,
  });

  @override
  _FlagHistoryTileState createState() => _FlagHistoryTileState();
}

class _FlagHistoryTileState extends State<FlagHistoryTile> {
  @override
  Widget build(BuildContext context) {
    final String defaultImageUrl = 'assets/images/Branding2.png';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(7.0),
      decoration: BoxDecoration(
        color: MoldifyColors.taupe,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.asset(
                    (widget.imageUrl != null && widget.imageUrl != "no_image")
                        ? widget.imageUrl!
                        : defaultImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: MoldifyColors.MoldifySoftGrey,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: MoldifyColors.primaryColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 15.0),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0, right: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          AutoSizeText(
                            'System Predicted: ',
                            style: const TextStyle(
                              fontSize: 10.0,
                              color: MoldifyColors.primaryColor,
                              fontFamily: 'Bricolage-Grotesque-Bold',
                            ),
                            maxLines: 1,
                            minFontSize: 8,
                          ),
                          AutoSizeText(
                            widget.systemPredicted,
                            style: const TextStyle(
                              fontSize: 10.0,
                              color: MoldifyColors.MoldifyBlack,
                              fontFamily: 'Bricolage-Grotesque-Regular',
                            ),
                            maxLines: 1,
                            minFontSize: 8,
                          ),
                        ],
                      ),
                      SizedBox(height: 5.0),

                      /// Corrected Genus
                      Row(
                        children: [
                          AutoSizeText(
                            'Corrected Genus: ',
                            style: const TextStyle(
                              fontSize: 10.0,
                              color: MoldifyColors.primaryColor,
                              fontFamily: 'Bricolage-Grotesque-Bold',
                            ),
                            maxLines: 1,
                            minFontSize: 8,
                          ),
                          AutoSizeText(
                            widget.correctedGenus,
                            style: const TextStyle(
                              fontSize: 10.0,
                              color: MoldifyColors.MoldifyBlack,
                              fontFamily: 'Bricolage-Grotesque-Regular',
                            ),
                            maxLines: 1,
                            minFontSize: 8,
                          ),
                        ],
                      ),

                      SizedBox(height: 5.0),
                      /// Date Flagged
                      Row(
                        children: [
                          AutoSizeText(
                            'Date Flagged: ',
                            style: const TextStyle(
                              fontSize: 10.0,
                              color: MoldifyColors.primaryColor,
                              fontFamily: 'Bricolage-Grotesque-Bold',
                            ),
                            maxLines: 1,
                            minFontSize: 8,
                          ),
                          AutoSizeText(
                            widget.dateFlagged,
                            style: const TextStyle(
                              fontSize: 10.0,
                              color: MoldifyColors.MoldifyBlack,
                              fontFamily: 'Bricolage-Grotesque-Regular',
                            ),
                            maxLines: 1,
                            minFontSize: 8,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}