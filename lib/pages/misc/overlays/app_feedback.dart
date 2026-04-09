import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/colors.dart';

enum AppFeedbackType { success, error, info }

class AppFeedback {
  static void showSuccess(BuildContext context, String message) {
    _show(context: context, message: message, type: AppFeedbackType.success);
  }

  static void showError(BuildContext context, String message) {
    _show(context: context, message: message, type: AppFeedbackType.error);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context: context, message: message, type: AppFeedbackType.info);
  }

  static void _show({
    required BuildContext context,
    required String message,
    required AppFeedbackType type,
  }) {
    if (!context.mounted) return;

    final Color backgroundColor = switch (type) {
      AppFeedbackType.success => MoldifyColors.primaryColor,
      AppFeedbackType.error => MoldifyColors.MoldifyRed,
      AppFeedbackType.info => MoldifyColors.accentColor,
    };

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          backgroundColor: backgroundColor,
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'Bricolage-Grotesque-Regular',
              fontSize: 14,
              color: MoldifyColors.backgroundColor,
            ),
          ),
        ),
      );
  }
}
