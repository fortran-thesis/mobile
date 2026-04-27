import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/core/features/mold_case/service/mold_case_service.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/core/utils/mutation_result.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/overlays/modals/confirmation_dialog.dart';
import 'package:moldify/pages/misc/tiles/bottom_sheet.dart';
import 'package:moldify/pages/misc/tiles/bottom_sheet_contents/culture_timer.dart';
import 'package:moldify/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../misc/colors.dart';
import '../../misc/functions/empty_state.dart';
import 'package:moldify/pages/misc/tiles/experiment_timeline_tile.dart';

class InVivoTab extends StatelessWidget {
  final bool isCaseClosed;
  final String dateTime;
  final String environmentalTemperature;
  final List<Map<String, String>> inVivoEntries;
  final String caseId;
  final String? initialMicroIdentifiedMold;
  final String? initialMacroColor;
  final String? initialMacroTexture;
  final String? initialMacroSymptoms;
  final String? initialMacroSigns;
  final String? initialMacroCharacteristics;
  final ValueChanged<Map<String, dynamic>>? onLogSaved;

  const InVivoTab({
    super.key,
    required this.isCaseClosed,
    required this.dateTime,
    required this.environmentalTemperature,
    required this.inVivoEntries,
    required this.caseId,
    this.initialMicroIdentifiedMold,
    this.initialMacroColor,
    this.initialMacroTexture,
    this.initialMacroSymptoms,
    this.initialMacroSigns,
    this.initialMacroCharacteristics,
    this.onLogSaved,
  });

  Future<void> _deleteLogEntry(
    BuildContext context,
    Map<String, String> entry,
  ) async {
    final logId = entry['logId']?.trim() ?? '';
    if (logId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No log entry found to delete.')),
      );
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BuildConfirmationDialog(
          title: 'Delete log entry?',
          subtitle:
              'This will permanently remove the selected in vivo log entry.',
          onConfirm: () => Navigator.of(dialogContext).pop(true),
          onCancel: () => Navigator.of(dialogContext).pop(false),
          cancelText: 'Cancel',
          confirmText: 'Delete',
        );
      },
    );

    if (shouldDelete != true || !context.mounted) return;

    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final service = MoldCaseService();
      await service.deleteCultivationLog(
        caseId,
        logId,
        sessionCookie: authProvider.cookie,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log entry deleted.')),
      );

      onLogSaved?.call(
        const MutationResult.changed(tags: [MutationTags.moldCase]).toMap(),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete log entry: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      'IN VIVO',
                      style: TextStyle(
                        fontFamily: 'Montserrat-Black',
                        fontSize: 18,
                        letterSpacing: -0.5,
                        color: MoldifyColors.primaryColor,
                      ),
                    ),
                    Text(
                      inVivoEntries.isEmpty
                          ? 'NO ENTRIES FOUND'
                          : dateTime.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Bricolage-Grotesque-Bold',
                        fontSize: 8,
                        letterSpacing: 1.0,
                        color: MoldifyColors.primaryColor.withValues(
                          alpha: 0.5,
                        ),
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
                                    final cultureName = result['name']
                                        ?.toString()
                                        .trim();
                                    if (cultureName == null ||
                                        cultureName.isEmpty) {
                                      return;
                                    }
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Culture "$cultureName" initialized.',
                                        ),
                                      ),
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
                        textColor: MoldifyColors.primaryColor.withValues(
                          alpha: 0.6,
                        ),
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
                              'sourceTab': 'in-vivo',
                              'caseId': caseId,
                              'includeSize': false,
                              'initialMicroIdentifiedMold':
                                  initialMicroIdentifiedMold,
                              'initialMacroColor': initialMacroColor,
                              'initialMacroTexture': initialMacroTexture,
                              'initialMacroSymptoms': initialMacroSymptoms,
                              'initialMacroSigns': initialMacroSigns,
                              'initialMacroCharacteristics':
                                  initialMacroCharacteristics,
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

          SizedBox(height: 12),

          if (inVivoEntries.isEmpty)
            EmptyState(
              message: 'No entries made yet.',
              icon: FontAwesomeIcons.leaf,
              height: MediaQuery.of(context).size.height - 400,
            )
          else
            ...List.generate(inVivoEntries.length, (index) {
              final entry = inVivoEntries[index];
              return ExperimentTimelineTile(
                dateTime: entry['date'] ?? '',
                popupMenuItems: isCaseClosed ? const [] : const ['Delete'],
                popupMenuIcons: isCaseClosed
                    ? const []
                    : const [FontAwesomeIcons.solidTrashCan],
                onPopupMenuItemSelected: isCaseClosed
                    ? null
                    : (menuIndex) {
                        if (menuIndex == 0) {
                          unawaited(_deleteLogEntry(context, entry));
                        }
                      },
                microscopicImagePath: entry['microscopicImagePath'] ?? '',
                microGenusName: entry['microGenusName'] ?? '',
                macroscopicImagePath: entry['macroscopicImagePath'] ?? '',
                macroShape: entry['macroShape'] ?? '',
                macroTexture: entry['macroTexture'] ?? '',
                shapeLabel: 'Lesion Shape',
                textureLabel: 'Lesion Texture',
                macroSymptoms: entry['macroSymptoms'] ?? '',
                macroSigns: entry['macroSigns'] ?? '',
                macroCharacteristics: entry['macroCharacteristics'] ?? '',
                cultureName: entry['cultureName'] ?? '',
                isFirst: index == 0,
                isLast: index == inVivoEntries.length - 1,
              );
            }),
        ],
      ),
    );
  }
}
