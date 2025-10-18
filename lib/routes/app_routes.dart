import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moldify/pages/auth/signup.dart';
import 'package:moldify/pages/auth/email_recover_account.dart';
import 'package:moldify/pages/auth/code_recover_account.dart';
import 'package:moldify/pages/auth/intro.dart';
import 'package:moldify/pages/identification/camera.dart';
import 'package:moldify/pages/identification/image_preview.dart';
import 'package:moldify/pages/identification/main_camera.dart';
import 'package:moldify/pages/monitor/add_log.dart';
import 'package:moldify/pages/monitor/add_log_instructions.dart';
import 'package:moldify/pages/monitor/add_treatment.dart';
import 'package:moldify/pages/monitor/edit_log.dart';
import 'package:moldify/pages/monitor/identification_history.dart';
import 'package:moldify/pages/monitor/set_monitoring_details.dart';
import 'package:moldify/pages/monitor/treatment_history.dart';
import 'package:moldify/pages/monitor/view_case.dart';
import '../pages/auth/login.dart';
import '../core/constants/route_names.dart';
import 'package:moldify/providers/auth_provider.dart';
import 'package:moldify/pages/auth/set_new_password.dart';
import '../pages/identification/mold_result.dart';
import '../main.dart';

class AppRoutes {
  /// Creates a GoRouter configured with app routes and auth-based redirects.
  static GoRouter createRouter(AppAuthProvider authProvider) {
    return GoRouter(
      debugLogDiagnostics: false,
      refreshListenable: authProvider,
      initialLocation: RouteNames.intro,
      redirect: (context, state) {
        final loggedIn = authProvider.cookie != null && authProvider.cookie!.isNotEmpty;

        // routes allowed while unauthenticated
        final unauthenticatedAllowed = <String>{
          RouteNames.login,
          RouteNames.signup,
          RouteNames.intro,
          RouteNames.emailRecoverAccount,
          RouteNames.codeRecoverAccount,
          RouteNames.setNewPassword,
        };

        final goingTo = state.uri.toString();
        final isAuthRoute = unauthenticatedAllowed.contains(goingTo);

        if (!loggedIn && !isAuthRoute) {
          return RouteNames.login;
        }
        return null;
      },
      routes: <GoRoute>[
        GoRoute(path: RouteNames.intro, name: 'intro', builder: (context, state) => IntroScreen()),
        GoRoute(path: RouteNames.login, name: 'login', builder: (context, state) => LoginScreen()),
        GoRoute(path: RouteNames.signup, name: 'signup', builder: (context, state) => SignUpScreen()),
        GoRoute(
          path: RouteNames.emailRecoverAccount,
          builder: (context, state) {
            final pageTitle = state.uri.queryParameters['pageTitle'] ?? '';
            return EmailRecoverAccountScreen(pageTitle: pageTitle);
          },
        ),
        GoRoute(
          path: RouteNames.codeRecoverAccount,
          builder: (context, state) {
            final pageTitle = state.uri.queryParameters['pageTitle'] ?? '';
            final email = state.uri.queryParameters['email'] ?? '';
            return CodeRecoverAccountScreen(email: email, pageTitle: pageTitle);
          },
        ),
        GoRoute(path: RouteNames.main, name: 'main', builder: (context, state) => MainPage()),
        GoRoute(
          path: RouteNames.setNewPassword,
          builder: (context, state) {
            final token = state.uri.queryParameters['token'] ?? '';
            return SetNewPasswordScreen(token: token);
          },
        ),
        GoRoute(path: RouteNames.camera, builder: (context, state) => CameraScreen()),
        GoRoute(
          path: RouteNames.imagePreview,
          builder: (context, state) {
            // prefer query param, fall back to extra
            final imagePath = state.uri.queryParameters['imagePath'] ?? (state.extra is String ? state.extra as String : null);
            if (imagePath == null || imagePath.isEmpty) {
              return Scaffold(
                appBar: AppBar(title: const Text('Argument Error')),
                body: const Center(child: Text('ImagePreview: imagePath missing or invalid in arguments.')),
              );
            }
            return ImagePreviewScreen(imagePath: imagePath);
          },
        ),
        GoRoute(
          path: RouteNames.moldResult,
          builder: (context, state) {
            final croppedImagePath = state.uri.queryParameters['croppedImagePath'] ?? (state.extra is String ? state.extra as String : null);
            if (croppedImagePath == null || croppedImagePath.isEmpty) {
              return Scaffold(
                appBar: AppBar(title: const Text('Argument Error')),
                body: const Center(child: Text('MoldResult: croppedImagePath missing or invalid in arguments.')),
              );
            }
            return MoldResultScreen(croppedImagePath: croppedImagePath);
          },
        ),
        GoRoute(
          path: RouteNames.setMonitoringDetails,
          builder: (context, state) => SetMonitoringDetailsScreen(),
        ),
        GoRoute(
          path: RouteNames.viewCase,
          builder: (context, state) => ViewCaseScreen(),
        ),
        GoRoute(
          path: RouteNames.editLog,
          builder: (context, state) {
            final tabName = state.uri.queryParameters['tabName'];
            if (tabName == null || tabName.isEmpty) {
              return Scaffold(appBar: AppBar(title: const Text('Error')), body: const Center(child: Text('tabName missing')));
            }
            return EditLogScreen(tabName: tabName);
          },
        ),
        GoRoute(
          path: RouteNames.addTreatment,
          builder: (context, state) => AddTreatmentScreen(),
        ),
        GoRoute(
          path: RouteNames.identificationHistory,
          builder: (context, state) => IdentificationHistoryScreen(),
        ),
        GoRoute(
          path: RouteNames.treatmentHistory,
          builder: (context, state) => TreatmentHistoryScreen(),
        ),
        GoRoute(
          path: RouteNames.addLogInstructions,
          builder: (context, state) {
            final sourceTab = state.uri.queryParameters['sourceTab'];
            return AddLogInstructionsScreen(sourceTab: sourceTab);
          },
        ),
        GoRoute(
          path: RouteNames.addLog,
          builder: (context, state) {
            final imagePath = state.uri.queryParameters['imagePath'];
            final sourceTab = state.uri.queryParameters['sourceTab'];
            if (imagePath == null || sourceTab == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Argument Error')),
                body: const Center(child: Text('AddLog: imagePath or sourceTab missing or invalid.')),
              );
            }
            return AddLogScreen(imagePath: imagePath, sourceTab: sourceTab);
          },
        ),
        GoRoute(
          path: RouteNames.mainCamera,
          builder: (context, state) {
            final showAppBar = state.uri.queryParameters['showAppBar'] == 'true';
            return MainCameraScreen(showAppBar: showAppBar);
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(body: Center(child: Text('No route defined: ${state.error}'))),
    );
  }
}
