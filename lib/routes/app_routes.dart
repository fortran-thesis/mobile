import 'package:flutter/material.dart';
import 'package:moldify/pages/auth/signup.dart';
import 'package:moldify/pages/auth/email_recover_account.dart';
import 'package:moldify/pages/auth/code_recover_account.dart';
import 'package:moldify/pages/auth/intro.dart';
import 'package:moldify/pages/identification/camera.dart';
import 'package:moldify/pages/identification/image_preview.dart';
import '../pages/auth/login.dart';
import '../core/constants/route_names.dart';
import 'package:provider/provider.dart';
import 'package:moldify/providers/auth_provider.dart';
import '../main.dart';
import 'package:moldify/pages/auth/set_new_password.dart';

import '../pages/identification/mold_result.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
        final isAuthenticated = authProvider.cookie != null && authProvider.cookie!.isNotEmpty;
        switch (settings.name) {
          case RouteNames.login:
            if (isAuthenticated) {
              return MainPage();
            }
            return MainPage();
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
            return MainPage();
          case RouteNames.main:
            return MainPage();
          case RouteNames.setNewPassword:
            final args = settings.arguments as Map<String, dynamic>?;
            final token = args != null && args['token'] != null ? args['token'] as String : '';
            return SetNewPasswordScreen(token: token);
          case RouteNames.camera:
            return CameraScreen();
          case RouteNames.imagePreview:
            if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>; // Safe cast
              if (args.containsKey('imagePath') && args['imagePath'] is String) {
                final String imagePath = args['imagePath'] as String;
                // Ensure ImagePreviewScreen is imported
                return ImagePreviewScreen(imagePath: imagePath);
              } else {
                print('ERROR (ImagePreview): Arguments are Map, but \'imagePath\' key is missing or not a String. Args: $args');
                return Scaffold(
                  appBar: AppBar(title: const Text('Argument Error')),
                  body: const Center(child: Text('ImagePreview: imagePath missing or invalid in arguments.')),
                );
              }
            } else {
              // This handles the case where arguments are not a Map (e.g., String, null), preventing the crash.
              print('ERROR (ImagePreview): Expected Map arguments, but got ${settings.arguments.runtimeType}. Args: ${settings.arguments}');
              return Scaffold(
                appBar: AppBar(title: const Text('Navigation Error')),
                body: Center(
                    child: Text('ImagePreview: Invalid argument type. Expected Map, got ${settings.arguments.runtimeType}.\nCheck console for details. Args: ${settings.arguments}')
                ),
              );
            }
          case RouteNames.moldResult:
            if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>; // Safe cast
              if (args.containsKey('croppedImagePath') && args['croppedImagePath'] is String) {
                final String croppedImagePath = args['croppedImagePath'] as String;
                // Ensure MoldResultScreen is imported
                return MoldResultScreen(croppedImagePath: croppedImagePath);
              } else {
                print('ERROR (MoldResult): Arguments are Map, but \'croppedImagePath\' key is missing or not a String. Args: $args');
                return Scaffold(
                  appBar: AppBar(title: const Text('Argument Error')),
                  body: const Center(child: Text('MoldResult: croppedImagePath missing or invalid in arguments.')),
                );
              }
            } else {
              // This handles the case where arguments are not a Map (e.g., String, null), preventing the crash.
              print('ERROR (MoldResult): Expected Map arguments, but got ${settings.arguments.runtimeType}. Args: ${settings.arguments}');
              return Scaffold(
                appBar: AppBar(title: const Text('Navigation Error')),
                body: Center(
                    child: Text('MoldResult: Invalid argument type. Expected Map, got ${settings.arguments.runtimeType}.\nCheck console for details. Args: ${settings.arguments}')
                ),
              );
            }
          // Add more cases for other routes using RouteNames
          default:
            return Scaffold(
              body: Center(child: Text('No route defined for \'${settings.name}\'')),
            );
        }
      },
    );
  }
}
