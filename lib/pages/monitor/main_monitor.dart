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

  @override
  void initState() {
    super.initState();
    _repository = MoldCaseRepository(pageSize: 10);
    _bloc = MoldCaseBloc(repository: _repository, pageSize: 10);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;
      _bloc.add(FetchMoldCases(sessionCookie: sessionCookie));
    });

    _scrollController.addListener(() {
      final state = _bloc.state;
      if (state is MoldCaseLoaded) {
        final max = _scrollController.position.maxScrollExtent;
        final current = _scrollController.position.pixels;
        if (current >= (max - 200)) {
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
  }

  @override
  void dispose() {
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
                            items: ['All', 'In Progress', 'Resolved'],
                            onItemSelected: (index) {
                              if (index == 0) {
                                // All was tapped
                              } else if (index == 1) {
                                // In Progress was tapped
                              } else if (index == 2) {
                                // Resolved was tapped
                              }
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
                            if (state.cases.isEmpty) {
                              return EmptyState(
                                message: 'No cases available.',
                                height: MediaQuery.of(context).size.height - 300,
                              );
                            }

                            // Convert cases to display format with statuses
                            return Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: state.cases.length,
                                  itemBuilder: (context, index) {
                                    final moldCase = state.cases[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: MainCaseTile(
                                          caseName: moldCase.name,
                                          dateSubmitted: DateFormat('MMMM dd, yyyy').format(moldCase.startDate),
                                          priorityLevel: '${moldCase.priority[0].toUpperCase()}${moldCase.priority.substring(1)} Priority',
                                          caseStatus: 'In Progress',
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/view-case',
                                              arguments: {'id': moldCase.moldReportId},
                                            );
                                          },
                                          showPopupMenu: true,
                                          popupMenuItems: ['Set Monitoring Details', 'Identification History', 'Treatment History', 'Export PDF'],
                                          popupMenuIcons: [FontAwesomeIcons.circleInfo, FontAwesomeIcons.clockRotateLeft, FontAwesomeIcons.sprayCan, FontAwesomeIcons.solidFilePdf],
                                          onPopupMenuItemSelected: (menuIndex) {
                                            if (menuIndex == 0) {
                                              Navigator.pushNamed(
                                                context,
                                                '/set-monitoring-details',
                                                arguments: {'moldCase': moldCase},
                                              );
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