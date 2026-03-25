import 'package:flutter/material.dart';
import '../../../misc/colors.dart';

class ReportDiseaseCycleImpactTab extends StatelessWidget {
  final String diseaseCycleSpread;
  final String infectionMechanism;
  final String soilInoculum;
  final String onPeanuts;
  final String mycotoxinRisk;
  final String impact;

  const ReportDiseaseCycleImpactTab({
    super.key,
    required this.diseaseCycleSpread,
    required this.infectionMechanism,
    required this.soilInoculum,
    required this.onPeanuts,
    required this.mycotoxinRisk,
    required this.impact,
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
          // 1. Architectural Accent Header
          Row(
            children: [
              Container(
                width: 40,
                height: 2,
                color: MoldifyColors.accentColor,
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

          // 2. High-Readability Justified Content
          Text(
            hasData ? content : 'Scientific data pending review...',
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

          // 3. Section Separation Line
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
      padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 60.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'Disease Cycle / Spread', 
            content: diseaseCycleSpread
          ),
          _buildSection(
            title: 'Infection Mechanism', 
            content: infectionMechanism
          ),
          _buildSection(
            title: 'Soil Inoculum Details', 
            content: soilInoculum
          ),
          _buildSection(
            title: 'Peanut-Specific Impact', 
            content: onPeanuts
          ),
          _buildSection(
            title: 'Mycotoxin Risk Assessment', 
            content: mycotoxinRisk
          ),
          _buildSection(
            title: 'Overall Impact', 
            content: impact, 
            isLast: true
          ),
        ],
      ),
    );
  }
}