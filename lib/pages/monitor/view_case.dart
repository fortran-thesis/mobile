// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/functions/scrollable_tab_bar.dart';
import 'package:moldify/pages/monitor/content_tab/case_details.dart';
import 'package:moldify/pages/monitor/content_tab/initial_observation.dart';
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
  bool _mutationOccurred = false; // Signal list refresh to caller on pop
  bool _hasGivenRecommendation = false;

  // Farmer details from mold report
  String farmerName = 'Juan Dela Cruz';
  String dateFirstObserved = 'October 30, 2025';
  String emailAddress = 'juan.delacruz@example.com';
  String contactNumber = '+63 917 123 4567';
  String location = 'Unknown Location';
  late List<Map<String, dynamic>> caseEntries = [];

  // Active tab index for the ScrollableTabBar.
  // 0 = Case Details, 1 = Initial Observation, 2 = In Vitro, 3 = In Vivo.
  int _selectedTabIndex = 0;

  // Dummy data for Initial Observation tab.
  // TODO: Replace with real data persisted from the Set Monitoring Details step.
  // These image paths are intentionally non-empty so the tab can always preview
  // full-content state during development and UI review.
  String _initMicroscopicImagePath = 'assets/images/bacteria_leaves.png';
  String _initMacroscopicImagePath = 'assets/images/mold_home_banner.png';
  String _initIdentifiedMold = 'Aspergillus fumigatus';
  String _initConfidence = '87%';
  String _initMacroColor = 'Yellowish-green';
  String _initMacroTexture = 'Powdery';
  String _initMacroSymptoms = 'Leaf yellowing, Stem rot';
  String _initMacroCharacteristics = 'Dense sporulation, Irregular margins';

  // Data for In-Vitro Tab
  String inVitroDateTime = 'November 01, 2025 – 10:00 AM';
  String inVitroGrowthMedium = 'Potato Dextrose Agar';
  String inVitroIncubationTemperature = '25°C';
  // TODO: Replace with real backend data.
  List<Map<String, String>> inVitroEntries = [
    {
      'date': 'November 01, 2025 • 10:00 AM',
      'microscopicImagePath': 'assets/images/bacteria_leaves.png',
      'macroscopicImagePath': 'assets/images/mold_home_banner.png',
      'microSize': '12',
      'microColor': 'Black',
      'microTexture': 'Powdery',
      'macroColor': 'Greenish-black',
      'macroTexture': 'Cottony',
      'macroSymptoms': 'Leaf spots, Wilting',
      'macroCharacteristics': 'Rapid spreading, Fuzzy',
      'notes': 'Colony diameter increased significantly from baseline.',
    },
    {
      'date': 'November 05, 2025 • 02:30 PM',
      'microscopicImagePath': 'assets/images/bacteria_leaves.png',
      'macroscopicImagePath': 'assets/images/mold_home_banner.png',
      'microSize': '18',
      'microColor': 'Dark grey',
      'microTexture': 'Granular',
      'macroColor': 'Dark brown',
      'macroTexture': 'Slimy',
      'macroSymptoms': 'Yellowing, Soft rot',
      'macroCharacteristics': 'Water-soaked, Irregular margins',
      'notes': 'Growth rate accelerated. Necrosis spreading.',
    },
  ];

  // Data for In-Vivo Tab
  String inVivoDateTime = 'November 01, 2025 – 10:00 AM';
  String inVivoEnvironmentalTemperature = '28°C';
  // TODO: Replace with real backend data.
  List<Map<String, String>> inVivoEntries = [
    {
      'date': 'November 01, 2025 • 10:00 AM',
      'microscopicImagePath': 'assets/images/bacteria_leaves.png',
      'macroscopicImagePath': 'assets/images/mold_home_banner.png',
      'microSize': '4',
      'microColor': 'Brown',
      'microTexture': 'Rough',
      'macroColor': 'Dark brown',
      'macroTexture': 'Wet',
      'macroSymptoms': 'Stem lesions, Necrosis',
      'macroCharacteristics': 'Water-soaked, Rapid spreading',
      'notes': 'Initial lesion observed on lower stem.',
    },
    {
      'date': 'November 04, 2025 • 09:15 AM',
      'microscopicImagePath': 'assets/images/bacteria_leaves.png',
      'macroscopicImagePath': 'assets/images/mold_home_banner.png',
      'microSize': '7',
      'microColor': 'Reddish-brown',
      'microTexture': 'Dry',
      'macroColor': 'Black',
      'macroTexture': 'Crusty',
      'macroSymptoms': 'Wilting, Leaf spots',
      'macroCharacteristics': 'Cottony edges, Dense sporulation',
      'notes': 'Lesion expanded. Wilting now visible on upper foliage.',
    },
  ];

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
        _mutationOccurred = true;
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

  /// Handles the temporary local "Give Recommendation" flow.
  ///
  /// Navigates to the dedicated recommendation page and only flips local state
  /// when that page returns a successful submission (`true`).
  Future<void> _handleGiveRecommendation() async {
    final result = await Navigator.pushNamed(
      context,
      RouteNames.giveRecommendation,
      arguments: {
        'reportId': _reportId,
        'caseId': _case?.id,
      },
    );

    if (!mounted || result != true) return;

    setState(() {
      _hasGivenRecommendation = true;
      _mutationOccurred = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recommendation submitted. You can now mark this case as resolved.'),
      ),
    );
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

      final reportService = MoldReportService();
      AppLogger.d('ViewCase: calling getMoldReportById($reportId)');
      final reportData = await reportService.getMoldReportById(
        reportId,
        sessionCookie: sessionCookie,
      );
      AppLogger.d('ViewCase: report data = $reportData');

      final reportPayload = reportData['data'] is Map<String, dynamic>
          ? reportData['data'] as Map<String, dynamic>
          : reportData;

      String capitalizeStatus(String raw) {
        final normalized = raw.trim();
        if (normalized.isEmpty) return 'Unknown';
        return normalized[0].toUpperCase() + normalized.substring(1);
      }

      final resolvedReportId = reportPayload['id']?.toString().trim().isNotEmpty == true
          ? reportPayload['id'].toString().trim()
          : reportId;

      final statusRaw = reportPayload['status']?.toString() ?? 'Unknown';
      final localReportStatus = capitalizeStatus(statusRaw);
      final localCaseName = reportPayload['case_name']?.toString() ??
          reportPayload['name']?.toString() ??
          'Unknown Case';
      final localMycologistId = reportPayload['assigned_mycologist_id']?.toString() ??
          reportPayload['mycologist_id']?.toString() ??
          '';

      final dateObservedRaw = reportPayload['date_observed']?.toString();
      final startDate = (dateObservedRaw != null && dateObservedRaw.isNotEmpty)
          ? (DateTime.tryParse(dateObservedRaw)?.toUtc() ?? DateTime.now().toUtc())
          : DateTime.now().toUtc();

      // Build a fallback case from report payload so view page always works.
      MoldCase moldCase = MoldCase(
        id: resolvedReportId,
        mycologistId: localMycologistId,
        name: localCaseName,
        moldReportId: resolvedReportId,
        priority: 'low',
        startDate: startDate,
        endDate: null,
        cultivationDetails: null,
        cultivationLogs: null,
        isArchived: false,
      );

      // Try to enrich with mold-case data (priority, cultivation details/logs).
      try {
        final repo = MoldCaseRepository(pageSize: 10);
        final moldCases = await repo.getCasesByReportId(
          resolvedReportId,
          sessionCookie: sessionCookie,
        );
        if (moldCases.isNotEmpty) {
          moldCase = moldCases.first;
        }
      } catch (e) {
        AppLogger.w('ViewCase: no mold-case enrichment found, using report payload only');
      }

      // Fetch farmer details from the mold report
      String localFarmerName = 'Juan Dela Cruz';
      String localDateFirstObserved = 'October 30, 2025';
      String localEmailAddress = 'juan.delacruz@example.com';
      String localContactNumber = '+63 917 123 4567';
      String localLocation = 'Unknown Location';
      final List<Map<String, dynamic>> localCaseEntries = [];

      cropName = reportPayload['host']?.toString() ?? 'Kamatis Tagalog';

      // Extract reporter details from the report
      final reporter = reportPayload['reporter'] as Map<String, dynamic>?;
      if (reporter != null) {
        final user = reporter['user'] as Map<String, dynamic>?;
        final details = reporter['details'] as Map<String, dynamic>?;

        if (user != null) {
          localFarmerName =
              '${user['first_name']?.toString() ?? ''} ${user['last_name']?.toString() ?? ''}'
                  .trim();
        }
        if (details != null) {
          localEmailAddress = details['email']?.toString() ?? localEmailAddress;
          localContactNumber = details['phone_number']?.toString() ?? localContactNumber;
          localLocation = details['location']?.toString() ??
              reportPayload['location']?.toString() ??
              details['address']?.toString() ??
              'Unknown Location';
        } else {
          localLocation = reportPayload['location']?.toString() ?? localLocation;
        }
      } else {
        localLocation = reportPayload['location']?.toString() ?? localLocation;
      }

      // Extract date observed from report, format it
      final dateObserved = reportPayload['date_observed']?.toString();
      if (dateObserved != null && dateObserved.isNotEmpty) {
        localDateFirstObserved = formatIsoDateToDisplay(dateObserved);
      }

      // Extract case_details from report and build caseEntries
      final caseDetails = reportPayload['case_details'] as List<dynamic>?;
      if (caseDetails != null && caseDetails.isNotEmpty) {
        for (final detail in caseDetails) {
          if (detail is! Map<String, dynamic>) continue;

          final description = detail['description']?.toString() ?? '';
          String entryDate = localDateFirstObserved;

          // Primary source per API docs
          final timestamp = detail['timestamp']?.toString();
          if (timestamp != null && timestamp.isNotEmpty) {
            entryDate = formatIsoDateToDisplay(timestamp);
          } else {
            // Backward compatibility for legacy payloads
            final metadata = detail['metadata'] as Map<String, dynamic>?;
            if (metadata != null && metadata['created_at'] != null) {
              entryDate = formatFirestoreTimestampToDisplay(
                metadata['created_at'] as Map<String, dynamic>?,
              );
            }
          }

          final coverPhotos = detail['cover_photo'] as List<dynamic>?;
          final images = coverPhotos is List
              ? coverPhotos.whereType<String>().toList()
              : <String>[];

          localCaseEntries.add({
            'date': entryDate,
            'notes': description,
            'images': images,
          });
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
                'microscopicImagePath': '',
                'macroscopicImagePath': '',
                'microSize': log.characteristics['size']?.toString() ?? 'Not measured',
                'microColor': log.characteristics['color']?.toString() ?? 'Not specified',
                'microTexture': log.characteristics['texture']?.toString() ?? 'Not specified',
                'macroColor': log.characteristics['macroColor']?.toString() ?? '',
                'macroTexture': log.characteristics['macroTexture']?.toString() ?? '',
                'macroSymptoms': log.characteristics['symptoms']?.toString() ?? '',
                'macroCharacteristics': log.characteristics['characteristics']?.toString() ?? '',
                'notes': log.additionalInfo,
              });
              if (localInVitroDateTime == 'No data') {
                localInVitroDateTime = DateFormat('MMMM dd, yyyy – hh:mm a').format(DateTime.now());
              }
            } else if (log.type == 'vivo') {
              localInVivoEntries.add({
                'date': 'Log Entry',
                'microscopicImagePath': '',
                'macroscopicImagePath': '',
                'microSize': log.characteristics['size']?.toString() ?? 'Not measured',
                'microColor': log.characteristics['color']?.toString() ?? 'Not specified',
                'microTexture': log.characteristics['texture']?.toString() ?? 'Not specified',
                'macroColor': log.characteristics['macroColor']?.toString() ?? '',
                'macroTexture': log.characteristics['macroTexture']?.toString() ?? '',
                'macroSymptoms': log.characteristics['symptoms']?.toString() ?? '',
                'macroCharacteristics': log.characteristics['characteristics']?.toString() ?? '',
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
        _reportId = resolvedReportId; // Store report ID for status updates
        caseStatus = localReportStatus;
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
        // TODO: Replace with real backend data once API supports dual-image logs.
        // ALWAYS assign entries — backend data if available, else hardcoded dummies.
        // This keeps the list non-empty even across hot reloads.
        inVitroEntries = localInVitroEntries.isNotEmpty
            ? localInVitroEntries
            : [
                {
                  'date': 'November 01, 2025 \u2022 10:00 AM',
                  'microscopicImagePath': 'assets/images/bacteria_leaves.png',
                  'macroscopicImagePath': 'assets/images/mold_home_banner.png',
                  'microSize': '12',
                  'microColor': 'Black',
                  'microTexture': 'Powdery',
                  'macroColor': 'Greenish-black',
                  'macroTexture': 'Cottony',
                  'macroSymptoms': 'Leaf spots, Wilting',
                  'macroCharacteristics': 'Rapid spreading, Fuzzy',
                  'notes': 'Colony diameter increased significantly from baseline.',
                },
                {
                  'date': 'November 05, 2025 \u2022 02:30 PM',
                  'microscopicImagePath': 'assets/images/bacteria_leaves.png',
                  'macroscopicImagePath': 'assets/images/mold_home_banner.png',
                  'microSize': '18',
                  'microColor': 'Dark grey',
                  'microTexture': 'Granular',
                  'macroColor': 'Dark brown',
                  'macroTexture': 'Slimy',
                  'macroSymptoms': 'Yellowing, Soft rot',
                  'macroCharacteristics': 'Water-soaked, Irregular margins',
                  'notes': 'Growth rate accelerated. Necrosis spreading.',
                },
              ];
        inVivoDateTime = localInVivoDateTime;
        inVivoEnvironmentalTemperature = localInVivoEnvironmentalTemperature;
        inVivoEntries = localInVivoEntries.isNotEmpty
            ? localInVivoEntries
            : [
                {
                  'date': 'November 01, 2025 \u2022 10:00 AM',
                  'microscopicImagePath': 'assets/images/bacteria_leaves.png',
                  'macroscopicImagePath': 'assets/images/mold_home_banner.png',
                  'microSize': '4',
                  'microColor': 'Brown',
                  'microTexture': 'Rough',
                  'macroColor': 'Dark brown',
                  'macroTexture': 'Wet',
                  'macroSymptoms': 'Stem lesions, Necrosis',
                  'macroCharacteristics': 'Water-soaked, Rapid spreading',
                  'notes': 'Initial lesion observed on lower stem.',
                },
                {
                  'date': 'November 04, 2025 \u2022 09:15 AM',
                  'microscopicImagePath': 'assets/images/bacteria_leaves.png',
                  'macroscopicImagePath': 'assets/images/mold_home_banner.png',
                  'microSize': '7',
                  'microColor': 'Reddish-brown',
                  'microTexture': 'Dry',
                  'macroColor': 'Black',
                  'macroTexture': 'Crusty',
                  'macroSymptoms': 'Wilting, Leaf spots',
                  'macroCharacteristics': 'Cottony edges, Dense sporulation',
                  'notes': 'Lesion expanded. Wilting now visible on upper foliage.',
                },
              ];
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

  /// Re-run the load on hot reload so dummy/real data is always fresh.
  @override
  void reassemble() {
    super.reassemble();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadCaseFromArgs();
    });
  }

  @override
  Widget build(BuildContext context) {
    //Determine if the case is closed. This boolean will control the UI.
    final bool isCaseClosed = caseStatus == 'Closed';
    String identifiedFungi = "Pending Analysis";

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
      if (!isCaseClosed && !_hasGivenRecommendation) 'Give Recommendation',
      if (!isCaseClosed && _hasGivenRecommendation) 'Mark as Resolved',
      'Identification History',
      'Treatment History',
      'Export PDF'
    ];

    final List<IconData> popupMenuIcons = [
      if (!isCaseClosed) FontAwesomeIcons.circleInfo,
      if (!isCaseClosed && !_hasGivenRecommendation) Icons.recommend,
      if (!isCaseClosed && _hasGivenRecommendation) FontAwesomeIcons.solidCircleCheck,
      FontAwesomeIcons.clockRotateLeft,
      FontAwesomeIcons.sprayCan,
      FontAwesomeIcons.solidFilePdf,
    ];


    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.of(context).pop(_mutationOccurred);
      },
      child: Scaffold(
        backgroundColor: MoldifyColors.backgroundColor,
        appBar: PrimaryAppBar(
            title: 'View Case',
            showPopupMenu: true,
            popupMenuItems: popupMenuItems,
            popupMenuIcons: popupMenuIcons,
            onPopupMenuItemSelected: (index) async {
              // The selected item is now correctly determined from the same list used by the menu.
              final selectedItem = popupMenuItems[index];

              if (selectedItem == 'Set Monitoring Details') {
                final result = await Navigator.pushNamed(
                  context,
                  '/set-monitoring-details',
                  arguments: {'moldCase': _case},
                );
                if (result == true && mounted) {
                  setState(() => _mutationOccurred = true);
                  _loadCaseFromArgs();
                }
              }
              else if (selectedItem == 'Mark as Resolved') {
                _markCaseAsResolved();
              }
              else if (selectedItem == 'Give Recommendation') {
                _handleGiveRecommendation();
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
            ? const Center(
                child: CircularProgressIndicator(
                  color: MoldifyColors.primaryColor,
                ),
              )
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
                    /// Cover image for the case
                    BuildCoverImage(
                      imageUrl: caseImageUrl,
                      borderRadiusContainer: 0,
                      borderRadiusImage: 0,
                      isHeader: true,
                    ),

                    Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.23),
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: MoldifyColors.backgroundColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            topRight: Radius.circular(30.0),
                          ),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(25, 30, 25, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // --- HEADER ---
                              // Groups the Status and Title into a single, clean unit
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      StatusBox(status: priorityLevel, fontSize: 8),
                                      const SizedBox(width: 5),
                                      StatusBox(status: reportStatus, fontSize: 8),
                                    ],
                                  ),
                                  Text(
                                    "End Date: $endDate".toUpperCase(),
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
                                _case?.name ?? 'Tomato Mold',
                                style: const TextStyle(
                                  fontFamily: 'Montserrat-Black',
                                  fontSize: 32,
                                  color: MoldifyColors.primaryColor,
                                  height: 1.0,
                                  letterSpacing: -1.2,
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Metadata Row
                              Row(
                                children: [
                                  Text(
                                    _getCaseCropName().toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Bricolage-Grotesque-Bold',
                                      color: MoldifyColors.accentColor,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  const Text("•", style: TextStyle(color: MoldifyColors.primaryColor, fontSize: 12)),
                                  const SizedBox(width: 15),
                                  Text(
                                    location,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Bricolage-Grotesque-Regular',
                                      color: MoldifyColors.primaryColor,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 25),

                              // --- THE ANALYSIS HIGHLIGHT ---
                              const Text(
                                "IDENTIFIED FUNGI",
                                style: TextStyle(
                                  fontSize: 9,
                                  letterSpacing: 2.0,
                                  fontFamily: 'Bricolage-Grotesque-Bold',
                                  color: MoldifyColors.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                identifiedFungi, // Using the variable
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontFamily: 'Bricolage-Grotesque-Bold',
                                  color: MoldifyColors.primaryColor,
                                  height: 1.1,
                                ),
                              ),

                              const SizedBox(height: 30),

                              // --- CONTENT TABS ---
                              ScrollableTabBar(
                                tabs: const [
                                  'Case Details',
                                  'Initial Observation',
                                  'In Vitro',
                                  'In Vivo',
                                ],
                                currentIndex: _selectedTabIndex,
                                onTabSelected: (i) => setState(() => _selectedTabIndex = i),
                              ),
                              
                              const SizedBox(height: 15),

                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.7,
                                child: IndexedStack(
                                  index: _selectedTabIndex,
                                  children: [
                                    CaseDetailsTab(
                                      entries: caseEntries,
                                      farmerName: farmerName,
                                      dateFirstObserved: dateFirstObserved,
                                      emailAddress: emailAddress,
                                      contactNumber: contactNumber,
                                    ),
                                    InitialObservationTab(
                                      microscopicImagePath: _initMicroscopicImagePath,
                                      macroscopicImagePath: _initMacroscopicImagePath,
                                      identifiedMold: _initIdentifiedMold,
                                      confidence: _initConfidence,
                                      macroColor: _initMacroColor,
                                      macroTexture: _initMacroTexture,
                                      macroSymptoms: _initMacroSymptoms,
                                      macroCharacteristics: _initMacroCharacteristics,
                                    ),
                                    InVitroTab(
                                      isCaseClosed: isCaseClosed,
                                      dateTime: inVitroDateTime,
                                      growthMedium: inVitroGrowthMedium,
                                      incubationTemperature: inVitroIncubationTemperature,
                                      inVitroEntries: inVitroEntries,
                                      caseId: _case!.id,
                                    ),
                                    InVivoTab(
                                      isCaseClosed: isCaseClosed,
                                      dateTime: inVivoDateTime,
                                      environmentalTemperature: inVivoEnvironmentalTemperature,
                                      inVivoEntries: inVivoEntries,
                                      caseId: _case!.id,
                                    ),
                                  ],
                                ),
                              ),
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

