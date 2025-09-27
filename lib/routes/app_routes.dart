import 'package:flutter/material.dart';
import 'package:moldify/pages/auth/signup.dart';
import 'package:moldify/pages/auth/email_recover_account.dart';
import 'package:moldify/pages/auth/code_recover_account.dart';
import 'package:moldify/pages/auth/intro.dart';
import '../pages/auth/login.dart';
import '../core/constants/route_names.dart';
import 'package:provider/provider.dart';
import 'package:moldify/providers/auth_provider.dart';
import '../main.dart';
import 'package:moldify/pages/auth/set_new_password.dart';

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
