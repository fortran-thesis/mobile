import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/tiles/bottom_sheet.dart';
import 'package:moldify/pages/misc/tiles/bottom_sheet_contents/culture_timer.dart';

import '../../misc/colors.dart';
import '../../misc/functions/empty_state.dart';
import 'package:moldify/pages/misc/tiles/experiment_timeline_tile.dart';

class InVitroTab extends StatelessWidget {
  // This is used to determine if the case is closed
  final bool isCaseClosed;
  final String dateTime;
  final String growthMedium;
  final String incubationTemperature;
  final List<Map<String, String>> inVitroEntries;
  final String caseId;
  final String? initialMicroIdentifiedMold;
  final String? initialMacroColor;
  final String? initialMacroTexture;
  final String? initialMacroSymptoms;
  final String? initialMacroCharacteristics;
  final ValueChanged<Map<String, dynamic>>? onLogSaved;

  const InVitroTab({
    super.key,
    required this.isCaseClosed,
    required this.dateTime,
    required this.growthMedium,
    required this.incubationTemperature,
    required this.inVitroEntries,
    required this.caseId,
    this.initialMicroIdentifiedMold,
    this.initialMacroColor,
    this.initialMacroTexture,
    this.initialMacroSymptoms,
    this.initialMacroCharacteristics,
    this.onLogSaved,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      // --- THE CONTROL BAR ---
      Container(
        padding: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: MoldifyColors.primaryColor.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IN VITRO',
                  style: TextStyle(
                    fontFamily: 'Montserrat-Black',
                    fontSize: 18,
                    letterSpacing: -0.5,
                    color: MoldifyColors.primaryColor,
                  ),
                ),
                Text(
                  inVitroEntries.isEmpty ? 'NO ENTRIES FOUND' : dateTime.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Bold',
                    fontSize: 8,
                    letterSpacing: 1.0,
                    color: MoldifyColors.primaryColor.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),

            // --- ACTION BUTTONS ---
            if (!isCaseClosed)
              Row(
                children: [
                  BuildButton(
                    buttonText: 'CULTURE',
                    onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => BuildBottomSheet(
                          showDragHandle: true,
                          child: CultureHubBottomSheetContent(
                            onCreateNew: () {
                              Navigator.of(context).pop();
                              Navigator.pushNamed(
                                context,
                                RouteNames.setCulture,
                                arguments: {'caseId': caseId},
                              ).then((result) {
                                if (result is! Map<String, dynamic>) return;
                                final cultureName = result['name']?.toString().trim();
                                if (cultureName == null || cultureName.isEmpty) return;
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Culture "$cultureName" initialized.')),
                                );
                              });
                            },
                            onViewActive: () {
                              Navigator.of(context).pop();
                              Navigator.pushNamed(
                                context,
                                RouteNames.cultureDashboard,
                                arguments: {'caseId': caseId},
                              );

                            },
                          ),
                        ),
                      );
                    },
                    backgroundColor: Colors.transparent,
                    textColor: MoldifyColors.primaryColor.withValues(alpha: 0.6),
                    buttonHeight: 30,
                    buttonRadius: 0,
                    fontSize: 12,
                  ),
                  const SizedBox(width: 4),
                  const Text("|", style: TextStyle(color: Colors.black12)),
                  const SizedBox(width: 4),
                  BuildButton(
                    buttonText: 'ADD LOG',
                    onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          RouteNames.addLogChoices,
                          arguments: {
                            'sourceTab': 'in-vitro',
                            'caseId': caseId,
                            'includeSize': false,
                            'initialMicroIdentifiedMold': initialMicroIdentifiedMold,
                            'initialMacroColor': initialMacroColor,
                            'initialMacroTexture': initialMacroTexture,
                            'initialMacroSymptoms': initialMacroSymptoms,
                            'initialMacroCharacteristics': initialMacroCharacteristics,
                          },
                        );

                        if (result is Map && onLogSaved != null) {
                          onLogSaved!(Map<String, dynamic>.from(result));
                        }
                      },
                    backgroundColor: Colors.transparent,
                    textColor: MoldifyColors.primaryColor,
                    leftIcon: FontAwesomeIcons.plus,
                    iconColor: MoldifyColors.primaryColor,
                    iconSize: 10,
                    paddingIconText: 6,
                    buttonHeight: 30,
                    buttonRadius: 0,
                    fontSize: 12,
                  ),
                ],
              ),
            ],
          ),
        ),

      const SizedBox(height: 25),

            if (inVitroEntries.isEmpty)
              EmptyState(
                message: 'No entries made yet.',
                icon: FontAwesomeIcons.flaskVial,
                height: MediaQuery.of(context).size.height - 400,
              )
            else
              ...List.generate(inVitroEntries.length, (index) {
                final entry = inVitroEntries[index];
                return ExperimentTimelineTile(
                  dateTime: entry['date'] ?? '',
                  microscopicImagePath: entry['microscopicImagePath'] ?? '',
                  microGenusName: entry['microGenusName'] ?? '',
                  macroscopicImagePath: entry['macroscopicImagePath'] ?? '',
                  macroShape: entry['macroShape'] ?? '',
                  macroTexture: entry['macroTexture'] ?? '',
                  shapeLabel: 'Colony Shape',
                  textureLabel: 'Colony Texture',
                  macroSymptoms: entry['macroSymptoms'] ?? '',
                  macroCharacteristics: entry['macroCharacteristics'] ?? '',
                  cultureName: entry['cultureName'] ?? '',
                  isFirst: index == 0,
                  isLast: index == inVitroEntries.length - 1,
                  // Hide popup menu when the case is closed
                  popupMenuItems: isCaseClosed ? [] : ['Edit Log', 'Delete Log'],
                  popupMenuIcons: isCaseClosed ? [] : [FontAwesomeIcons.pen, FontAwesomeIcons.trash],
                  onPopupMenuItemSelected: isCaseClosed ? null : (selectedIndex) {
                    if (selectedIndex == 0) {
                      Navigator.pushNamed(
                        context,
                        RouteNames.editLog,
                        arguments: {'tabName': 'In Vitro'},
                      );
                    } else if (selectedIndex == 1) {
                      // TODO: Handle delete
                    }
                  },
                );
              }),
          ],
        )
    );
  }
}