import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/pages/misc/buttons/icon_button.dart';

import '../../misc/colors.dart';
import '../../misc/functions/empty_state.dart';
import '../../misc/tiles/experiment_timeline_tile.dart';

class InVivoTab extends StatelessWidget {
  final bool isCaseClosed;
  final String dateTime;
  final String environmentalTemperature;
  final List<Map<String, String>> inVivoEntries;

  const InVivoTab({
    super.key,
    required this.isCaseClosed,
    required this.dateTime,
    required this.environmentalTemperature,
    required this.inVivoEntries,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text (
                      'In Vivo',
                      style: TextStyle(
                        fontFamily: 'Montserrat-Black',
                        fontSize: 20,
                        color: MoldifyColors.primaryColor,
                      ),
                    ),
                    Text (
                      dateTime,
                      style: TextStyle(
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        fontSize: 12,
                        color: MoldifyColors.MoldifyGrey,
                      ),
                    ),
                  ],
                ),
                // Conditionally show the 'Add' button if the case is not closed
                if (!isCaseClosed)
                  BuildIconButton(
                      icon: FontAwesomeIcons.plus,
                      backgroundColor: MoldifyColors.MoldifySoftGrey,
                      color: MoldifyColors.MoldifyGrey,
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          RouteNames.addLogInstructions,
                          arguments: {'sourceTab': 'in-vivo'},
                        );
                      }
                  )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Text(
                  "Environmental Temperature",
                  style: TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    fontSize: 12,
                    color: MoldifyColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  environmentalTemperature,
                  style: const TextStyle(
                    fontFamily: 'Montserrat-Black',
                    fontSize: 16,
                    color: MoldifyColors.primaryColor,
                  ),
                ),
              ],
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
                  imagePath: entry['imagePath'] ?? '',
                  sizeValue: entry['sizeValue'] ?? '',
                  colorValue: entry['colorValue'] ?? '',
                  notes: entry['notes'] ?? '',
                  isFirst: index == 0,
                  isLast: index == inVivoEntries.length - 1,
                  // Conditionally provide empty lists to hide the popup menu if the case is closed
                  popupMenuItems: isCaseClosed ? [] : ['Edit Log', 'Delete Log'],
                  popupMenuIcons: isCaseClosed ? [] : [FontAwesomeIcons.pen, FontAwesomeIcons.trash, ],
                  onPopupMenuItemSelected: isCaseClosed ? null : (selectedIndex) {
                    if (selectedIndex == 0) {
                      Navigator.pushNamed(
                          context,
                          '/edit-log', arguments: {'tabName': 'In Vivo'}
                      );
                    }
                    else if (selectedIndex == 1) {
                      // Handle delete
                    }
                  },
                  sizeLabel: 'Lesion Size',
                  colorLabel: 'Lesion Color',
                );
              }),
          ],
        )
    );
  }
}
