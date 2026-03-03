// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/functions/tab_bar.dart';
import 'package:moldify/pages/monitor/content_tab/case_details.dart';
import 'package:moldify/pages/monitor/content_tab/in_vitro.dart';
import 'package:moldify/pages/monitor/content_tab/in_vivo.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../misc/appbar/primary_app_bar.dart';
import '../misc/images/cover_image.dart';
import '../misc/tiles/status_tile.dart';
import '../../../core/features/mold_case/models/mold_case.dart';
import '../../../core/features/mold_case/repository/mold_case_repository.dart';
import '../../../core/features/mold_report/service/mold_report_services.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/auth_provider.dart';
import 'package:moldify/core/utils/logger.dart';

class ViewCaseScreen extends StatefulWidget {

  const ViewCaseScreen({super.key});

  @override
  _ViewCaseScreenState createState() => _ViewCaseScreenState();
}
class _ViewCaseScreenState extends State<ViewCaseScreen> {
  String? caseImageUrl = "https://aggie-horticulture.tamu.edu/wp-content/uploads/sites/10/2012/01/black_mold.jpg";
  String caseStatus = 'Pending';
  String reportStatus = 'Unknown';
  String cropName = '';


  // Backend-driven state
  bool _isLoading = true;
  String? _error;
  MoldCase? _case;
  String? _reportId; // Store the report ID for status updates

  // Farmer details from mold report
  String farmerName = 'Juan Dela Cruz';
  String dateFirstObserved = 'October 30, 2025';
  String emailAddress = 'juan.delacruz@example.com';
  String contactNumber = '+63 917 123 4567';
  String location = 'Unknown Location';
  late List<Map<String, dynamic>> caseEntries = [];

  // Data for In-Vitro Tab
  String inVitroDateTime = 'November 01, 2025 – 10:00 AM';
  String inVitroGrowthMedium = 'Potato Dextrose Agar';
  String inVitroIncubationTemperature = '25°C';
  List<Map<String, String>> inVitroEntries = [];

  // Data for In-Vivo Tab
  String inVivoDateTime = 'November 01, 2025 – 10:00 AM';
  String inVivoEnvironmentalTemperature = '28°C';
  List<Map<String, String>> inVivoEntries = [];

  String _getCaseCropName() {
    return cropName.isNotEmpty ? cropName : 'Kamatis Tagalog';

  }

  Future<void> _markCaseAsResolved() async {
    if (_reportId == null || _reportId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Report ID not found')),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Mark Case as Resolved?'),
        content: const Text(
          'Are you sure you want to mark this case as resolved? '
          'If the farmer adds a follow-up, the status will reset to pending.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Resolve'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed) return;
    if (!mounted) return;

    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;
      final reportService = MoldReportService();

      // Update the mold report status to "resolved"
      await reportService.patchMoldReport(
        _reportId!,
        {'status': 'resolved'},
        sessionCookie: sessionCookie,
      );

      if (!mounted) return;
      setState(() {
        caseStatus = 'Resolved';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Case marked as resolved!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark case as resolved: $e')),
      );
    }
  }

  Future<void> _loadCaseFromArgs() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    AppLogger.d('ViewCase: args = $args');
    String? reportId;
    if (args is Map<String, dynamic>) {
      reportId = args['id']?.toString();
    } else if (args is String) {
      reportId = args;
    }

    AppLogger.d('ViewCase: extracted reportId = $reportId');

    if (reportId == null || reportId.isEmpty) {
      setState(() {
        _error = 'No report id provided';
        _isLoading = false;
      });
      return;
    }

    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;
      AppLogger.d('ViewCase: sessionCookie = ${sessionCookie?.substring(0, 20)}...');

      // Create a local repository
      final repo = MoldCaseRepository(pageSize: 10);

      AppLogger.d('ViewCase: calling getCasesByReportId($reportId)');
      final List<MoldCase> moldCases = await repo.getCasesByReportId(reportId, sessionCookie: sessionCookie);
      AppLogger.d('ViewCase: getCasesByReportId returned ${moldCases.length} cases');

      if (moldCases.isEmpty) {
        setState(() {
          _error = 'No cases found for this report';
          _isLoading = false;
        });
        return;
      }

      // Use the first case (or you could let user select if multiple)
      final MoldCase moldCase = moldCases.first;

      AppLogger.d('ViewCase: case.mycologistId = ${moldCase.mycologistId}');
      AppLogger.d('ViewCase: case.name = ${moldCase.name}');
      AppLogger.d('ViewCase: case.priority = ${moldCase.priority}');
      AppLogger.d('ViewCase: case.moldReportId = ${moldCase.moldReportId}');

      // Fetch farmer details from the mold report
      String localFarmerName = 'Juan Dela Cruz';
      String localDateFirstObserved = 'October 30, 2025';
      String localEmailAddress = 'juan.delacruz@example.com';
      String localContactNumber = '+63 917 123 4567';
      String localLocation = 'Unknown Location';
      final List<Map<String, dynamic>> localCaseEntries = [];
      String localReportStatus = 'Unknown';

      if (moldCase.moldReportId.isNotEmpty) {
        try {
          AppLogger.d('ViewCase: fetching report ${moldCase.moldReportId} for farmer details');
          final reportService = MoldReportService();
          final reportData = await reportService.getMoldReportById(
            moldCase.moldReportId,
            sessionCookie: sessionCookie,
          );
          AppLogger.d('ViewCase: report data = $reportData');

          // Extract farmer details from report data
          final reportPayload = reportData['data'] is Map<String, dynamic> 
              ? reportData['data'] as Map<String, dynamic>
              : reportData;
            AppLogger.d('ViewCase: reportPayload.location = ${reportPayload['location']}');
          cropName = reportPayload['host']?.toString() ?? 'Kamatis Tagalog';          AppLogger.d('Report crop_name: ${reportPayload['crop_name']}');
          // Extract status from report
          final statusRaw = reportPayload['status']?.toString() ?? 'Unknown';
          localReportStatus = statusRaw[0].toUpperCase() + statusRaw.substring(1);

          // Extract reporter details from the report
          final reporter = reportPayload['reporter'] as Map<String, dynamic>?;
            if (reporter != null) {
              AppLogger.d('ViewCase: reporter found = $reporter');
            final user = reporter['user'] as Map<String, dynamic>?;
            final details = reporter['details'] as Map<String, dynamic>?;
              AppLogger.d('ViewCase: reporter.details = $details');
            
            if (user != null) {
              localFarmerName = '${user['first_name']?.toString() ?? ''} ${user['last_name']?.toString() ?? ''}'.trim();
            }
            AppLogger.d('ViewCase: resolved localLocation = $localLocation');
            if (details != null) {
              localEmailAddress = details['email']?.toString() ?? localEmailAddress;
              localContactNumber = details['phone_number']?.toString() ?? localContactNumber;
              // Prefer reporter details.location, then top-level report location, then address
              localLocation = details['location']?.toString() ??
                              reportPayload['location']?.toString() ??
                              details['address']?.toString() ??
                              'Unknown Location';
            } else {
              // If no reporter details, fall back to top-level report location
              localLocation = reportPayload['location']?.toString() ?? localLocation;
            }
          }
          
          // Extract date observed from report, format it
          final dateObserved = reportPayload['date_observed']?.toString();
          if (dateObserved != null) {
            localDateFirstObserved = formatIsoDateToDisplay(dateObserved);
          }

          // Extract case_details from report and build caseEntries
          final caseDetails = reportPayload['case_details'] as List<dynamic>?;
          AppLogger.d('ViewCase: case_details = $caseDetails');
          if (caseDetails != null && caseDetails.isNotEmpty) {
            AppLogger.d('ViewCase: processing ${caseDetails.length} case detail entries');
            for (var i = 0; i < caseDetails.length; i++) {
              final detail = caseDetails[i];
              AppLogger.d('ViewCase: detail[$i] = $detail');
              if (detail is Map<String, dynamic>) {
                final description = detail['description']?.toString() ?? '';
                final metadata = detail['metadata'] as Map<String, dynamic>?;
                
                // Extract created_at from metadata
                String entryDate = localDateFirstObserved;
                if (metadata != null && metadata['created_at'] != null) {
                  entryDate = formatFirestoreTimestampToDisplay(
                    metadata['created_at'] as Map<String, dynamic>?,
                  );
                }
                
                // Extract cover_photo images
                final coverPhotos = detail['cover_photo'] as List<dynamic>?;
                final images = coverPhotos is List 
                    ? coverPhotos.whereType<String>().toList()
                    : <String>[];
                
                AppLogger.d('ViewCase: adding entry with date=$entryDate, notes=$description, images=${images.length}');
                localCaseEntries.add({
                  'date': entryDate,
                  'notes': description,
                  'images': images,
                });
              }
            }
          }

          AppLogger.d('ViewCase: extracted farmer details - name=$localFarmerName, email=$localEmailAddress');
          AppLogger.d('ViewCase: extracted ${localCaseEntries.length} case entries from report');

        } catch (e) {
          AppLogger.e('ViewCase: WARNING - failed to fetch report for farmer details', error: e);
          // Continue with fallback data
        }
      }

      // Extract cultivation details from the MoldCase
      String localInVitroDateTime = 'No data';
      String localInVitroGrowthMedium = 'Not specified';
      String localInVitroIncubationTemperature = 'Not specified';
      List<Map<String, String>> localInVitroEntries = [];
      
      String localInVivoDateTime = 'No data';
      String localInVivoEnvironmentalTemperature = 'Not specified';
      List<Map<String, String>> localInVivoEntries = [];

      if (moldCase.cultivationDetails != null) {
        final cultivationDetails = moldCase.cultivationDetails!;
        
        // Extract in vitro details
        if (cultivationDetails.inVitroDetails != null) {
          localInVitroIncubationTemperature = '${cultivationDetails.inVitroDetails!.incubationTemperature}°C';
        }
        localInVitroGrowthMedium = cultivationDetails.growthMedium.isNotEmpty 
            ? cultivationDetails.growthMedium 
            : 'Not specified';

        // Extract cultivation logs and categorize them
        if (moldCase.cultivationLogs != null && moldCase.cultivationLogs!.isNotEmpty) {
          for (var log in moldCase.cultivationLogs!) {
            if (log.type == 'vitro') {
              localInVitroEntries.add({
                'date': 'Log Entry',
                'imagePath': '',
                'sizeValue': log.characteristics['size']?.toString() ?? 'Not measured',
                'colorValue': log.characteristics['color']?.toString() ?? 'Not specified',
                'notes': log.additionalInfo,
              });
              if (localInVitroDateTime == 'No data') {
                localInVitroDateTime = DateFormat('MMMM dd, yyyy – hh:mm a').format(DateTime.now());
              }
            } else if (log.type == 'vivo') {
              localInVivoEntries.add({
                'date': 'Log Entry',
                'imagePath': '',
                'sizeValue': log.characteristics['size']?.toString() ?? 'Not measured',
                'colorValue': log.characteristics['color']?.toString() ?? 'Not specified',
                'notes': log.additionalInfo,
              });
              if (localInVivoDateTime == 'No data') {
                localInVivoDateTime = DateFormat('MMMM dd, yyyy – hh:mm a').format(DateTime.now());
              }
            }
          }
        }

        // Extract in vivo details
        if (cultivationDetails.inVivoDetails != null) {
          localInVivoEnvironmentalTemperature = '${cultivationDetails.inVivoDetails!.environmentalTemperature}°C';
        }
      }

      setState(() {
        _case = moldCase;
        _reportId = reportId; // Store report ID for status updates
        caseStatus = _case!.priority[0].toUpperCase() + _case!.priority.substring(1);
        reportStatus = localReportStatus;
        caseImageUrl = _case!.photoUrl ?? caseImageUrl;
        farmerName = localFarmerName;
        dateFirstObserved = localDateFirstObserved;
        emailAddress = localEmailAddress;
        contactNumber = localContactNumber;
        location = localLocation;
        caseEntries = localCaseEntries;
        inVitroDateTime = localInVitroDateTime;
        inVitroGrowthMedium = localInVitroGrowthMedium;
        inVitroIncubationTemperature = localInVitroIncubationTemperature;
        inVitroEntries = localInVitroEntries;
        inVivoDateTime = localInVivoDateTime;
        inVivoEnvironmentalTemperature = localInVivoEnvironmentalTemperature;
        inVivoEntries = localInVivoEntries;
        cropName = cropName;
        _isLoading = false;

      });
    } catch (e, stackTrace) {
      AppLogger.e('ViewCase: ERROR', error: e);
      AppLogger.e('ViewCase: stackTrace', error: stackTrace);
      setState(() {
        _error = 'Failed to load case: $e';
        _isLoading = false;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCaseFromArgs();
    });
  }

  @override
  Widget build(BuildContext context) {
    //Determine if the case is closed. This boolean will control the UI.
    final bool isCaseClosed = caseStatus == 'Closed';
    
    // Use API data if available, otherwise use fallback defaults
    String priorityLevel = _case?.priority != null 
        ? '${_case!.priority[0].toUpperCase()}${_case!.priority.substring(1)} Priority'
        : 'Low Priority';
    
    String endDate = _case?.endDate != null
        ? DateFormat('MMMM dd, yyyy').format(_case!.endDate!)
        : 'December 15, 2025';


    //Dynamically build the list of menu items based on the case status.
    final List<String> popupMenuItems = [
      if (!isCaseClosed) 'Set Monitoring Details',
      if (!isCaseClosed) 'Mark as Resolved',
      'Identification History',
      'Treatment History',
      'Export PDF'
    ];

    final List<IconData> popupMenuIcons = [
      if (!isCaseClosed) FontAwesomeIcons.circleInfo,
      if (!isCaseClosed) FontAwesomeIcons.circleCheck,
      FontAwesomeIcons.clockRotateLeft,
      FontAwesomeIcons.sprayCan,
      FontAwesomeIcons.solidFilePdf,
    ];


    return Scaffold(
        backgroundColor: MoldifyColors.backgroundColor,
        appBar: PrimaryAppBar(
            title: 'View Case',
            showPopupMenu: true,
            popupMenuItems: popupMenuItems,
            popupMenuIcons: popupMenuIcons,
            onPopupMenuItemSelected: (index) {
              // The selected item is now correctly determined from the same list used by the menu.
              final selectedItem = popupMenuItems[index];

              if (selectedItem == 'Set Monitoring Details') {
                Navigator.pushNamed(
                  context, 
                  '/set-monitoring-details',
                  arguments: {'moldCase': _case},
                );
              }
              else if (selectedItem == 'Mark as Resolved') {
                _markCaseAsResolved();
              }
              else if (selectedItem == 'Identification History') {
                Navigator.pushNamed(context, '/identification-history');
              }
              else if (selectedItem == 'Treatment History') {
                Navigator.pushNamed(context, '/treatment-history');
              }
              else if (selectedItem == 'Export PDF') {
                // Implement export PDF functionality here
              }
            }
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            FontAwesomeIcons.triangleExclamation,
                            size: 48,
                            color: MoldifyColors.accentColor,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Error Loading Case',
                            style: TextStyle(
                              fontFamily: 'Montserrat-Bold',
                              fontSize: 16,
                              color: MoldifyColors.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Bricolage-Grotesque-Regular',
                              fontSize: 12,
                              color: MoldifyColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
          child: Stack(
            children: [

              ///1. Cover image for the case
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
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0, bottom: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            StatusBox(status: priorityLevel, fontSize: 12,),
                            SizedBox(width: 5),
                            StatusBox(status: reportStatus, fontSize: 12,),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'End Date: ',
                                  style: const TextStyle(
                                    fontSize: 10.0,
                                    color: MoldifyColors.primaryColor,
                                    fontFamily: 'Bricolage-Grotesque-Regular',
                                  ),
                                ),
                                TextSpan(
                                  text: endDate,
                                  style: const TextStyle(
                                    fontSize: 10.0,
                                    color: MoldifyColors.primaryColor,
                                    fontFamily: 'Bricolage-Grotesque-Bold',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _case?.name ?? 'Tomato Mold',
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
                                      text: "			${_getCaseCropName()}",
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
                                      text: "			$location",
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

                        if(!isCaseClosed)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Row(
                              children: [
                                Flexible(
                                  child: BuildButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        RouteNames.mainCamera,
                                        arguments: {'showAppBar': true},
                                      );
                                    },
                                    buttonText: 'Identify Mold',
                                    fontSize: 12,
                                    backgroundColor: MoldifyColors.primaryColor,
                                    textColor: MoldifyColors.backgroundColor,
                                    leftIcon: FontAwesomeIcons.camera,
                                    iconSize: 12,
                                    iconColor: MoldifyColors.backgroundColor,
                                    paddingIconText: 10,
                                    buttonHeight: 30,
                                    buttonRadius: 7,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: BuildButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/add-treatment',
                                      );
                                    },
                                    buttonText: 'Add Treatment',
                                    fontSize: 12,
                                    backgroundColor: MoldifyColors.accentColor,
                                    textColor: MoldifyColors.MoldifyBlack,
                                    leftIcon: FontAwesomeIcons.plus,
                                    iconSize: 12,
                                    iconColor: MoldifyColors.MoldifyBlack,
                                    paddingIconText: 10,
                                    buttonHeight: 30,
                                    buttonRadius: 7,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: BuildTabBar(
                              tabs: ['Case Details', 'In Vitro', 'In Vivo'],
                              tabContents: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                  child: CaseDetailsTab(
                                    entries: caseEntries,
                                    farmerName: farmerName,
                                    dateFirstObserved: dateFirstObserved,
                                    emailAddress: emailAddress,
                                    contactNumber: contactNumber,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                  child: InVitroTab(
                                    isCaseClosed: isCaseClosed,
                                    dateTime: inVitroDateTime,
                                    growthMedium: inVitroGrowthMedium,
                                    incubationTemperature: inVitroIncubationTemperature,
                                    inVitroEntries: inVitroEntries,
                                    caseId: _case!.id,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                  child: InVivoTab(
                                    isCaseClosed: isCaseClosed,
                                    dateTime: inVivoDateTime,
                                    environmentalTemperature: inVivoEnvironmentalTemperature,
                                    inVivoEntries: inVivoEntries,
                                    caseId: _case!.id,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

            ],
          ),
        )
                );
  }
}