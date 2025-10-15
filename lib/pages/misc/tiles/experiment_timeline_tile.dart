import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../buttons/popmenu_button.dart';
import '../colors.dart';

class ExperimentTimelineTile extends StatelessWidget {
  final String dateTime;
  final String imagePath;
  final String colonyDiameter;
  final String colonyColor;
  final String notes;
  final bool isFirst;
  final bool isLast;

  const ExperimentTimelineTile({
    super.key,
    required this.dateTime,
    required this.imagePath,
    required this.colonyDiameter,
    required this.colonyColor,
    required this.notes,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      alignment: TimelineAlign.start,
      lineXY: 0.5,
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: IndicatorStyle(
        width: 10,
        color: MoldifyColors.primaryColor,
        indicatorXY: 0.1,
        padding: const EdgeInsets.all(6),
      ),
      beforeLineStyle: LineStyle(
        color: MoldifyColors.primaryColor,
        thickness: 1,
      ),
      endChild: Padding(
        padding: const EdgeInsets.only(left: 12.0, bottom: 24.0, right: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- DATE ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateTime,
                  style: const TextStyle(
                    color: MoldifyColors.MoldifyGrey,
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    fontSize: 12,
                  ),
                ),
                PopupMenu(
                  items: ['Edit Log', 'Delete Log'],
                  icons: [FontAwesomeIcons.pen, FontAwesomeIcons.trash],
                  popMenuColor: MoldifyColors.MoldifyGrey,
                  onItemSelected: (int index) {
                    // Handle menu item selection
                    if (index == 0) {
                      // Edit log action
                    } else if (index == 1) {
                      // Delete log action
                    }
                  },
                ),
              ],
            ),

            // --- IMAGE + DETAILS ROW ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGE
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (_) {
                        return Dialog(
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          backgroundColor: Colors.black.withValues(alpha: 0.9),
                          insetPadding: EdgeInsets.zero,
                          child: Stack(
                            children: [
                              Center(
                                child: InteractiveViewer(
                                  child: Image.network(
                                    imagePath,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 20,
                                right: 15,
                                child: IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white, size: 28),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imagePath,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // DETAILS COLUMN
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // COLONY DIAMETER & COLOR
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Colony Diameter:",
                                style: TextStyle(
                                  fontFamily: 'Bricolage-Grotesque-Bold',
                                  fontSize: 10,
                                  color: MoldifyColors.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                colonyDiameter,
                                style: const TextStyle(
                                  fontFamily: 'Bricolage-Grotesque-Regular',
                                  fontSize: 12,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Colony Color:",
                                style: TextStyle(
                                  fontFamily: 'Bricolage-Grotesque-Bold',
                                  fontSize: 10,
                                  color: MoldifyColors.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                colonyColor,
                                style: const TextStyle(
                                  fontFamily: 'Bricolage-Grotesque-Regular',
                                  fontSize: 12,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      const Text(
                        "Additional Notes:",
                        style: TextStyle(
                          fontFamily: 'Bricolage-Grotesque-Bold',
                          fontSize: 14,
                          color: MoldifyColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notes,
                        style: const TextStyle(
                          fontFamily: 'Bricolage-Grotesque-Regular',
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
