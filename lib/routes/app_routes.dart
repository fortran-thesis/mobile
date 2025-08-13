import 'package:flutter/material.dart';
import 'package:moldify/pages/auth/signup.dart';
import 'package:moldify/pages/auth/email_recover_account.dart';
import 'package:moldify/pages/auth/code_recover_account.dart';
import 'package:moldify/pages/auth/intro.dart';
import '../pages/auth/login.dart';
import '../core/constants/route_names.dart';
import 'package:provider/provider.dart';
import 'package:moldify/providers/auth_provider.dart';
import 'package:moldify/pages/home/home_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isAuthenticated = authProvider.cookie != null && authProvider.cookie!.isNotEmpty;
        switch (settings.name) {
          case RouteNames.login:
            if (isAuthenticated) {
              return HomeScreen();
            }
            return LoginScreen();
          case RouteNames.signup:
            return SignUpScreen();
          case RouteNames.emailRecoverAccount:
            return EmailRecoverAccountScreen(pageTitle: '');
          case RouteNames.codeRecoverAccount:
            final args = settings.arguments as Map<String, dynamic>?;
            final pageTitle = args != null && args['pageTitle'] != null ? args['pageTitle'] as String : '';
            return CodeRecoverAccountScreen(pageTitle: pageTitle);
          case RouteNames.intro:
            if (isAuthenticated) {
              return HomeScreen();
            }
            return IntroScreen();
          case RouteNames.home:
            return HomeScreen();

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
