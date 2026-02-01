import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/farmer/wikimold/main_wikimold.dart';
import 'package:moldify/pages/home/notification_page.dart';
import 'package:moldify/pages/misc/chart/status_donut_chart.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/functions/app_drawer.dart';
import 'package:moldify/pages/misc/functions/empty_state.dart';
import 'package:moldify/pages/monitor/main_monitor.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:moldify/core/features/user/logic/user_bloc.dart';
import 'package:moldify/core/features/user/services/user_services.dart';
import 'package:moldify/providers/auth_provider.dart';
import 'package:moldify/pages/misc/tiles/home_banner.dart';
import 'package:moldify/pages/misc/tiles/main_case_tile.dart';
import '../farmer/faq/main_faq.dart';
import '../farmer/wikimold/view_wikimold.dart';
import '../misc/images/circle_avatar.dart';
import '../misc/tiles/action_tile.dart';
import '../misc/tiles/wikimold_tiles.dart';
import 'package:moldify/core/features/mold_report/service/mold_report_services.dart';
import 'package:moldify/core/features/mold_case/service/mold_case_service.dart';
import 'package:moldify/core/features/mold_case/models/mold_case.dart';

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
  
  // Dashboard data
  Map<String, dynamic> _reportCounts = {};
  List<MoldCase> _assignedCases = [];
  Map<String, String> _caseStatusMap = {}; // Map caseId -> status from mold report
  List<Map<String, dynamic>> _moldipediaArticles = [];
  bool _isLoadingDashboard = true;
  String? _dashboardError;

  @override
  void initState() {
    super.initState();
    _userBloc = UserBloc(userService: UserService());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;
      _userBloc.add(FetchUserProfile(sessionCookie: sessionCookie));
      _loadDashboardData(sessionCookie);
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

  Future<void> _loadDashboardData(String? sessionCookie) async {
    if (sessionCookie == null) return;
    
    try {
      final reportService = MoldReportService();
      final caseService = MoldCaseService();
      
      if (mounted) {
        setState(() => _isLoadingDashboard = true);
      }
      
      // Fetch report counts
      final countsResponse = await reportService.getReportCounts(sessionCookie: sessionCookie);
      
      // Fetch assigned cases (if mycologist)
      List<MoldCase> assignedCases = [];
      Map<String, String> caseStatusMap = {};
      if (role.toLowerCase() == 'mycologist') {
        final casesResponse = await caseService.fetchAssignedMycologists(
          sessionCookie: sessionCookie,
          limit: 3,
        );
        // Parse cases into MoldCase objects
        if (casesResponse['data'] is List) {
          assignedCases = (casesResponse['data'] as List)
              .map((c) => MoldCase.fromJson(c as Map<String, dynamic>))
              .toList();
          
          // Fetch report status for each case
          for (final case_ in assignedCases) {
            if (!mounted) return;
            try {
              final reportResponse = await reportService.getMoldReportById(
                case_.moldReportId,
                sessionCookie: sessionCookie,
              );
              final status = reportResponse['data']?['status'] as String? ?? 'unknown';
              caseStatusMap[case_.id] = status;
            } catch (e) {
              // Fallback if report fetch fails
              caseStatusMap[case_.id] = 'unknown';
            }
          }
        }
      }
      
      // Fetch moldipedia articles for WikiMold section
      final articlesResponse = await reportService.getMoldipediaArticles(
        sessionCookie: sessionCookie,
        limit: 3,
      );
      
      if (mounted) {
        setState(() {
          _reportCounts = countsResponse['data'] ?? {};
          _assignedCases = assignedCases;
          _caseStatusMap = caseStatusMap;
          _moldipediaArticles = articlesResponse;
          _isLoadingDashboard = false;
          _dashboardError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDashboard = false;
          _dashboardError = 'Failed to load dashboard: $e';
        });
      }
    }
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

    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = 30.0; // same as page padding
    // Choose tile width so it fits visually — tweak 0.85 if you want narrower tiles
    final tileWidth = (screenWidth - (horizontalPadding * 2)) * 0.95;


    return Material(
      child: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Container(
                color: MoldifyColors.backgroundColor,
                width: double.infinity,
                height: double.infinity,
              // drawer: const AppDrawer(),
              child: SingleChildScrollView(
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
                                AutoSizeText(
                                  fullName,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat-Black',
                                    fontSize: 16,
                                    color: MoldifyColors.primaryColor,
                                  ),
                                  maxLines: 1,
                                  minFontSize: 12,
                                ),
                                /// User Role
                                AutoSizeText(
                                  role,
                                  style: TextStyle(
                                    fontFamily: 'Bricolage-Grotesque-Regular',
                                    fontSize: 12,
                                    color: MoldifyColors.MoldifyBlack,
                                  ),
                                  maxLines: 1,
                                  minFontSize: 10,
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
                          title: role.toLowerCase() == 'mycologist'
                              ? 'Let’s start Identifying'
                              : 'Bold Against Mold',
                          subtitle: role.toLowerCase() == 'farmer'
                              ? 'Begin your mold journey now!'
                              : 'Take action, and protect your growing crops.',
                        ),
                      ),

                      if(role.isEmpty)...[
                        SizedBox(height: 20.0),
                        Center(
                          child: CircularProgressIndicator(
                            color: MoldifyColors.primaryColor,
                          ),
                        ),
                      ]
                      else if (role.toLowerCase() == 'mycologist')...[
                        /// Case status breakdown label
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
                          child: AutoSizeText(
                            'Case Status Breakdown',
                            style: TextStyle(
                              fontFamily: 'Bricolage-Grotesque-Bold',
                              fontSize: 16,
                              color: MoldifyColors.primaryColor,
                            ),
                            maxLines: 1,
                            minFontSize: 12,
                          ),
                        ),

                        /// Case status breakdown chart - NOW USING REAL DATA
                        _isLoadingDashboard
                            ? Center(
                          child: CircularProgressIndicator(
                            color: MoldifyColors.primaryColor,
                          ),
                        )
                            : StatusDonutChart(
                          statusData: {
                            'Pending': (_reportCounts['pending'] ?? 0).toDouble(),
                            'In Progress': (_reportCounts['in_progress'] ?? 0).toDouble(),
                            'Resolved': (_reportCounts['resolved'] ?? 0).toDouble(),
                          },
                        ),

                        /// Recently Assigned Cases Label
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
                          child: AutoSizeText(
                            'Recently Assigned Cases',
                            style: TextStyle(
                              fontFamily: 'Bricolage-Grotesque-Bold',
                              fontSize: 16,
                              color: MoldifyColors.primaryColor,
                            ),
                            maxLines: 1,
                            minFontSize: 12,
                          ),
                        ),

                        pendingCases.isEmpty
                            ? EmptyState(
                          message: 'No Recently Assigned Cases',
                          height: MediaQuery.of(context).size.height - 500,
                        )
                            : const SizedBox.shrink(),
                        /// This displays assigned cases from API
                        ..._assignedCases.take(3).map((case_) => Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: MainCaseTile(
                            caseName: case_.name,
                            dateSubmitted: case_.startDate.toString().split(' ')[0],
                            priorityLevel: '${case_.priority[0].toUpperCase()}${case_.priority.substring(1)} Priority',
                            caseStatus: _caseStatusMap[case_.id] ?? 'unknown',
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
                        if (_assignedCases.length > 3)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              style: ButtonStyle(
                                overlayColor: WidgetStateProperty.all(MoldifyColors.primaryColor.withValues(alpha: 0.1)),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const MainMonitorScreen(),
                                  ),
                                );
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
                      ] else if (role.toLowerCase() == 'farmer') ... [
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ActionTile(
                                    icon: FontAwesomeIcons.solidCircleQuestion,
                                    iconColor: MoldifyColors.MoldifyBlue,
                                    label: 'FAQ',
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const MainFAQSCreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ActionTile(
                                    icon: FontAwesomeIcons.solidPaperPlane,
                                    iconColor: MoldifyColors.primaryColor,
                                    label: 'Submit Report',
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/submit-report',
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ActionTile(
                                    icon: FontAwesomeIcons.bookOpen,
                                    iconColor: MoldifyColors.MoldifyRed,
                                    label: 'WikiMold',
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const MainWikiMoldScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
                          child: AutoSizeText(
                            'Case Status Breakdown',
                            style: TextStyle(
                              fontFamily: 'Bricolage-Grotesque-Bold',
                              fontSize: 16,
                              color: MoldifyColors.primaryColor,
                            ),
                            maxLines: 1,
                            minFontSize: 12,
                          ),
                        ),

                        /// Case status breakdown chart - NOW USING REAL DATA
                        _isLoadingDashboard
                            ? Center(
                          child: CircularProgressIndicator(
                            color: MoldifyColors.primaryColor,
                          ),
                        )
                            : StatusDonutChart(
                          statusData: {
                            'Pending': (_reportCounts['pending'] ?? 0).toDouble(),
                            'In Progress': (_reportCounts['in_progress'] ?? 0).toDouble(),
                            'Resolved': (_reportCounts['resolved'] ?? 0).toDouble(),
                            'Rejected': (_reportCounts['rejected'] ?? 0).toDouble(),
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
                          child: AutoSizeText(
                            'WikiMold',
                            style: TextStyle(
                              fontFamily: 'Bricolage-Grotesque-Bold',
                              fontSize: 16,
                              color: MoldifyColors.primaryColor,
                            ),
                            maxLines: 1,
                            minFontSize: 12,
                          ),
                        ),
                        SizedBox(
                          height: 163.0,
                          child: _isLoadingDashboard
                              ? Center(
                            child: CircularProgressIndicator(
                              color: MoldifyColors.primaryColor,
                            ),
                          )
                              : _moldipediaArticles.isEmpty
                              ? Center(
                            child: Text(
                              'No articles available',
                              style: TextStyle(
                                fontFamily: 'Montserrat-Regular',
                                fontSize: 14,
                                color: MoldifyColors.MoldifyGrey,
                              ),
                            ),
                          )
                              : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.only(right: horizontalPadding),
                            itemCount: _moldipediaArticles.length > 2 ? 3 : _moldipediaArticles.length,
                            itemBuilder: (context, index) {
                              if (index == 2 && _moldipediaArticles.length > 2) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: Center(
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.chevron_right_rounded,
                                        size: 32,
                                        color: MoldifyColors.primaryColor,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => const MainWikiMoldScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }

                              // Regular article tile from API data
                              final article = _moldipediaArticles[index];
                              final title = article['title'] as String? ?? 'Untitled';
                              final authorId = article['author_id'] as String? ?? 'Unknown Author';
                              final coverPhoto = article['cover_photo'] as String?;
                              return Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: SizedBox(
                                  width: tileWidth,
                                  child: WikiMoldTile(
                                    title: title,
                                    authorName: authorId,
                                    imageUrl: coverPhoto,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => ViewWikiMoldScreen(
                                            articleAuthor: authorId,
                                            articleTitle: title,
                                            articleImageUrl: coverPhoto ?? 'assets/images/Branding2.png',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      ] else ...[
                        SizedBox(height: 20.0),
                        Center(
                          child: Text(
                            'Role not recognized.',
                            style: TextStyle(
                              fontFamily: 'Bricolage-Grotesque-Regular',
                              fontSize: 14,
                              color: MoldifyColors.MoldifyBlack,
                            ),
                          ),
                        )
                      ],
                      SizedBox(height: 70.0)
                    ],
                  ),
                ),
              )
            ),
          ),
        ],
      ),
    );
  }
}