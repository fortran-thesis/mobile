// ignore_for_file: library_private_types_in_public_api
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/core/constants/route_names.dart';
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
import '../../../core/features/mold_case/service/mold_case_service.dart';
import '../../../core/features/lookup/service/lookup_service.dart';
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
  String? caseImageUrl =
      "https://aggie-horticulture.tamu.edu/wp-content/uploads/sites/10/2012/01/black_mold.jpg";
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
  bool _isRunningLookup = false;
  String _lookupTopMoldId = '';
  String _lookupTopMoldName = '';
  double? _lookupTopConfidence;
  String _lookupTopConfidenceDisplay = '';
  Map<String, dynamic>? _latestMicroscopicSnapshot;
  List<Map<String, dynamic>> _latestReportLookupResults = [];

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

  // Initial observation values hydrated from saved cultivation details.
  String _initMicroscopicImagePath = '';
  String _initMacroscopicImagePath = '';
  String _initIdentifiedMold = '';
  String _initConfidence = '';
  String _initMacroColor = '';
  String _initMacroTexture = '';
  String _initMacroSymptoms = '';
  String _initMacroCharacteristics = '';

  // Data for In-Vitro Tab
  String inVitroDateTime = 'November 01, 2025 – 10:00 AM';
  String inVitroGrowthMedium = 'Potato Dextrose Agar';
  String inVitroIncubationTemperature = '25°C';
  List<Map<String, String>> inVitroEntries = [];

  // Data for In-Vivo Tab
  String inVivoDateTime = 'November 01, 2025 – 10:00 AM';
  String inVivoEnvironmentalTemperature = '28°C';
  List<Map<String, String>> inVivoEntries = [];

  String _displayText(dynamic value) {
    if (value == null) return '';
    if (value is List) {
      final text = value
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .join(', ');
      return text;
    }
    return value.toString().trim();
  }

  String _firstNonEmpty(Iterable<dynamic> values) {
    for (final value in values) {
      final parsed = _displayText(value);
      if (parsed.isNotEmpty) return parsed;
    }
    return '';
  }

  Map<String, dynamic>? _asStringMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  bool _looksLikeMicroscopicLog(Map<String, dynamic> characteristics) {
    return _firstNonEmpty([
      characteristics['microscopic_identification'],
      characteristics['identified_mold'],
      characteristics['identifiedMold'],
      characteristics['confidence'],
      characteristics['top_predictions'],
    ]).isNotEmpty;
  }

  bool _looksLikeMacroscopicLog(Map<String, dynamic> characteristics) {
    return _firstNonEmpty([
      characteristics['size'],
      characteristics['lesion_size'],
      characteristics['colony_diameter'],
      characteristics['color'],
      characteristics['lesion_color'],
      characteristics['colony_color'],
      characteristics['texture'],
      characteristics['lesion_texture'],
      characteristics['colony_texture'],
      characteristics['symptoms'],
      characteristics['characteristics'],
    ]).isNotEmpty;
  }

  String _formatLogDate(DateTime? value) {
    if (value == null) return 'Log Entry';
    return DateFormat('MMMM dd, yyyy • hh:mm a').format(value.toLocal());
  }

  Map<String, String> _mapCultivationLogToTimelineEntry(CultivationLog log) {
    final characteristics = log.characteristics;
    final hasMicroData = _looksLikeMicroscopicLog(characteristics);
    final hasMacroData = _looksLikeMacroscopicLog(characteristics);
    final size = _firstNonEmpty([
      characteristics['size'],
      characteristics['lesion_size'],
      characteristics['colony_diameter'],
    ]);
    final color = _firstNonEmpty([
      characteristics['color'],
      characteristics['lesion_color'],
      characteristics['colony_color'],
      characteristics['macroColor'],
    ]);
    final texture = _firstNonEmpty([
      characteristics['texture'],
      characteristics['lesion_texture'],
      characteristics['colony_texture'],
      characteristics['macroTexture'],
    ]);
    final symptoms = _firstNonEmpty([
      characteristics['symptoms'],
      characteristics['symptomsDisplay'],
    ]);
    final trait = _firstNonEmpty([
      characteristics['characteristics'],
      characteristics['characteristicsDisplay'],
    ]);

    final microscopicImage = _firstNonEmpty([
      characteristics['microscopic_image_url'],
      hasMicroData ? log.imageUrl : '',
    ]);
    final macroscopicImage = _firstNonEmpty([
      characteristics['macroscopic_image_url'],
      hasMacroData ? log.imageUrl : '',
    ]);

    final microGenus = _firstNonEmpty([
      characteristics['microscopic_identification'],
      characteristics['identified_mold'],
      characteristics['identifiedMold'],
    ]);

    return {
      'date': _formatLogDate(log.createdAt),
      'microscopicImagePath': microscopicImage,
      'macroscopicImagePath': macroscopicImage,
      'microGenusName': microGenus,
      'macroSize': size,
      'macroTexture': texture,
      'macroShape': color,
      'macroSymptoms': symptoms,
      'macroCharacteristics': trait,
      'notes': log.additionalInfo,
    };
  }

  bool _didCultivationLogPersist(Map<String, dynamic>? macroPayload) {
    if (macroPayload == null) return false;
    if (macroPayload['cultivationLogSaved'] == true) return true;
    final cultivationLog = macroPayload['cultivationLog'];
    return cultivationLog is Map<String, dynamic> && cultivationLog.isNotEmpty;
  }

  bool _didMicroscopicLogPersist(Map<String, dynamic> payload) {
    if (payload['microCultivationLogSaved'] == true) return true;
    final microLog = payload['microCultivationLog'];
    return microLog is Map<String, dynamic> && microLog.isNotEmpty;
  }

  Future<void> _handleLogSaved(
    Map<String, dynamic> payload, {
    required String sourceTab,
  }) async {
    final macro = payload['macroResult'] as Map<String, dynamic>?;
    final macroPersisted = _didCultivationLogPersist(macro);
    final microPersisted = _didMicroscopicLogPersist(payload);
    final persisted = macroPersisted || microPersisted;

    AppLogger.d(
      'ViewCase: onLogSaved sourceTab=$sourceTab persisted=$persisted '
      'hasMacroResult=${macro != null} '
      'macroPersisted=$macroPersisted microPersisted=$microPersisted',
    );

    if (!persisted) {
      final hadMacroAttempt = macro != null;
      if (hadMacroAttempt && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cultivation log was not saved. Please try again.'),
          ),
        );
      }
      return;
    }

    await _refreshCaseAndPendingAnalysis(showLoader: false);
    if (!mounted) return;

    setState(() => _mutationOccurred = true);

    if (macro?['scanSaveError'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Log saved but scan evidence failed: ${macro!['scanSaveError']}',
          ),
        ),
      );
    } else if (macro?['scanAssociationError'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Log saved, but failed to associate scan to case: ${macro!['scanAssociationError']}',
          ),
        ),
      );
    } else if (payload['microLogSaveError'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Microscopic log save failed: ${payload['microLogSaveError']}',
          ),
        ),
      );
    }
  }

  void _handleInVitroLogSaved(Map<String, dynamic> payload) {
    unawaited(_handleLogSaved(payload, sourceTab: 'in-vitro'));
  }

  void _handleInVivoLogSaved(Map<String, dynamic> payload) {
    unawaited(_handleLogSaved(payload, sourceTab: 'in-vivo'));
  }

  String _getCaseCropName() {
    return cropName.isNotEmpty ? cropName : 'Kamatis Tagalog';
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
        'suggestedMoldId': _lookupTopMoldId,
        'suggestedMoldName': _lookupTopMoldName,
        'suggestedConfidence': _lookupTopConfidence,
      },
    );

    if (!mounted || result != true) return;

    await _refreshCaseAndPendingAnalysis(showLoader: false);
    if (!mounted) return;

    setState(() {
      _hasGivenRecommendation = true;
      _mutationOccurred = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Final verdict submitted and case marked as resolved.'),
      ),
    );
  }

  String _extractLookupMoldId(Map<String, dynamic> result) {
    final direct = result['moldId']?.toString().trim();
    if (direct != null && direct.isNotEmpty) return direct;

    final fallback = result['mold_id']?.toString().trim();
    if (fallback != null && fallback.isNotEmpty) return fallback;

    return '';
  }

  double? _extractLookupConfidenceValue(Map<String, dynamic> result) {
    final confidenceRaw = result['confidence'];
    if (confidenceRaw is num) return confidenceRaw.toDouble();
    return double.tryParse(confidenceRaw?.toString() ?? '');
  }

  List<String> _extractLookupTerms(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final raw = value.toString();
    return raw
        .split(RegExp(r'[,;|]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Map<String, List<String>> _collectLookupInputsFromCase() {
    final symptoms = <String>{};
    final signs = <String>{};
    final characteristics = <String>{};

    final cultivationDetails = _case?.cultivationDetails;
    if (cultivationDetails != null) {
      if (cultivationDetails.initialSymptoms != null) {
        symptoms.addAll(
          cultivationDetails.initialSymptoms!
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty),
        );
      }
      if (cultivationDetails.initialCharacteristics != null) {
        characteristics.addAll(
          cultivationDetails.initialCharacteristics!
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty),
        );
      }

      final microscopic = cultivationDetails.initialMicroscopic?.trim();
      final macroscopic = cultivationDetails.initialMacroscopic?.trim();
      if (microscopic != null && microscopic.isNotEmpty) {
        signs.add(microscopic);
      }
      if (macroscopic != null && macroscopic.isNotEmpty) {
        signs.add(macroscopic);
      }
    }

    final logs = _case?.cultivationLogs ?? const <CultivationLog>[];
    for (final log in logs) {
      final map = log.characteristics;

      symptoms.addAll(_extractLookupTerms(map['symptoms']));
      characteristics.addAll(_extractLookupTerms(map['characteristics']));

      characteristics.addAll(_extractLookupTerms(map['color']));
      characteristics.addAll(_extractLookupTerms(map['texture']));
      characteristics.addAll(_extractLookupTerms(map['macroColor']));
      characteristics.addAll(_extractLookupTerms(map['macroTexture']));

      final notes = log.additionalInfo.trim();
      if (notes.isNotEmpty) {
        signs.add(notes);
      }
    }

    return {
      'symptoms': symptoms.toList(),
      'signs': signs.toList(),
      'characteristics': characteristics.toList(),
    };
  }

  String _extractLookupMoldName(Map<String, dynamic> result) {
    final direct = result['moldName']?.toString().trim();
    if (direct != null && direct.isNotEmpty) return direct;

    final fallback = result['mold_name']?.toString().trim();
    if (fallback != null && fallback.isNotEmpty) return fallback;

    return '';
  }

  String _formatLookupConfidence(Map<String, dynamic> result) {
    final confidenceRaw = result['confidence'];
    final confidence = confidenceRaw is num
        ? confidenceRaw.toDouble()
        : double.tryParse(confidenceRaw?.toString() ?? '');

    if (confidence == null) return '';
    return '${confidence.toStringAsFixed(1)}%';
  }

  Map<String, dynamic>? _firstMapFromValue(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is List) {
      for (final item in value) {
        if (item is Map<String, dynamic>) return item;
      }
    }
    return null;
  }

  bool _applyStoredPendingAnalysisFallback() {
    Map<String, dynamic>? candidate;

    if (_latestReportLookupResults.isNotEmpty) {
      candidate = _latestReportLookupResults.first;
    }

    final snapshotTopPrediction = _firstMapFromValue(
      _latestMicroscopicSnapshot?['top_predictions'],
    );
    candidate ??= snapshotTopPrediction;

    if (candidate == null && _latestMicroscopicSnapshot != null) {
      candidate = _latestMicroscopicSnapshot;
    }

    if (candidate == null) return false;

    final moldId = _extractLookupMoldId(candidate);
    final moldName = _extractLookupMoldName(candidate);
    final confidence = _extractLookupConfidenceValue(candidate);
    final confidenceText = _formatLookupConfidence(candidate);

    if (moldId.isEmpty && moldName.isEmpty) return false;

    if (!mounted) return true;
    setState(() {
      _lookupTopMoldId = moldId;
      _lookupTopMoldName = moldName;
      _lookupTopConfidence = confidence;
      _lookupTopConfidenceDisplay = confidenceText;
    });
    return true;
  }

  Future<void> _computePendingAnalysisFromCurrentCase() async {
    if (_case == null || _isRunningLookup) return;

    final inputs = _collectLookupInputsFromCase();
    final totalInputCount =
        inputs['symptoms']!.length +
        inputs['signs']!.length +
        inputs['characteristics']!.length;

    if (totalInputCount == 0) {
      final restored = _applyStoredPendingAnalysisFallback();
      if (restored) return;
      if (!mounted) return;
      setState(() {
        _lookupTopMoldId = '';
        _lookupTopMoldName = '';
        _lookupTopConfidence = null;
        _lookupTopConfidenceDisplay = '';
      });
      return;
    }

    setState(() => _isRunningLookup = true);
    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final lookupService = LookupService();
      final lookupResults = await lookupService.performLookup(
        reportedSymptoms: inputs['symptoms']!,
        reportedSigns: inputs['signs']!,
        reportedCharacteristics: inputs['characteristics']!,
        sessionCookie: authProvider.cookie,
      );

      if (!mounted) return;

      if (lookupResults.isEmpty) {
        setState(() {
          _lookupTopMoldId = '';
          _lookupTopMoldName = '';
          _lookupTopConfidence = null;
          _lookupTopConfidenceDisplay = '';
        });
        return;
      }

      final topResult = lookupResults.first;
      setState(() {
        _lookupTopMoldId = _extractLookupMoldId(topResult);
        _lookupTopMoldName = _extractLookupMoldName(topResult);
        _lookupTopConfidence = _extractLookupConfidenceValue(topResult);
        _lookupTopConfidenceDisplay = _formatLookupConfidence(topResult);
      });
    } catch (e) {
      AppLogger.w(
        'ViewCase: lookup refresh failed, falling back to pending analysis',
      );
      final restored = _applyStoredPendingAnalysisFallback();
      if (!restored && mounted) {
        setState(() {
          _lookupTopMoldId = '';
          _lookupTopMoldName = '';
          _lookupTopConfidence = null;
          _lookupTopConfidenceDisplay = '';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isRunningLookup = false);
      }
    }
  }

  Future<void> _refreshCaseAndPendingAnalysis({bool showLoader = true}) async {
    if (showLoader && mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    await _loadCaseFromArgs();
    if (!mounted || _case == null) return;

    await _computePendingAnalysisFromCurrentCase();
  }

  String _buildIdentifiedFungiLabel() {
    if (_lookupTopMoldName.trim().isNotEmpty) {
      if (_lookupTopConfidenceDisplay.trim().isEmpty) return _lookupTopMoldName;
      return '$_lookupTopMoldName ($_lookupTopConfidenceDisplay)';
    }

    if (_initIdentifiedMold.trim().isNotEmpty) {
      if (_initConfidence.trim().isEmpty) return _initIdentifiedMold;
      return '$_initIdentifiedMold ($_initConfidence)';
    }

    return 'Pending Analysis';
  }

  MoldCase _cloneCaseWithLogs(MoldCase source, List<CultivationLog>? logs) {
    return MoldCase(
      id: source.id,
      mycologistId: source.mycologistId,
      name: source.name,
      moldReportId: source.moldReportId,
      photoUrl: source.photoUrl,
      priority: source.priority,
      startDate: source.startDate,
      endDate: source.endDate,
      cultivationDetails: source.cultivationDetails,
      cultivationLogs: logs,
      isArchived: source.isArchived,
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
      AppLogger.d(
        'ViewCase: sessionCookie = ${sessionCookie?.substring(0, 20)}...',
      );

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

      final lookupResultsRaw = reportPayload['lookup_results'];
      final parsedLookupResults = (lookupResultsRaw is List)
          ? lookupResultsRaw
                .whereType<Map>()
                .map((entry) => Map<String, dynamic>.from(entry))
                .toList()
          : <Map<String, dynamic>>[];

      String capitalizeStatus(String raw) {
        final normalized = raw.trim();
        if (normalized.isEmpty) return 'Unknown';
        return normalized[0].toUpperCase() + normalized.substring(1);
      }

      final resolvedReportId =
          reportPayload['id']?.toString().trim().isNotEmpty == true
          ? reportPayload['id'].toString().trim()
          : reportId;

      final statusRaw = reportPayload['status']?.toString() ?? 'Unknown';
      final localReportStatus = capitalizeStatus(statusRaw);
      final localCaseName =
          reportPayload['case_name']?.toString() ??
          reportPayload['name']?.toString() ??
          'Unknown Case';
      final localMycologistId =
          reportPayload['assigned_mycologist_id']?.toString() ??
          reportPayload['mycologist_id']?.toString() ??
          '';
      final localHasRecommendation =
          (reportPayload['recommendation'] != null) ||
          (reportPayload['analysis'] is Map<String, dynamic> &&
              (reportPayload['analysis'] as Map<String, dynamic>).isNotEmpty) ||
          ((reportPayload['recommended_mold']?.toString().trim().isNotEmpty ??
              false));

      final dateObservedRaw = reportPayload['date_observed']?.toString();
      final startDate = (dateObservedRaw != null && dateObservedRaw.isNotEmpty)
          ? (DateTime.tryParse(dateObservedRaw)?.toUtc() ??
                DateTime.now().toUtc())
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

          try {
            final moldCaseService = MoldCaseService();
            final logsResponse = await moldCaseService.getCultivationLogs(
              moldCase.id,
              sessionCookie: sessionCookie,
            );

            final logsRaw = logsResponse['snapshot'];
            final logs = (logsRaw is List)
                ? logsRaw
                      .whereType<Map>()
                      .map(
                        (e) => CultivationLog.fromJson(
                          Map<String, dynamic>.from(e),
                        ),
                      )
                      .toList()
                : <CultivationLog>[];

            moldCase = _cloneCaseWithLogs(moldCase, logs);
            AppLogger.d(
              'ViewCase: loaded ${logs.length} cultivation logs for caseId=${moldCase.id}',
            );
          } catch (e) {
            AppLogger.w(
              'ViewCase: failed to fetch cultivation logs for caseId=${moldCase.id}: $e',
            );
          }
        }
      } catch (e) {
        AppLogger.w(
          'ViewCase: no mold-case enrichment found, using report payload only',
        );
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
      final reporter = _asStringMap(reportPayload['reporter']);
      if (reporter != null) {
        final user = _asStringMap(reporter['user']);
        final details = _asStringMap(reporter['details']);

        if (user != null) {
          localFarmerName =
              '${user['first_name']?.toString() ?? ''} ${user['last_name']?.toString() ?? ''}'
                  .trim();
        }
        if (details != null) {
          localEmailAddress = details['email']?.toString() ?? localEmailAddress;
          localContactNumber =
              details['phone_number']?.toString() ?? localContactNumber;
          localLocation =
              details['location']?.toString() ??
              reportPayload['location']?.toString() ??
              details['address']?.toString() ??
              'Unknown Location';
        } else {
          localLocation =
              reportPayload['location']?.toString() ?? localLocation;
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

          // Primary source per API
          final timestamp = detail['timestamp']?.toString();
          if (timestamp != null && timestamp.isNotEmpty) {
            entryDate = formatIsoDateToDisplay(timestamp);
          } else {
            // Backward compatibility for legacy payloads
            final metadata = _asStringMap(detail['metadata']);
            if (metadata != null && metadata['created_at'] != null) {
              final createdAt = metadata['created_at'];
              if (createdAt is String && createdAt.trim().isNotEmpty) {
                entryDate = formatIsoDateToDisplay(createdAt);
              } else {
                entryDate = formatFirestoreTimestampToDisplay(
                  _asStringMap(createdAt),
                );
              }
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

        _initMicroscopicImagePath =
            cultivationDetails.initialMicroscopicImageUrl ?? '';
        _initMacroscopicImagePath =
            cultivationDetails.initialMacroscopicImageUrl ?? '';
        _initIdentifiedMold = cultivationDetails.initialMicroscopic ?? '';
        final snapshot = cultivationDetails.microscopicAiSnapshot;
        _latestMicroscopicSnapshot = snapshot;
        if (_initIdentifiedMold.trim().isEmpty && snapshot != null) {
          _initIdentifiedMold = snapshot['identified_mold']?.toString() ?? '';
        }
        _initConfidence = snapshot != null
            ? (snapshot['confidence_display']?.toString() ??
                  (snapshot['confidence']?.toString().isNotEmpty == true
                      ? '${snapshot['confidence']}%'
                      : ''))
            : '';
        _initMacroColor = cultivationDetails.initialMacroscopicColor ?? '';
        _initMacroTexture = cultivationDetails.initialMacroscopicTexture ?? '';
        _initMacroSymptoms =
            cultivationDetails.initialMacroscopicSymptoms ?? '';
        _initMacroCharacteristics =
            cultivationDetails.initialMacroscopicCharacteristics ?? '';

        // Extract in vitro details
        if (cultivationDetails.inVitroDetails != null) {
          localInVitroIncubationTemperature =
              '${cultivationDetails.inVitroDetails!.incubationTemperature}°C';
        }
        localInVitroGrowthMedium = cultivationDetails.growthMedium.isNotEmpty
            ? cultivationDetails.growthMedium
            : 'Not specified';

        // Extract cultivation logs and categorize them.
        if (moldCase.cultivationLogs != null &&
            moldCase.cultivationLogs!.isNotEmpty) {
          for (final log in moldCase.cultivationLogs!) {
            final entry = _mapCultivationLogToTimelineEntry(log);
            if (log.type == 'vitro') {
              localInVitroEntries.add(entry);
            } else if (log.type == 'vivo') {
              localInVivoEntries.add(entry);
            }
          }

          if (localInVitroEntries.isNotEmpty) {
            final firstVitroDate = moldCase.cultivationLogs!
                .where((log) => log.type == 'vitro')
                .map((log) => log.createdAt)
                .firstWhere((value) => value != null, orElse: () => null);
            if (firstVitroDate != null) {
              localInVitroDateTime = DateFormat(
                'MMMM dd, yyyy – hh:mm a',
              ).format(firstVitroDate.toLocal());
            }
          }

          if (localInVivoEntries.isNotEmpty) {
            final firstVivoDate = moldCase.cultivationLogs!
                .where((log) => log.type == 'vivo')
                .map((log) => log.createdAt)
                .firstWhere((value) => value != null, orElse: () => null);
            if (firstVivoDate != null) {
              localInVivoDateTime = DateFormat(
                'MMMM dd, yyyy – hh:mm a',
              ).format(firstVivoDate.toLocal());
            }
          }
        }

        // Extract in vivo details
        if (cultivationDetails.inVivoDetails != null) {
          localInVivoEnvironmentalTemperature =
              '${cultivationDetails.inVivoDetails!.environmentalTemperature}°C';
        }
      }

      setState(() {
        _case = moldCase;
        _latestReportLookupResults = parsedLookupResults;
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
        inVitroEntries = localInVitroEntries;
        inVivoDateTime = localInVivoDateTime;
        inVivoEnvironmentalTemperature = localInVivoEnvironmentalTemperature;
        inVivoEntries = localInVivoEntries;
        cropName = cropName;
        _hasGivenRecommendation =
            _hasGivenRecommendation || localHasRecommendation;
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
      _refreshCaseAndPendingAnalysis();
    });
  }

  /// Re-run the load on hot reload so dummy/real data is always fresh.
  @override
  void reassemble() {
    super.reassemble();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refreshCaseAndPendingAnalysis(showLoader: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    //Determine if the case is closed. This boolean will control the UI.
    final bool isCaseClosed = caseStatus == 'Closed';
    final String identifiedFungi = _buildIdentifiedFungiLabel();

    // Use API data if available, otherwise use fallback defaults
    String priorityLevel = _case?.priority != null
        ? '${_case!.priority[0].toUpperCase()}${_case!.priority.substring(1)} Priority'
        : 'Low Priority';

    String endDate = _case?.endDate != null
        ? DateFormat('MMMM dd, yyyy').format(_case!.endDate!)
        : 'N/A';

    //Dynamically build the list of menu items based on the case status.
    final List<String> popupMenuItems = [
      if (!isCaseClosed) 'Set Monitoring Details',
      if (!isCaseClosed && !_hasGivenRecommendation) 'Give Recommendation',
      'Identification History',
      'Treatment History',
      'Export PDF',
    ];

    final List<IconData> popupMenuIcons = [
      if (!isCaseClosed) FontAwesomeIcons.circleInfo,
      if (!isCaseClosed && !_hasGivenRecommendation) Icons.recommend,
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
                _refreshCaseAndPendingAnalysis(showLoader: false);
              }
            } else if (selectedItem == 'Give Recommendation') {
              await _handleGiveRecommendation();
            } else if (selectedItem == 'Identification History') {
              Navigator.pushNamed(context, '/identification-history');
            } else if (selectedItem == 'Treatment History') {
              Navigator.pushNamed(context, '/treatment-history');
            } else if (selectedItem == 'Export PDF') {
              // Implement export PDF functionality here
            }
          },
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
            : RefreshIndicator(
                color: MoldifyColors.primaryColor,
                onRefresh: () =>
                    _refreshCaseAndPendingAnalysis(showLoader: false),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.23,
                        ),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        StatusBox(
                                          status: priorityLevel,
                                          fontSize: 8,
                                        ),
                                        const SizedBox(width: 5),
                                        StatusBox(
                                          status: reportStatus,
                                          fontSize: 8,
                                        ),
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
                                    const Text(
                                      "•",
                                      style: TextStyle(
                                        color: MoldifyColors.primaryColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Text(
                                      location,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily:
                                            'Bricolage-Grotesque-Regular',
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
                                  onTabSelected: (i) =>
                                      setState(() => _selectedTabIndex = i),
                                ),

                                const SizedBox(height: 15),

                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.7,
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
                                        microscopicImagePath:
                                            _initMicroscopicImagePath,
                                        macroscopicImagePath:
                                            _initMacroscopicImagePath,
                                        identifiedMold: _initIdentifiedMold,
                                        confidence: _initConfidence,
                                        macroColor: _initMacroColor,
                                        macroTexture: _initMacroTexture,
                                        macroSymptoms: _initMacroSymptoms,
                                        macroCharacteristics:
                                            _initMacroCharacteristics,
                                      ),
                                      InVitroTab(
                                        isCaseClosed: isCaseClosed,
                                        dateTime: inVitroDateTime,
                                        growthMedium: inVitroGrowthMedium,
                                        incubationTemperature:
                                            inVitroIncubationTemperature,
                                        inVitroEntries: inVitroEntries,
                                        caseId: _case!.id,
                                        initialMicroIdentifiedMold:
                                            _initIdentifiedMold,
                                        initialMacroColor: _initMacroColor,
                                        initialMacroTexture: _initMacroTexture,
                                        initialMacroSymptoms:
                                            _initMacroSymptoms,
                                        initialMacroCharacteristics:
                                            _initMacroCharacteristics,
                                        onLogSaved: _handleInVitroLogSaved,
                                      ),
                                      InVivoTab(
                                        isCaseClosed: isCaseClosed,
                                        dateTime: inVivoDateTime,
                                        environmentalTemperature:
                                            inVivoEnvironmentalTemperature,
                                        inVivoEntries: inVivoEntries,
                                        caseId: _case!.id,
                                        initialMicroIdentifiedMold:
                                            _initIdentifiedMold,
                                        initialMacroColor: _initMacroColor,
                                        initialMacroTexture: _initMacroTexture,
                                        initialMacroSymptoms:
                                            _initMacroSymptoms,
                                        initialMacroCharacteristics:
                                            _initMacroCharacteristics,
                                        onLogSaved: _handleInVivoLogSaved,
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
                ),
              ),
      ),
    );
  }
}
