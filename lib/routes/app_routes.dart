import 'package:flutter/material.dart';
import 'package:moldify/pages/auth/signup.dart';
import 'package:moldify/pages/auth/email_recover_account.dart';
import 'package:moldify/pages/auth/code_recover_account.dart';
import 'package:moldify/pages/auth/intro.dart';
import 'package:moldify/pages/farmer/report/main_report.dart';
import 'package:moldify/pages/identification/camera.dart';
import 'package:moldify/pages/identification/image_preview.dart';
import 'package:moldify/pages/identification/input_characteristics.dart';
import 'package:moldify/pages/monitor/add_treatment.dart';
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
import '../pages/monitor/identification_history.dart';
import '../pages/monitor/set_monitoring_details.dart';
import '../pages/monitor/treatment_history.dart';
import '../pages/monitor/view_case.dart';
import '../splash_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings, // Pass settings so arguments are accessible
      builder: (context) {
        final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
        final isAuthenticated = authProvider.cookie != null && authProvider.cookie!.isNotEmpty;
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
            final pageTitle = args != null && args['pageTitle'] != null ? args['pageTitle'] as String : '';
            return EmailRecoverAccountScreen(pageTitle: pageTitle);
          case RouteNames.codeRecoverAccount:
            final args = settings.arguments as Map<String, dynamic>?;
            final pageTitle = args != null && args['pageTitle'] != null ? args['pageTitle'] as String : '';
            final email = args != null && args['email'] != null ? args['email'] as String : '';
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
            final token = args != null && args['token'] != null ? args['token'] as String : '';
            return SetNewPasswordScreen(token: token);

          case RouteNames.camera:
            final args = settings.arguments as Map<String, dynamic>?;
            final source = args?['source'] as String?;
            final sourceTab = args?['sourceTab'] as String?;
            final caseId = args?['caseId'] as String?;
            return CameraScreen(source: source, sourceTab: sourceTab, caseId: caseId);

          case RouteNames.imagePreview:
            if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              if (args.containsKey('imagePath') && args['imagePath'] is String) {
                final String imagePath = args['imagePath'] as String;
                final String? source = args['source'] as String?;
                final String? sourceTab = args['sourceTab'] as String?;
                final String? caseId = args['caseId'] as String?;
                return ImagePreviewScreen(imagePath: imagePath, source: source, sourceTab: sourceTab, caseId: caseId);
              } else {
                return Scaffold(appBar: AppBar(title: const Text('Error')), body: const Center(child: Text('imagePath missing')));
              }
            } else {
              return Scaffold(appBar: AppBar(title: const Text('Error')), body: const Center(child: Text('Invalid arguments for imagePreview')));
            }

          case RouteNames.moldResult:
            if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              if (args.containsKey('croppedImagePath') && args['croppedImagePath'] is String) {
                final String croppedImagePath = args['croppedImagePath'] as String;
                final Map<String, dynamic>? modelResult = args['modelResult'] as Map<String, dynamic>?;
                return MoldResultScreen(croppedImagePath: croppedImagePath, modelResult: modelResult);
              } else {
                return Scaffold(appBar: AppBar(title: const Text('Error')), body: const Center(child: Text('croppedImagePath missing')));
              }
            } else {
              return Scaffold(appBar: AppBar(title: const Text('Error')), body: const Center(child: Text('Invalid arguments for moldResult')));
            }

          case RouteNames.setMonitoringDetails:
            if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              if (args.containsKey('moldCase')) {
                final moldCase = args['moldCase'];
                return SetMonitoringDetailsScreen(moldCase: moldCase);
              } else {
                return Scaffold(appBar: AppBar(title: const Text('Error')), body: const Center(child: Text('moldCase missing')));
              }
            } else {
              return Scaffold(appBar: AppBar(title: const Text('Error')), body: const Center(child: Text('Invalid arguments for setMonitoringDetails')));
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
                return Scaffold(appBar: AppBar(title: const Text('Error')), body: const Center(child: Text('tabName missing')));
              }
            } else {
              return Scaffold(appBar: AppBar(title: const Text('Error')), body: const Center(child: Text('Invalid arguments for editLog')));
            }

          case RouteNames.addTreatment:
            return AddTreatmentScreen();

          case RouteNames.identificationHistory:
            return IdentificationHistoryScreen();

          case RouteNames.treatmentHistory:
            return TreatmentHistoryScreen();

          case RouteNames.addLogInstructions:
            final args = settings.arguments as Map<String, dynamic>?;
            final sourceTab = args?['sourceTab'] as String?;
            final caseId = args?['caseId'] as String?;
            return AddLogInstructionsScreen(sourceTab: sourceTab, caseId: caseId);

          case RouteNames.addLog:
            if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              if (args.containsKey('imagePath') && args['imagePath'] is String &&
                  args.containsKey('sourceTab') && args['sourceTab'] is String &&
                  args.containsKey('caseId') && args['caseId'] is String) {
                final imagePath = args['imagePath'] as String;
                final sourceTab = args['sourceTab'] as String;
                final caseId = args['caseId'] as String;
                return AddLogScreen(imagePath: imagePath, sourceTab: sourceTab, caseId: caseId);
              } else {
                return Scaffold(
                  appBar: AppBar(title: const Text('Argument Error')),
                  body: const Center(child: Text('AddLog: imagePath, sourceTab, or caseId missing or invalid.')),
                );
              }
            } else {
              return Scaffold(
                appBar: AppBar(title: const Text('Navigation Error')),
                body: Center(child: Text('AddLog: Invalid argument type. Expected Map, got ${settings.arguments.runtimeType}.')),
              );
            }
            
          case RouteNames.mainCamera:
            final args = settings.arguments as Map<String, dynamic>?;
            final bool showAppBar = args?['showAppBar'] as bool? ?? false;
            return MainCameraScreen(showAppBar: showAppBar);
            case RouteNames.submitReport:
              return SubmitReportScreen();
          case RouteNames.viewReport:
              return ViewReportScreen();
          case RouteNames.addFollowUp:
              return AddFollowUpScreen();
              case RouteNames.inputCharacteristics:
                return InputCharacteristicsScreen();


          default:
            return Scaffold(
              body: Center(child: Text('No route defined for \'${settings.name}\'')),
            );
        }
      },
    );
  }
}
