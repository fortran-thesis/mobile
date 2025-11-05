import 'package:flutter/material.dart';
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
  bool _isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    _repository = MoldReportRepository(pageSize: 10);
    _bloc = MoldReportBloc(repository: _repository, pageSize: 10);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;
      _bloc.add(FetchMoldReports(sessionCookie: sessionCookie));
    });

    _scrollController.addListener(() {
      final state = _bloc.state;
      if (state is MoldReportLoaded) {
        final max = _scrollController.position.maxScrollExtent;
        final current = _scrollController.position.pixels;
        if (current >= (max - 200)) {
          if (!_isFetchingMore && state.hasMore && state.nextPageToken != null && state.nextPageToken!.isNotEmpty) {
            _isFetchingMore = true;
            final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
            final sessionCookie = authProvider.cookie;
            _bloc.add(FetchMoldReports(pageToken: state.nextPageToken, sessionCookie: sessionCookie));
            // Use a more reliable way to reset the flag after fetch completes
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) _isFetchingMore = false;
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // Reports will be loaded from the backend using MoldReportBloc

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
                          'Mold Report',
                          style: TextStyle(
                            fontSize: 36,
                            fontFamily: 'Montserrat-Black',
                            color: MoldifyColors.primaryColor,
                          )
                      ),
                      Text(
                          'This is the collection of your submitted mold report',
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
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/submit-report',
                                );
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
                                    'Submit Mold Report',
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
                                // Handle the selection based on the index
                                if (index == 0) {
                                  // All was tapped
                                } else if (index == 1) {
                                  // In Progress was tapped
                                } else if (index == 2) {
                                  // Pending was tapped
                                } else if (index == 3) {
                                  // Resolved was tapped
                                } else if (index == 4) {
                                  // Rejected was tapped
                                }
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
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (state is MoldReportError) {
                                return EmptyState(message: state.message, height: MediaQuery.of(context).size.height - 300);
                              }

                              final reports = state is MoldReportLoaded ? state.reports : <dynamic>[];

                              if (reports.isEmpty) {
                                return EmptyState(message: 'No reports available.', height: MediaQuery.of(context).size.height - 300);
                              }

                              return RefreshIndicator(
                                onRefresh: () async {
                                  final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
                                  _bloc.add(RefreshMoldReports(sessionCookie: authProvider.cookie));
                                },
                                child: ListView.builder(
                                  controller: _scrollController,
                                  itemCount: reports.length + (state is MoldReportLoaded && state.hasMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index >= reports.length) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 12.0),
                                        child: Center(child: CircularProgressIndicator()),
                                      );
                                    }

                                    final report = reports[index] as MoldReport;
                                    final String caseName = (report.caseName.isNotEmpty ? report.caseName : "Untitled Case").toString();                                    // Capitalize the first letter of status
                                    String caseStatus = (report.status).toString();
                                    if (caseStatus.isNotEmpty) {
                                      caseStatus = caseStatus[0].toUpperCase() + caseStatus.substring(1);
                                    }
                  final String dateSubmitted = report.dateObserved != null
                    ? DateFormat('MMMM d, yyyy').format(report.dateObserved!.toLocal())
                    : '';

                                    return Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: MainCaseTile(
                                        caseName: caseName,
                                        dateSubmitted: dateSubmitted,
                                        caseStatus: caseStatus,
                                        onTap: () {
                                          print('MainReport: Navigating to view-report with id: ${report.id}');
                                          print('MainReport: report = ${report.toJson()}');
                                          Navigator.pushNamed(
                                            context,
                                            '/view-report',
                                            arguments: {'id': report.id},
                                          );
                                        },
                                        showPopupMenu: true,
                                        popupMenuItems: ['Treatment History', 'Export PDF'],
                                        popupMenuIcons: [FontAwesomeIcons.clockRotateLeft, FontAwesomeIcons.solidFilePdf],
                                        onPopupMenuItemSelected: (menuIndex) {
                                          if (menuIndex == 0) {
                                            Navigator.pushNamed(context, '/treatment-history');
                                          } else if (menuIndex == 1) {
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