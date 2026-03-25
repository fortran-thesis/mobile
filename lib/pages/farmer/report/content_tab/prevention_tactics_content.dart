import 'package:flutter/material.dart';
import '../../../misc/colors.dart';
import '../../../misc/tiles/control_management_tile.dart';

class PreventionTacticsContent extends StatelessWidget {
  final String treatmentsContent;
  
  // Parsing delimiters for structured data (same as WikiMold)
  static const String _stageDelimiter = '|';
  static const String _fieldDelimiter = '::';

  const PreventionTacticsContent({
    super.key,
    required this.treatmentsContent,
  });

  /// Icon mapping for different treatment types
  IconData _getIconForTreatmentType(String type) {
    const iconMap = {
      'PREVENTION': Icons.shield_outlined,
      'MECHANICAL': Icons.settings_suggest_outlined,
      'BIOLOGICAL': Icons.biotech_outlined,
      'CHEMICAL': Icons.science_outlined,
      'PHYSICAL': Icons.build_outlined,
      'CULTURAL': Icons.agriculture_outlined,
    };
    return iconMap[type.toUpperCase()] ?? Icons.medical_services_outlined;
  }

  List<Map<String, String>> _parseStructuredTreatments(String content) {
    if (!content.contains(_fieldDelimiter)) return const [];

    final treatments = content
        .split(_stageDelimiter)
        .where((s) => s.trim().isNotEmpty)
        .toList();

    final entries = <Map<String, String>>[];
    final seenKeys = <String>{};
    for (final treatment in treatments) {
      final parts = treatment.split(_fieldDelimiter);
      if (parts.length < 3) continue;

      final type = parts[0].toUpperCase().trim();
      final title = parts[1].trim();
      final desc = parts.sublist(2).join(_fieldDelimiter).trim();
      if (title.isEmpty || desc.isEmpty) continue;

      final key = '$type::${title.toLowerCase()}';
      if (!seenKeys.add(key)) continue;

      entries.add({
        'type': type,
        'title': title,
        'desc': desc,
      });
    }
    return entries;
  }

  /// Parse structured treatment format: TYPE::Title::Description|TYPE::...
  List<Widget> _buildTreatmentTiles(String content) {
    if (content.isEmpty) return [];

    final structured = _parseStructuredTreatments(content);
    if (structured.isNotEmpty) {
      final widgets = <Widget>[];

      final preventionSections = structured
          .where((e) => e['type'] == 'PREVENTION')
          .toList();

      final controlOrder = <String>[
        'MECHANICAL',
        'CULTURAL',
        'BIOLOGICAL',
        'PHYSICAL',
        'CHEMICAL',
      ];
      final controlsByType = <String, Map<String, String>>{};
      for (final entry in structured) {
        final type = entry['type'] ?? '';
        if (!controlOrder.contains(type)) continue;
        controlsByType.putIfAbsent(type, () => entry);
      }

      for (final section in preventionSections) {
        widgets.add(
          ControlManagementTile(
            title: section['title']!,
            icon: _getIconForTreatmentType(section['type']!),
            description: section['desc']!,
          ),
        );
      }

      if (controlsByType.isNotEmpty) {
        widgets.add(const SizedBox(height: 14));
        widgets.add(
          const Text(
            '5 CONTROL TREATMENTS',
            style: TextStyle(
              fontFamily: 'Bricolage-Grotesque-Bold',
              fontSize: 10,
              letterSpacing: 1.4,
              color: MoldifyColors.primaryColor,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 10));

        for (final type in controlOrder) {
          final entry = controlsByType[type];
          if (entry == null) continue;
          widgets.add(
            ControlManagementTile(
              title: entry['title']!,
              icon: _getIconForTreatmentType(type),
              description: entry['desc']!,
            ),
          );
        }
      }

      return widgets;
    }

    // Fallback: render plain text as generic treatment card
    return [
      ControlManagementTile(
        title: 'Treatment Recommendations',
        icon: Icons.medical_services_outlined,
        description: content.replaceAll(RegExp(r'<[^>]*>'), ''),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final controlMethods = _buildTreatmentTiles(treatmentsContent);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          const Text(
            'Prevention Tactics',
            style: TextStyle(
              fontFamily: 'Montserrat-Black',
              fontSize: 20,
              color: MoldifyColors.primaryColor,
            ),
          ),
          const Text(
            'Comprehensive mold control management strategies.',
            style: TextStyle(
              fontFamily: 'Bricolage-Grotesque-Regular',
              fontSize: 12,
              color: MoldifyColors.MoldifyGrey,
            ),
          ),
          const SizedBox(height: 20),

          /// Control Management Tiles
          if (controlMethods.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No prevention tactics available',
                  style: TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    fontSize: 14,
                    color: MoldifyColors.MoldifyGrey,
                  ),
                ),
              ),
            )
          else
            ...controlMethods,
        ],
      ),
    );
  }
}