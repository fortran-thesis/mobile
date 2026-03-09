import 'package:flutter/material.dart';
import 'package:moldify/core/constants/route_names.dart';

class AuthNavigation {
  static void resetToLoginFromContext(BuildContext context) {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil(RouteNames.login, (route) => false);
  }

  static void resetToMainFromContext(BuildContext context) {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil(RouteNames.main, (route) => false);
  }

  static void resetToLoginFromNavigator(NavigatorState navigator) {
    navigator.pushNamedAndRemoveUntil(RouteNames.login, (route) => false);
  }
}
