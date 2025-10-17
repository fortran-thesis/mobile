import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/colors.dart'; // optional if you have custom colors

class TreatmentHistoryTile extends StatelessWidget {
  final String date;
  final List<String> recommendedFungicides;
  final String additionalNotes;

  const TreatmentHistoryTile({
    super.key,
    required this.date,
    required this.recommendedFungicides,
    required this.additionalNotes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MoldifyColors.taupe,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date
          Text(
            date,
            style: TextStyle(
              color: MoldifyColors.MoldifyGrey,
              fontSize: 12,
              fontFamily: 'Bricolage-Grotesque-Regular',
            ),
          ),

          // Recommended Fungicides
          const Text(
            'Recommended Fungicides',
            style: TextStyle(
              fontFamily: 'Bricolage-Grotesque-SemiBold',
              color: MoldifyColors.primaryColor,
              fontSize: 16
            ),
          ),
          const SizedBox(height: 6),

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

          const SizedBox(height: 12),

          // Additional Notes
          const Text(
            'Additional Notes',
            style: TextStyle(
                fontFamily: 'Bricolage-Grotesque-SemiBold',
                color: MoldifyColors.primaryColor,
                fontSize: 16
            ),
          ),
          const SizedBox(height: 4),
          Text(
            additionalNotes,
            style: const TextStyle(
                height: 1.4,
                fontFamily: 'Bricolage-Grotesque-Regular',
                fontSize: 16,
                color: MoldifyColors.MoldifyBlack
            ),
          ),
        ],
      ),
    );
  }
}
