import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/colors.dart';

/// The Hub for Culture management.
/// To be used as a child of [BuildBottomSheet].
class CultureHubBottomSheetContent extends StatelessWidget {
  final VoidCallback onCreateNew;
  final VoidCallback onViewActive;

  const CultureHubBottomSheetContent({
    super.key,
    required this.onCreateNew,
    required this.onViewActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // OPTION 1: START NEW
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: MoldifyColors.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              FontAwesomeIcons.flask,
              color: MoldifyColors.accentColor,
              size: 18.0,
            ),
          ),
          title: const AutoSizeText(
            'Set Culture Timer',
            style: TextStyle(
              fontFamily: 'Bricolage-Grotesque-Bold',
              color: MoldifyColors.primaryColor,
              fontSize: 16,
            ),
            maxLines: 1,
          ),
          subtitle: const Text(
            "Name a sample and set growth reminders",
            style: TextStyle(
              fontSize: 12, 
              fontFamily: 'Bricolage-Grotesque-Regular',
              color: MoldifyColors.MoldifyGrey,
            ),
          ),
          onTap: onCreateNew,
        ),
        
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Divider(height: 20, thickness: 0.5),
        ),

        // OPTION 2: VIEW ACTIVE
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: MoldifyColors.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              FontAwesomeIcons.clockRotateLeft,
              color: MoldifyColors.accentColor,
              size: 18.0,
            ),
          ),
          title: const AutoSizeText(
            'View Active Culture Timer',
            style: TextStyle(
              fontFamily: 'Bricolage-Grotesque-Bold',
              color: MoldifyColors.primaryColor,
              fontSize: 16,
            ),
            maxLines: 1,
          ),
          subtitle: const Text(
            "Monitor timers for your team",
            style: TextStyle(
              fontSize: 12, 
              fontFamily: 'Bricolage-Grotesque-Regular',
              color: MoldifyColors.MoldifyGrey,
            ),
          ),
          onTap: onViewActive,
        ),
      ],
    );
  }
}