import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../misc/appbar/primary_app_bar.dart';
import '../misc/colors.dart';
import '../misc/functions/empty_state.dart';
import '../misc/textboxes/textboxes.dart';
import '../misc/tiles/flag_history_tile.dart';

class FlagHistoryScreen extends StatefulWidget {
  const FlagHistoryScreen({Key? key}) : super(key: key);

  @override
  State<FlagHistoryScreen> createState() => _FlagHistoryScreenState();
}

class _FlagHistoryScreenState extends State<FlagHistoryScreen> {
  final TextEditingController searchController = TextEditingController();
  /// Sample data for Closed Assigned Cases
  final List<Map<String, String?>> flaggedHistory = [
    {
      'systemPredicted': 'Rhizopus',
      'correctedGenus': 'Penicillium',
      'dateFlagged': 'November 01, 2025',
    },
    {
      'systemPredicted': 'Rhizopus',
      'correctedGenus': 'Penicillium',
      'dateFlagged': 'November 01, 2025',
    },
    {
      'systemPredicted': 'Rhizopus',
      'correctedGenus': 'Penicillium',
      'dateFlagged': 'November 01, 2025',
    },
    {
      'systemPredicted': 'Rhizopus',
      'correctedGenus': 'Penicillium',
      'dateFlagged': 'November 01, 2025',
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MoldifyColors.backgroundColor,
        appBar: PrimaryAppBar(
          title: 'Flagged History',
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0, bottom: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ----------- Case History Header -----------
                Text(
                    'Flagged History',
                    style: TextStyle(
                      fontSize: 36,
                      fontFamily: 'Montserrat-Black',
                      color: MoldifyColors.primaryColor,
                    )
                ),
                Text(
                    'View your previously flagged mold identifications below.',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Bricolage-Grotesque-Regular',
                      color: MoldifyColors.MoldifyBlack,
                    )
                ),
                /// ----------- End of Case History Header -----------

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
                flaggedHistory.isEmpty
                    ? EmptyState(
                  message: 'No flagged mold history available.',
                  height: MediaQuery.of(context).size.height - 300,
                  icon: FontAwesomeIcons.flag,
                ):
                /// The list of cases will be here
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: flaggedHistory.length,
                  itemBuilder: (context, index) {
                    final flagged = flaggedHistory[index];
                    return Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: FlagHistoryTile(
                        systemPredicted: flagged['systemPredicted']!,
                        correctedGenus: flagged['correctedGenus']!,
                        dateFlagged: flagged['dateFlagged']!,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        )
    );
  }
}