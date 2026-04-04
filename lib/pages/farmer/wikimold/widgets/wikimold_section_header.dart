import 'package:flutter/material.dart';

import '../../../misc/colors.dart';

class WikiMoldSectionHeader extends StatelessWidget {
  const WikiMoldSectionHeader({
    super.key,
    required this.phaseNumber,
    required this.superTitle,
    required this.mainTitle,
    this.subtitle,
  });

  final String phaseNumber;
  final String superTitle;
  final String mainTitle;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -10,
            top: -15,
            child: Text(
              phaseNumber,
              style: TextStyle(
                fontFamily: 'Montserrat-Black',
                fontSize: 80,
                color: MoldifyColors.primaryColor.withValues(alpha: 0.05),
                height: 1,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 3,
                    height: 45,
                    margin: const EdgeInsets.only(right: 12, top: 2),
                    decoration: BoxDecoration(
                      color: MoldifyColors.accentColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          superTitle.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Bricolage-Grotesque',
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.5,
                            color: MoldifyColors.MoldifyGrey.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mainTitle.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Montserrat-Black',
                            fontSize: 24,
                            height: 1.1,
                            letterSpacing: -0.5,
                            color: MoldifyColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    subtitle!.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Bricolage-Grotesque',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                      color: MoldifyColors.MoldifyGrey.withValues(alpha: 0.8),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
