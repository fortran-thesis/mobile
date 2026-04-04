import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:moldify/l10n/app_localizations.dart';
import 'package:moldify/pages/misc/colors.dart';

import '../../misc/functions/empty_state.dart';
import 'package:moldify/core/utils/logger.dart';

/// This is the "Case Details" tab content in the "Monitoring" page for mycologists
/// It displays a timeline of case updates with dates, notes, and images.
/// This displays all the follow up entries of the farmer
class CaseDetailsTab extends StatelessWidget {
  final List<Map<String, dynamic>> entries;
  final String farmerName;
  final String? farmerOccupation;
  final String dateFirstObserved;
  final String emailAddress;
  final String contactNumber;
  final String? mycologistOccupation;

  const CaseDetailsTab({
    super.key,
    required this.entries,
    required this.farmerName,
    this.farmerOccupation,
    required this.dateFirstObserved,
    required this.emailAddress,
    required this.contactNumber,
    this.mycologistOccupation,
  });

  @override
  Widget build(BuildContext context) {
    /// Entries are displayed in reverse chronological order (most recent first)
    AppLogger.d('CaseDetailsTab.build(): entries.length = ${entries.length}');
    for (var i = 0; i < entries.length; i++) {
      AppLogger.d('  entry[$i]: ${entries[i]}');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Case Details Header
          Text(
            AppLocalizations.of(context)!.caseDetailsLabel,
            style: TextStyle(
              fontFamily: 'Montserrat-Black',
              fontSize: 20,
              color: MoldifyColors.primaryColor,
            ),
          ),
          Text(
            AppLocalizations.of(context)!.viewDetailsDescription,
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
                  const SizedBox(height: 20),

                  /// Submitted By Label
                  Text(
                    AppLocalizations.of(context)!.submittedBy,
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

                  /// Farmer Occupation (if available)
                  if (farmerOccupation != null &&
                      farmerOccupation!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      farmerOccupation!,
                      style: TextStyle(
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        fontSize: 12,
                        color: MoldifyColors.MoldifyGrey,
                      ),
                    ),
                  ],
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  /// Date First Observed Label
                  Text(
                    AppLocalizations.of(context)!.dateFirstObservedLabel,
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
              AppLocalizations.of(context)!.contactNumberLabel,
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

          /// Assigned Mycologist Occupation (if available)
          if (mycologistOccupation != null && mycologistOccupation!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                "Assigned Mycologist:",
                style: TextStyle(
                  fontFamily: 'Bricolage-Grotesque-Regular',
                  fontSize: 12,
                  color: MoldifyColors.primaryColor,
                ),
              ),
            ),
          if (mycologistOccupation != null && mycologistOccupation!.isNotEmpty)
            SizedBox(height: 4),
          if (mycologistOccupation != null && mycologistOccupation!.isNotEmpty)
            Text(
              mycologistOccupation!,
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
          if (entries.isEmpty)
            EmptyState(
              message: AppLocalizations.of(context)!.noInformationAvailable,
              icon: FontAwesomeIcons.circleInfo,
              height: MediaQuery.of(context).size.height - 500,
            )
          else
            ...List.generate(entries.length, (index) {
              AppLogger.d(
                'CaseDetailsTab: generating tile for index=$index, entries.length=${entries.length}',
              );
              final reversedIndex = entries.length - 1 - index;
              AppLogger.d(
                'CaseDetailsTab: reversedIndex=$reversedIndex, entry=${entries[reversedIndex]}',
              );
              return _CaseTimelineTile(
                dateTime: entries[reversedIndex]["date"],
                notes: entries[reversedIndex]["notes"],
                imageUrls: List<String>.from(entries[reversedIndex]["images"]),
                isLast: index == entries.length - 1,
              );
            }),
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
    AppLogger.d(
      '_CaseTimelineTile.build(): dateTime=$dateTime, notes=$notes, imageUrls=$imageUrls, isLast=$isLast',
    );
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
            Text(
              AppLocalizations.of(context)!.additionalNotes,
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
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 12),

            /// --- IMAGES ---
            if (imageUrls.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: imageUrls.map((url) {
                  return GestureDetector(
                    onTap: () {
                      final initialIndex = imageUrls.indexOf(url);

                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) {
                          final controller = PageController(
                            initialPage: initialIndex,
                          );
                          int currentIndex = initialIndex;

                          return StatefulBuilder(
                            builder: (context, setState) {
                              return Dialog(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                                backgroundColor: Colors.black.withValues(
                                  alpha: 0.9,
                                ),
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
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                          ),
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
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ),

                                    /// --- Bottom control bar (arrows + counter) ---
                                    Positioned(
                                      bottom: 30,
                                      left: 0,
                                      right: 0,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          /// Left arrow
                                          IconButton(
                                            icon: const Icon(
                                              Icons.arrow_back_ios_new,
                                              color:
                                                  MoldifyColors.backgroundColor,
                                              size: 20,
                                            ),
                                            onPressed: currentIndex > 0
                                                ? () {
                                                    controller.previousPage(
                                                      duration: const Duration(
                                                        milliseconds: 200,
                                                      ),
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
                                              color:
                                                  MoldifyColors.backgroundColor,
                                              fontSize: 16,
                                              fontFamily:
                                                  'Bricolage-Grotesque-Regular',
                                            ),
                                          ),
                                          const SizedBox(width: 16),

                                          /// Right arrow
                                          IconButton(
                                            icon: const Icon(
                                              Icons.arrow_forward_ios,
                                              color:
                                                  MoldifyColors.backgroundColor,
                                              size: 20,
                                            ),
                                            onPressed:
                                                currentIndex <
                                                    imageUrls.length - 1
                                                ? () {
                                                    controller.nextPage(
                                                      duration: const Duration(
                                                        milliseconds: 200,
                                                      ),
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
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[300],
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'No images available for this entry.',
                  style: TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    fontSize: 14,
                    color: MoldifyColors.MoldifyGrey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
