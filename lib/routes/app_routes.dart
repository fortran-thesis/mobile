import 'package:flutter/material.dart';
import 'package:moldify/pages/auth/signup.dart';
import 'package:moldify/pages/auth/email_recover_account.dart';
import 'package:moldify/pages/auth/code_recover_account.dart';
import 'package:moldify/pages/auth/intro.dart';
import 'package:moldify/pages/identification/camera.dart';
import 'package:moldify/pages/identification/image_preview.dart';
import 'package:moldify/pages/identification/input_characteristics.dart';
import 'package:moldify/pages/monitor/add_log_choices.dart';
import 'package:moldify/pages/monitor/add_treatment.dart';
import 'package:moldify/pages/support/privacy_policy.dart';
import 'package:moldify/pages/support/terms_of_agreement.dart';
import 'package:moldify/core/features/mold_case/service/mold_case_service.dart';
import 'package:moldify/core/utils/mutation_result.dart';
import '../pages/auth/login.dart';
import '../core/constants/route_names.dart';
import 'package:provider/provider.dart';
import 'package:moldify/providers/auth_provider.dart';
import '../main.dart';
import 'package:moldify/pages/auth/set_new_password.dart';

import '../pages/auth/welcome.dart';
import '../pages/farmer/report/add_follow_up.dart';
import '../pages/farmer/report/submit_report.dart';
import '../pages/farmer/report/view_report.dart';
import '../pages/identification/main_camera.dart';
import '../pages/identification/mold_result.dart';
import '../pages/identification/low_confidence_correction_screen.dart';
import '../pages/monitor/add_log.dart';
import '../pages/monitor/add_log_instructions.dart';
import '../pages/monitor/edit_log.dart';
import '../pages/monitor/give_recommendation.dart';
import '../pages/monitor/create_mold.dart';
import '../pages/monitor/identification_history.dart';
import '../pages/monitor/set_monitoring_details.dart';
import '../pages/monitor/treatment_history.dart';
import '../pages/monitor/view_case.dart';
import '../pages/farmer/wikimold/view_wikimold.dart';
import '../pages/monitor/culture/view_timers.dart';
import '../pages/monitor/culture/set_timer.dart';
import '../splash_screen.dart';

class AppRoutes {
  static Map<String, dynamic>? _mapArgs(RouteSettings settings) {
    final args = settings.arguments;
    if (args is Map<String, dynamic>) return args;
    if (args is Map) {
      return args.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  static String? _stringArg(
    Map<String, dynamic>? args,
    String key, {
    bool required = false,
  }) {
    final value = args?[key];
    if (value == null) return required ? null : null;
    final text = value.toString();
    if (required && text.trim().isEmpty) return null;
    return text;
  }

  static bool _boolArg(
    Map<String, dynamic>? args,
    String key, {
    required bool fallback,
  }) {
    final value = args?[key];
    if (value is bool) return value;
    return fallback;
  }

  static Widget _routeArgError(String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation Error')),
      body: Center(child: Text(message)),
    );
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings, // Pass settings so arguments are accessible
      builder: (context) {
        final authProvider = Provider.of<AppAuthProvider>(
          context,
          listen: false,
        );
        final isAuthenticated =
            authProvider.cookie != null && authProvider.cookie!.isNotEmpty;
        switch (settings.name) {
          case RouteNames.splash:
            return const SplashScreen();
          case RouteNames.welcome:
            return const WelcomeScreen();
          case RouteNames.login:
            if (isAuthenticated) {
              return MainPage();
            }
            return LoginScreen();
          case RouteNames.signup:
            return SignUpScreen();
          case RouteNames.emailRecoverAccount:
            final args = settings.arguments as Map<String, dynamic>?;
            final pageTitle = args != null && args['pageTitle'] != null
                ? args['pageTitle'] as String
                : '';
            return EmailRecoverAccountScreen(pageTitle: pageTitle);
          case RouteNames.codeRecoverAccount:
            final args = settings.arguments as Map<String, dynamic>?;
            final pageTitle = args != null && args['pageTitle'] != null
                ? args['pageTitle'] as String
                : '';
            final email = args != null && args['email'] != null
                ? args['email'] as String
                : '';
            return CodeRecoverAccountScreen(email: email, pageTitle: pageTitle);
          case RouteNames.intro:
            if (isAuthenticated) {
              return MainPage();
            }
            return IntroScreen();
          case RouteNames.main:
            return MainPage();
          case RouteNames.setNewPassword:
            final args = settings.arguments as Map<String, dynamic>?;
            final token = args != null && args['token'] != null
                ? args['token'] as String
                : '';
            return SetNewPasswordScreen(token: token);

          case RouteNames.camera:
            final args = settings.arguments as Map<String, dynamic>?;
            final source = args?['source'] as String?;
            final sourceTab = args?['sourceTab'] as String?;
            final caseId = args?['caseId'] as String?;
            final selectedCultureId = args?['selectedCultureId'] as String?;
            final selectedCultureName = args?['selectedCultureName'] as String?;
            final sourceFlow = args?['sourceFlow'] as String?;
            final scanModality = args?['scanModality'] as String?;
            final includeSize = args?['includeSize'] as bool? ?? true;
            final returnResult = args?['returnResult'] as bool? ?? false;
            return CameraScreen(
              source: source,
              sourceTab: sourceTab,
              caseId: caseId,
              selectedCultureId: selectedCultureId,
              selectedCultureName: selectedCultureName,
              sourceFlow: sourceFlow,
              scanModality: scanModality,
              includeSize: includeSize,
              returnResult: returnResult,
            );

          case RouteNames.imagePreview:
            final args = _mapArgs(settings);
            final imagePath = _stringArg(args, 'imagePath', required: true);
            if (imagePath == null) {
              return _routeArgError('imagePreview requires imagePath');
            }
            final source = _stringArg(args, 'source');
            final sourceTab = _stringArg(args, 'sourceTab');
            final caseId = _stringArg(args, 'caseId');
            final selectedCultureId = _stringArg(args, 'selectedCultureId');
            final selectedCultureName = _stringArg(args, 'selectedCultureName');
            final sourceFlow = _stringArg(args, 'sourceFlow');
            final scanModality = _stringArg(args, 'scanModality');
            final includeSize = _boolArg(args, 'includeSize', fallback: true);
            final returnResult = _boolArg(
              args,
              'returnResult',
              fallback: false,
            );
            return ImagePreviewScreen(
              imagePath: imagePath,
              source: source,
              sourceTab: sourceTab,
              caseId: caseId,
              selectedCultureId: selectedCultureId,
              selectedCultureName: selectedCultureName,
              sourceFlow: sourceFlow,
              scanModality: scanModality,
              includeSize: includeSize,
              returnResult: returnResult,
            );

          case RouteNames.moldResult:
            final args = _mapArgs(settings);
            final croppedImagePath = _stringArg(
              args,
              'croppedImagePath',
              required: true,
            );
            if (croppedImagePath == null) {
              return _routeArgError('moldResult requires croppedImagePath');
            }
            final modelResult = args?['modelResult'] as Map<String, dynamic>?;
            final moldDetails = args?['moldDetails'] as Map<String, dynamic>?;
            final sourceFlow = _stringArg(args, 'sourceFlow');
            final scanModality = _stringArg(args, 'scanModality');
            final sourceTab = _stringArg(args, 'sourceTab');
            final caseId = _stringArg(args, 'caseId');
            final correctedGenus = _stringArg(args, 'correctedGenus');
            return MoldResultScreen(
              croppedImagePath: croppedImagePath,
              modelResult: modelResult,
              moldDetails: moldDetails,
              sourceFlow: sourceFlow,
              scanModality: scanModality,
              sourceTab: sourceTab,
              caseId: caseId,
              correctedGenus: correctedGenus,
            );

          case RouteNames.lowConfidenceCorrection:
            final args = _mapArgs(settings);
            final croppedImagePathLc = _stringArg(
              args,
              'croppedImagePath',
              required: true,
            );
            if (croppedImagePathLc == null) {
              return _routeArgError(
                'lowConfidenceCorrection requires croppedImagePath',
              );
            }
            final modelResultLc =
                args?['modelResult'] as Map<String, dynamic>? ?? {};
            return LowConfidenceCorrectionScreen(
              croppedImagePath: croppedImagePathLc,
              modelResult: modelResultLc,
              sourceFlow: _stringArg(args, 'sourceFlow'),
              scanModality: _stringArg(args, 'scanModality'),
              sourceTab: _stringArg(args, 'sourceTab'),
              caseId: _stringArg(args, 'caseId'),
            );

          case RouteNames.setMonitoringDetails:
            final args = _mapArgs(settings);
            final moldCase = args?['moldCase'];
            if (moldCase == null) {
              return _routeArgError('setMonitoringDetails requires moldCase');
            }
            return SetMonitoringDetailsScreen(moldCase: moldCase);

          case RouteNames.viewCase:
            return ViewCaseScreen();

          case RouteNames.editLog:
            final args = _mapArgs(settings);
            final tabName = _stringArg(args, 'tabName', required: true);
            if (tabName == null) {
              return _routeArgError('editLog requires tabName');
            }
            return EditLogScreen(tabName: tabName);

          case RouteNames.addTreatment:
            return AddTreatmentScreen();

          case RouteNames.giveRecommendation:
            return const GiveRecommendationScreen();

          case RouteNames.createMold:
            return CreateMoldScreen();

          case RouteNames.identificationHistory:
            return IdentificationHistoryScreen();

          case RouteNames.treatmentHistory:
            return TreatmentHistoryScreen();

          case RouteNames.addLogInstructions:
            final args = settings.arguments as Map<String, dynamic>?;
            final sourceTab = args?['sourceTab'] as String?;
            final caseId = args?['caseId'] as String?;
            final selectedCultureId = args?['selectedCultureId'] as String?;
            final selectedCultureName = args?['selectedCultureName'] as String?;
            final pageTitle = args?['pageTitle'] as String?;
            final pageSubtitle = args?['pageSubtitle'] as String?;
            final includeSize = args?['includeSize'] as bool? ?? true;
            final sourceFlow = args?['sourceFlow'] as String?;
            final scanModality = args?['scanModality'] as String?;
            final returnResult = args?['returnResult'] as bool? ?? false;
            return AddLogInstructionsScreen(
              sourceTab: sourceTab,
              caseId: caseId,
              selectedCultureId: selectedCultureId,
              selectedCultureName: selectedCultureName,
              pageTitle: pageTitle,
              pageSubtitle: pageSubtitle,
              includeSize: includeSize,
              sourceFlow: sourceFlow,
              scanModality: scanModality,
              returnResult: returnResult,
            );

          case RouteNames.addLog:
            final args = _mapArgs(settings);
            final imagePath = _stringArg(args, 'imagePath', required: true);
            final sourceTab = _stringArg(args, 'sourceTab', required: true);
            final caseId = _stringArg(args, 'caseId', required: true);
            if (imagePath == null || sourceTab == null || caseId == null) {
              return _routeArgError(
                'addLog requires imagePath, sourceTab, and caseId',
              );
            }

            final includeSize = _boolArg(args, 'includeSize', fallback: true);
            final sourceFlow = _stringArg(args, 'sourceFlow');
            final scanModality = _stringArg(args, 'scanModality');
            final selectedCultureId = _stringArg(args, 'selectedCultureId');
            final selectedCultureName = _stringArg(args, 'selectedCultureName');
            return AddLogScreen(
              imagePath: imagePath,
              sourceTab: sourceTab,
              caseId: caseId,
              includeSize: includeSize,
              sourceFlow: sourceFlow,
              scanModality: scanModality,
              selectedCultureId: selectedCultureId,
              selectedCultureName: selectedCultureName,
            );

          case RouteNames.mainCamera:
            final args = settings.arguments as Map<String, dynamic>?;
            final bool showAppBar = args?['showAppBar'] as bool? ?? false;
            final bool returnResult = args?['returnResult'] as bool? ?? false;
            final String? sourceFlow = args?['sourceFlow'] as String?;
            final String? scanModality = args?['scanModality'] as String?;
            final String? sourceTab = args?['sourceTab'] as String?;
            final String? moldCaseId = args?['caseId'] as String?;
            return MainCameraScreen(
              showAppBar: showAppBar,
              returnResult: returnResult,
              sourceFlow: sourceFlow,
              scanModality: scanModality,
              sourceTab: sourceTab,
              moldCaseId: moldCaseId,
            );
          case RouteNames.submitReport:
            return SubmitReportScreen();
          case RouteNames.viewReport:
            return ViewReportScreen();
          case RouteNames.addFollowUp:
            return AddFollowUpScreen();
          case RouteNames.inputCharacteristics:
            return InputCharacteristicsScreen();
          case RouteNames.terms:
            return TermsOfAgreementScreen();
          case RouteNames.privacy:
            return PrivacyPolicyScreen();
          case RouteNames.addLogChoices:
            final args = settings.arguments as Map<String, dynamic>?;
            final sourceTab = args?['sourceTab'] as String?;
            final caseId = args?['caseId'] as String?;
            final includeSize = args?['includeSize'] as bool? ?? true;
            final microscopicImagePath =
                args?['microscopicImagePath'] as String?;
            final macroscopicImagePath =
                args?['macroscopicImagePath'] as String?;
            final Map<String, dynamic>? microResult =
                args?['microResult'] as Map<String, dynamic>?;
            final Map<String, dynamic>? macroResult =
                args?['macroResult'] as Map<String, dynamic>?;
            final String? initialMicroIdentifiedMold =
                args?['initialMicroIdentifiedMold'] as String?;
            final String? initialMacroColor =
                args?['initialMacroColor'] as String?;
            final String? initialMacroTexture =
                args?['initialMacroTexture'] as String?;
            final String? initialMacroSymptoms =
                args?['initialMacroSymptoms'] as String?;
            final String? initialMacroSigns =
                args?['initialMacroSigns'] as String?;
            final String? initialMacroCharacteristics =
                args?['initialMacroCharacteristics'] as String?;
            final String? selectedCultureId =
                args?['selectedCultureId'] as String?;
            final String? selectedCultureName =
                args?['selectedCultureName'] as String?;

            List<String> toStringList(dynamic value) {
              if (value is List) {
                return value
                    .map((e) => e.toString().trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
              }
              return <String>[];
            }

            String? extractScanId(Map<String, dynamic>? payload) {
              if (payload == null) return null;
              final direct = payload['scanId']?.toString().trim();
              if (direct != null && direct.isNotEmpty) return direct;

              final savedScan = payload['savedScan'];
              if (savedScan is Map<String, dynamic>) {
                final nested = savedScan['id']?.toString().trim();
                if (nested != null && nested.isNotEmpty) return nested;
              }

              final fallback = payload['id']?.toString().trim();
              if (fallback != null && fallback.isNotEmpty) return fallback;
              return null;
            }

            bool didCultivationLogPersist(Map<String, dynamic>? payload) {
              if (payload == null) return false;
              if (payload['cultivationLogSaved'] == true) return true;
              final saved = payload['cultivationLog'];
              return saved is Map<String, dynamic> && saved.isNotEmpty;
            }

            String resolveCultivationType(String? tab) {
              if (tab == 'in-vivo') return 'vivo';
              return 'vitro';
            }

            return AddLogChoicesScreen(
              microscopicImagePath: microscopicImagePath,
              macroscopicImagePath: macroscopicImagePath,
              microResult: microResult,
              macroResult: macroResult,
              initialMicroIdentifiedMold: initialMicroIdentifiedMold,
              initialMacroColor: initialMacroColor,
              initialMacroTexture: initialMacroTexture,
              initialMacroSymptoms: initialMacroSymptoms,
              initialMacroSigns: initialMacroSigns,
              initialMacroCharacteristics: initialMacroCharacteristics,
              caseId: caseId,
              selectedCultureId: selectedCultureId,
              selectedCultureName: selectedCultureName,
              onCaptureMicro: (captureCultureId, captureCultureName) {
                final navigator = Navigator.of(context);
                navigator
                    .pushNamed(
                      RouteNames.mainCamera,
                      arguments: {
                        'showAppBar': true,
                        'returnResult': true,
                        'sourceFlow': 'cultivation_log',
                        'scanModality': 'microscopic',
                        'sourceTab': sourceTab,
                        'caseId': caseId,
                      },
                    )
                    .then((result) {
                      if (result is Map<String, dynamic>) {
                        final nextMicroPath = result['imagePath']?.toString();
                        final nextMicroResult = {
                          ...result,
                          if (captureCultureId != null &&
                              captureCultureId.trim().isNotEmpty)
                            'cultureId': captureCultureId,
                          if (captureCultureName != null &&
                              captureCultureName.trim().isNotEmpty)
                            'cultureName': captureCultureName,
                        };
                        navigator.pushReplacementNamed(
                          RouteNames.addLogChoices,
                          arguments: {
                            'sourceTab': sourceTab,
                            'caseId': caseId,
                            'includeSize': includeSize,
                            'microscopicImagePath': nextMicroPath,
                            'macroscopicImagePath': macroscopicImagePath,
                            'microResult': nextMicroResult,
                            'macroResult': macroResult,
                            'initialMicroIdentifiedMold':
                                initialMicroIdentifiedMold,
                            'initialMacroColor': initialMacroColor,
                            'initialMacroTexture': initialMacroTexture,
                            'initialMacroSymptoms': initialMacroSymptoms,
                            'initialMacroSigns': initialMacroSigns,
                            'initialMacroCharacteristics':
                                initialMacroCharacteristics,
                            'selectedCultureId': captureCultureId,
                            'selectedCultureName': captureCultureName,
                          },
                        );
                      }
                    });
              },
              onCaptureMacro: (captureCultureId, captureCultureName) {
                if (sourceTab == null || caseId == null) return;
                final navigator = Navigator.of(context);
                navigator
                    .pushNamed(
                      RouteNames.addLogInstructions,
                      arguments: {
                        'sourceTab': sourceTab,
                        'caseId': caseId,
                        'selectedCultureId': captureCultureId,
                        'selectedCultureName': captureCultureName,
                        'includeSize': includeSize,
                        'sourceFlow': 'cultivation_log',
                        'scanModality': 'macroscopic',
                        'returnResult': true,
                      },
                    )
                    .then((result) {
                      if (result is Map<String, dynamic>) {
                        final nextMacroPath = result['imagePath']?.toString();
                        navigator.pushReplacementNamed(
                          RouteNames.addLogChoices,
                          arguments: {
                            'sourceTab': sourceTab,
                            'caseId': caseId,
                            'includeSize': includeSize,
                            'microscopicImagePath': microscopicImagePath,
                            'macroscopicImagePath': nextMacroPath,
                            'microResult': microResult,
                            'macroResult': result,
                            'initialMicroIdentifiedMold':
                                initialMicroIdentifiedMold,
                            'initialMacroColor': initialMacroColor,
                            'initialMacroTexture': initialMacroTexture,
                            'initialMacroSymptoms': initialMacroSymptoms,
                            'initialMacroSigns': initialMacroSigns,
                            'initialMacroCharacteristics':
                                initialMacroCharacteristics,
                            'selectedCultureId': captureCultureId,
                            'selectedCultureName': captureCultureName,
                          },
                        );
                      }
                    });
              },
              onSubmit: (submitCultureId, submitCultureName) async {
                if (microResult == null && macroResult == null) {
                  Navigator.of(context).pop();
                  return;
                }

                final moldCaseService = MoldCaseService();

                Map<String, dynamic>? microCultivationLog;
                String? microLogSaveError;

                final microPersisted = didCultivationLogPersist(microResult);
                final microImagePath =
                    microResult?['imagePath']?.toString().trim() ?? '';
                final cultureId =
                    (submitCultureId ??
                            macroResult?['cultureId'] ??
                            microResult?['cultureId'])
                        ?.toString()
                        .trim();
                final cultureName =
                    (submitCultureName ??
                            macroResult?['cultureName'] ??
                            microResult?['cultureName'])
                        ?.toString()
                        .trim();

                // Persist a microscopic-only cultivation log when no macroscopic
                // log was stored. This ensures microscopy entries appear in the
                // case timeline and are included in refresh flows.
                if (!microPersisted &&
                    caseId != null &&
                    caseId.isNotEmpty &&
                    microResult != null &&
                    microImagePath.isNotEmpty) {
                  try {
                    final microscopicCharacteristics = <String, dynamic>{
                      'microscopic_identification':
                          microResult['identifiedMold']?.toString() ?? '',
                      'identified_mold':
                          microResult['identifiedMold']?.toString() ?? '',
                      'confidence':
                          (microResult['confidenceDecimal'] as num?)
                              ?.toDouble() ??
                          0.0,
                      if (microResult['topPredictions'] is List)
                        'top_predictions': microResult['topPredictions'],
                      if (microResult['modelSource'] != null)
                        'model_source': microResult['modelSource'].toString(),
                      if (cultureId != null && cultureId.isNotEmpty)
                        'culture_id': cultureId,
                      if (cultureName != null && cultureName.isNotEmpty)
                        'culture_name': cultureName,
                    };

                    final microLogResponse = await moldCaseService
                        .addCultivationLog(
                          caseId,
                          {
                            'type': resolveCultivationType(sourceTab),
                            'characteristics': microscopicCharacteristics,
                            'additional_info': '',
                          },
                          imagePath: microImagePath,
                          sessionCookie: authProvider.cookie,
                        );

                    final savedLog = microLogResponse['data'];
                    if (savedLog is Map<String, dynamic>) {
                      microCultivationLog = savedLog;
                    }
                  } catch (e) {
                    microLogSaveError = e.toString();
                  }
                }

                final microScanId = extractScanId(microResult);
                final macroScanId = extractScanId(macroResult);
                final hasAnyScanId =
                    (microScanId != null && microScanId.isNotEmpty) ||
                    (macroScanId != null && macroScanId.isNotEmpty);

                bool scanAssociationSaved = false;
                final scannedMicroscopicIdsAdded = <String>[];
                final scannedMacroscopicIdsAdded = <String>[];

                if (caseId != null && caseId.isNotEmpty && hasAnyScanId) {
                  try {
                    final moldCaseService = MoldCaseService();
                    final caseData = await moldCaseService.getMoldCaseById(
                      caseId,
                      sessionCookie: authProvider.cookie,
                    );

                    final existingDetails =
                        (caseData['cultivation_details']
                            is Map<String, dynamic>)
                        ? Map<String, dynamic>.from(
                            caseData['cultivation_details']
                                as Map<String, dynamic>,
                          )
                        : <String, dynamic>{};

                    final microscopicIds = toStringList(
                      existingDetails['scanned_microscopic_ids'],
                    );
                    final macroscopicIds = toStringList(
                      existingDetails['scanned_macroscopic_ids'],
                    );

                    if (microScanId != null &&
                        microScanId.isNotEmpty &&
                        !microscopicIds.contains(microScanId)) {
                      microscopicIds.add(microScanId);
                      scannedMicroscopicIdsAdded.add(microScanId);
                    }
                    if (macroScanId != null &&
                        macroScanId.isNotEmpty &&
                        !macroscopicIds.contains(macroScanId)) {
                      macroscopicIds.add(macroScanId);
                      scannedMacroscopicIdsAdded.add(macroScanId);
                    }

                    existingDetails['scanned_microscopic_ids'] = microscopicIds;
                    existingDetails['scanned_macroscopic_ids'] = macroscopicIds;

                    await moldCaseService.updateCultivationDetails(caseId, {
                      'cultivation_details': existingDetails,
                    }, sessionCookie: authProvider.cookie);

                    scanAssociationSaved = true;
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to associate scan IDs to case: $e',
                        ),
                      ),
                    );
                    return;
                  }
                }

                final Map<String, dynamic>? enrichedMacroResult =
                    macroResult == null
                    ? null
                    : {
                        ...macroResult,
                        if (cultureId != null && cultureId.isNotEmpty)
                          'cultureId': cultureId,
                        if (cultureName != null && cultureName.isNotEmpty)
                          'cultureName': cultureName,
                        'scanAssociationSaved': scanAssociationSaved,
                        'scannedMicroscopicIdsAdded':
                            scannedMicroscopicIdsAdded,
                        'scannedMacroscopicIdsAdded':
                            scannedMacroscopicIdsAdded,
                      };

                final Map<String, dynamic>? enrichedMicroResult =
                    microResult == null
                    ? null
                    : {
                        ...microResult,
                        if (cultureId != null && cultureId.isNotEmpty)
                          'cultureId': cultureId,
                        if (cultureName != null && cultureName.isNotEmpty)
                          'cultureName': cultureName,
                        'scanAssociationSaved': scanAssociationSaved,
                        'scannedMicroscopicIdsAdded':
                            scannedMicroscopicIdsAdded,
                        'scannedMacroscopicIdsAdded':
                            scannedMacroscopicIdsAdded,
                      };

                if (!context.mounted) return;

                Navigator.of(context).pop({
                  ...const MutationResult.changed(
                    tags: [MutationTags.moldCase],
                  ).toMap(),
                  'sourceTab': sourceTab,
                  'microscopicImagePath': microscopicImagePath,
                  'macroscopicImagePath': macroscopicImagePath,
                  'microCultivationLog': microCultivationLog,
                  'microCultivationLogSaved': microCultivationLog != null,
                  if (microLogSaveError != null)
                    'microLogSaveError': microLogSaveError,
                  'scanAssociationSaved': scanAssociationSaved,
                  'scannedMicroscopicIdsAdded': scannedMicroscopicIdsAdded,
                  'scannedMacroscopicIdsAdded': scannedMacroscopicIdsAdded,
                  if (cultureId != null && cultureId.isNotEmpty)
                    'selectedCultureId': cultureId,
                  if (cultureName != null && cultureName.isNotEmpty)
                    'selectedCultureName': cultureName,
                  if (enrichedMicroResult != null)
                    'microResult': enrichedMicroResult,
                  if (enrichedMacroResult != null)
                    'macroResult': enrichedMacroResult,
                });
              },
            );

          case RouteNames.viewWikiMold:
            final args = _mapArgs(settings);
            final articleId = _stringArg(args, 'id') ?? '';
            return ViewWikiMoldScreen(articleId: articleId);

          case RouteNames.cultureDashboard:
            final args = _mapArgs(settings);
            return CultureDashboard(caseId: _stringArg(args, 'caseId'));

          case RouteNames.setCulture:
            final args = _mapArgs(settings);
            return InitializeCulturePage(caseId: _stringArg(args, 'caseId'));

          default:
            return Scaffold(
              body: Center(
                child: Text('No route defined for \'${settings.name}\''),
              ),
            );
        }
      },
    );
  }
}
