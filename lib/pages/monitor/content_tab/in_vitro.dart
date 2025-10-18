import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/pages/misc/buttons/icon_button.dart';

import '../../misc/colors.dart';
import '../../misc/functions/empty_state.dart';
import '../../misc/tiles/experiment_timeline_tile.dart';

class InVitroTab extends StatelessWidget {
  // This is used to determine if the case is closed
  final bool isCaseClosed;
  const InVitroTab({super.key, required this.isCaseClosed});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> inVitroEntries = [
      {
        'date': 'October 2, 2025 • 09:14 PM',
        'imagePath': 'https://www.shutterstock.com/image-photo/colletotrichum-gloeosporioides-colony-culture-on-600nw-1248498718.jpg',
        'sizeValue': '20 mm',
        'colorValue': 'White',
        'notes': 'Growth appears normal.',
      },
      {
        'date': 'October 5, 2025 • 10:30 AM',
        'imagePath': 'https://www.shutterstock.com/image-photo/colletotrichum-gloeosporioides-colony-culture-on-600nw-1248498718.jpg',
        'sizeValue': '35 mm',
        'colorValue': 'Greenish center',
        'notes': 'Colonies expanding rapidly.',
      },
    ];
    String dateTime = 'October 2, 2025 • 09:14 PM';
    String growthMedium = 'PDA';
    String incubationTemperature = '36°C';

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
                    'In Vitro',
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
              //Conditionally show the 'Add' button if the case is not closed
              if (!isCaseClosed)
              BuildIconButton(
                  icon: FontAwesomeIcons.plus,
                  backgroundColor: MoldifyColors.MoldifySoftGrey,
                  color: MoldifyColors.MoldifyGrey,
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      RouteNames.addLogInstructions,
                      arguments: {'sourceTab': 'in-vitro'},
                    );
                  }
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    "Growth Medium",
                    style: TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Regular',
                      fontSize: 12,
                      color: MoldifyColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    growthMedium,
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
                  const Text(
                    "Incubation Temperature",
                    style: TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Regular',
                      fontSize: 12,
                      color: MoldifyColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    incubationTemperature,
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
          SizedBox(height: 12),

          inVitroEntries.isEmpty
              ? EmptyState(
            message: 'No entries made yet.',
            icon: FontAwesomeIcons.flaskVial,
            height: MediaQuery.of(context).size.height - 400,
          ): const SizedBox.shrink(),
          /// Timeline Entries
          ...List.generate(inVitroEntries.length, (index) {
            final entry = inVitroEntries[index];
            return ExperimentTimelineTile(
              dateTime: entry['date'] ?? '',
              imagePath: entry['imagePath'] ?? '',
              sizeValue: entry['sizeValue'] ?? '',
              colorValue: entry['colorValue'] ?? '',
              notes: entry['notes'] ?? '',
              isFirst: index == 0,
              isLast: index == inVitroEntries.length - 1,
                //Conditionally provide empty lists to hide the popup menu if the case is closed
                popupMenuItems: isCaseClosed ? [] : ['Edit Log', 'Delete Log'],
                popupMenuIcons: isCaseClosed ? [] : [FontAwesomeIcons.pen, FontAwesomeIcons.trash, ],
                onPopupMenuItemSelected: isCaseClosed ? null : (selectedIndex) {
                  if (selectedIndex == 0) {
                    Navigator.pushNamed(
                        context,
                        '/edit-log', arguments: {'tabName': 'In Vitro'}
                    );
                  }
                  else if (selectedIndex == 1) {
                    // Handle delete
                  }
                },
              sizeLabel: 'Colony Diameter',
              colorLabel: 'Colony Color',
            );
          }),
        ],
      )
    );
  }
}
