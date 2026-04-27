import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../misc/buttons/popmenu_button.dart';
import '../misc/colors.dart';
import '../misc/functions/empty_state.dart';
import '../misc/overlays/loading_ui.dart';
import '../misc/textboxes/textboxes.dart';
import '../misc/tiles/main_case_tile.dart';
import '../../core/features/mold_case/logic/mold_case_bloc.dart';
import '../../core/features/mold_case/models/mold_case.dart';
import '../../core/features/mold_case/repository/mold_case_repository.dart';
import '../../core/features/mold_report/service/mold_report_services.dart';
import '../../core/features/report_export/services/report_pdf_service.dart';
import '../../core/utils/mutation_result.dart';
import '../../providers/auth_provider.dart';

class MainMonitorScreen extends StatefulWidget {
  const MainMonitorScreen({super.key});

  @override
  State<MainMonitorScreen> createState() => _MainMonitorScreenState();
}

/// Main Monitor Screen - displays assigned mold cases for mycologists
/// 
/// FILTERING APPROACH:
/// - All search and filter operations are CLIENT-SIDE for instant results
/// - Cases are fetched from server with pagination
/// - Search and status filters are applied locally using _applyClientFilters()
/// - No server calls are made when searching or filtering
/// - Pagination is disabled when filters are active
class _MainMonitorScreenState extends State<MainMonitorScreen> {
  final TextEditingController searchController = TextEditingController();
  late final MoldCaseRepository _repository;
  late final MoldCaseBloc _bloc;
  late final MoldReportService _reportService;
  final ScrollController _scrollController = ScrollController();
  bool _isFetchingMore = false;
  Map<String, String> _caseStatusMap = {};
  
  // Client-side filter state
  String? _activeStatusFilter;
  String _sortOrder = 'desc'; // 'desc' = newest first, 'asc' = oldest first
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _repository = MoldCaseRepository(pageSize: 10);
    _bloc = MoldCaseBloc(repository: _repository, pageSize: 10);
    _reportService = MoldReportService();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;
      print('🔍 MainMonitor: Session cookie = ${sessionCookie == null ? "NULL" : "${sessionCookie.substring(0, 20)}..."}');
      if (sessionCookie == null || sessionCookie.isEmpty) {
        print('⚠️ MainMonitor: No session cookie found - user may need to log in');
      }
      _bloc.add(FetchMoldCases(sessionCookie: sessionCookie));
      // Don't load cover photos - mycologists don't have access to /user endpoint
      // _loadUserReportCoverPhotos(sessionCookie);
    });

    _scrollController.addListener(() {
      final state = _bloc.state;
      if (state is MoldCaseLoaded) {
        final max = _scrollController.position.maxScrollExtent;
        final current = _scrollController.position.pixels;
        if (current >= (max - 200)) {
          if (_hasActiveSearchOrFilter) return;
          if (!_isFetchingMore && state.hasMore && state.nextPageToken != null && state.nextPageToken!.isNotEmpty) {
            _isFetchingMore = true;
            final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
            final sessionCookie = authProvider.cookie;
            _bloc.add(FetchMoldCases(pageToken: state.nextPageToken, sessionCookie: sessionCookie));
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

  String _normalizeStatusKey(String? status) {
    final value = status?.trim().toLowerCase() ?? '';
    if (value.isEmpty) return '';

    return value.replaceAll(RegExp(r'[\s-]+'), '_');
  }

  String _toTitleCase(String value) {
    return value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
        .join(' ');
  }

  String _extractReportStatus(Map<String, dynamic> reportResponse) {
    final directStatus = reportResponse['status']?.toString();
    if (directStatus != null && directStatus.trim().isNotEmpty) {
      return directStatus;
    }

    final data = reportResponse['data'];
    if (data is Map<String, dynamic>) {
      final nestedStatus = data['status']?.toString();
      if (nestedStatus != null && nestedStatus.trim().isNotEmpty) {
        return nestedStatus;
      }

      final nestedData = data['data'];
      if (nestedData is Map<String, dynamic>) {
        final deeperStatus = nestedData['status']?.toString();
        if (deeperStatus != null && deeperStatus.trim().isNotEmpty) {
          return deeperStatus;
        }
      }
    }

    return '';
  }

  Future<void> _syncCaseStatuses(List<MoldCase> cases) async {
    if (!mounted || cases.isEmpty) return;

    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final sessionCookie = authProvider.cookie;

    final statusEntries = await Future.wait(
      cases.map((moldCase) async {
        try {
          final reportResponse = await _reportService.getMoldReportById(
            moldCase.moldReportId,
            sessionCookie: sessionCookie,
          );
          final rawStatus = _extractReportStatus(reportResponse);
          final normalized = _normalizeStatusKey(rawStatus);
          return MapEntry(
            moldCase.id,
            normalized.isNotEmpty
                ? normalized
                : (moldCase.isArchived ? 'resolved' : 'in_progress'),
          );
        } catch (_) {
          return MapEntry(
            moldCase.id,
            moldCase.isArchived ? 'resolved' : 'in_progress',
          );
        }
      }),
    );

    if (!mounted) return;

    setState(() {
      _caseStatusMap = Map<String, String>.fromEntries(statusEntries);
    });
  }

  Future<void> _handleExportPdfForCase(MoldCase moldCase) async {
    final reportId = moldCase.moldReportId.trim();
    if (reportId.isEmpty) {
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

      final payload = await _reportService.getPrintableReportPayload(
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

  String _getCaseFilterStatus(MoldCase moldCase) {
    final cachedStatus = _caseStatusMap[moldCase.id];
    if (cachedStatus != null && cachedStatus.isNotEmpty) {
      return cachedStatus;
    }

    // Fall back to archive state until the report status has been fetched.
    return moldCase.isArchived ? 'resolved' : 'in_progress';
  }

  String _displayStatusForCase(MoldCase moldCase) {
    final statusKey = _getCaseFilterStatus(moldCase);
    final normalized = _normalizeStatusKey(statusKey);
    if (normalized.isEmpty) {
      return 'In Progress';
    }

    if (normalized == 'in_progress') {
      return 'In Progress';
    }

    return _toTitleCase(normalized.replaceAll('_', ' '));
  }

  /// Client-side filtering: applies search and status filter locally
  /// without making additional API calls, then sorts by date
  List<MoldCase> _applyClientFilters(List<MoldCase> cases) {
    if (cases.isEmpty) return cases;

    final searchText = searchController.text.trim().toLowerCase();
    final hasSearch = searchText.isNotEmpty;
    final hasFilter = _activeStatusFilter != null;

    // Filter cases
    List<MoldCase> filtered = cases;
    if (hasSearch || hasFilter) {
      filtered = cases.where((moldCase) {
        // Apply search filter: match case name
        bool matchesSearch = true;
        if (hasSearch) {
          matchesSearch = moldCase.name.toLowerCase().contains(searchText);
        }

        // Apply status filter
        bool matchesStatus = true;
        if (hasFilter) {
          final caseStatus = _getCaseFilterStatus(moldCase);
          matchesStatus = caseStatus == _activeStatusFilter;
        }

        return matchesSearch && matchesStatus;
      }).toList();
    }

    // Sort by date
    filtered.sort((a, b) {
      final dateA = a.startDate.millisecondsSinceEpoch;
      final dateB = b.startDate.millisecondsSinceEpoch;
      return _sortOrder == 'desc' ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
    });

    return filtered;
  }

  String? _extractPhotoUrl(dynamic raw) {
    if (raw is String) {
      final normalized = raw.trim();
      if (normalized.isNotEmpty && normalized != 'no_image' && normalized != '[]' && normalized != 'null') {
        return normalized;
      }
      return null;
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

  String? _resolveTileImageUrl(MoldCase moldCase) {
    // Return the case's photo URL directly
    return _extractPhotoUrl(moldCase.photoUrl);
  }

  /// Trigger UI update for client-side filtering (search/filter changes)
  void _dispatchSearchOrFilter() {
    if (!mounted) return;
    // Simply trigger a rebuild - filters are applied in _applyClientFilters
    setState(() {});
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), _dispatchSearchOrFilter);
  }

  void _onStatusFilterChanged(int index) {
    String? selectedStatus;

    // Map menu index to status value
    switch (index) {
      case 0: // "All"
        selectedStatus = null;
        break;
      case 1: // "In Progress"
        selectedStatus = 'in_progress';
        break;
      case 2: // "Resolved"
        selectedStatus = 'resolved';
        break;
    }

    setState(() {
      _activeStatusFilter = selectedStatus;
    });
  }

  void _onSortOrderChanged(int index) {
    setState(() {
      _sortOrder = index == 0 ? 'desc' : 'asc';
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
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ----------- My Cases Header -----------
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
                      /// ----------- End of Header -----------
      
                      /// Filter and Sort buttons
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            PopupMenu(
                              popMenuIcon: Icon(
                                FontAwesomeIcons.arrowUpShortWide,
                                color: MoldifyColors.accentColor,
                                size: 20.0,
                              ),
                              items: ['Newest First', 'Oldest First'],
                              onItemSelected: _onSortOrderChanged,
                            ),
                            SizedBox(width: 10.0),
                            PopupMenu(
                              popMenuIcon: Icon(
                                FontAwesomeIcons.filter,
                                color: MoldifyColors.accentColor,
                                size: 20.0,
                              ),
                              items: ['All', 'In Progress', 'Resolved'],
                              onItemSelected: _onStatusFilterChanged,
                            ),
                          ],
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
      
                      /// BlocBuilder for cases
                      BlocListener<MoldCaseBloc, MoldCaseState>(
                        bloc: _bloc,
                        listener: (context, state) {
                          if (state is MoldCaseLoaded) {
                            _syncCaseStatuses(state.cases);
                          }
                        },
                        child: BlocBuilder<MoldCaseBloc, MoldCaseState>(
                          bloc: _bloc,
                          builder: (context, state) {
                            if (state is MoldCaseInitial || (state is MoldCaseLoading)) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.3),
                                  child: const AppLoadingSpinner(size: 36),
                                ),
                              );
                            } else if (state is MoldCaseError) {
                              // Check if it's an auth error
                              final isAuthError = state.message.toLowerCase().contains('authentication') ||
                                  state.message.toLowerCase().contains('unauthorized') ||
                                  state.message.toLowerCase().contains('session');
                              
                              return EmptyState(
                                message: isAuthError 
                                    ? 'Session expired. Please log out and log in again.'
                                    : state.message,
                                height: MediaQuery.of(context).size.height - 300,
                              );
                            } else if (state is MoldCaseLoaded) {
                              final filteredCases = _applyClientFilters(state.cases);

                              if (filteredCases.isEmpty) {
                                // Show different message based on whether we have filters active
                                final hasFilters = _hasActiveSearchOrFilter;
                                final message = hasFilters
                                    ? 'No cases match your search or filter criteria.'
                                    : 'No cases assigned yet.';
                                
                                return EmptyState(
                                  message: message,
                                  height: MediaQuery.of(context).size.height - 300,
                                );
                              }

                              // Show filtered count if filters are active
                              final hasFilters = _hasActiveSearchOrFilter;
                              final totalCount = state.cases.length;
                              final filteredCount = filteredCases.length;

                              // Convert cases to display format with statuses
                              return Column(
                                children: [
                                  // Show filter results count
                                  if (hasFilters && filteredCount < totalCount)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10.0),
                                      child: Text(
                                        'Showing $filteredCount of $totalCount cases',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Bricolage-Grotesque-Regular',
                                          color: MoldifyColors.accentColor,
                                        ),
                                      ),
                                    ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: filteredCases.length,
                                    itemBuilder: (context, index) {
                                      final moldCase = filteredCases[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 10.0),
                                        child: MainCaseTile(
                                            caseName: moldCase.name,
                                            dateSubmitted: (moldCase.cropName != null && moldCase.cropName!.trim().isNotEmpty)
                                              ? moldCase.cropName!.trim()
                                              : 'Crop not specified',
                                            dateLabel: 'Crop Name',
                                            caseStatus: _displayStatusForCase(moldCase),
                                            imageUrl: _resolveTileImageUrl(moldCase),
                                            onTap: () async {
                                              final reportId = moldCase.moldReportId.trim().isNotEmpty
                                                  ? moldCase.moldReportId
                                                  : moldCase.id;
                                              final result = await pushNamedForMutationResult(
                                                context,
                                                '/view-case',
                                                arguments: {'id': reportId},
                                              );
                                              if (result.changed && mounted) {
                                                final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
                                                _bloc.add(RefreshMoldCases(sessionCookie: authProvider.cookie));
                                              }
                                            },
                                            showPopupMenu: true,
                                            popupMenuItems: ['Export PDF'],
                                            popupMenuIcons: [FontAwesomeIcons.solidFilePdf],
                                            onPopupMenuItemSelected: (menuIndex) async {
                                              if (menuIndex == 0) {
                                                await _handleExportPdfForCase(moldCase);
                                              }
                                            }
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 20.0),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
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