import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/colors.dart';

class CultureModel {
  final String id;
  final String name;
  final String remainingTime;

  CultureModel({
    required this.id,
    required this.name,
    required this.remainingTime,
  });
}

final List<CultureModel> dummyCultures = [
  CultureModel(
    id: '1',
    name: "Tomato Sample A",
    remainingTime: "2 Days",
  ),
  CultureModel(
    id: '2',
    name: "Fusarium Plate 2",
    remainingTime: "Ready",
  ),
  CultureModel(
    id: '3',
    name: "Root Sample",
    remainingTime: "5 Days",
  ),
];

class CultureDashboard extends StatelessWidget {
  const CultureDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: const PrimaryAppBar(title: "Active Incubation Timer"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Active Incubation Timer",
                  style: TextStyle(
                    fontFamily: 'Montserrat-Black',
                    fontSize: 36,
                    height: 1.1,
                    letterSpacing: -2,
                    color: MoldifyColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "Monitor your ongoing growth samples and track time remaining for each culture timer.",
                  style: TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    fontSize: 16,
                    height: 1.5,
                    color: MoldifyColors.MoldifyBlack,
                  ),
                ),
              ],
            ),
          ),

          // Dynamic List Section
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              itemCount: dummyCultures.length,
              itemBuilder: (context, index) {
                return _buildCultureCard(dummyCultures[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCultureCard(CultureModel culture) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MoldifyColors.taupe.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: MoldifyColors.primaryColor.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            culture.name,
            style: const TextStyle(
              fontFamily: 'Bricolage-Grotesque-Bold',
              fontSize: 22,
              letterSpacing: -0.5,
              color: MoldifyColors.primaryColor,
            ),
          ),
          const SizedBox(height: 30),
          _buildStat("REMAINING", culture.remainingTime),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String val) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Bricolage-Grotesque-Bold',
              fontSize: 10,
              letterSpacing: 1,
              color: MoldifyColors.MoldifyGrey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            val,
            style: const TextStyle(
              fontFamily: 'Bricolage-Grotesque-SemiBold',
              fontSize: 18,
              color: MoldifyColors.primaryColor,
            ),
          ),
        ],
      );
}