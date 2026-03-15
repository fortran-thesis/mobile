import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/textboxes/dropdwon.dart';
import 'package:moldify/pages/misc/textboxes/textboxes.dart';
import 'package:moldify/pages/misc/tiles/control_management_tile.dart';

class GiveRecommendationScreen extends StatefulWidget {
  const GiveRecommendationScreen({super.key});

  @override
  State<GiveRecommendationScreen> createState() => _GiveRecommendationScreenState();
}

class _GiveRecommendationScreenState extends State<GiveRecommendationScreen> {
  final TextEditingController _diseaseController = TextEditingController();
  String? _selectedGenus;
  bool _didInitialize = false;
  bool _isLoading = false;
  String? _reportId;
  String? _caseId;

  final String _screenTitle = 'Give Recommendation';
  final String _screenSubtitle = 'Finalize the entry and review the diagnostic overview';

  /// Standard sections including HEALTH RISKS
  final Map<String, String> _analysisSections = {
    'OVERVIEW': '',
    'DESCRIPTION': '',
    'HEALTH RISKS': '',
    'AFFECTED CROPS / HOSTS': '',
    'SYMPTOMS & SIGNS': '',
    'DISEASE CYCLE / SPREAD': '',
    'IMPACT': '',
    'PREVENTION': '',
  };

  final List<Map<String, String>> _managementControls = [];

  static const List<String> _genusOptions = [
    'Fusarium',
    'Aspergillus',
    'Penicillium',
    'Botrytis',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitialize) return;
    _didInitialize = true;
    _initializeFromArgs();
  }

  void _initializeFromArgs() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _reportId = args['reportId']?.toString();
      _caseId = args['caseId']?.toString();
      _diseaseController.text = args['diseaseName']?.toString() ?? '';
      _selectedGenus = args['genus']?.toString();

      final Map<String, dynamic>? analysis = args['analysis'] as Map<String, dynamic>?;
      
      if (analysis != null) {
        // Map all standard sections from the analysis payload
        for (final key in _analysisSections.keys) {
          _analysisSections[key] = analysis[key]?.toString() ?? '';
        }

       
      }

      

      final List<dynamic>? controls = args['managementControls'] as List<dynamic>?;
      if (controls != null) {
        _managementControls
          ..clear()
          ..addAll(
            controls.whereType<Map>().map(
              (item) => {
                'title': item['title']?.toString() ?? '',
                'content': item['content']?.toString() ?? '',
              },
            ),
          );
      }
    }

    if (_managementControls.isEmpty) {
      _managementControls.addAll([
        {'title': 'Physical Control', 'content': ''},
        {'title': 'Cultural Control', 'content': ''},
        {'title': 'Biological Control', 'content': ''},
        {'title': 'Mechanical Control', 'content': ''},
        {'title': 'Chemical Control', 'content': ''},
      ]);
    }
  }

  String? _readKeyVariants(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      if (source.containsKey(key) && source[key].toString().isNotEmpty) {
        return source[key].toString();
      }
    }
    return null;
  }

  @override
  void dispose() {
    _diseaseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: const PrimaryAppBar(title: "Give Recommendation"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _screenTitle,
              style: const TextStyle(
                fontSize: 36,
                fontFamily: 'Montserrat-Black',
                color: MoldifyColors.primaryColor,
              )
            ),
            Text(
              _screenSubtitle,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Bricolage-Grotesque-Regular',
                color: MoldifyColors.MoldifyBlack,
              )
            ),
            const SizedBox(height: 40),

            _buildFormLabel("DISEASE NAME"),
            const SizedBox(height: 12),
            BuildTextBox(
              hintText: "Enter disease name...",
              controller: _diseaseController,
              showPassword: false,
              fontSize: 16,
            ),
            const SizedBox(height: 35),

            _buildFormLabel("GENUS CLASSIFICATION"),
            const SizedBox(height: 12),
            BuildDropdown(
              hintText: "Select Genus",
              items: _genusOptions,
              initialValue: _selectedGenus,
              onChanged: (val) => setState(() => _selectedGenus = val),
            ),

            const SizedBox(height: 50),
            
            _buildMajorSectionHeader("REVISED RESULTS ANALYSIS"),
            const SizedBox(height: 30),
            
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(color: MoldifyColors.primaryColor),
                ),
              )
            else
              ..._analysisSections.entries.map(
                (entry) => _buildTextSection(
                  entry.key,
                  entry.value.trim().isNotEmpty ? entry.value : 'No data available yet.',
                  isWarning: entry.key == 'HEALTH RISKS',
                ),
              ),
            
            _buildMajorSectionHeader("INTEGRATED MANAGEMENT CONTROLS"),
            const SizedBox(height: 25),
            
            _buildIPMControls(),

            const SizedBox(height: 60),
            _buildFooterAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildMajorSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Bricolage-Grotesque-Bold',
            fontSize: 18,
            letterSpacing: 0.5,
            color: MoldifyColors.primaryColor.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(thickness: 1.5, color: MoldifyColors.primaryColor),
      ],
    );
  }

  Widget _buildIPMControls() {
    IconData iconForTitle(String title) {
      final normalized = title.toLowerCase();
      if (normalized.contains('mechanical')) return Icons.settings_suggest_outlined;
      if (normalized.contains('biological')) return Icons.biotech_outlined;
      if (normalized.contains('chemical')) return Icons.science_outlined;
      if (normalized.contains('physical')) return Icons.build_outlined;
      if (normalized.contains('cultural')) return Icons.agriculture_outlined;
      return Icons.medical_services_outlined;
    }

    return Column(
      children: _managementControls.asMap().entries.map((entry) {
        final item = entry.value;
        return ControlManagementTile(
          title: item['title'] ?? '',
          description: (item['content'] ?? '').isNotEmpty
              ? item['content']!
              : 'No recommendation available yet.',
          icon: iconForTitle(item['title'] ?? ''),
        );
      }).toList(),
    );
  }

  Widget _buildTextSection(String label, String body, {bool isWarning = false}) {
    // If the body is the fallback text, we don't want the "warning" color/icon 
    // because there isn't actually a risk identified yet.
    final bool showWarningStyle = isWarning && body != 'No data available yet.';

    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Bricolage-Grotesque-Bold',
                  fontSize: 12,
                  letterSpacing: 1.0,
                  color: showWarningStyle 
                    ? Colors.redAccent.withValues(alpha: 0.8) 
                    : MoldifyColors.primaryColor.withValues(alpha: 0.7),
                ),
              ),
              if (showWarningStyle) ...[
                const SizedBox(width: 8),
                const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.redAccent),
              ]
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              fontFamily: 'Bricolage-Grotesque-Regular',
              fontSize: 16,
              height: 1.6,
              color: MoldifyColors.MoldifyBlack.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Bricolage-Grotesque-Bold',
        fontSize: 12,
        letterSpacing: 1.5,
        color: MoldifyColors.primaryColor.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildFooterAction() {
    return SizedBox(
      width: double.infinity,
      child: BuildButton(
        onPressed: () {
          Navigator.of(context).pop(true);
        },
        buttonText: 'Confirm Diagnosis',
        fontSize: 16,
        backgroundColor: MoldifyColors.primaryColor,
        textColor: MoldifyColors.backgroundColor,
        buttonHeight: 56,
        buttonRadius: 12,
      ),
    );
  }
}