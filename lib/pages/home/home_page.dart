import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/home/notification_page.dart';
import 'package:moldify/pages/misc/chart/status_donut_chart.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/functions/app_drawer.dart';
import 'package:moldify/pages/misc/tiles/home_banner.dart';
import 'package:moldify/pages/misc/tiles/main_case_tile.dart';
import '../misc/images/circle_avatar.dart';

/// This is the homepage for mycologists

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  int _unReadNotifications = 2;

  @override
  Widget build(BuildContext context) {
    String fullName = 'John Doe' ?? 'N/A';
    String role = 'Mycologist' ?? 'N/A';

    /// Sample data for recent cases
    final recentCases = <Map<String, String>>[
      {
        'caseName': 'Wowerz',
        'dateSubmitted': 'October 25, 2025',
        'status': 'Pending',
      },
      {
        'caseName': 'Case Two',
        'dateSubmitted': 'October 20, 2025',
        'status': 'Pending',
      },
      {
        'caseName': 'Case Three',
        'dateSubmitted': 'October 15, 2025',
        'status': 'Pending',
      },
      {
        'caseName': 'Case Four',
        'dateSubmitted': 'October 10, 2025',
        'status': 'Pending',
      },
    ];

    /// Filter only pending cases
    final pendingCases = recentCases
        .where((c) => (c['status'] ?? '').toLowerCase() == 'pending')
        .toList();

    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header with Menu and Notification Icons
              Row(
                children: [
                  Builder(
                    builder: (BuildContext newContext) {
                      return IconButton(
                          onPressed: () {
                            Scaffold.of(newContext).openDrawer();
                          },
                          icon: const Icon(
                              FontAwesomeIcons.bars,
                              color: MoldifyColors.primaryColor,
                              size: 24.0
                          )
                      );
                    }
                  ),
                  const Spacer(),
                  Stack(
                    children: [
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _unReadNotifications = 0;
                            });
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const NotificationScreen(),
                              ),
                            );
                          },
                          icon: const Icon
                            (
                              FontAwesomeIcons.solidBell,
                              color: MoldifyColors.primaryColor,
                              size: 24.0
                          )
                      ),
                      if (_unReadNotifications > 0)
                        Positioned(
                          right: 7,
                          top: 15,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: MoldifyColors.backgroundColor,
                                width: 2.0,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 5.0,
                              backgroundColor: MoldifyColors.MoldifyRed,
                            ),
                          ),
                        )
                    ],
                  ),
                ],
              ),
              /// End Of Header with Menu and Notification Icons

              /// User Info with role
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                child: Row(
                  children: [
                    /// User Profile Image
                    CircleAvatarImage(
                      radius: 22.0,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// User Name
                        Text(
                          fullName,
                          style: TextStyle(
                            fontFamily: 'Montserrat-Black',
                            fontSize: 16,
                            color: MoldifyColors.primaryColor,
                          ),
                        ),
                        /// User Role
                        Text(
                          role,
                          style: TextStyle(
                            fontFamily: 'Bricolage-Grotesque-Regular',
                            fontSize: 12,
                            color: MoldifyColors.MoldifyBlack,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ///End User Info

              /// Home Banner
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: HomeBanner(
                    title: 'Let’s start Identifying',
                    subtitle: 'Begin your mold journey now!'
                ),
              ),

              /// Case status breakdown label
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
                child: Text(
                  'Case Status Breakdown',
                  style: TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Bold',
                    fontSize: 16,
                    color: MoldifyColors.primaryColor,
                  ),
                ),
              ),

              /// Case status breakdown chart
              StatusDonutChart(
                statusData: {
                  'Pending': 8.0,
                  'In Progress': 2.0,
                  'Resolved': 10.0,
                },
              ),

              /// Recently Assigned Cases Label
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
                child: Text(
                  'Recently Assigned Cases',
                  style: TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Bold',
                    fontSize: 16,
                    color: MoldifyColors.primaryColor,
                  ),
                ),
              ),

              /// This displays only pending cases
              ...pendingCases.take(3).map((c) => Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: MainCaseTile(
                  caseName: c['caseName'] ?? 'Unknown',
                  dateSubmitted: c['dateSubmitted'] ?? '',
                  status: c['status'] ?? '',
                  onTap: () {
                    // TODO: Navigate to different screen
                  },
                ),
              )).toList(),

              /// This shows 'View All Cases' when there are more than 3 case tiles
              if (pendingCases.length > 3)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navigate to full cases list
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                            'View All Cases',
                          style: TextStyle(
                            fontFamily: 'Bricolage-Grotesque-SemiBold',
                            fontSize: 14,
                            color: MoldifyColors.primaryColor,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: MoldifyColors.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 40.0)
            ],
          ),
        ),
      )
    );
  }
}