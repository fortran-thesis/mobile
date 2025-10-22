import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../misc/colors.dart';

class PreventionTacticsContent extends StatelessWidget {
  final List<String> recommendedFungicides;
  final String additionalInformation;

  const PreventionTacticsContent({
    super.key,
    required this.recommendedFungicides,
    required this.additionalInformation
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Case Details Header
          Text (
            'Prevention Tactics',
            style: TextStyle(
              fontFamily: 'Montserrat-Black',
              fontSize: 20,
              color: MoldifyColors.primaryColor,
            ),
          ),
          Text (
            'View recommended prevention tactics to avoid mold growth.',
            style: TextStyle(
              fontFamily: 'Bricolage-Grotesque-Regular',
              fontSize: 12,
              color: MoldifyColors.MoldifyGrey,
            ),
          ),
          /// End of Case Details Header

          SizedBox(height: 12),
          Text(
            'Recommend Fungicides',
            style: TextStyle(
              fontFamily: 'Bricolage-Grotesque-SemiBold',
              fontSize: 16,
              color: MoldifyColors.primaryColor,
            ),
          ),
          // Bullet List
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: recommendedFungicides
                .map((fungicide) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(fontSize: 15, height: 1.4),
                  ),
                  Expanded(
                    child: Text(
                      fungicide,
                      style: const TextStyle(
                          height: 1.4,
                          fontFamily: 'Bricolage-Grotesque-Regular',
                          fontSize: 16,
                          color: MoldifyColors.MoldifyBlack
                      ),
                    ),
                  ),
                ],
              ),
            ))
                .toList(),
          ),
          SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MoldifyColors.taupe,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.circleInfo,
                      color: MoldifyColors.accentColor,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Additional Information',
                        style: TextStyle(
                          fontFamily: 'Bricolage-Grotesque-SemiBold',
                          fontSize: 16,
                          color: MoldifyColors.primaryColor,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  additionalInformation,
                  style: TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    fontSize: 16,
                    color: MoldifyColors.MoldifyBlack,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}