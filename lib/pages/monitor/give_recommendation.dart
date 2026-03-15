import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/textboxes/dropdwon.dart';
import 'package:moldify/pages/misc/textboxes/textboxes.dart';
import 'package:moldify/pages/misc/tiles/expansion_tile.dart';


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

  String _screenTitle = 'Give Recommendation';
  String _screenSubtitle = 'Finalize the entry and review the diagnostic overview';

  final Map<String, String> _analysisSections = {
    'OVERVIEW': '',
    'DESCRIPTION': '',
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
        for (final key in _analysisSections.keys.toList()) {
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
            /// ----------- Identification History Header -----------
              Text(
                  _screenTitle,
                  style: TextStyle(
                    fontSize: 36,
                    fontFamily: 'Montserrat-Black',
                    color: MoldifyColors.primaryColor,
                  )
              ),
              Text(
                  _screenSubtitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    color: MoldifyColors.MoldifyBlack,
                  )
              ),
            const SizedBox(height: 20),

            // --- INPUT SECTION ---
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

            const SizedBox(height: 40),
            
            // --- REVISED RESULTS HEADER ---
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
                  entry.value.isNotEmpty ? entry.value : 'No data available yet.',
                ),
              ),
            

            // --- MANAGEMENT CONTROLS HEADER ---
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

  // --- COMPONENT BUILDERS ---

 
  /// **Major Section Headers** (Revised Results / IPM Controls)
  /// Purpose: Create high-visibility anchors for the editorial layout.
  Widget _buildMajorSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Bricolage-Grotesque-Bold',
            fontSize: 18, // Significantly larger for hierarchy
            letterSpacing: 0.5,
            color: MoldifyColors.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(thickness: 1.5, color: MoldifyColors.primaryColor),
      ],
    );
  }

  Widget _buildIPMControls() {
    return Column(
      children: _managementControls.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: index == _managementControls.length - 1 ? 0 : 12),
          child: CustomExpansionTile(
            title: item['title'] ?? '',
            content: (item['content'] ?? '').isNotEmpty
                ? item['content']!
                : 'No recommendation available yet.',
          ),
        );
      }).toList(),
    );
  }

  /// Individual detail blocks within the report.
  Widget _buildTextSection(String label, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Bricolage-Grotesque-Bold',
              fontSize: 12,
              letterSpacing: 1.0,
              color: MoldifyColors.primaryColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              fontFamily: 'Bricolage-Grotesque-Regular',
              fontSize: 16,
              height: 1.6,
              color: MoldifyColors.MoldifyBlack.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  /// Small labels for Input fields.
  Widget _buildFormLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Bricolage-Grotesque-Bold',
        fontSize: 12,
        letterSpacing: 1.5,
        color: MoldifyColors.primaryColor.withOpacity(0.5),
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
        fontSize: 16, // Balanced with the new header sizes
        backgroundColor: MoldifyColors.primaryColor,
        textColor: MoldifyColors.backgroundColor,
        buttonHeight: 56,
        buttonRadius: 12,
      ),
    );
  }
}