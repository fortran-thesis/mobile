import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:moldify/l10n/app_localizations.dart';
import 'package:moldify/pages/misc/colors.dart';

class StatusBox extends StatelessWidget {
  final String status;
  final double? fontSize;

  const StatusBox({super.key, required this.status, this.fontSize});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return MoldifyColors.accentColor;
      case 'in progress':
        return MoldifyColors.MoldifyBlue;
      case 'resolved':
        return MoldifyColors.primaryColor;
      case 'closed':
        return MoldifyColors.MoldifyGrey;
      case 'rejected':
        return MoldifyColors.MoldifyRed;
      case 'low priority':
        return MoldifyColors.MoldifyLightGreen;
      case 'medium priority':
        return MoldifyColors.MoldifyLightYellow;
      case 'high priority':
        return MoldifyColors.MoldifyLightRed;

      default:
        return Colors.black26;
    }
  }

  String _getLocalizedStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status.toLowerCase()) {
      case 'pending':
        return l10n.statusLabelPending;
      case 'in progress':
        return l10n.statusLabelInProgress;
      case 'resolved':
        return l10n.statusLabelResolved;
      case 'closed':
        return l10n.statusLabelClosed;
      case 'rejected':
        return l10n.statusLabelRejected;
      case 'low priority':
        return l10n.statusLabelLowPriority;
      case 'medium priority':
        return l10n.statusLabelMediumPriority;
      case 'high priority':
        return l10n.statusLabelHighPriority;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    final localizedStatus = _getLocalizedStatus(context, status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: AutoSizeText(
          localizedStatus,
          style: TextStyle(
              fontFamily: 'Bricolage-Grotesque-Bold',
              fontSize: fontSize ?? 10,
              color: status.toLowerCase() == 'pending' ||
                      status.toLowerCase() == 'low priority' ||
                      status.toLowerCase() == 'medium priority' ||
                      status.toLowerCase() == 'high priority'
                  ? MoldifyColors.MoldifyBlack
                  : MoldifyColors.backgroundColor),
          maxLines: 1,
          minFontSize: 6,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
