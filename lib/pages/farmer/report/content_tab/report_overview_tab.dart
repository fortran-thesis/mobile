import 'package:flutter/material.dart';
import '../../../misc/colors.dart';

class ReportOverviewTab extends StatelessWidget {
  final String overview;
  final String description;
  final String healthRisk;

  const ReportOverviewTab({
    super.key,
    required this.overview,
    required this.description,
    required this.healthRisk,
  });

  Widget _buildSection({
    required String title,
    required String content,
    bool isLast = false,
  }) {
    final bool hasData = content.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 24.0 : 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Thin Header Line with Accent
          Row(
            children: [
              Container(
                width: 40,
                height: 2,
                color: MoldifyColors.accentColor, 
              ),
              const SizedBox(width: 12),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 2.5,
                  fontFamily: 'Montserrat-Black',
                  color: MoldifyColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          // 2. Justified Body Text
          Text(
            hasData ? content : 'Information currently unavailable.',
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 18, // Large, clear, and professional
              fontFamily: 'Bricolage-Grotesque-Regular',
              color: hasData 
                  ? MoldifyColors.MoldifyBlack.withValues(alpha: 0.85) 
                  : MoldifyColors.MoldifyGrey,
              height: 1.6, // Spacious line height
            ),
          ),
          
          // 3. Bottom Hairline Divider (except for the last section)
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
            title: 'Overview', 
            content: overview,
          ),
          _buildSection(
            title: 'Detailed Description', 
            content: description,
          ),
          _buildSection(
            title: 'Health & Safety Risk', 
            content: healthRisk,
            isLast: true,
          ),
        ],
      ),
    );
  }
}