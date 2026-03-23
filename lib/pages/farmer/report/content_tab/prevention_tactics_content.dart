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
      'MECHANICAL': Icons.settings_suggest_outlined,
      'BIOLOGICAL': Icons.biotech_outlined,
      'CHEMICAL': Icons.science_outlined,
      'PHYSICAL': Icons.build_outlined,
      'CULTURAL': Icons.agriculture_outlined,
    };
    return iconMap[type.toUpperCase()] ?? Icons.medical_services_outlined;
  }

  /// Parse structured treatment format: TYPE::Title::Description|TYPE::...
  List<Widget> _buildTreatmentTiles(String content) {
    if (content.isEmpty) return [];
    
    if (content.contains(_fieldDelimiter)) {
      final treatments = content
          .split(_stageDelimiter)
          .where((s) => s.trim().isNotEmpty)
          .toList();
      
      final widgets = <Widget>[];
      for (final treatment in treatments) {
        final parts = treatment.split(_fieldDelimiter);
        if (parts.length >= 3) {
          final type = parts[0].toUpperCase();
          final title = parts[1];
          final desc = parts[2];
          final icon = _getIconForTreatmentType(type);
          
          widgets.add(
            ControlManagementTile(
              title: title,
              icon: icon,
              description: desc,
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