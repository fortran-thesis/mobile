import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/tiles/identification_history_tile.dart';

import '../misc/appbar/primary_app_bar.dart';
import '../misc/colors.dart';
import '../misc/functions/empty_state.dart';
import '../misc/textboxes/textboxes.dart';

class IdentificationHistoryScreen extends StatefulWidget{
  const IdentificationHistoryScreen({super.key});

  @override
  State<IdentificationHistoryScreen> createState() => _IdentificationHistoryScreenState();

}

class _IdentificationHistoryScreenState extends State<IdentificationHistoryScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    /// Sample data for WikiMold articles
    final List<Map<String, String?>> moldsIdentified = [
      {
        'moldName': 'Wowerz',
        'dateIdentified': 'October 25, 2025',
      },
      {
        'moldName': 'Wowerz',
        'dateIdentified': 'October 25, 2025',
      },
      {
        'moldName': 'Wowerz',
        'dateIdentified': 'October 25, 2025',
      },
      {
        'moldName': 'Wowerz',
        'dateIdentified': 'October 25, 2025',
      },
    ];

    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(
        title: 'Identification History',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
          child: Column(
            children: [
              /// ----------- Identification History Header -----------
              Text(
                  'Identification History',
                  style: TextStyle(
                    fontSize: 36,
                    fontFamily: 'Montserrat-Black',
                    color: MoldifyColors.primaryColor,
                  )
              ),
              Text(
                  'Review the history of identifications made for this mold case.',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    color: MoldifyColors.MoldifyBlack,
                  )
              ),
              /// ----------- End of Identification History Header -----------

              /// Search Box
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                child: BuildTextBox(
                  hintText: 'Search History',
                  controller: searchController,
                  showPassword: false,
                  rightIcon: FontAwesomeIcons.magnifyingGlass,
                ),
              ),

              moldsIdentified.isEmpty
                  ? EmptyState(
                message: 'No identification history available.',
                icon: FontAwesomeIcons.clockRotateLeft,
                height: MediaQuery.of(context).size.height - 300,
              ):
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: moldsIdentified.length,
                itemBuilder: (context, index) {
                  final molds = moldsIdentified[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: IdentificationHistoryTile(
                        moldName: molds['moldName']!,
                        dateIdentified: molds['dateIdentified']!,
                        onTap: () {
                          // Navigator.pushNamed(
                          //   context,
                          //   '/view-case',
                          // );
                          /// TODO: Navigate to the mold result scren
                        },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}