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
import '../pages/monitor/add_log.dart';
import '../pages/monitor/add_log_instructions.dart';
import '../pages/monitor/edit_log.dart';
import '../pages/monitor/give_recommendation.dart';
import '../pages/monitor/identification_history.dart';
import '../pages/monitor/set_monitoring_details.dart';
import '../pages/monitor/treatment_history.dart';
import '../pages/monitor/view_case.dart';
import '../pages/monitor/culture/view_timers.dart';
import '../pages/monitor/culture/set_timer.dart';
import '../splash_screen.dart';

class AppRoutes {
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
            final sourceFlow = args?['sourceFlow'] as String?;
            final scanModality = args?['scanModality'] as String?;
            final includeSize = args?['includeSize'] as bool? ?? true;
            final returnResult = args?['returnResult'] as bool? ?? false;
            return CameraScreen(
              source: source,
              sourceTab: sourceTab,
              caseId: caseId,
              sourceFlow: sourceFlow,
              scanModality: scanModality,
              includeSize: includeSize,
              returnResult: returnResult,
            );

          case RouteNames.imagePreview:
            if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              if (args.containsKey('imagePath') &&
                  args['imagePath'] is String) {
                final String imagePath = args['imagePath'] as String;
                final String? source = args['source'] as String?;
                final String? sourceTab = args['sourceTab'] as String?;
                final String? caseId = args['caseId'] as String?;
                final String? sourceFlow = args['sourceFlow'] as String?;
                final String? scanModality = args['scanModality'] as String?;
                final bool includeSize = args['includeSize'] as bool? ?? true;
                final bool returnResult =
                    args['returnResult'] as bool? ?? false;
                return ImagePreviewScreen(
                  imagePath: imagePath,
                  source: source,
                  sourceTab: sourceTab,
                  caseId: caseId,
                  sourceFlow: sourceFlow,
                  scanModality: scanModality,
                  includeSize: includeSize,
                  returnResult: returnResult,
                );
              } else {
                return Scaffold(
                  appBar: AppBar(title: const Text('Error')),
                  body: const Center(child: Text('imagePath missing')),
                );
              }
            } else {
              return Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: const Center(
                  child: Text('Invalid arguments for imagePreview'),
                ),
              );
            }

          case RouteNames.moldResult:
            if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              if (args.containsKey('croppedImagePath') &&
                  args['croppedImagePath'] is String) {
                final String croppedImagePath =
                    args['croppedImagePath'] as String;
                final Map<String, dynamic>? modelResult =
                    args['modelResult'] as Map<String, dynamic>?;
                final Map<String, dynamic>? moldDetails =
                    args['moldDetails'] as Map<String, dynamic>?;
                final String? sourceFlow = args['sourceFlow'] as String?;
                final String? scanModality = args['scanModality'] as String?;
                final String? sourceTab = args['sourceTab'] as String?;
                final String? caseId = args['caseId'] as String?;
                return MoldResultScreen(
                  croppedImagePath: croppedImagePath,
                  modelResult: modelResult,
                  moldDetails: moldDetails,
                  sourceFlow: sourceFlow,
                  scanModality: scanModality,
                  sourceTab: sourceTab,
                  caseId: caseId,
                );
              } else {
                return Scaffold(
                  appBar: AppBar(title: const Text('Error')),
                  body: const Center(child: Text('croppedImagePath missing')),
                );
              }
            } else {
              return Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: const Center(
                  child: Text('Invalid arguments for moldResult'),
                ),
              );
            }

          case RouteNames.setMonitoringDetails:
            if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              if (args.containsKey('moldCase')) {
                final moldCase = args['moldCase'];
                return SetMonitoringDetailsScreen(moldCase: moldCase);
              } else {
                return Scaffold(
                  appBar: AppBar(title: const Text('Error')),
                  body: const Center(child: Text('moldCase missing')),
                );
              }
            } else {
              return Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: const Center(
                  child: Text('Invalid arguments for setMonitoringDetails'),
                ),
              );
            }

          case RouteNames.viewCase:
            return ViewCaseScreen();

          case RouteNames.editLog:
            if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              if (args.containsKey('tabName') && args['tabName'] is String) {
                final String tabName = args['tabName'] as String;
                return EditLogScreen(tabName: tabName);
              } else {
                return Scaffold(
                  appBar: AppBar(title: const Text('Error')),
                  body: const Center(child: Text('tabName missing')),
                );
              }
            } else {
              return Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: const Center(
                  child: Text('Invalid arguments for editLog'),
                ),
              );
            }

          case RouteNames.addTreatment:
            return AddTreatmentScreen();

          case RouteNames.giveRecommendation:
            return const GiveRecommendationScreen();

          case RouteNames.identificationHistory:
            return IdentificationHistoryScreen();

          case RouteNames.treatmentHistory:
            return TreatmentHistoryScreen();

          case RouteNames.addLogInstructions:
            final args = settings.arguments as Map<String, dynamic>?;
            final sourceTab = args?['sourceTab'] as String?;
            final caseId = args?['caseId'] as String?;
            final pageTitle = args?['pageTitle'] as String?;
            final pageSubtitle = args?['pageSubtitle'] as String?;
            final includeSize = args?['includeSize'] as bool? ?? true;
            final sourceFlow = args?['sourceFlow'] as String?;
            final scanModality = args?['scanModality'] as String?;
            final returnResult = args?['returnResult'] as bool? ?? false;
            return AddLogInstructionsScreen(
              sourceTab: sourceTab,
              caseId: caseId,
              pageTitle: pageTitle,
              pageSubtitle: pageSubtitle,
              includeSize: includeSize,
              sourceFlow: sourceFlow,
              scanModality: scanModality,
              returnResult: returnResult,
            );

          case RouteNames.addLog:
            if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              if (args.containsKey('imagePath') &&
                  args['imagePath'] is String &&
                  args.containsKey('sourceTab') &&
                  args['sourceTab'] is String &&
                  args.containsKey('caseId') &&
                  args['caseId'] is String) {
                final imagePath = args['imagePath'] as String;
                final sourceTab = args['sourceTab'] as String;
                final caseId = args['caseId'] as String;
                final includeSize = args['includeSize'] as bool? ?? true;
                final sourceFlow = args['sourceFlow'] as String?;
                final scanModality = args['scanModality'] as String?;
                return AddLogScreen(
                  imagePath: imagePath,
                  sourceTab: sourceTab,
                  caseId: caseId,
                  includeSize: includeSize,
                  sourceFlow: sourceFlow,
                  scanModality: scanModality,
                );
              } else {
                return Scaffold(
                  appBar: AppBar(title: const Text('Argument Error')),
                  body: const Center(
                    child: Text(
                      'AddLog: imagePath, sourceTab, or caseId missing or invalid.',
                    ),
                  ),
                );
              }
            } else {
              return Scaffold(
                appBar: AppBar(title: const Text('Navigation Error')),
                body: Center(
                  child: Text(
                    'AddLog: Invalid argument type. Expected Map, got ${settings.arguments.runtimeType}.',
                  ),
                ),
              );
            }

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
            final String? initialMacroCharacteristics =
                args?['initialMacroCharacteristics'] as String?;

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
              initialMacroCharacteristics: initialMacroCharacteristics,
              onCaptureMicro: () {
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
                        navigator.pushReplacementNamed(
                          RouteNames.addLogChoices,
                          arguments: {
                            'sourceTab': sourceTab,
                            'caseId': caseId,
                            'includeSize': includeSize,
                            'microscopicImagePath': nextMicroPath,
                            'macroscopicImagePath': macroscopicImagePath,
                            'microResult': result,
                            'macroResult': macroResult,
                            'initialMicroIdentifiedMold':
                                initialMicroIdentifiedMold,
                            'initialMacroColor': initialMacroColor,
                            'initialMacroTexture': initialMacroTexture,
                            'initialMacroSymptoms': initialMacroSymptoms,
                            'initialMacroCharacteristics':
                                initialMacroCharacteristics,
                          },
                        );
                      }
                    });
              },
              onCaptureMacro: () {
                if (sourceTab == null || caseId == null) return;
                final navigator = Navigator.of(context);
                navigator
                    .pushNamed(
                      RouteNames.addLogInstructions,
                      arguments: {
                        'sourceTab': sourceTab,
                        'caseId': caseId,
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
                            'initialMacroCharacteristics':
                                initialMacroCharacteristics,
                          },
                        );
                      }
                    });
              },
              onSubmit: () async {
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
                        'scanAssociationSaved': scanAssociationSaved,
                        'scannedMicroscopicIdsAdded':
                            scannedMicroscopicIdsAdded,
                        'scannedMacroscopicIdsAdded':
                            scannedMacroscopicIdsAdded,
                      };

                if (!context.mounted) return;

                Navigator.of(context).pop({
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
                  if (enrichedMicroResult != null)
                    'microResult': enrichedMicroResult,
                  if (enrichedMacroResult != null)
                    'macroResult': enrichedMacroResult,
                });
              },
            );

          case RouteNames.cultureDashboard:
            return const CultureDashboard();

          case RouteNames.setCulture:
            return const InitializeCulturePage();

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
