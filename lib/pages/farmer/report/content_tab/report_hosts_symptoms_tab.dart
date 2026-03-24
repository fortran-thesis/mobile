import 'package:flutter/material.dart';
import '../../../misc/colors.dart';

class ReportHostsSymptomsTab extends StatelessWidget {
  final String affectedHosts;
  final String symptomsSigns;
  final String inOnions;
  final String inPostharvestFruit;

  const ReportHostsSymptomsTab({
    super.key,
    required this.affectedHosts,
    required this.symptomsSigns,
    required this.inOnions,
    required this.inPostharvestFruit,
  });

  Widget _buildSection({
    required String title,
    required String content,
    bool isLast = false,
  }) {
    final bool hasData = content.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 40.0 : 48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Minimalist Architectural Header
          Row(
            children: [
              Container(
                width: 40,
                height: 2,
                color: MoldifyColors.accentColor, // The subtle accent spark
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 2.2,
                    fontFamily: 'Montserrat-Black',
                    color: MoldifyColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 2. High-Legibility Justified Body
          Text(
            hasData ? content : 'Observation data pending...',
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Bricolage-Grotesque-Regular',
              color: hasData 
                  ? MoldifyColors.MoldifyBlack.withValues(alpha: 0.85) 
                  : MoldifyColors.MoldifyGrey,
              height: 1.6,
            ),
          ),
          
          // 3. Hairline Separation
          if (!isLast) ...[
            Divider(
              color: MoldifyColors.taupe.withValues(alpha: 0.2),
              thickness: 1,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Consistent asymmetric padding
      padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 60.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'Affected Crops / Hosts', 
            content: affectedHosts
          ),
          _buildSection(
            title: 'Symptoms & Signs', 
            content: symptomsSigns
          ),
          _buildSection(
            title: 'Signs in Onions', 
            content: inOnions
          ),
          _buildSection(
            title: 'Postharvest Fruit Conditions', 
            content: inPostharvestFruit, 
            isLast: true
          ),
        ],
      ),
    );
  }
}