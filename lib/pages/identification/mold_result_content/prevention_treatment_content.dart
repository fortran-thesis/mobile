import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../misc/colors.dart';
import '../../misc/tiles/control_management_tile.dart';

class PreventionTreatmentContent extends StatefulWidget {
  final String treatmentsContent;
  
  // Parsing delimiters for structured data (same as WikiMold)
  static const String _stageDelimiter = '|';
  static const String _fieldDelimiter = '::';

  const PreventionTreatmentContent({
    super.key,
    required this.treatmentsContent,
  });

  @override
  State<PreventionTreatmentContent> createState() =>
      _PreventionTreatmentContentState();
}

class _PreventionTreatmentContentState
    extends State<PreventionTreatmentContent> {
  
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
    
    if (content.contains(PreventionTreatmentContent._fieldDelimiter)) {
      final treatments = content
          .split(PreventionTreatmentContent._stageDelimiter)
          .where((s) => s.trim().isNotEmpty)
          .toList();
      
      final widgets = <Widget>[];
      for (final treatment in treatments) {
        final parts = treatment.split(PreventionTreatmentContent._fieldDelimiter);
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
    final controlMethods = _buildTreatmentTiles(widget.treatmentsContent);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controlMethods.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: AutoSizeText(
                  'No prevention tactics available',
                  style: TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    fontSize: 14,
                    color: MoldifyColors.MoldifyGrey,
                  ),
                  minFontSize: 10,
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
