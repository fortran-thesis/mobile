import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../misc/buttons/popmenu_button.dart';
import '../misc/colors.dart';
import '../misc/functions/empty_state.dart';
import '../misc/textboxes/textboxes.dart';
import '../misc/tiles/main_case_tile.dart';
import '../../core/features/mold_case/logic/mold_case_bloc.dart';
import '../../core/features/mold_case/models/mold_case.dart';
import '../../core/features/mold_case/repository/mold_case_repository.dart';
import '../../core/features/mold_report/service/mold_report_services.dart';
import '../../providers/auth_provider.dart';

class MainMonitorScreen extends StatefulWidget {
  const MainMonitorScreen({super.key});

  @override
  State<MainMonitorScreen> createState() => _MainMonitorScreenState();
}

class _MainMonitorScreenState extends State<MainMonitorScreen> {
  final TextEditingController searchController = TextEditingController();
  late final MoldCaseRepository _repository;
  late final MoldCaseBloc _bloc;
  final ScrollController _scrollController = ScrollController();
  bool _isFetchingMore = false;
  final MoldReportService _reportService = MoldReportService();
  String? _activePriorityFilter;
  Timer? _searchDebounce;
  final Map<String, String> _coverPhotoByReportId = {};
  bool _isLoadingUserReportPhotos = false;
  bool _hasLoadedUserReportPhotos = false;

  @override
  void initState() {
    super.initState();
    _repository = MoldCaseRepository(pageSize: 10);
    _bloc = MoldCaseBloc(repository: _repository, pageSize: 10);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;
      _bloc.add(FetchMoldCases(sessionCookie: sessionCookie));
      _loadUserReportCoverPhotos(sessionCookie);
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
    return searchController.text.trim().isNotEmpty || _activePriorityFilter != null;
  }

  String _normalizePriority(String value) {
    return value
        .toLowerCase()
        .replaceAll('priority', '')
        .trim();
  }

  List<MoldCase> _applyClientFilters(List<MoldCase> cases) {
    final searchText = searchController.text.trim().toLowerCase();
    return cases.where((moldCase) {
      final matchesSearch = searchText.isEmpty || moldCase.name.toLowerCase().contains(searchText);
      final casePriority = _normalizePriority(moldCase.priority);
      final activePriority = _activePriorityFilter == null ? null : _normalizePriority(_activePriorityFilter!);
      final matchesPriority = activePriority == null || casePriority == activePriority;
      return matchesSearch && matchesPriority;
    }).toList();
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

  String? _extractCoverPhotoFromReport(Map<String, dynamic> payload) {
    final topLevelPhoto = _extractPhotoUrl(payload['cover_photo']);
    if (topLevelPhoto != null) return topLevelPhoto;

    final caseDetails = payload['case_details'];
    if (caseDetails is List) {
      for (final detail in caseDetails) {
        if (detail is Map<String, dynamic>) {
          final photo = _extractPhotoUrl(detail['cover_photo']);
          if (photo != null) return photo;
        }
      }
    }

    return null;
  }

  Future<void> _loadUserReportCoverPhotos(String? sessionCookie) async {
    if (_isLoadingUserReportPhotos || _hasLoadedUserReportPhotos) return;

    _isLoadingUserReportPhotos = true;
    try {
      String? pageToken;
      final localMap = <String, String>{};

      for (var page = 0; page < 10; page++) {
        final response = await _reportService.fetchMoldReports(
          sessionCookie: sessionCookie,
          limit: 50,
          pageToken: pageToken,
          path: '/user',
        );

        final data = response['data'];
        if (data is! Map<String, dynamic>) break;

        final snapshot = data['snapshot'];
        if (snapshot is! List) break;

        for (final item in snapshot) {
          if (item is! Map<String, dynamic>) continue;
          final reportId = item['id']?.toString().trim() ?? '';
          if (reportId.isEmpty) continue;

          final coverPhotoUrl = _extractCoverPhotoFromReport(item);
          if (coverPhotoUrl != null && coverPhotoUrl.isNotEmpty) {
            localMap[reportId] = coverPhotoUrl;
          }
        }

        final nextToken = data['nextPageToken']?.toString();
        if (nextToken == null || nextToken.isEmpty) {
          pageToken = null;
          break;
        }

        pageToken = nextToken;
      }

      if (!mounted) return;

      setState(() {
        _coverPhotoByReportId.addAll(localMap);
      });
      _hasLoadedUserReportPhotos = true;
    } catch (_) {}
    finally {
      _isLoadingUserReportPhotos = false;
    }
  }

  String? _resolveTileImageUrl(MoldCase moldCase) {
    final directPhoto = _extractPhotoUrl(moldCase.photoUrl);
    if (directPhoto != null) return directPhoto;
    return _coverPhotoByReportId[moldCase.moldReportId.trim()];
  }

  void _dispatchSearchOrFilter() {
    if (!mounted) return;
    setState(() {});
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), _dispatchSearchOrFilter);
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
      
                      /// Filter button
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
                            items: ['All', 'Low', 'Medium', 'High'],
                            onItemSelected: (index) {
                              String? selectedPriority;
                              if (index == 1) {
                                selectedPriority = 'low';
                              } else if (index == 2) {
                                selectedPriority = 'medium';
                              } else if (index == 3) {
                                selectedPriority = 'high';
                              }

                              setState(() => _activePriorityFilter = selectedPriority);
                              _dispatchSearchOrFilter();
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
      
                      /// BlocBuilder for cases
                      BlocBuilder<MoldCaseBloc, MoldCaseState>(
                        bloc: _bloc,
                        builder: (context, state) {
                          if (state is MoldCaseInitial || (state is MoldCaseLoading)) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.3),
                                child: const CircularProgressIndicator(),
                              ),
                            );
                          } else if (state is MoldCaseError) {
                            return EmptyState(
                              message: state.message,
                              height: MediaQuery.of(context).size.height - 300,
                            );
                          } else if (state is MoldCaseLoaded) {
                            final filteredCases = _applyClientFilters(state.cases);

                            if (filteredCases.isEmpty) {
                              return EmptyState(
                                message: 'No cases match your current search/filter.',
                                height: MediaQuery.of(context).size.height - 300,
                              );
                            }

                            // Convert cases to display format with statuses
                            return Column(
                              children: [
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
                                          dateSubmitted: DateFormat('MMMM dd, yyyy').format(moldCase.startDate),
                                          priorityLevel: '${moldCase.priority[0].toUpperCase()}${moldCase.priority.substring(1)} Priority',
                                          caseStatus: 'In Progress',
                                          imageUrl: _resolveTileImageUrl(moldCase),
                                          onTap: () async {
                                            final result = await Navigator.pushNamed(
                                              context,
                                              '/view-case',
                                              arguments: {'id': moldCase.moldReportId},
                                            );
                                            if (result == true && mounted) {
                                              final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
                                              _bloc.add(RefreshMoldCases(sessionCookie: authProvider.cookie));
                                            }
                                          },
                                          showPopupMenu: true,
                                          popupMenuItems: ['Set Monitoring Details', 'Identification History', 'Treatment History', 'Export PDF'],
                                          popupMenuIcons: [FontAwesomeIcons.circleInfo, FontAwesomeIcons.clockRotateLeft, FontAwesomeIcons.sprayCan, FontAwesomeIcons.solidFilePdf],
                                          onPopupMenuItemSelected: (menuIndex) async {
                                            if (menuIndex == 0) {
                                              final result = await Navigator.pushNamed(
                                                context,
                                                '/set-monitoring-details',
                                                arguments: {'moldCase': moldCase},
                                              );
                                              if (result == true && mounted) {
                                                final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
                                                _bloc.add(RefreshMoldCases(sessionCookie: authProvider.cookie));
                                              }
                                            } else if (menuIndex == 1) {
                                              Navigator.pushNamed(
                                                context,
                                                '/identification-history',
                                              );
                                            } else if (menuIndex == 2) {
                                              Navigator.pushNamed(
                                                context,
                                                '/treatment-history',
                                              );
                                            } else if (menuIndex == 3) {
                                              // Export PDF
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