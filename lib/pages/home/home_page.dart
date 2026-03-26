import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/farmer/wikimold/main_wikimold.dart';
import 'package:moldify/pages/home/notification_page.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/functions/empty_state.dart';
import 'package:moldify/pages/misc/tiles/stat_tile.dart';
import 'package:moldify/pages/monitor/main_monitor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moldify/core/features/user/logic/user_bloc.dart';
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
import 'package:moldify/core/utils/logger.dart';
import 'package:moldify/core/features/notification/logic/notification_bloc.dart';
import 'package:moldify/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String fullName = '';
  String role = '';
  String? occupation;

  // Dashboard data
  Map<String, dynamic> _reportCounts = {};
  List<MoldCase> _assignedCases = [];
  Map<String, String> _caseStatusMap = {};
  List<WikiArticle> _moldipediaArticles = [];
  bool _isLoadingDashboard = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AppAuthProvider>();
      context.read<UserBloc>().add(
        FetchUserProfile(sessionCookie: authProvider.cookie),
      );
      context.read<NotificationBloc>().add(
        FetchUnreadCount(sessionCookie: authProvider.cookie),
      );
    });
  }

  Future<void> _loadDashboardData(
    String? sessionCookie,
    String userRole,
  ) async {
    AppLogger.d('_loadDashboardData called with role: $userRole');

    if (sessionCookie == null) {
      AppLogger.d('Session cookie is null, returning early');
      return;
    }

    try {
      final reportService = MoldReportService();
      final caseService = MoldCaseService();

      if (mounted) {
        setState(() => _isLoadingDashboard = true);
      }

      // Fetch status counts using the dedicated API endpoint
      final reportCounts = await _fetchReportStatusCounts(
        reportService,
        sessionCookie,
      );

      // Fetch role-specific data
      final assignedCases = await _fetchRoleSpecificData(
        caseService,
        reportService,
        sessionCookie,
        userRole,
      );

      // Fetch moldipedia articles
      final moldipediaArticles = await _fetchWikiMoldArticles(sessionCookie);

      if (mounted) {
        setState(() {
          _reportCounts = reportCounts;
          _assignedCases = assignedCases['cases'];
          _caseStatusMap = assignedCases['statusMap'];
          _moldipediaArticles = moldipediaArticles;
          _isLoadingDashboard = false;
        });
      }
    } catch (e) {
      AppLogger.e('Dashboard load error', error: e);
    } finally {
      if (mounted) setState(() => _isLoadingDashboard = false);
    }
  }

  /// Fetch report status counts from the API endpoint
  Future<Map<String, dynamic>> _fetchReportStatusCounts(
    MoldReportService reportService,
    String sessionCookie,
  ) async {
    try {
      final response = await reportService.getReportCounts(
        sessionCookie: sessionCookie,
      );
      // Response is already unwrapped by the service

      return {
        'total': response['total'] ?? 0,
        'pending': response['pending'] ?? 0,
        'in_progress': response['in_progress'] ?? 0,
        'resolved': response['resolved'] ?? 0,
        'rejected': response['rejected'] ?? response['closed'] ?? 0,
      };
    } catch (e) {
      AppLogger.e('Failed to fetch report counts', error: e);
      return {
        'total': 0,
        'pending': 0,
        'in_progress': 0,
        'resolved': 0,
        'rejected': 0,
      };
    }
  }

  /// Normalize mold report from API to MoldCase model
  Map<String, dynamic> _normalizeMoldReport(Map<String, dynamic> report) {
    return {
      'id': report['id']?.toString() ?? '',
      'mycologist_id':
          report['assigned_mycologist_id']?.toString() ??
          report['mycologist_id']?.toString() ??
          '',
      'name':
          report['case_name']?.toString() ?? report['name']?.toString() ?? '',
      // For /mold-case/assigned payloads, id is case id while mold_report_id is the report id.
      // Fall back to id only for legacy payloads that do not include mold_report_id.
      'mold_report_id':
          report['mold_report_id']?.toString() ??
          report['id']?.toString() ??
          '',
      'photo_url': report['cover_photo'] ?? report['photo_url'],
      'priority': report['priority']?.toString() ?? 'low',
      'start_date':
          report['date_observed'] ??
          report['created_at'] ??
          DateTime.now().toIso8601String(),
      'end_date': report['end_date'],
      'is_archived': report['is_archived'] ?? false,
    };
  }

  /// Fetch role-specific data (assigned cases for mycologists)
  Future<Map<String, dynamic>> _fetchRoleSpecificData(
    MoldCaseService caseService,
    MoldReportService reportService,
    String sessionCookie,
    String userRole,
  ) async {
    List<MoldCase> cases = [];
    Map<String, String> statusMap = {};

    if (userRole.toLowerCase() == 'mycologist') {
      try {
        final casesResponse = await caseService.fetchAssignedMycologists(
          sessionCookie: sessionCookie,
          limit: 3,
        );

        // Extract snapshot from response { snapshot: [...], nextPageToken: ... }
        final snapshot = casesResponse['snapshot'];
        if (snapshot is List) {
          final parsedCases = snapshot
              .whereType<Map>()
              .map((c) => _normalizeMoldReport(Map<String, dynamic>.from(c)))
              .map((normalized) => MoldCase.fromJson(normalized))
              .toList();

          // Keep one case per mold report. If duplicates exist, prefer higher priority.
          final priorityOrder = {'low': 1, 'medium': 2, 'high': 3};
          final dedupedByReport = <String, MoldCase>{};
          for (final case_ in parsedCases) {
            final key = case_.moldReportId.trim().isNotEmpty
                ? case_.moldReportId
                : case_.id;
            final existing = dedupedByReport[key];
            if (existing == null) {
              dedupedByReport[key] = case_;
              continue;
            }

            final existingRank =
                priorityOrder[existing.priority.toLowerCase()] ?? 0;
            final currentRank =
                priorityOrder[case_.priority.toLowerCase()] ?? 0;
            if (currentRank > existingRank) {
              dedupedByReport[key] = case_;
            }
          }
          cases = dedupedByReport.values.toList();

          // Fetch report statuses for each case
          for (final case_ in cases) {
            if (!mounted) break;
            try {
              final reportResponse = await reportService.getMoldReportById(
                case_.moldReportId,
                sessionCookie: sessionCookie,
              );
              final status =
                  reportResponse['data']?['status'] as String? ?? 'unknown';
              statusMap[case_.id] = status;
            } catch (e) {
              AppLogger.e(
                'Failed to fetch report for case ${case_.id}',
                error: e,
              );
              statusMap[case_.id] = 'unknown';
            }
          }
        }
      } catch (e) {
        AppLogger.e('Failed to fetch assigned cases', error: e);
      }
    }

    return {'cases': cases, 'statusMap': statusMap};
  }

  /// Fetch WikiMold articles
  Future<List<WikiArticle>> _fetchWikiMoldArticles(String sessionCookie) async {
    try {
      final wikiService = WikiService();
      final result = await wikiService.fetchMoldipedia(
        sessionCookie: sessionCookie,
      );
      return result['articles'] as List<WikiArticle>? ?? [];
    } catch (e) {
      AppLogger.e('Failed to fetch WikiMold articles', error: e);
      return [];
    }
  }

  String _statusCount(String key, {bool padTwoDigits = false}) {
    final rawValue = _reportCounts[key];
    final parsedValue = rawValue is num
        ? rawValue.toInt()
        : int.tryParse(rawValue?.toString() ?? '') ?? 0;
    return padTwoDigits
        ? parsedValue.toString().padLeft(2, '0')
        : parsedValue.toString();
  }

  List<Widget> _buildStatusTiles(AppLocalizations l10n) {
    if (role.toLowerCase() == 'mycologist') {
      return [
        StatisticTile(
          icon: FontAwesomeIcons.hourglassHalf,
          statusColor: MoldifyColors.MoldifyBlue,
          value: _statusCount('in_progress', padTwoDigits: true),
          label: l10n.statusLabelInProgress,
        ),
        StatisticTile(
          icon: FontAwesomeIcons.solidCircleCheck,
          statusColor: MoldifyColors.primaryColor,
          value: _statusCount('resolved', padTwoDigits: true),
          label: l10n.statusLabelResolved,
        ),
      ];
    } else {
      return [
        StatisticTile(
          icon: FontAwesomeIcons.solidClock,
          statusColor: MoldifyColors.accentColor,
          value: _statusCount('pending', padTwoDigits: true),
          label: l10n.statusLabelPending,
        ),
        StatisticTile(
          icon: FontAwesomeIcons.hourglassHalf,
          statusColor: MoldifyColors.MoldifyBlue,
          value: _statusCount('in_progress', padTwoDigits: true),
          label: l10n.statusLabelInProgress,
        ),
        StatisticTile(
          icon: FontAwesomeIcons.solidCircleCheck,
          statusColor: MoldifyColors.primaryColor,
          value: _statusCount('resolved', padTwoDigits: true),
          label: l10n.statusLabelResolved,
        ),
        StatisticTile(
          icon: FontAwesomeIcons.solidCircleXmark,
          statusColor: MoldifyColors.MoldifyRed,
          value: _statusCount('rejected', padTwoDigits: true),
          label: l10n.statusLabelRejected,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (fullName.isEmpty) {
      fullName = l10n.guestUser;
    }

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
            occupation = profile.occupation;
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
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 30.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        _buildUserInfo(),
                        _buildBanner(l10n),
                        if (role.isEmpty)
                          _buildLoadingState()
                        else if (role.toLowerCase() == 'mycologist')
                          _buildMycologistUI()
                        else if (role.toLowerCase() == 'farmer')
                          _buildFarmerUI(l10n)
                        else
                          _buildUnrecognizedRoleState(l10n),
                        const SizedBox(height: 70.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Builder(
          builder: (BuildContext newContext) {
            return IconButton(
              onPressed: () => Scaffold.of(newContext).openDrawer(),
              icon: const Icon(
                FontAwesomeIcons.bars,
                color: MoldifyColors.primaryColor,
                size: 24.0,
              ),
            );
          },
        ),
        const Spacer(),
        Stack(
          children: [
            IconButton(
              onPressed: () {
                setState(() {});
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
              icon: const Icon(
                FontAwesomeIcons.solidBell,
                color: MoldifyColors.primaryColor,
                size: 24.0,
              ),
            ),
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                final count = state is NotificationLoaded
                    ? state.unreadCount
                    : 0;
                if (count == 0) return const SizedBox.shrink();
                return Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: MoldifyColors.MoldifyRed,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: 'Montserrat-Black',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      child: Row(
        children: [
          const CircleAvatarImage(radius: 22.0),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                fullName,
                style: const TextStyle(
                  fontFamily: 'Montserrat-Black',
                  fontSize: 16,
                  color: MoldifyColors.primaryColor,
                ),
                maxLines: 1,
                minFontSize: 12,
              ),
              AutoSizeText(
                role.toLowerCase() == 'farmer' && occupation != null && occupation!.isNotEmpty
                    ? occupation!
                    : role,
                style: const TextStyle(
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
    );
  }

  Widget _buildBanner(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: HomeBanner(
        title: role.toLowerCase() == 'mycologist'
            ? 'Let\'s start Identifying'
            : l10n.boldAgainstMold,
        subtitle: role.toLowerCase() == 'mycologist'
            ? 'Begin your mold journey now!'
            : l10n.protectYourCrops,
        imagePath: role.toLowerCase() == 'mycologist'
            ? 'assets/images/mold_home_banner.png'
            : 'assets/images/farm_home_banner.png',
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: Center(
        child: CircularProgressIndicator(color: MoldifyColors.primaryColor),
      ),
    );
  }

  Widget _buildUnrecognizedRoleState(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Center(
        child: Text(
          l10n.unrecognizedRole,
          style: const TextStyle(
            fontFamily: 'Bricolage-Grotesque-Regular',
            fontSize: 14,
            color: MoldifyColors.MoldifyBlack,
          ),
        ),
      ),
    );
  }

  Widget _buildMycologistUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCaseStatusLabel(AppLocalizations.of(context)!),
        _buildCaseStatusBreakdown(AppLocalizations.of(context)!),
        _buildRecentCasesLabel(),
        if (_assignedCases.isEmpty)
          EmptyState(
            message: 'No Recently Assigned Cases',
            height: MediaQuery.of(context).size.height - 500,
          )
        else
          ..._assignedCases
              .take(3)
              .map(
                (case_) => Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: MainCaseTile(
                    caseName: case_.name,
                    dateSubmitted: case_.startDate.toString().split(' ')[0],
                    caseStatus: _caseStatusMap[case_.id] ?? 'unknown',
                    imageHeight: 70.0,
                    imageWidth: 70.0,
                    onTap: () {
                      final reportId = case_.moldReportId.trim().isNotEmpty
                          ? case_.moldReportId
                          : case_.id;
                      Navigator.pushNamed(
                        context,
                        '/view-case',
                        arguments: {'id': reportId},
                      ).then((result) {
                        if (result == true && mounted) {
                          final authProvider = context.read<AppAuthProvider>();
                          _loadDashboardData(authProvider.cookie, role);
                        }
                      });
                    },
                  ),
                ),
              ),
        if (_assignedCases.length > 3)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MainMonitorScreen(),
                  ),
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
      ],
    );
  }

  Widget _buildFarmerUI(AppLocalizations l10n) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tileWidth = (screenWidth - 60) * 0.95;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFarmerActionTiles(l10n),
        _buildCaseStatusLabel(l10n),
        _buildCaseStatusBreakdown(l10n),
        _buildWikiMoldLabel(l10n),
        _buildWikiMoldSection(tileWidth, l10n),
      ],
    );
  }

  Widget _buildCaseStatusLabel(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 5.0),
      child: AutoSizeText(
        l10n.caseStatusBreakdown,
        style: const TextStyle(
          fontFamily: 'Montserrat-Black',
          fontSize: 16,
          color: MoldifyColors.primaryColor,
        ),
        maxLines: 1,
        minFontSize: 12,
      ),
    );
  }

  Widget _buildCaseStatusBreakdown(AppLocalizations l10n) {
    return _isLoadingDashboard
        ? Center(
            child: CircularProgressIndicator(color: MoldifyColors.primaryColor),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatisticTile(
                icon: FontAwesomeIcons.seedling,
                statusColor: MoldifyColors.primaryColor,
                value: _statusCount('total', padTwoDigits: true),
                label: l10n.totalCasesReported,
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                crossAxisCount: 2,
                crossAxisSpacing: 6,
                mainAxisSpacing: 12,
                childAspectRatio: 1.9,
                children: _buildStatusTiles(l10n),
              ),
            ],
          );
  }

  Widget _buildRecentCasesLabel() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
      child: AutoSizeText(
        'Recently Assigned Cases',
        style: const TextStyle(
          fontFamily: 'Montserrat-Black',
          fontSize: 16,
          color: MoldifyColors.primaryColor,
        ),
        maxLines: 1,
        minFontSize: 12,
      ),
    );
  }

  Widget _buildFarmerActionTiles(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ActionTile(
                icon: FontAwesomeIcons.solidCircleQuestion,
                iconColor: MoldifyColors.MoldifyBlue,
                backgroundColor: const Color(0xFFE8F0F7),
                label: l10n.faq,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MainFAQSCreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ActionTile(
                icon: FontAwesomeIcons.solidPaperPlane,
                iconColor: MoldifyColors.primaryColor,
                backgroundColor: MoldifyColors.primaryColor.withValues(
                  alpha: 0.1,
                ),
                label: l10n.submitReport,
                onTap: () => Navigator.pushNamed(context, '/submit-report'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ActionTile(
                icon: FontAwesomeIcons.bookOpen,
                iconColor: MoldifyColors.accentColor,
                backgroundColor: MoldifyColors.accentColor.withValues(
                  alpha: 0.1,
                ),
                label: l10n.wikiMold,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainWikiMoldScreen()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWikiMoldLabel(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 5.0),
      child: AutoSizeText(
        l10n.wikiMold,
        style: const TextStyle(
          fontFamily: 'Montserrat-Black',
          fontSize: 16,
          color: MoldifyColors.primaryColor,
        ),
        maxLines: 1,
        minFontSize: 12,
      ),
    );
  }

  Widget _buildWikiMoldSection(double tileWidth, AppLocalizations l10n) {
    return SizedBox(
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
                l10n.noArticlesAvailable,
                style: const TextStyle(
                  fontFamily: 'Montserrat-Regular',
                  fontSize: 14,
                  color: MoldifyColors.MoldifyGrey,
                ),
              ),
            )
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 30),
              itemCount: _moldipediaArticles.length > 2
                  ? 3
                  : _moldipediaArticles.length,
              separatorBuilder: (_, __) => const SizedBox(width: 15),
              itemBuilder: (context, index) {
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
                return SizedBox(
                  width: tileWidth,
                  child: WikiMoldTile(
                    title: article.title,
                    authorName: article.author,
                    imageUrl: article.coverPhoto,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ViewWikiMoldScreen(articleId: article.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
