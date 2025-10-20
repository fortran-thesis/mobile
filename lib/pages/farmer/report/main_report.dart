import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../misc/buttons/popmenu_button.dart';
import '../../misc/colors.dart';
import '../../misc/functions/empty_state.dart';
import '../../misc/textboxes/textboxes.dart';
import '../../misc/tiles/main_case_tile.dart';

class MainReportScreen extends StatefulWidget {
  const MainReportScreen({super.key});

  @override
  State<MainReportScreen> createState() => _MainReportScreenState();
}

class _MainReportScreenState extends State<MainReportScreen> {
  final TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String?>> reportsSubmitted = [
      {
        'caseName': 'Wowerz',
        'dateSubmitted': 'October 25, 2025',
        'status': 'Pending',
      },
      {
        'caseName': 'Case Two Na sobrnag haba ba ganons ahsuhasuashushasuhsuh',
        'dateSubmitted': 'October 20, 2025',
        'status': 'Resolved',
      },
      {
        'caseName': 'Wowersz',
        'dateSubmitted': 'October 25, 2025',
        'status': 'In Progress',
      },
      {
        'caseName': 'Case Two Na sobrnag haba ba ganons ahsuhasuashushasuhsuh',
        'dateSubmitted': 'October 20, 2025',
        'status': 'Resolved',
      },
    ];

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Container(
              color: MoldifyColors.backgroundColor,
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ----------- Mold Scanner Header -----------
                      Text(
                          'Mold Report',
                          style: TextStyle(
                            fontSize: 36,
                            fontFamily: 'Montserrat-Black',
                            color: MoldifyColors.primaryColor,
                          )
                      ),
                      Text(
                          'This is the collection of your submitted mold report',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Bricolage-Grotesque-Regular',
                            color: MoldifyColors.MoldifyBlack,
                          )),
                      /// ----------- End of Mold Scanner Header -----------
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            /// Submit Mold Report Button
                            TextButton(
                              onPressed: () {
                                // TODO: Navigate to full cases list
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.solidPaperPlane,
                                    size: 16,
                                    color: MoldifyColors.accentColor,
                                  ),
                                  SizedBox(width: 10.0,),
                                  Text(
                                    'Submit Mold Report',
                                    style: TextStyle(
                                      fontFamily: 'Bricolage-Grotesque-SemiBold',
                                      fontSize: 14,
                                      color: MoldifyColors.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 5.0,),
                            /// This is the filter button
                            PopupMenu(
                              popMenuIcon: Icon (
                                  FontAwesomeIcons.filter,
                                  color: MoldifyColors.accentColor,
                                  size: 20.0
                              ),
                              items: ['All', 'In Progress', 'Pending', 'Resolved', 'Rejected'],
                              onItemSelected: (index) {
                                // Handle the selection based on the index
                                if (index == 0) {
                                  // All was tapped
                                } else if (index == 1) {
                                  // In Progress was tapped
                                } else if (index == 2) {
                                  // Pending was tapped
                                } else if (index == 3) {
                                  // Resolved was tapped
                                } else if (index == 4) {
                                  // Rejected was tapped
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      /// Search Box
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: BuildTextBox(
                          hintText: 'Search Cases',
                          controller: searchController,
                          showPassword: false,
                          rightIcon: FontAwesomeIcons.magnifyingGlass,
                        ),
                      ),
                      /// This the empty state if there are no reports
                      reportsSubmitted.isEmpty
                          ? EmptyState(
                        message: 'No reports available.',
                        height: MediaQuery.of(context).size.height - 300,
                      ):
                      /// The list of cases will be here
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reportsSubmitted.length,
                        itemBuilder: (context, index) {
                          final report = reportsSubmitted[index];
                          return Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: MainCaseTile(
                                caseName: report['caseName']!,
                                dateSubmitted: report['dateSubmitted']!,
                                status: report['status']!,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/view-case',
                                  );
                                },
                                /// This is the pop menu button
                                showPopupMenu: true,
                                popupMenuItems: ['Identification History', 'Treatment History'],
                                popupMenuIcons: [FontAwesomeIcons.clockRotateLeft, FontAwesomeIcons.sprayCan],
                                onPopupMenuItemSelected: (index) {
                                  // Handle the selection based on the index

                                  /// Identification History
                                  if (index == 0) {
                                    Navigator.pushNamed(
                                      context,
                                      '/identification-history',
                                    );
                                  }
                                  /// End of Identification History

                                  /// Treatment History
                                  else if (index == 1) {
                                    Navigator.pushNamed(
                                      context,
                                      '/treatment-history',
                                    );
                                  }
                                  /// End of Treatment History
                                }
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20.0), // To give some space at the bottom
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],

      ),
    );
  }
}