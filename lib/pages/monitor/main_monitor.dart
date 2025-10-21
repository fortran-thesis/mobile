import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/functions/empty_state.dart';
import 'package:moldify/pages/misc/tiles/main_case_tile.dart';
import '../misc/buttons/popmenu_button.dart';
import '../misc/colors.dart';
import '../misc/textboxes/textboxes.dart';

class MainMonitorScreen extends StatefulWidget {
  const MainMonitorScreen({super.key});

  @override
  State<MainMonitorScreen> createState() => _MainMonitorScreenState();
}

class _MainMonitorScreenState extends State<MainMonitorScreen> {
  final TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {

    /// Sample data for Cases Assigned
    final List<Map<String, String?>> casesAssigned = [
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
    return Stack(
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
                        'My Cases',
                        style: TextStyle(
                          fontSize: 36,
                          fontFamily: 'Montserrat-Black',
                          color: MoldifyColors.primaryColor,
                        )
                    ),
                    Text(
                        'This is the collection of your cases assigned to you.',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Bricolage-Grotesque-Regular',
                          color: MoldifyColors.MoldifyBlack,
                        )),
                    /// ----------- End of Mold Scanner Header -----------

                    /// This is the filter button
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: PopupMenu(
                          popMenuIcon: Icon (
                            FontAwesomeIcons.filter,
                            color: MoldifyColors.accentColor,
                            size: 20.0
                          ),
                          items: ['All', 'In Progress', 'Pending', 'Resolved'],
                          onItemSelected: (index) {
                            // Handle the selection based on the index
                            if (index == 0) {
                              // All was tapped
                            } else if (index == 1) {
                              // In Progress was tapped
                            } else if (index == 2) {
                              // Pending was tapped
                            } else if (index == 2) {
                              // Resolved was tapped
                            }
                          },
                        ),
                      ),
                    ),

                    /// Search Box
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: BuildTextBox(
                        hintText: 'Search Cases',
                        controller: searchController,
                        showPassword: false,
                        rightIcon: FontAwesomeIcons.magnifyingGlass,
                      ),
                    ),

                    /// This the empty state if there are no cases
                    casesAssigned.isEmpty
                        ? EmptyState(
                      message: 'No cases available.',
                      height: MediaQuery.of(context).size.height - 300,
                    ):
                    /// The list of cases will be here
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: casesAssigned.length,
                      itemBuilder: (context, index) {
                        final article = casesAssigned[index];
                        return Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: MainCaseTile(
                              caseName: article['caseName']!,
                              dateSubmitted: article['dateSubmitted']!,
                              status: article['status']!,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/view-case',
                                );
                              },
                              /// This is the pop menu button
                              showPopupMenu: true,
                              popupMenuItems: ['Set Monitoring Details', 'Identification History', 'Treatment History', 'Export PDF'],
                              popupMenuIcons: [FontAwesomeIcons.circleInfo, FontAwesomeIcons.clockRotateLeft, FontAwesomeIcons.sprayCan, FontAwesomeIcons.solidFilePdf],
                              onPopupMenuItemSelected: (index) {
                                // Handle the selection based on the index

                                /// Edit Monitoring Details
                                if (index == 0) {
                                  Navigator.pushNamed(
                                    context,
                                    '/set-monitoring-details',
                                  );
                                }
                                /// End of Monitoring Details

                                /// Identification History
                                else if (index == 1) {
                                  Navigator.pushNamed(
                                    context,
                                    '/identification-history',
                                  );
                                }
                                /// End of Identification History

                                /// Treatment History
                                else if (index == 2) {
                                  Navigator.pushNamed(
                                    context,
                                    '/treatment-history',
                                  );
                                }
                                /// End of Treatment History

                                /// Export PDF
                                else if (index == 3) {

                                }
                                /// End of Export PDF
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
    );
  }
}