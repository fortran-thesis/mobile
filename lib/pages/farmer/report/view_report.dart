import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/farmer/report/content_tab/prevention_tactics_content.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/features/user/logic/user_bloc.dart';

import '../../../core/features/mold_report/models/mold_report.dart';
import '../../../core/features/mold_report/repository/mold_report_repository.dart';
import '../../../core/features/mold_report/logic/mold_report_bloc.dart';
import '../../../providers/auth_provider.dart';
import 'package:moldify/core/utils/logger.dart';

// route names not used here
import '../../misc/appbar/primary_app_bar.dart';
import '../../misc/buttons/primary_button.dart';
import '../../misc/colors.dart';
import '../../misc/functions/tab_bar.dart';
import '../../misc/images/cover_image.dart';
import '../../misc/overlays/modals/confirmation_dialog.dart';
import '../../misc/tiles/status_tile.dart';
import '../../monitor/content_tab/case_details.dart';

class ViewReportScreen extends StatefulWidget {
  const ViewReportScreen({super.key});

  @override
  State<ViewReportScreen> createState() => _ViewReportScreenState();
}

class _ViewReportScreenState extends State<ViewReportScreen> {
  String? caseImageUrl;
  // Change the status to 'Resolved', 'Closed', 'In Progress', or 'Rejected' to see different UI states.
  String caseStatus = 'Pending';

  /// Builds a centered text widget to display messages for non-resolved statuses.
  Widget _buildStatusMessageWidget(String status) {
    String message;
    switch (status) {
      case 'Pending':
        message = 'Your report has been sent in and is now waiting to be checked.';
        break;
      case 'In Progress':
        message = 'We\'re checking your report now. You\'ll see the results when it\'s ready.';
        break;
      case 'Rejected':
        message = 'Sorry, your report was rejected and can\'t be processed.';
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
          )
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
      'notes': 'Initial report. Small, dark spots observed on the lower leaves of several tomato plants. The area is humid and has poor air circulation.',
      'images': [
        'https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg',
        'https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg',
      ],
    },
    {
      'date': 'November 2, 2025',
      'notes': 'Follow-up. The spots have enlarged and now have a dark border with a lighter tan center. Some lower leaves are starting to turn yellow and drop.',
      'images': [
        'https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg',
      ],
    },
    {
      'date': 'November 2, 2025',
      'notes': 'Follow-up. The spots have enlarged and now have a dark border with a lighter tan center. Some lower leaves are starting to turn yellow and drop.',
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
      AppLogger.d('ViewReport: sessionCookie = ${sessionCookie?.substring(0, 20)}...');

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
      final MoldReport? report = await repo.getReportById(id, sessionCookie: sessionCookie);
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
      AppLogger.d('ViewReport: report.caseDetails.length = ${report.caseDetails.length}');

      setState(() {
        _report = report;
        // Capitalize the first letter of status
        String status = report.status.isNotEmpty ? report.status : 'Pending';
        if (status.isNotEmpty) {
          status = status[0].toUpperCase() + status.substring(1);
        }
        caseStatus = status;
        caseImageUrl = report.caseDetails.isNotEmpty && report.caseDetails.first.coverPhoto.isNotEmpty
            ? report.caseDetails.first.coverPhoto.first
            : null;
        AppLogger.d('ViewReport: setState - caseStatus = $caseStatus, caseImageUrl = $caseImageUrl');
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
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadReportFromArgs());
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.of(context).pop(true);
      },
      child: Scaffold(
        backgroundColor: MoldifyColors.backgroundColor,
        appBar: PrimaryAppBar(
            title: 'View Report',
            showPopupMenu: true,
            popupMenuItems: ['Treatment History', 'Export PDF'],
            popupMenuIcons: [FontAwesomeIcons.clockRotateLeft, FontAwesomeIcons.solidFilePdf],
            onPopupMenuItemSelected: (index) {
              // Handle the selection based on the index

              /// Treatment History
              if (index == 0) {
                Navigator.pushNamed(
                  context,
                  '/treatment-history',
                );
              }
              /// End of Identification History

              /// Export PDF
              else if (index == 1) {
                // Navigator.pushNamed(
                //   context,
                //   '/treatment-history',
                // );
              }
              /// End of Treatment History
            }
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [

              ///1. Cover image for the case
              if (_isLoading)
                SizedBox(
                  height: 220,
                  child: const Center(child: CircularProgressIndicator()),
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
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.23),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: MoldifyColors.backgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Status and Priority Boxes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StatusBox(status: caseStatus, fontSize: 11),
                            const SizedBox(width: 8),
                            StatusBox(
                              status: 'Unassigned',
                              fontSize: 11,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Text(
                            _report?.caseName ?? 'Case Details',
                            style: TextStyle(
                              fontFamily: 'Montserrat-Black',
                              fontSize: 24,
                              color: MoldifyColors.primaryColor,
                              height: 1.2,
                            ),
                          ),
                        ),
                        /// Crop Name
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: RichText(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                text: TextSpan(
                                  children: [
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Icon(
                                        FontAwesomeIcons.seedling,
                                        size: 16,
                                        color: MoldifyColors.accentColor,
                                      ),
                                    ),
                                      TextSpan(
                                        text: '\t\t\t${_report?.host ?? 'Unknown crop'}',
                                        style: TextStyle(
                                          color: MoldifyColors.primaryColor,
                                          fontSize: 12,
                                          fontFamily:
                                          'Bricolage-Grotesque-Regular',
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: RichText(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                text: TextSpan(
                                  children: [
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Icon(
                                        FontAwesomeIcons.locationDot,
                                        size: 16,
                                        color: MoldifyColors.accentColor,
                                      ),
                                    ),
                                      TextSpan(
                                        text: '\t\t\t${_report?.location ?? "Unknown location"}',
                                        style: TextStyle(
                                          color: MoldifyColors.primaryColor,
                                          fontSize: 12,
                                          fontFamily:
                                          'Bricolage-Grotesque-Regular',
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Conditional UI based on case status
                        if (caseStatus == 'Resolved' || caseStatus == 'Closed')
                          Column(
                            children: [
                              // Buttons are only visible if the case is 'Resolved'
                              if (caseStatus == 'Resolved')
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Row (
                                    children: [
                                      /// Close Case Button
                                      BuildButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return BuildConfirmationDialog(
                                                title: 'Are you sure you want to close this report?',
                                                subtitle: 'Once closed, you will not be able to add follow-ups.',
                                                onConfirm: () {
                                                  Navigator.of(context).pop();
                                                  Navigator.of(context).pop();
                                                },
                                                onCancel: (){
                                                  Navigator.of(context).pop();
                                                },
                                                cancelText: 'No',
                                                confirmText: 'Yes',
                                              );
                                            },
                                          );
                                        },
                                        buttonText: 'Close Case',
                                        fontSize: 12,
                                        backgroundColor: MoldifyColors.primaryColor,
                                        textColor: MoldifyColors.backgroundColor,
                                        leftIcon: FontAwesomeIcons.solidCircleCheck,
                                        iconSize: 12,
                                        iconColor: MoldifyColors.backgroundColor,
                                        paddingIconText: 10,
                                        buttonHeight: 30,
                                        buttonWidth: 120,
                                        buttonRadius: 7,
                                      ),
                                      SizedBox(width: 5),

                                      /// Create Follow-up Button
                                      BuildButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/add-follow-up',
                                            arguments: {'id': _report?.id},
                                          );
                                        },
                                        buttonText: 'Add Follow-up',
                                        fontSize: 12,
                                        backgroundColor: MoldifyColors.accentColor,
                                        textColor: MoldifyColors.MoldifyBlack,
                                        leftIcon: FontAwesomeIcons.plus,
                                        iconSize: 12,
                                        iconColor: MoldifyColors.MoldifyBlack,
                                        paddingIconText: 10,
                                        buttonHeight: 30,
                                        buttonWidth: 120,
                                        buttonRadius: 7,
                                      )
                                    ],
                                  ),
                                ),
                              Padding(
                                // Add top padding if the buttons are hidden
                                padding: EdgeInsets.only(top: caseStatus == 'Closed' ? 20.0 : 10.0),
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.7,
                                  child: BuildTabBar(
                                    tabs: ['Case Details', 'Prevention Tactics'],
                                    tabContents: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                        child: Builder(builder: (ctx) {
                                          // derive display values from UserBloc when available, fall back to defaults
                                          String displayFarmerName = farmerName;
                                          String displayEmail = emailAddress;
                                          String displayContact = contactNumber;

                                          try {
                                            final userState = BlocProvider.of<UserBloc>(ctx).state;
                                            if (userState is UserProfileLoaded) {
                                              final profile = userState.profile;
                                              final fullName = ((profile.firstName.isNotEmpty || profile.lastName.isNotEmpty)
                                                      ? '${profile.firstName} ${profile.lastName}'.trim()
                                                      : profile.username);
                                              displayFarmerName = fullName.isNotEmpty ? fullName : displayFarmerName;
                                              displayEmail = profile.email.isNotEmpty ? profile.email : displayEmail;
                                              displayContact = profile.phoneNumber.isNotEmpty ? profile.phoneNumber : displayContact;
                                            }
                                          } catch (_) {
                                            // no UserBloc in context or other error; keep defaults
                                          }

                                          // format dateObserved when available
                                          String formattedObserved(DateTime? dt) {
                                            if (dt == null) return dateFirstObserved;
                                            try {
                                              return DateFormat('MMMM d, yyyy').format(dt.toLocal());
                                            } catch (_) {
                                              return dateFirstObserved;
                                            }
                                          }

                                          final entries = _report != null
                                              ? _report!.caseDetails.map((d) => {
                                                  'date': formattedObserved(_report!.dateObserved),
                                                  'notes': d.description,
                                                  'images': d.coverPhoto,
                                                }).toList()
                                              : caseEntries;

                                          return CaseDetailsTab(
                                            entries: entries,
                                            farmerName: _report != null ? displayFarmerName : farmerName,
                                            dateFirstObserved: _report != null ? formattedObserved(_report!.dateObserved) : dateFirstObserved,
                                            emailAddress: displayEmail,
                                            contactNumber: displayContact,
                                          );
                                        }),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                        child: PreventionTacticsContent(
                                          recommendedFungicides: [
                                            'Mancozeb',
                                            'Chlorothalonil',
                                            'Copper-based fungicides',
                                            'Azoxystrobin'
                                          ],
                                          additionalInformation: 'To prevent future outbreaks, ensure proper '
                                              'plant spacing for good air circulation, water at the base of plants '
                                              'to keep foliage dry, and promptly remove and destroy any infected plant'
                                              ' debris. Rotate crops annually and consider using resistant varieties if available.'
                                          ,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
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
        )
      ),
    );
  }
}