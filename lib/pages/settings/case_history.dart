import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:provider/provider.dart';

import '../../../core/features/user/logic/user_bloc.dart';

import '../../../core/features/mold_report/models/closed_mold_report.dart';
import '../../../core/features/mold_report/service/mold_report_services.dart';
import '../../../core/features/report_export/services/report_pdf_service.dart';
import '../../../core/utils/role_routing.dart' as role_routing;
import '../../../core/utils/date_utils.dart';
import '../../../providers/auth_provider.dart';
import '../misc/colors.dart';
import '../misc/functions/empty_state.dart';
import '../misc/overlays/loading_ui.dart';
import '../misc/textboxes/textboxes.dart';
import '../misc/tiles/main_case_tile.dart';

String resolveCaseHistoryRouteForRole(String? role) {
  return role_routing.resolveCaseHistoryRouteForRole(role);
}

class CaseHistoryScreen extends StatefulWidget {
  const CaseHistoryScreen({super.key});

  @override
  State<CaseHistoryScreen> createState() => _CaseHistoryScreenState();
}

class _CaseHistoryScreenState extends State<CaseHistoryScreen> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MoldReportService _moldReportService = MoldReportService();
  static const int _pageSize = 10;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  String? _nextPageToken;

  List<ClosedMoldReport> _closedReports = [];
  List<ClosedMoldReport> _filteredReports = [];

  @override
  void initState() {
    super.initState();
    _loadInitialClosedReports();
    searchController.addListener(_filterCases);

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final currentPosition = _scrollController.position.pixels;
      final maxPosition = _scrollController.position.maxScrollExtent;

      if (currentPosition >= (maxPosition - 200)) {
        _loadMoreClosedReports();
      }
    });
  }

  @override
  void dispose() {
    searchController.removeListener(_filterCases);
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialClosedReports() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _isLoadingMore = false;
      _error = null;
      _nextPageToken = null;
      _closedReports = [];
      _filteredReports = [];
    });

    await _fetchClosedReports();
  }

  Future<void> _loadMoreClosedReports() async {
    if (_isLoading || _isLoadingMore || _nextPageToken == null || !mounted)
      return;

    setState(() => _isLoadingMore = true);
    await _fetchClosedReports(pageToken: _nextPageToken);

    if (!mounted) return;
    setState(() => _isLoadingMore = false);
  }

  Map<String, dynamic> _extractData(Map<String, dynamic> response) {
    final dynamic raw = response['data'] ?? response;
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }

  String _resolveHistoryScope() {
    try {
      final userState = context.read<UserBloc>().state;
      if (userState is UserProfileLoaded) {
        final role = userState.profile.role.trim().toLowerCase();
        if (role == 'admin') return 'all';
        if (role == 'curator' || role == 'mycologist') return 'assigned';
      }
    } catch (_) {
      // Fall back to own scope when profile information is unavailable.
    }
    return 'own';
  }

  Future<void> _fetchClosedReports({String? pageToken}) async {
    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;
      if (sessionCookie == null || sessionCookie.isEmpty) {
        if (!mounted) return;
        setState(() {
          _error = 'Authentication error. Please log in again.';
          _isLoading = false;
          _isLoadingMore = false;
        });
        return;
      }

      final response = await _moldReportService.fetchClosedMoldReports(
        sessionCookie: sessionCookie,
        limit: _pageSize,
        pageToken: pageToken,
        scope: _resolveHistoryScope(),
      );

      final data = _extractData(response);
      final snapshot = data['snapshot'] ??
          (data['data'] is Map<String, dynamic>
              ? (data['data'] as Map<String, dynamic>)['snapshot']
              : null);

      final List<ClosedMoldReport> pageItems = snapshot is List<dynamic>
          ? snapshot
                .whereType<Map>()
                .map(
                  (item) => ClosedMoldReport.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .where((item) => item.id.isNotEmpty)
                .toList()
          : <ClosedMoldReport>[];

      final nextTokenValue = data['nextPageToken'];
      final String? nextToken =
          (nextTokenValue == null || nextTokenValue.toString().trim().isEmpty)
          ? null
          : nextTokenValue.toString();

      if (!mounted) return;
      setState(() {
        if (pageToken == null) {
          _closedReports = pageItems;
        } else {
          final existingIds = _closedReports.map((report) => report.id).toSet();
          final uniqueIncoming = pageItems.where(
            (report) => !existingIds.contains(report.id),
          );
          _closedReports.addAll(uniqueIncoming);
        }

        _nextPageToken = nextToken;
        _error = null;
        _isLoading = false;
      });

      _filterCases();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load case history: ${e.toString()}';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _handleExportPdf(String reportId) async {
    if (reportId.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No report ID found for PDF export.')),
      );
      return;
    }

    try {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating PDF...')),
      );

      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;

      final payload = await _moldReportService.getPrintableReportPayload(
        reportId,
        sessionCookie: sessionCookie,
      );

      final savedPath = await ReportPdfService().sharePdfFromPayload(
        payload: payload,
        fileName: 'laboratory-report-$reportId.pdf',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to: $savedPath')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export PDF: $e')),
      );
    }
  }

  String _toTitleCase(String value) {
    final normalized = value.trim().replaceAll('_', ' ').toLowerCase();
    if (normalized.isEmpty) return 'Rejected';
    return normalized
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  void _filterCases() {
    final query = searchController.text.toLowerCase();
    setState(() {
      _filteredReports = _closedReports.where((report) {
        return report.caseName.toLowerCase().contains(query) ||
            report.status.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(title: 'Case History'),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 15.0,
          right: 15.0,
          top: 20.0,
          bottom: 30.0,
        ),
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
              ),
            ),
            Text(
              'View records of closed, resolved, and rejected mold reports.',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Bricolage-Grotesque-Regular',
                color: MoldifyColors.MoldifyBlack,
              ),
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

            Expanded(
              child: _isLoading
                  ? const Center(child: AppLoadingSpinner())
                  : _error != null
                  ? EmptyState(
                      message: _error!,
                      height: MediaQuery.of(context).size.height - 300,
                    )
                  : _filteredReports.isEmpty
                  ? EmptyState(
                      message: 'No case history available.',
                      height: MediaQuery.of(context).size.height - 300,
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          _filteredReports.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _filteredReports.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(child: AppLoadingSpinner()),
                          );
                        }

                        final report = _filteredReports[index];
                        return Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: MainCaseTile(
                            caseName: report.caseName.isEmpty
                                ? 'Untitled Case'
                                : report.caseName,
                            dateSubmitted: formatDateTimeToDisplay(
                              report.dateObserved,
                            ),
                            caseStatus: _toTitleCase(report.status),
                            dateLabel: 'Date Observed',
                            onTap: () {
                              try {
                                final userState = context
                                    .read<UserBloc>()
                                    .state;
                                String? role;
                                if (userState is UserProfileLoaded) {
                                  role = userState.profile.role.toLowerCase();
                                }

                                final routeName =
                                    resolveCaseHistoryRouteForRole(role);

                                Navigator.pushNamed(
                                  context,
                                  routeName,
                                  arguments: {'id': report.id},
                                );
                              } catch (e) {
                                // If UserBloc is not available or any error occurs, fall back to report view
                                Navigator.pushNamed(
                                  context,
                                  RouteNames.viewReport,
                                  arguments: {'id': report.id},
                                );
                              }
                            },
                            showPopupMenu: true,
                            popupMenuItems: ['Export PDF'],
                            popupMenuIcons: [FontAwesomeIcons.solidFilePdf],
                            onPopupMenuItemSelected: (index) async {
                              // Handle the selection based on the index

                              /// Export PDF
                              if (index == 0) {
                                await _handleExportPdf(report.id);
                              }

                              /// End of Export PDF
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
