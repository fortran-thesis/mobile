import 'package:flutter/material.dart';
import 'package:moldify/l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/farmer/report/content_tab/prevention_tactics_content.dart';
import 'package:moldify/pages/farmer/report/content_tab/report_case_details_tab.dart';
import 'package:moldify/pages/farmer/report/content_tab/report_disease_cycle_impact_tab.dart';
import 'package:moldify/pages/farmer/report/content_tab/report_hosts_symptoms_tab.dart';
import 'package:moldify/pages/farmer/report/content_tab/report_overview_tab.dart';
import 'package:moldify/pages/farmer/report/content_tab/report_resolved_actions_row.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/features/user/logic/user_bloc.dart';

import '../../../core/features/mold_report/models/mold_report.dart';
import '../../../core/features/mold_report/repository/mold_report_repository.dart';
import '../../../core/features/mold_report/logic/mold_report_bloc.dart';
import '../../../core/features/mold/service/mold_service.dart';
import '../../../core/features/mold_case/service/mold_case_service.dart';
import '../../../services/api_service.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/constants/api_url.dart';
import '../../../providers/auth_provider.dart';
import 'package:moldify/core/utils/logger.dart';
import '../../../core/utils/mutation_result.dart';
import '../../../core/features/mold_report/service/mold_report_services.dart';
import '../../../core/features/report_export/services/report_pdf_service.dart';
import 'report_view_parser.dart';

// route names not used here
import '../../misc/appbar/primary_app_bar.dart';
import '../../misc/colors.dart';
import '../../misc/functions/scrollable_tab_bar.dart';
import '../../misc/images/cover_image.dart';
import '../../misc/overlays/loading_ui.dart';
import '../../misc/overlays/modals/confirmation_dialog.dart';
import '../../misc/tiles/status_tile.dart';

class ViewReportScreen extends StatefulWidget {
  const ViewReportScreen({super.key});

  @override
  State<ViewReportScreen> createState() => _ViewReportScreenState();
}

class _ViewReportScreenState extends State<ViewReportScreen> {
  static const String _defaultPreventionTacticsContent =
      'MECHANICAL::Mechanical Control::Remove infected plant debris promptly using sterilized tools. Prune affected areas and ensure proper disposal of contaminated materials in sealed bags.|'
      'BIOLOGICAL::Biological Control::Apply beneficial microorganisms like Bacillus subtilis. Use organic fungicides such as neem oil or garlic extract. Encourage natural predators in the environment.|'
      'CHEMICAL::Chemical Control::Recommended fungicides: Mancozeb, Chlorothalonil, Copper-based fungicides, Azoxystrobin. Apply according to manufacturer instructions and observe safety protocols.|'
      'PHYSICAL::Physical Control::Ensure proper plant spacing for good air circulation. Water at the base of plants to keep foliage dry. Maintain optimal temperature and humidity levels.|'
      'CULTURAL::Cultural Control::Rotate crops annually to prevent soil-borne diseases. Use resistant plant varieties if available. Practice proper sanitation and field hygiene.';

  String? caseImageUrl;
  // Change the status to 'Resolved', 'Closed', 'In Progress', or 'Rejected' to see different UI states.
  String caseStatus = 'Pending';

  /// Builds a centered text widget to display messages for non-resolved statuses.
  Widget _buildStatusMessageWidget(String status) {
    final l10n = AppLocalizations.of(context)!;
    String message;
    switch (status) {
      case 'Pending':
        message = l10n.statusPending;
        break;
      case 'In progress':
        message = l10n.statusInProgress;
        break;
      case 'Rejected':
        message = l10n.statusRejected;
        break;
      default:
        // Return an empty widget if the status is not one of the above.
        return const SizedBox.shrink();
    }

    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 400,
        child: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Bricolage-Grotesque-Regular',
              color: MoldifyColors.MoldifyGrey,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  // Data for Case Details Tab
  final String farmerName = 'Juan Dela Cruz';
  final String dateFirstObserved = 'October 30, 2025';
  final String emailAddress = 'juan.delacruz@example.com';
  final String contactNumber = '+63 917 123 4567';
  final List<Map<String, dynamic>> caseEntries = [
    {
      'date': 'October 30, 2025',
      'notes':
          'Initial report. Small, dark spots observed on the lower leaves of several tomato plants. The area is humid and has poor air circulation.',
      'images': [
        'https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg',
        'https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg',
      ],
    },
    {
      'date': 'November 2, 2025',
      'notes':
          'Follow-up. The spots have enlarged and now have a dark border with a lighter tan center. Some lower leaves are starting to turn yellow and drop.',
      'images': [
        'https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg',
      ],
    },
    {
      'date': 'November 2, 2025',
      'notes':
          'Follow-up. The spots have enlarged and now have a dark border with a lighter tan center. Some lower leaves are starting to turn yellow and drop.',
      'images': [
        'https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg',
        'https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg',
        'https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg',
        'https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg',
        'https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg',
      ],
    },
  ];

  // Backend-driven state
  bool _isLoading = true;
  String? _error;
  MoldReport? _report;
  String _mycologistName = '';
  String? _mycologistOccupation;
  String _finalVerdictMoldName = '';
  String _finalVerdictConfidence = '';
  String _finalVerdictNotes = '';
  String? _linkedMoldipediaId;
  String _preventionTacticsContent = _defaultPreventionTacticsContent;
  int _selectedTabIndex = 0;

  Future<void> _handleCloseCase() async {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BuildConfirmationDialog(
          title: l10n.confirmCloseTitle,
          subtitle: l10n.confirmCloseSubtitle,
          onConfirm: () async {
            Navigator.of(dialogContext).pop();
            try {
              final authProvider = Provider.of<AppAuthProvider>(
                context,
                listen: false,
              );
              final sessionCookie = authProvider.cookie;
              final service = MoldReportService();
              await service.deleteMoldReportSoft(
                _report!.id,
                sessionCookie: sessionCookie,
              );
              if (!mounted) return;
              if (mounted) {
                Navigator.of(context).pop(
                  const MutationResult.changed(
                    tags: [MutationTags.moldReport],
                  ).toMap(),
                );
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.reportClosed)));
              }
            } catch (e) {
              if (!mounted) return;
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.failedToCloseReport(e.toString()))),
                );
              }
            }
          },
          onCancel: () {
            Navigator.of(dialogContext).pop();
          },
          cancelText: l10n.no,
          confirmText: l10n.yes,
        );
      },
    );
  }

  Future<void> _handleAddFollowUp() async {
    final result = await pushNamedForMutationResult(
      context,
      '/add-follow-up',
      arguments: {'id': _report?.id},
    );

    if (!mounted || !result.changed) return;
    await _loadReportFromArgs();
  }

  Future<void> _handleExportPdf() async {
    final reportId = _report?.id;
    if (reportId == null || reportId.isEmpty) {
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

      final payload = await MoldReportService().getPrintableReportPayload(
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

  Widget _buildCaseDetailsTab(BuildContext context) {
    // derive display values from UserBloc when available, fall back to defaults
    String displayFarmerName = farmerName;
    String displayEmail = emailAddress;
    String displayContact = contactNumber;

    try {
      final userState = BlocProvider.of<UserBloc>(context).state;
      if (userState is UserProfileLoaded) {
        final profile = userState.profile;
        final fullName =
            ((profile.firstName.isNotEmpty || profile.lastName.isNotEmpty)
            ? '${profile.firstName} ${profile.lastName}'.trim()
            : profile.username);
        displayFarmerName = fullName.isNotEmpty ? fullName : displayFarmerName;
        displayEmail = profile.email.isNotEmpty ? profile.email : displayEmail;
        displayContact = profile.phoneNumber.isNotEmpty
            ? profile.phoneNumber
            : displayContact;
      }
    } catch (_) {
      // no UserBloc in context or other error; keep defaults
    }

    String formattedObserved(DateTime? dt) {
      if (dt == null) return dateFirstObserved;
      try {
        return DateFormat('MMMM d, yyyy').format(dt.toLocal());
      } catch (_) {
        return dateFirstObserved;
      }
    }

    final entries = _report != null
        ? _report!.caseDetails
              .map(
                (d) => {
                  'date': formattedObserved(_report!.dateObserved),
                  'notes': d.description,
                  'images': d.coverPhoto,
                },
              )
              .toList()
        : caseEntries;

    return ReportCaseDetailsTab(
      entries: entries,
      farmerName: _report != null ? displayFarmerName : farmerName,
      dateFirstObserved: _report != null
          ? formattedObserved(_report!.dateObserved)
          : dateFirstObserved,
      emailAddress: displayEmail,
      contactNumber: displayContact,
    );
  }

  Future<void> _loadReportFromArgs() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    AppLogger.d('ViewReport: args = $args');
    String? id;
    if (args is Map<String, dynamic>) {
      id = args['id']?.toString();
    } else if (args is String) {
      id = args;
    }

    AppLogger.d('ViewReport: extracted id = $id');

    if (id == null || id.isEmpty) {
      setState(() {
        _error = 'No report id provided';
        _isLoading = false;
      });
      return;
    }

    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;
      AppLogger.d(
        'ViewReport: sessionCookie = ${sessionCookie?.substring(0, 20)}...',
      );

      // Prefer existing repository from a surrounding MoldReportBloc if available
      MoldReportRepository repo;
      try {
        final bloc = Provider.of<MoldReportBloc>(context, listen: false);
        repo = bloc.repository;
        AppLogger.d('ViewReport: using repository from MoldReportBloc');
      } catch (_) {
        // no bloc in context, create a local repository
        repo = MoldReportRepository(pageSize: 10);
        AppLogger.d('ViewReport: created new repository');
      }

      AppLogger.d('ViewReport: calling getReportById($id)');
      final MoldReport? report = await repo.getReportById(
        id,
        sessionCookie: sessionCookie,
      );
      AppLogger.d('ViewReport: getReportById returned: $report');

      if (report == null) {
        setState(() {
          _error = 'Report not found';
          _isLoading = false;
        });
        return;
      }

      AppLogger.d('ViewReport: report.id = ${report.id}');
      AppLogger.d('ViewReport: report.caseName = ${report.caseName}');
      AppLogger.d('ViewReport: report.host = ${report.host}');
      AppLogger.d('ViewReport: report.status = ${report.status}');
      AppLogger.d(
        'ViewReport: report.caseDetails.length = ${report.caseDetails.length}',
      );

      String localVerdictMoldName = '';
      String localVerdictConfidence = '';
      String localVerdictNotes = '';
      String localPreventionTacticsContent = _defaultPreventionTacticsContent;

      try {
        final moldCaseService = MoldCaseService();
        final caseData = await moldCaseService.getMoldCasesByReportId(
          report.id,
          sessionCookie: sessionCookie,
        );

        final casePayload = (caseData['data'] is Map<String, dynamic>)
            ? caseData['data'] as Map<String, dynamic>
            : caseData;
        final finalVerdict = casePayload['final_verdict'];
        if (finalVerdict is Map<String, dynamic>) {
          localVerdictMoldName = finalVerdict['moldName']?.toString() ?? '';
          localVerdictConfidence = ReportViewParser.formatConfidence(
            finalVerdict['confidence'],
          );
          localVerdictNotes =
              finalVerdict['mycologist_notes']?.toString() ?? '';
          final mid = finalVerdict['moldipedia_id']?.toString().trim() ?? '';
          if (mid.isNotEmpty) {
            setState(() => _linkedMoldipediaId = mid);
          }

          final verdictMoldId =
              finalVerdict['moldId']?.toString().trim().isNotEmpty == true
              ? finalVerdict['moldId'].toString().trim()
              : (finalVerdict['mold_id']?.toString().trim() ?? '');

          if (verdictMoldId.isNotEmpty) {
            final moldService = MoldService();
            final moldCatalog = await moldService.fetchMoldById(
              verdictMoldId,
              sessionCookie: sessionCookie,
            );
            if (moldCatalog != null) {
              localPreventionTacticsContent =
                  ReportViewParser.buildPreventionContentFromMold(
                    moldCatalog,
                    _defaultPreventionTacticsContent,
                  );
            }
          }
        }
      } catch (e) {
        AppLogger.w(
          'ViewReport: no final verdict enrichment found for report=${report.id}: $e',
        );
      }

      // Fetch mycologist information if assigned
      String localMycologistName = '';
      String? localMycologistOccupation;
      if (report.assignedMycologistId != null &&
          report.assignedMycologistId!.isNotEmpty) {
        try {
          final apiService = ApiService(baseUrl: ApiUrl.user);
          final response = await apiService.get(
            '/${report.assignedMycologistId!}',
            sessionCookie: sessionCookie,
          );
          if (response.data is Map<String, dynamic>) {
            final responseData = response.data as Map<String, dynamic>;
            final userData = responseData['data'] as Map<String, dynamic>?;
            if (userData != null) {
              final userObj = userData['user'] as Map<String, dynamic>?;
              if (userObj != null) {
                final firstName =
                    userObj['first_name']?.toString().trim() ?? '';
                final lastName = userObj['last_name']?.toString().trim() ?? '';
                localMycologistName = '$firstName $lastName'.trim();
                localMycologistOccupation = userObj['occupation']?.toString();
              }
            }
          }
        } catch (e) {
          AppLogger.w('ViewReport: Failed to fetch mycologist information: $e');
        }
      }

      setState(() {
        _report = report;
        _mycologistName = localMycologistName;
        _mycologistOccupation = localMycologistOccupation;
        // Capitalize the first letter of status
        String status = report.status.isNotEmpty ? report.status : 'Pending';
        if (status.isNotEmpty) {
          status = status[0].toUpperCase() + status.substring(1);
        }
        caseStatus = status;
        caseImageUrl =
            report.caseDetails.isNotEmpty &&
                report.caseDetails.first.coverPhoto.isNotEmpty
            ? report.caseDetails.first.coverPhoto.first
            : null;
        _finalVerdictMoldName = localVerdictMoldName;
        _finalVerdictConfidence = localVerdictConfidence;
        _finalVerdictNotes = localVerdictNotes;
        _preventionTacticsContent = localPreventionTacticsContent;
        AppLogger.d(
          'ViewReport: setState - caseStatus = $caseStatus, caseImageUrl = $caseImageUrl',
        );
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      AppLogger.e('ViewReport: ERROR', error: e, stackTrace: stackTrace);
      setState(() {
        _error = 'Failed to load report: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // trigger loading once after the first frame when arguments are available
    if (_isLoading && _report == null && _error == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _loadReportFromArgs(),
      );
    }
    final String observedDate = _report?.dateObserved != null
        ? DateFormat('MMMM dd, yyyy').format(_report!.dateObserved!.toLocal())
        : 'N/A';
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(const MutationResult.unchanged().toMap());
        }
      },
      child: Scaffold(
        backgroundColor: MoldifyColors.backgroundColor,
        appBar: PrimaryAppBar(
          title: AppLocalizations.of(context)!.viewReportTitle,
          showPopupMenu: true,
          popupMenuItems: [
            if (caseStatus.toLowerCase() == 'resolved')
              AppLocalizations.of(context)!.exportPdf,
          ],
          popupMenuIcons: [
            if (caseStatus.toLowerCase() == 'resolved')
              FontAwesomeIcons.solidFilePdf,
          ],
          onPopupMenuItemSelected: (index) async {
            // Handle the selection based on the index

            /// Export PDF
            if (index == 0) {
              await _handleExportPdf();
            }
          },
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              ///1. Cover image for the case
              if (_isLoading)
                SizedBox(
                  height: 220,
                  child: const Center(child: AppLoadingSpinner()),
                )
              else if (_error != null)
                SizedBox(
                  height: 220,
                  child: Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              else
                BuildCoverImage(
                  imageUrl: caseImageUrl,
                  borderRadiusContainer: 8,
                  borderRadiusImage: 8,
                  isHeader: true,
                ),

              ///2. Case details
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.35,
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: MoldifyColors.backgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(25, 30, 25, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Header row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            StatusBox(status: caseStatus, fontSize: 12),
                            Text(
                              'Date Observed: $observedDate'.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontFamily: 'Bricolage-Grotesque-Bold',
                                color: MoldifyColors.primaryColor,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Text(
                          _report?.caseName ??
                              AppLocalizations.of(context)!.caseDetailsLabel,
                          style: const TextStyle(
                            fontFamily: 'Montserrat-Black',
                            fontSize: 32,
                            color: MoldifyColors.primaryColor,
                            height: 1.0,
                            letterSpacing: -1.2,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Text(
                              (_report?.host ??
                                      AppLocalizations.of(context)!.unknownCrop)
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Bricolage-Grotesque-Bold',
                                color: MoldifyColors.accentColor,
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Text(
                              '•',
                              style: TextStyle(
                                color: MoldifyColors.primaryColor,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                _report?.location ??
                                    AppLocalizations.of(
                                      context,
                                    )!.unknownLocation,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Bricolage-Grotesque-Regular',
                                  color: MoldifyColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (_mycologistName.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Assigned Mycologist'.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    letterSpacing: 2.2,
                                    fontFamily: 'Bricolage-Grotesque-Bold',
                                    color: MoldifyColors.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _mycologistName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Montserrat-Black',
                                    color: MoldifyColors.primaryColor,
                                    height: 1.1,
                                  ),
                                ),
                                if (_mycologistOccupation != null &&
                                    _mycologistOccupation!.isNotEmpty)
                                  const SizedBox(height: 4),
                                if (_mycologistOccupation != null &&
                                    _mycologistOccupation!.isNotEmpty)
                                  Text(
                                    _mycologistOccupation!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontFamily:
                                          'Bricolage-Grotesque-Regular',
                                      color: MoldifyColors.primaryColor
                                          .withValues(alpha: 0.5),
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                        if (caseStatus == 'Resolved' || caseStatus == 'Closed')
                          Builder(
                            builder: (context) {
                              final parsedSections =
                                  ReportViewParser.parseMycologistNoteSections(
                                    _finalVerdictNotes,
                                  );
                              final controlSections = parsedSections
                                  .where(
                                    (section) => ReportViewParser
                                        .isPreventionControlSectionTitle(
                                          section['title'] ?? '',
                                        ),
                                  )
                                  .toList();
                              final noteSections = parsedSections
                                  .where(
                                    (section) => !ReportViewParser
                                        .isPreventionControlSectionTitle(
                                          section['title'] ?? '',
                                        ),
                                  )
                                  .toList();

                              final preventionContent =
                                  controlSections.isNotEmpty
                                  ? ReportViewParser.buildTreatmentsFromControlSections(
                                      controlSections,
                                    )
                                  : _preventionTacticsContent;

                              final tabs = <String>[
                                'Case Details',
                                'Biological Description',
                                'Host & Pathogen Impact',
                                'Prevention & Treatment',
                              ];

                              final activeTabIndex = _selectedTabIndex
                                  .clamp(0, tabs.length - 1)
                                  .toInt();

                              final tabContents = <Widget>[
                                _buildCaseDetailsTab(context),
                                ReportOverviewTab(sections: noteSections),
                                ListView(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  children: [
                                    ReportHostsSymptomsTab(
                                      sections: noteSections,
                                    ),
                                    const SizedBox(height: 8),
                                    ReportDiseaseCycleImpactTab(
                                      sections: noteSections,
                                    ),
                                  ],
                                ),
                                PreventionTacticsContent(
                                  treatmentsContent: preventionContent,
                                ),
                              ];

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_finalVerdictMoldName.trim().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 38.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 1.5,
                                            color: MoldifyColors.accentColor,
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'DISEASE IDENTIFICATION',
                                            style: TextStyle(
                                              fontSize: 10,
                                              letterSpacing: 2.2,
                                              fontFamily:
                                                  'Bricolage-Grotesque-Bold',
                                              color: MoldifyColors.primaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.baseline,
                                            textBaseline:
                                                TextBaseline.alphabetic,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  _finalVerdictMoldName,
                                                  style: const TextStyle(
                                                    fontSize: 26,
                                                    fontFamily:
                                                        'Bricolage-Grotesque-Bold',
                                                    color: MoldifyColors
                                                        .primaryColor,
                                                    height: 1.0,
                                                  ),
                                                ),
                                              ),
                                              if (_finalVerdictConfidence
                                                  .trim()
                                                  .isNotEmpty)
                                                Text(
                                                  _finalVerdictConfidence
                                                      .trim(),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontFamily:
                                                        'Bricolage-Grotesque-Bold',
                                                    color: MoldifyColors
                                                        .accentColor,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                  if (_linkedMoldipediaId != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 20.0,
                                      ),
                                      child: GestureDetector(
                                        onTap: () => Navigator.of(
                                          context,
                                        ).pushNamed(
                                          RouteNames.viewWikiMold,
                                          arguments: {
                                            'id': _linkedMoldipediaId,
                                          },
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: MoldifyColors.primaryColor
                                                  .withValues(alpha: 0.15),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.menu_book_rounded,
                                                size: 14,
                                                color: MoldifyColors.primaryColor
                                                    .withValues(alpha: 0.8),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'WIKIMOLD REFERENCE',
                                                style: TextStyle(
                                                  fontFamily:
                                                      'Bricolage-Grotesque-Bold',
                                                  fontSize: 11,
                                                  letterSpacing: 1.2,
                                                  color: MoldifyColors
                                                      .primaryColor
                                                      .withValues(alpha: 0.8),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Icon(
                                                Icons.arrow_outward_rounded,
                                                size: 12,
                                                color: MoldifyColors.primaryColor
                                                    .withValues(alpha: 0.4),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                  ReportResolvedActionsRow(
                                    visible: caseStatus == 'Resolved',
                                    onCloseCase: _handleCloseCase,
                                    onAddFollowUp: _handleAddFollowUp,
                                    closeCaseLabel: AppLocalizations.of(
                                      context,
                                    )!.closeCase,
                                    addFollowUpLabel: AppLocalizations.of(
                                      context,
                                    )!.addFollowUp,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top:
                                          _finalVerdictMoldName
                                              .trim()
                                              .isNotEmpty
                                          ? 32.0
                                          : 18.0,
                                    ),
                                    child: ScrollableTabBar(
                                      tabs: tabs,
                                      currentIndex: activeTabIndex,
                                      onTabSelected: (index) {
                                        setState(
                                          () => _selectedTabIndex = index,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.7,
                                      child: IndexedStack(
                                        index: activeTabIndex,
                                        children: tabContents,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                        else
                          _buildStatusMessageWidget(caseStatus),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
