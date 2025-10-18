import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/colors.dart';

/// A widget that displays a donut chart representing case statuses.
/// It takes a map of status labels to their corresponding values.
/// Parameters:
/// - [statusData]: A map where keys are status labels (e.g., 'Resolved', 'Pending', 'In Progress')
///  and values are their corresponding numeric values.
/// Example usage:
/// StatusDonutChart(
/// statusData: {
/// 'Resolved': 40,
/// 'Pending': 30,
/// 'In Progress': 20,
/// },
/// );

class StatusDonutChart extends StatelessWidget {
  final Map<String, double> statusData;

  const StatusDonutChart({super.key, required this.statusData});

  @override
  Widget build(BuildContext context) {
    final totalCases = statusData.values.fold(0.0, (a, b) => a + b);

    final List<PieChartSectionData> sections = totalCases == 0
        ? [
      PieChartSectionData(
        color: MoldifyColors.MoldifyGrey,
        value: 1,
        radius: 38,
        showTitle: false,
      ),
    ]
        : statusData.entries.map((entry) {
      final color = _getColorForStatus(entry.key);
      return PieChartSectionData(
        color: color,
        value: entry.value,
        radius: 38,
        showTitle: false,
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: MoldifyColors.taupe,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Donut Chart with Center Text
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 140,
                width: 140,
                child: PieChart(
                  PieChartData(
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 0,
                    centerSpaceRadius: 45, // adjust for bigger center hole
                    sections: sections,
                  ),
                ),
              ),
              // Center Label
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    totalCases.toInt().toString(),
                    style: const TextStyle(
                      fontFamily: 'Montserrat-Black',
                      fontSize: 20,
                      color: MoldifyColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Total Cases',
                    style: TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Regular',
                      fontSize: 12,
                      color: MoldifyColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 24),

          // Legend
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: statusData.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getColorForStatus(entry.key),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.value.toInt()} - ${entry.key}',
                      style: const TextStyle(
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        fontSize: 14,
                        color: Color(0xFF2F3A1D),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getColorForStatus(String status) {
    switch (status) {
      case 'Resolved':
        return MoldifyColors.primaryColor;
      case 'Pending':
        return MoldifyColors.accentColor;
      case 'In Progress':
        return MoldifyColors.MoldifyBlue;
      default:
        return Colors.grey;
    }
  }
}
