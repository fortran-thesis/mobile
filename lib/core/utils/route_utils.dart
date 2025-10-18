import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Helper that prefers GoRouter navigation if available.
void navigateTo(BuildContext context, String path, {bool replace = false, Object? arguments}) {
  if (replace) {
    // replace the stack (use for logout/login flows)
    context.go(path, extra: arguments);
  } else {
    // push to preserve back stack
    context.push(path, extra: arguments);
  }
}