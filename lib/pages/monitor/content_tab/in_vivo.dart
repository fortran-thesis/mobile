import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/buttons/icon_button.dart';

import '../../misc/colors.dart';
import '../../misc/tiles/experiment_timeline_tile.dart';

class InVivoTab extends StatelessWidget {
  const InVivoTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> inVitroEntries = [
      {
        'date': 'October 2, 2025 • 09:14 PM',
        'imagePath': 'https://www.shutterstock.com/image-photo/colletotrichum-gloeosporioides-colony-culture-on-600nw-1248498718.jpg',
        'colonyDiameter': '20 mm',
        'colonyColor': 'White',
        'notes': 'Growth appears normal.',
      },
      {
        'date': 'October 5, 2025 • 10:30 AM',
        'imagePath': 'https://www.shutterstock.com/image-photo/colletotrichum-gloeosporioides-colony-culture-on-600nw-1248498718.jpg',
        'colonyDiameter': '35 mm',
        'colonyColor': 'Greenish center',
        'notes': 'Colonies expanding rapidly.',
      },
      {
        'date': 'October 2, 2025 • 09:14 PM',
        'imagePath': 'https://www.shutterstock.com/image-photo/colletotrichum-gloeosporioides-colony-culture-on-600nw-1248498718.jpg',
        'colonyDiameter': '20 mm',
        'colonyColor': 'White',
        'notes': 'Growth appears normal.',
      },
      {
        'date': 'October 5, 2025 • 10:30 AM',
        'imagePath': 'https://www.shutterstock.com/image-photo/colletotrichum-gloeosporioides-colony-culture-on-600nw-1248498718.jpg',
        'colonyDiameter': '35 mm',
        'colonyColor': 'Greenish center',
        'notes': 'Colonies expanding rapidly.',
      },
    ];
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
                      'October 2, 2025 • 09:14 PM',
                      style: TextStyle(
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        fontSize: 12,
                        color: MoldifyColors.MoldifyGrey,
                      ),
                    ),
                  ],
                ),
                BuildIconButton(
                    icon: FontAwesomeIcons.plus,
                    backgroundColor: MoldifyColors.MoldifySoftGrey,
                    color: MoldifyColors.MoldifyGrey,
                    onPressed: () {

                    }
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                /// Submitted By Label
                const Text(
                  "Environmental Temperature",
                  style: TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    fontSize: 12,
                    color: MoldifyColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                /// Farmer Name
                Text(
                  '36°C',
                  style: const TextStyle(
                    fontFamily: 'Montserrat-Black',
                    fontSize: 16,
                    color: MoldifyColors.primaryColor,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            /// Timeline Entries
            ...List.generate(inVitroEntries.length, (index) {
              final entry = inVitroEntries[index];
              return ExperimentTimelineTile(
                dateTime: entry['date'] ?? '',
                imagePath: entry['imagePath'] ?? '',
                colonyDiameter: entry['colonyDiameter'] ?? '',
                colonyColor: entry['colonyColor'] ?? '',
                notes: entry['notes'] ?? '',
                isFirst: index == 0,
                isLast: index == inVitroEntries.length - 1,
              );
            }),
          ],
        )
    );
  }
}