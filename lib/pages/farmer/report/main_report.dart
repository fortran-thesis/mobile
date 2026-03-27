import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moldify/l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../misc/buttons/popmenu_button.dart';
import '../../misc/colors.dart';
import '../../misc/functions/empty_state.dart';
import '../../misc/textboxes/textboxes.dart';
import '../../misc/tiles/main_case_tile.dart';
import '../../../core/features/mold_report/logic/mold_report_bloc.dart';
import '../../../core/features/mold_report/models/mold_report.dart';
import '../../../core/features/mold_report/repository/mold_report_repository.dart';
import '../../../core/utils/mutation_result.dart';
import '../../../providers/auth_provider.dart';

class MainReportScreen extends StatefulWidget {
  const MainReportScreen({super.key});

  @override
  State<MainReportScreen> createState() => _MainReportScreenState();
}

class _MainReportScreenState extends State<MainReportScreen> {
  final TextEditingController searchController = TextEditingController();
  late final MoldReportRepository _repository;
  late final MoldReportBloc _bloc;
  final ScrollController _scrollController = ScrollController();
  
  // Search and filter state
  String? _activeStatusFilter; // null for "All", or status string
  Timer? _searchDebounce;
  
  bool _isFetchingMore = false;
  final Map<String, MoldReport> _detailedReportById = {};
  final Set<String> _requestedDetailedReportIds = {};
  static const String _reportScope = 'own';

  @override
  void initState() {
    super.initState();
    _repository = MoldReportRepository(pageSize: 10);
    _bloc = MoldReportBloc(repository: _repository, pageSize: 10);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;
      _bloc.add(FetchMoldReports(sessionCookie: sessionCookie, scope: _reportScope));
    });

    _scrollController.addListener(() {
      final state = _bloc.state;
      if (state is MoldReportLoaded) {
        final max = _scrollController.position.maxScrollExtent;
        final current = _scrollController.position.pixels;
        if (current >= (max - 200)) {
          if (_hasActiveSearchOrFilter) return;
          if (!_isFetchingMore && state.hasMore && state.nextPageToken != null && state.nextPageToken!.isNotEmpty) {
            _isFetchingMore = true;
            final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
            final sessionCookie = authProvider.cookie;
            _bloc.add(FetchMoldReports(pageToken: state.nextPageToken, sessionCookie: sessionCookie, scope: _reportScope));
            // Use a more reliable way to reset the flag after fetch completes
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) _isFetchingMore = false;
            });
          }
        }
      }
    });

    searchController.addListener(_onSearchChanged);
  }

  bool get _hasActiveSearchOrFilter {
    return searchController.text.trim().isNotEmpty || _activeStatusFilter != null;
  }

  String _normalizeStatus(String value) {
    return value.toLowerCase().replaceAll('_', ' ').trim();
  }

  List<MoldReport> _applyClientFilters(List<MoldReport> reports) {
    final searchText = searchController.text.trim().toLowerCase();
    return reports.where((report) {
      final caseName = report.caseName.toLowerCase();
      final host = report.host.toLowerCase();
      final matchesSearch = searchText.isEmpty || caseName.contains(searchText) || host.contains(searchText);

      final reportStatus = _normalizeStatus(report.status);
      final activeStatus = _activeStatusFilter == null ? null : _normalizeStatus(_activeStatusFilter!);
      final matchesStatus = activeStatus == null || reportStatus == activeStatus;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  String? _extractPhotoUrl(dynamic raw) {
    if (raw is String) {
      final normalized = raw.trim();
      if (normalized.isNotEmpty && normalized != 'no_image' && normalized != '[]' && normalized != 'null') {
        return normalized;
      }
    }

    if (raw is List) {
      for (final item in raw) {
        if (item is String) {
          final normalized = item.trim();
          if (normalized.isNotEmpty && normalized != 'no_image') {
            return normalized;
          }
        }
      }
    }

    return null;
  }

  String? _resolveReportCoverPhoto(MoldReport report) {
    final displayReport = _detailedReportById[report.id] ?? report;
    for (final detail in displayReport.caseDetails) {
      final photo = _extractPhotoUrl(detail.coverPhoto);
      if (photo != null) return photo;
    }
    return null;
  }

  Future<void> _fetchDetailedReportById(String reportId, String? sessionCookie) async {
    try {
      final detailed = await _repository.getReportById(reportId, sessionCookie: sessionCookie);
      if (detailed == null || !mounted) return;
      setState(() {
        _detailedReportById[reportId] = detailed;
      });
    } catch (e) {
      // Log the error for debugging
      // AppLogger.e('Failed to fetch detailed report $reportId', error: e);
    }
  }

  void _prefetchDetailedReports(List<MoldReport> reports) {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final sessionCookie = authProvider.cookie;

    for (final report in reports) {
      if (_detailedReportById.containsKey(report.id)) continue;
      if (_requestedDetailedReportIds.contains(report.id)) continue;

      _requestedDetailedReportIds.add(report.id);
      _fetchDetailedReportById(report.id, sessionCookie);
    }
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // Reports will be loaded from the backend using MoldReportBloc
    final l10n = AppLocalizations.of(context)!;
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
                          l10n.moldReport,
                          style: TextStyle(
                            fontSize: 36,
                            fontFamily: 'Montserrat-Black',
                            color: MoldifyColors.primaryColor,
                          )
                      ),
                      Text(
                          l10n.moldReportSubtitle,
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
                              onPressed: () async {
                                final result = await pushNamedForMutationResult(
                                  context,
                                  '/submit-report',
                                );
                                if (!mounted) return;
                                if (result.changed) {
                                  final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
                                  _bloc.add(RefreshMoldReports(sessionCookie: authProvider.cookie, scope: _reportScope));
                                }
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
                                    l10n.submitMoldReport,
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
                                final selectedStatus = ['All', 'In Progress', 'Pending', 'Resolved', 'Rejected'][index];
                                setState(() {
                                  _activeStatusFilter = selectedStatus == 'All' ? null : selectedStatus;
                                });
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
                      /// Reports list (infinite scroll)
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 300,
                        child: BlocProvider.value(
                          value: _bloc,
                          child: BlocBuilder<MoldReportBloc, MoldReportState>(
                            builder: (context, state) {
                              if (state is MoldReportLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: MoldifyColors.primaryColor,
                                  ),
                                );
                              }
                              if (state is MoldReportError) {
                                return EmptyState(message: state.message, height: MediaQuery.of(context).size.height - 300);
                              }

                              final reports = state is MoldReportLoaded ? state.reports : <MoldReport>[];
                              final filteredReports = _applyClientFilters(reports);
                              _prefetchDetailedReports(filteredReports);

                              if (filteredReports.isEmpty) {
                                return EmptyState(message: 'No reports match your current search/filter.', height: MediaQuery.of(context).size.height - 300);
                              }

                              return RefreshIndicator(
                                onRefresh: () async {
                                  final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
                                  _bloc.add(RefreshMoldReports(sessionCookie: authProvider.cookie, scope: _reportScope));
                                },
                                child: ListView.builder(
                                  controller: _scrollController,
                                  itemCount: filteredReports.length + (state is MoldReportLoaded && state.hasMore && !_hasActiveSearchOrFilter ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index >= filteredReports.length) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 12.0),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: MoldifyColors.primaryColor,
                                          ),
                                        ),
                                      );
                                    }

                                    final report = filteredReports[index];
                                    final displayReport = _detailedReportById[report.id] ?? report;
                                    final String caseName = (report.caseName.isNotEmpty ? report.caseName : "Untitled Case").toString();                                    // Capitalize the first letter of status
                                    String caseStatus = (report.status).toString();
                                    if (caseStatus.isNotEmpty) {
                                      caseStatus = caseStatus[0].toUpperCase() + caseStatus.substring(1);
                                    }
                  // Use createdAt if available, fallback to dateObserved, then fallback to '-'
                  final DateTime? reportDate = displayReport.createdAt ?? displayReport.dateObserved;
                  final String dateSubmitted = reportDate != null
                    ? DateFormat('MMMM d, yyyy').format(reportDate.toLocal())
                    : '-';

                                    return Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: MainCaseTile(
                                        caseName: caseName,
                                        dateSubmitted: dateSubmitted,
                                        dateLabel: 'Date Submitted',
                                        caseStatus: caseStatus,
                                        imageUrl: _resolveReportCoverPhoto(report),
                                        onTap: () async {
                                          final result = await pushNamedForMutationResult(
                                            context,
                                            '/view-report',
                                            arguments: {'id': report.id},
                                          );
                                          if (!mounted) return;
                                          if (result.changed) {
                                            final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
                                            _bloc.add(RefreshMoldReports(sessionCookie: authProvider.cookie));
                                          }
                                        },
                                        showPopupMenu: true,
                                        popupMenuItems: ['Export PDF'],
                                        popupMenuIcons: [FontAwesomeIcons.solidFilePdf],
                                        onPopupMenuItemSelected: (menuIndex) {
                                          if (menuIndex == 0) {
                                            // export
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
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