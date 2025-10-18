import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';

import '../misc/colors.dart';
import '../misc/functions/empty_state.dart';
import '../misc/textboxes/textboxes.dart';
import '../misc/tiles/main_case_tile.dart';

class CaseHistoryScreen extends StatefulWidget {
  const CaseHistoryScreen({super.key});

  @override
  State<CaseHistoryScreen> createState() => _CaseHistoryScreenState();
}

class _CaseHistoryScreenState extends State<CaseHistoryScreen> {
  final TextEditingController searchController = TextEditingController();
  /// Sample data for Closed Assigned Cases
  final List<Map<String, String?>> closedCases = [
    {
      'caseName': 'Wowerz',
      'dateSubmitted': 'October 25, 2025',
      'status': 'Closed',
    },
    {
      'caseName': 'Case Two Na sobrnag haba ba ganons ahsuhasuashushasuhsuh',
      'dateSubmitted': 'October 20, 2025',
      'status': 'Closed',
    },
    {
      'caseName': 'Wowersz',
      'dateSubmitted': 'October 25, 2025',
      'status': 'Closed',
    },
    {
      'caseName': 'Case Two Na sobrnag haba ba ganons ahsuhasuashushasuhsuh',
      'dateSubmitted': 'October 20, 2025',
      'status': 'Closed',
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(
          title: 'Case History',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0, bottom: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ----------- Case History Header -----------
              Text(
                  'Case History',
                  style: TextStyle(
                    fontSize: 36,
                    fontFamily: 'Montserrat-Black',
                    color: MoldifyColors.primaryColor,
                  )
              ),
              Text(
                  'View records of closed mold investigations.',
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
              closedCases.isEmpty
                  ? EmptyState(
                message: 'No cases available.',
                height: MediaQuery.of(context).size.height - 300,
              ):
              /// The list of cases will be here
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: closedCases.length,
                itemBuilder: (context, index) {
                  final closed = closedCases[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: MainCaseTile(
                        caseName: closed['caseName']!,
                        dateSubmitted: closed['dateSubmitted']!,
                        status: closed['status']!,
                        dateLabel: 'Date Closed: ',
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/view-case',
                          );
                        },
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