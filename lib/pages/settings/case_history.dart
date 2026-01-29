import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:provider/provider.dart';

import '../../../core/features/mold_case/models/mold_case.dart';
import '../../../core/features/mold_case/service/mold_case_service.dart';
import '../../../providers/auth_provider.dart';
import '../misc/colors.dart';
import '../misc/functions/empty_state.dart';
import '../misc/textboxes/textboxes.dart';
import '../misc/tiles/main_case_tile.dart';

class CaseHistoryScreen extends StatefulWidget {
  const CaseHistoryScreen({super.key});

  @override
  State<CaseHistoryScreen> createState() => _CaseHistoryScreenState();
}

class _CaseHistoryScreenState extends State<CaseHistoryScreen> {
  final TextEditingController searchController = TextEditingController();
  final MoldCaseService _moldCaseService = MoldCaseService();
  
  bool _isLoading = true;
  String? _error;
  List<MoldCase> _archivedCases = [];
  List<MoldCase> _filteredCases = [];

  @override
  void initState() {
    super.initState();
    _loadArchivedCases();
    searchController.addListener(_filterCases);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadArchivedCases() async {
    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;

      final response = await _moldCaseService.getArchivedCases(
        sessionCookie: sessionCookie,
        limit: 20,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final snapshot = data['snapshot'] as List<dynamic>?;
        
        if (snapshot != null) {
          final cases = snapshot
              .map((item) => MoldCase.fromJson(item as Map<String, dynamic>))
              .toList();
          
          setState(() {
            _archivedCases = cases;
            _filteredCases = cases;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = response['error'] ?? 'Failed to load archived cases';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterCases() {
    final query = searchController.text.toLowerCase();
    setState(() {
      _filteredCases = _archivedCases.where((case_) {
        return case_.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(
          title: 'Case History',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0, bottom: 30.0),
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
                  )
              ),
              Text(
                  'View records of closed mold investigations.',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    color: MoldifyColors.MoldifyBlack,
                  )
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
              if (_isLoading)
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 4),
                    child: const CircularProgressIndicator(),
                  ),
                )
              else if (_error != null)
                EmptyState(
                  message: _error!,
                  height: MediaQuery.of(context).size.height - 300,
                )
              else if (_filteredCases.isEmpty)
                EmptyState(
                  message: 'No cases available.',
                  height: MediaQuery.of(context).size.height - 300,
                )
              else
              /// The list of cases will be here
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredCases.length,
                itemBuilder: (context, index) {
                  final moldCase = _filteredCases[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: MainCaseTile(
                        caseName: moldCase.name,
                        dateSubmitted: moldCase.endDate?.toString().split(' ')[0] ?? 'Unknown',
                        priorityLevel: '${moldCase.priority[0].toUpperCase()}${moldCase.priority.substring(1)} Priority',
                        caseStatus: 'Closed',
                        dateLabel: 'Date Closed: ',
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/view-case',
                          );
                        },
                        showPopupMenu: true,
                        popupMenuItems: ['Identification History', 'Treatment History', 'Export PDF'],
                        popupMenuIcons: [FontAwesomeIcons.clockRotateLeft, FontAwesomeIcons.sprayCan, FontAwesomeIcons.solidFilePdf],
                        onPopupMenuItemSelected: (index) {
                          // Handle the selection based on the index

                          /// Identification History
                          if (index == 0) {
                            Navigator.pushNamed(
                              context,
                              '/identification-history',
                            );
                          }
                          /// End of Identification History

                          /// Treatment History
                          else if (index == 1) {
                            Navigator.pushNamed(
                              context,
                              '/treatment-history',
                            );
                          }
                          /// End of Treatment History

                          /// Export PDF
                          else if (index == 2) {

                          }
                          /// End of Export PDF
                        }
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      )
    );
  }
}