import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/home/notification_page.dart';
import 'package:moldify/pages/misc/chart/status_donut_chart.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/functions/app_drawer.dart';
import 'package:moldify/pages/misc/functions/empty_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:moldify/core/features/user/logic/user_bloc.dart';
import 'package:moldify/core/features/user/services/user_services.dart';
import 'package:moldify/providers/auth_provider.dart';
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
  late UserBloc _userBloc;
  StreamSubscription? _userSub;
  String fullName = 'Guest User';
  String role = '';

  @override
  void initState() {
    super.initState();
    _userBloc = UserBloc(userService: UserService());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;
      _userBloc.add(FetchUserProfile(sessionCookie: sessionCookie));
    });
    _userSub = _userBloc.stream.listen((state) {
      if (state is UserProfileLoaded) {
        final profile = state.profile;
        setState(() {
          final first = profile.firstName.trim();
          final last = profile.lastName.trim();

          if (first.isEmpty && last.isEmpty) {
            final user = profile.username.trim();
            fullName = user.isNotEmpty ? user : 'Guest User';
          } else {
            fullName = ('$first $last').trim();
          }

          role = profile.role.isNotEmpty
              ? profile.role[0].toUpperCase() + profile.role.substring(1)
              : profile.role;
        });
      }
    });
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _userBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    /// Sample data for recent cases
    final recentCases = <Map<String, String>>[
      {
        'caseName': 'Wowerz',
        'dateSubmitted': 'October 25, 2025',
        'caseStatus': 'Pending',
        'priorityLevel': 'Low Priority',
      },
      {
        'caseName': 'Case Two Na sobrnag haba ba ganons ahsuhasuashushasuhsuh',
        'dateSubmitted': 'October 20, 2025',
        'caseStatus': 'Pending',
        'priorityLevel': 'Medium Priority',
      },
      {
        'caseName': 'Case Three',
        'dateSubmitted': 'October 15, 2025',
        'caseStatus': 'Pending',
        'priorityLevel': 'High Priority',
      },
      {
        'caseName': 'Case Four',
        'dateSubmitted': 'October 10, 2025',
        'caseStatus': 'Pending',
        'priorityLevel': 'Low Priority',
      },
    ];

    /// Filter only pending cases
    final pendingCases = recentCases
        .where((c) => (c['caseStatus'] ?? '').toLowerCase() == 'pending')
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

              pendingCases.isEmpty
                  ? EmptyState(
                  message: 'No Recently Assigned Cases',
                  height: MediaQuery.of(context).size.height - 500,
              )
                  : const SizedBox.shrink(),
              /// This displays only pending cases
              ...pendingCases.take(3).map((c) => Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: MainCaseTile(
                  caseName: c['caseName'] ?? 'Unknown',
                  dateSubmitted: c['dateSubmitted'] ?? '',
                  priorityLevel: c['priorityLevel'] ?? '',
                  caseStatus: c['caseStatus'] ?? '',
                  imageHeight: 70.0,
                  imageWidth: 70.0,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/view-case',
                    );
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