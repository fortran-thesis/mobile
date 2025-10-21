import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontFamily: 'Bricolage-Grotesque-Bold',
          fontSize: fontSize ?? 8,
          color: status.toLowerCase() == 'pending' ||
              status.toLowerCase() == 'low priority' ||
              status.toLowerCase() == 'medium priority' ||
              status.toLowerCase() == 'high priority'
              ? MoldifyColors.MoldifyBlack
              : MoldifyColors.backgroundColor
        ),
      ),
    );
  }
}
