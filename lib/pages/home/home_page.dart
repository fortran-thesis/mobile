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
import '../../core/features/wikimold/models/wikimold.dart';
import '../../core/features/wikimold/services/wikimold_services.dart';
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
  // late UserBloc _userBloc;
  StreamSubscription? _userSub;
  String fullName = 'Guest User';
  String role = '';

  // Dashboard data
  Map<String, dynamic> _reportCounts = {};
  List<MoldCase> _assignedCases = [];
  Map<String, String> _caseStatusMap = {}; // Map caseId -> status from mold report
  List<WikiArticle> _moldipediaArticles = [];
  bool _isLoadingDashboard = true;
  String? _dashboardError;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AppAuthProvider>();
      context.read<UserBloc>().add(
        FetchUserProfile(sessionCookie: authProvider.cookie),
      );
    });
  }

  Future<void> _loadDashboardData(String? sessionCookie, String userRole) async {
    print('🔵 _loadDashboardData called with role: $userRole');
    print('🔵 Session cookie: ${sessionCookie?.substring(0, 20)}...');

    if (sessionCookie == null) {
      print('🔴 Session cookie is null, returning early');
      return;
    }

    print('🔵 Starting dashboard data load...');

    try {
      final reportService = MoldReportService();
      final caseService = MoldCaseService();

      print('🔵 Services initialized');

      if (mounted) {
        setState(() => _isLoadingDashboard = true);
        print('🔵 Set loading state to true');
      }

      // Fetch report counts - different logic for different roles
      Map<String, dynamic> reportCounts = {};
      print('🔵 About to fetch report counts...');

      try {
        if (userRole.toLowerCase() == 'mycologist') {
          // Mycologists use the dedicated counts endpoint
          final countsResponse = await reportService.getReportCounts(sessionCookie: sessionCookie);
          print('✅ Mycologist report counts received: $countsResponse');
          reportCounts = countsResponse['data'] ?? {};
        } else if (userRole.toLowerCase() == 'farmer') {
          // Farmers need to fetch their own reports and count them manually
          print('🔵 Fetching farmer reports to count by status...');
          final userReportsResponse = await reportService.fetchMoldReports(
            sessionCookie: sessionCookie,
            path: '/user',
            limit: 1000, // Fetch enough to get all reports (adjust if needed)
          );

          print('✅ Farmer reports received: $userReportsResponse');

          // Extract the reports list
          final List<dynamic> reports = userReportsResponse['data'] ?? [];
          print('🔵 Total farmer reports: ${reports.length}');

          // Count by status
          int pending = 0;
          int inProgress = 0;
          int resolved = 0;
          int rejected = 0;

          for (var report in reports) {
            final status = (report['status'] as String?)?.toLowerCase() ?? '';
            print('Report status: $status');

            if (status == 'pending') {
              pending++;
            } else if (status == 'in_progress' || status == 'in progress') {
              inProgress++;
            } else if (status == 'resolved') {
              resolved++;
            } else if (status == 'rejected') {
              rejected++;
            }
          }

          reportCounts = {
            'pending': pending,
            'in_progress': inProgress,
            'resolved': resolved,
            'rejected': rejected,
          };

          print('✅ Counted farmer reports by status: $reportCounts');
        }

        print('Final report counts: $reportCounts');
      } catch (e, stackTrace) {
        print('❌ Failed to fetch report counts: $e');
        print('Stack trace: $stackTrace');
      }

      print('🔵 About to check role for mycologist-specific data...');

      // Fetch assigned cases (if mycologist)
      List<MoldCase> assignedCases = [];
      Map<String, String> caseStatusMap = {};
      if (userRole.toLowerCase() == 'mycologist') {
        print('🔵 User is mycologist, fetching assigned cases...');
        try {
          final casesResponse = await caseService.fetchAssignedMycologists(
            sessionCookie: sessionCookie,
            limit: 3,
          );

          if (casesResponse['data'] is List) {
            assignedCases = (casesResponse['data'] as List)
                .map((c) => MoldCase.fromJson(c as Map<String, dynamic>))
                .toList();

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
                print('Failed to fetch report for case ${case_.id}: $e');
                caseStatusMap[case_.id] = 'unknown';
              }
            }
          }
        } catch (e, stackTrace) {
          print('❌ Failed to fetch assigned cases: $e');
          print('Stack trace: $stackTrace');
        }
      } else if (userRole.toLowerCase() == 'farmer') {
        // Farmers need to fetch their own reports and count them manually
        print('🔵 Fetching farmer reports to count by status...');
        final userReportsResponse = await reportService.fetchMoldReports(
          sessionCookie: sessionCookie,
          path: '/user',
          limit: 1000, // Fetch enough to get all reports (adjust if needed)
        );

        print('✅ Farmer reports response received:');
        print('Full response: $userReportsResponse');
        print('Response type: ${userReportsResponse.runtimeType}');
        print('Data field: ${userReportsResponse['data']}');
        print('Data type: ${userReportsResponse['data'].runtimeType}');

        // The response might be paginated with structure like:
        // {data: {snapshot: [...], nextPageToken: ...}}
        // OR {data: [...]}
        // Let's handle both cases

        List<dynamic> reports = [];

        if (userReportsResponse['data'] is List) {
          // Case 1: data is directly a list
          reports = userReportsResponse['data'] as List<dynamic>;
        } else if (userReportsResponse['data'] is Map) {
          // Case 2: data is a map containing a 'snapshot' or similar field
          final dataMap = userReportsResponse['data'] as Map<String, dynamic>;
          print('Data map keys: ${dataMap.keys}');

          // Try common field names
          if (dataMap.containsKey('snapshot')) {
            reports = dataMap['snapshot'] as List<dynamic>? ?? [];
          } else if (dataMap.containsKey('reports')) {
            reports = dataMap['reports'] as List<dynamic>? ?? [];
          } else if (dataMap.containsKey('items')) {
            reports = dataMap['items'] as List<dynamic>? ?? [];
          } else {
            print('⚠️ Unknown data structure, data map: $dataMap');
          }
        }

        print('🔵 Total farmer reports: ${reports.length}');

        // Count by status
        int pending = 0;
        int inProgress = 0;
        int resolved = 0;
        int rejected = 0;

        for (var report in reports) {
          if (report is! Map) continue;

          final status = (report['status'] as String?)?.toLowerCase()?.trim() ?? '';
          print('Report ID: ${report['id']}, Status: "$status"');

          if (status == 'pending') {
            pending++;
          } else if (status == 'in_progress' || status == 'in progress' || status == 'inprogress') {
            inProgress++;
          } else if (status == 'resolved') {
            resolved++;
          } else if (status == 'rejected') {
            rejected++;
          } else if (status.isNotEmpty) {
            print('⚠️ Unknown status: "$status"');
          }
        }

        reportCounts = {
          'pending': pending,
          'in_progress': inProgress,
          'resolved': resolved,
          'rejected': rejected,
        };

        print('✅ Counted farmer reports by status:');
        print('  Pending: $pending');
        print('  In Progress: $inProgress');
        print('  Resolved: $resolved');
        print('  Rejected: $rejected');
      }

      // Fetch moldipedia articles
      print('🔵 About to fetch WikiMold articles...');
      List<WikiArticle> formattedArticles = [];
      try {
        final wikiService = WikiService();
        final result = await wikiService.fetchMoldipedia(sessionCookie: sessionCookie);
        print('✅ WikiMold response received: ${result.toString()}');

        formattedArticles = result['articles'] as List<WikiArticle>? ?? [];

        print('✅ Loaded ${formattedArticles.length} WikiMold articles');
        for (var a in formattedArticles) {
          print('Article: ${a.title} by ${a.authorId}');
        }
      } catch (e, stackTrace) {
        print('❌ Failed to fetch WikiMold articles: $e');
        print('Stack trace: $stackTrace');
      }

      print('🔵 About to update state with fetched data...');

      // Update state with all fetched data
      if (mounted) {
        setState(() {
          _reportCounts = reportCounts;
          _assignedCases = assignedCases;
          _caseStatusMap = caseStatusMap;
          _moldipediaArticles = formattedArticles;
        });
        print('✅ State updated successfully');
        print('Final _reportCounts: $_reportCounts');
      } else {
        print('⚠️ Widget not mounted, skipping state update');
      }

    } catch (e, stackTrace) {
      print('❌ Dashboard load error: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _dashboardError = 'Failed to load dashboard';
        });
      }
    } finally {
      print('🔵 Finally block - setting loading to false');
      if (mounted) setState(() => _isLoadingDashboard = false);
      print('✅ Dashboard load complete');
    }
  }



  // @override
  // void dispose() {
  //   _userSub?.cancel();
  //   // _userBloc.close();
  //   super.dispose();
  // }

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
    final tileWidth = (screenWidth - (horizontalPadding * 2)) * 0.95;


    return BlocListener<UserBloc, UserState>(
        listener: (context, state) async {
          if (state is UserProfileLoaded) {
            final profile = state.profile;
            final authProvider = context.read<AppAuthProvider>();

            setState(() {
              final first = profile.firstName.trim();
              final last = profile.lastName.trim();

              fullName = ('$first $last').trim().isEmpty
                  ? profile.username
                  : ('$first $last').trim();

              role = profile.role.isNotEmpty
                  ? '${profile.role[0].toUpperCase()}${profile.role.substring(1).toLowerCase()}'
                  : '';
            });

            await _loadDashboardData(authProvider.cookie, profile.role);
          }
        },
        child: Material(
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
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MainWikiMoldScreen(
                                          ),
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
                              : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.only(right: horizontalPadding),
                            itemCount: _moldipediaArticles.length > 2
                                ? 3
                                : _moldipediaArticles.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 15),
                            itemBuilder: (context, index) {
                              // If there are more than 2 articles and this is the last tile, show "See All" button
                              if (index == 2 && _moldipediaArticles.length > 2) {
                                return Center(
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.chevron_right_rounded,
                                      size: 32,
                                      color: MoldifyColors.primaryColor,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const MainWikiMoldScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }

                              final article = _moldipediaArticles[index];
                              final title = article.title;
                              final authorId = article.authorId;
                              final coverPhoto = article.coverPhoto;
                              final articleId = article.id;

                              return SizedBox(
                                width: tileWidth,
                                child: WikiMoldTile(
                                  title: title,
                                  authorName: authorId,
                                  imageUrl: coverPhoto,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ViewWikiMoldScreen(articleId: articleId),
                                      ),
                                    );
                                  },
                                )

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
    )
    );
  }
}