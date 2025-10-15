import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:moldify/pages/misc/colors.dart';

/// This is the "Case Details" tab content in the "Monitoring" page for mycologists
/// It displays a timeline of case updates with dates, notes, and images.
/// This displays all the follow up entries of the farmer
class CaseDetailsTab extends StatelessWidget {
  const CaseDetailsTab({super.key});

  @override
  Widget build(BuildContext context) {

    /// This is sample data. In a real app, this would come from a backend or database.
    final List<Map<String, dynamic>> entries = [
      {
        "date": "September 30, 2025 • 10:31 PM",
        "notes":
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut et massa mi. Aliquam in hendrerit urna.",
        "images": [
          "https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg",
          "https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg",
          "https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg",
          "https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg",

        ]
      },
      {
        "date": "October 2, 2025 • 09:14 PM",
        "notes":
        "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        "images": [
          "https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg",
          "https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg",
        ]
      },
      {
        "date": "October 5, 2025 • 8:10 PM",
        "notes": "Final update before closing the monitoring case.",
        "images": [
          "https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg",
          "https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg",
        ],
      },
    ];

    String farmerName = "Lauren Bishmilla";
    String dateFirstObserved = "10-20-25";
    String emailAddress = "laurenbishmilla@gmail.com";
    String contactNumber = "+639674306842";

    /// Entries are displayed in reverse chronological order (most recent first)
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Case Details Header
          Text (
            'Case Details',
            style: TextStyle(
              fontFamily: 'Montserrat-Black',
              fontSize: 20,
              color: MoldifyColors.primaryColor,
            ),
          ),
          Text (
            'View details reported by the farmer about the mold problem.',
            style: TextStyle(
              fontFamily: 'Bricolage-Grotesque-Regular',
              fontSize: 12,
              color: MoldifyColors.MoldifyGrey,
            ),
          ),
          /// End of Case Details Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  /// Submitted By Label
                  const Text(
                    "Submitted By:",
                    style: TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Regular',
                      fontSize: 12,
                      color: MoldifyColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  /// Farmer Name
                  Text(
                    farmerName,
                    style: const TextStyle(
                      fontFamily: 'Montserrat-Black',
                      fontSize: 16,
                      color: MoldifyColors.primaryColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  /// Date First Observed Label
                  const Text(
                    "Date First Observed:",
                    style: TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Regular',
                      fontSize: 12,
                      color: MoldifyColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),

                  /// Date First Observed Value
                  Text(
                    dateFirstObserved,
                    style: const TextStyle(
                      fontFamily: 'Montserrat-Black',
                      fontSize: 16,
                      color: MoldifyColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            /// Email Address Label
            child: Text(
              "Email Address:",
              style: TextStyle(
                fontFamily: 'Bricolage-Grotesque-Regular',
                fontSize: 12,
                color: MoldifyColors.primaryColor,
              ),
            ),
          ),
          SizedBox(height: 4),

          /// Email Address Value
          Text(
            emailAddress,
            style: TextStyle(
              fontFamily: 'Montserrat-Black',
              fontSize: 16,
              color: MoldifyColors.primaryColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            /// Contact Number Label
            child: Text(
              "Contact Number:",
              style: TextStyle(
                fontFamily: 'Bricolage-Grotesque-Regular',
                fontSize: 12,
                color: MoldifyColors.primaryColor,
              ),
            ),
          ),
          SizedBox(height: 4),
          /// Contact Number Value
          Text(
            contactNumber,
            style: TextStyle(
              fontFamily: 'Montserrat-Black',
              fontSize: 16,
              color: MoldifyColors.primaryColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Divider(),
          ),

          /// This is the list of case timeline entries provided by the farmers
          ...List.generate(
            entries.length,
                (index) {
              final reversedIndex = entries.length - 1 - index;
              return _CaseTimelineTile(
                dateTime: entries[reversedIndex]["date"],
                notes: entries[reversedIndex]["notes"],
                imageUrls: List<String>.from(entries[reversedIndex]["images"]),
                isLast: index == entries.length - 1,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// A single timeline tile representing one case update entry
/// Includes date/time, notes, and images
/// Tapping an image opens a dialog to view it larger with swipe navigation
class _CaseTimelineTile extends StatelessWidget {
  final String dateTime;
  final String notes;
  final List<String> imageUrls;
  final bool isLast;

  const _CaseTimelineTile({
    required this.dateTime,
    required this.notes,
    required this.imageUrls,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      alignment: TimelineAlign.start,
      lineXY: 0.1,
      isLast: isLast,
      indicatorStyle: IndicatorStyle(
        width: 10,
        color: MoldifyColors.primaryColor,
        indicatorXY: 0.0,
        padding: const EdgeInsets.all(6),
      ),
      beforeLineStyle: LineStyle(
        color: MoldifyColors.primaryColor,
        thickness: 1,
      ),
      endChild: Padding(
        padding: const EdgeInsets.only(left: 12.0, bottom: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- DATE & TIME ---
            Text(
              dateTime,
              style: const TextStyle(
                fontFamily: 'Bricolage-Grotesque-Regular',
                fontSize: 12,
                color: MoldifyColors.MoldifyGrey,
              ),
            ),
            const SizedBox(height: 6),

            /// --- ADDITIONAL NOTES ---
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
            const SizedBox(height: 12),

            /// --- IMAGES ---
            if (imageUrls.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: imageUrls.map(
                      (url) {
                    return GestureDetector(
                      onTap: () {
                        final initialIndex = imageUrls.indexOf(url);

                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) {
                            final controller = PageController(initialPage: initialIndex);
                            int currentIndex = initialIndex;

                            return StatefulBuilder(
                              builder: (context, setState) {
                                return Dialog(
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                  backgroundColor: Colors.black.withValues(alpha: 0.9),
                                  insetPadding: EdgeInsets.zero,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      /// --- Swipeable images ---
                                      PageView.builder(
                                        controller: controller,
                                        itemCount: imageUrls.length,
                                        onPageChanged: (index) {
                                          setState(() {
                                            currentIndex = index;
                                          });
                                        },
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                            child: InteractiveViewer(
                                              child: Center(
                                                child: Image.network(
                                                  imageUrls[index],
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                      /// --- Close button (top right) ---
                                      Positioned(
                                        top: 20,
                                        right: 15,
                                        child: IconButton(
                                          icon: const Icon(Icons.close, color: Colors.white, size: 28),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                      ),

                                      /// --- Bottom control bar (arrows + counter) ---
                                      Positioned(
                                        bottom: 30,
                                        left: 0,
                                        right: 0,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            /// Left arrow
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.arrow_back_ios_new,
                                                  color: MoldifyColors.backgroundColor,
                                                  size: 20
                                              ),
                                              onPressed: currentIndex > 0
                                                  ? () {
                                                controller.previousPage(
                                                  duration: const Duration(milliseconds: 200),
                                                  curve: Curves.easeInOut,
                                                );
                                              }
                                                  : null,
                                            ),
                                            const SizedBox(width: 16),

                                            /// Counter text
                                            Text(
                                              "${currentIndex + 1} / ${imageUrls.length}",
                                              style: const TextStyle(
                                                color: MoldifyColors.backgroundColor,
                                                fontSize: 16,
                                                fontFamily: 'Bricolage-Grotesque-Regular',
                                              ),
                                            ),
                                            const SizedBox(width: 16),

                                            /// Right arrow
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: MoldifyColors.backgroundColor,
                                                  size: 20
                                              ),
                                              onPressed: currentIndex < imageUrls.length - 1
                                                  ? () {
                                                controller.nextPage(
                                                  duration: const Duration(milliseconds: 200),
                                                  curve: Curves.easeInOut,
                                                );
                                              }
                                                  : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      /// --- Thumbnail image ---x
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          url,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
