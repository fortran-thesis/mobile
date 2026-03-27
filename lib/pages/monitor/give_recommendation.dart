import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/textboxes/dropdwon.dart';
import 'package:moldify/pages/misc/textboxes/textboxes.dart';
import 'package:moldify/pages/misc/tiles/control_management_tile.dart';
import 'package:provider/provider.dart';
import '../../core/features/mold/service/mold_service.dart';
import '../../core/features/mold_case/service/mold_case_service.dart';
import '../../core/features/wikimold/models/wikimold.dart';
import '../../core/features/wikimold/services/wikimold_services.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/route_names.dart';
import '../../core/utils/mutation_result.dart';

class GiveRecommendationScreen extends StatefulWidget {
  const GiveRecommendationScreen({super.key});

  @override
  State<GiveRecommendationScreen> createState() =>
      _GiveRecommendationScreenState();
}

class _GiveRecommendationScreenState extends State<GiveRecommendationScreen> {
  final TextEditingController _diseaseController = TextEditingController();
  String? _selectedGenus;
  String? _selectedMoldId;
  bool _didInitialize = false;
  bool _isLoading = false;
  bool _isLoadingMoldOptions = false;
  String? _caseId;
  String? _suggestedMoldId;
  String? _suggestedMoldName;
  double? _suggestedConfidence;
  String? _moldOptionsError;
  int _dropdownKey = 0;
  final List<String> _genusOptions = [];
  final Map<String, MoldCatalogEntry> _moldCatalogByName = {};
  final Map<String, MoldCatalogEntry> _moldCatalogById = {};
  final Map<String, String> _baseAnalysisSections = {};
  final List<Map<String, String>> _baseManagementControls = [];

  final String _screenTitle = 'Give Recommendation';
  final String _screenSubtitle =
      'Finalize the entry and review the diagnostic overview';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitialize) return;
    _didInitialize = true;
    _initializeFromArgs();
    _loadMoldOptions();
  }

  Future<void> _loadMoldOptions() async {
    setState(() {
      _isLoadingMoldOptions = true;
      _moldOptionsError = null;
    });

    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final service = MoldService();
      final catalog = await service.fetchAllMoldCatalog(
        sessionCookie: authProvider.cookie,
      );

      if (!mounted) return;

      setState(() {
        _moldCatalogByName.clear();
        _moldCatalogById.clear();

        for (final mold in catalog) {
          if (mold.name.trim().isEmpty) continue;

          final key = mold.name.toLowerCase();
          _moldCatalogByName[key] = mold;

          if (mold.id.trim().isNotEmpty) {
            _moldCatalogById[mold.id.trim()] = mold;
          }
        }

        _genusOptions
          ..clear()
          ..addAll(
            _moldCatalogByName.values.map((entry) => entry.name).toList()
              ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())),
          )
          ..add('+ Add New Mold');

        if (_selectedGenus != null && !_genusOptions.contains(_selectedGenus)) {
          _selectedGenus = null;
          _selectedMoldId = null;
          _restoreBaseMoldDetails();
        }

        if ((_selectedGenus == null || _selectedGenus!.trim().isEmpty) &&
            _suggestedMoldId != null &&
            _suggestedMoldId!.trim().isNotEmpty) {
          final suggested = _moldCatalogById[_suggestedMoldId!.trim()];
          if (suggested != null) {
            _selectedGenus = suggested.name;
            _selectedMoldId = suggested.id;
            _applyCatalogDetails(suggested);
          }
        }

        if (_selectedGenus != null && _selectedGenus!.trim().isNotEmpty) {
          final selected =
              _moldCatalogByName[_selectedGenus!.trim().toLowerCase()];
          if (selected != null) {
            _selectedMoldId = selected.id;
            _applyCatalogDetails(selected);
          }
        }

        if (_genusOptions.isEmpty) {
          _moldOptionsError =
              'No mold options available in this environment yet. Seed mold data first.';
        }

        _isLoadingMoldOptions = false;
      });
    } catch (e) {
      if (!mounted) return;
      final errorText = e.toString().toLowerCase();
      setState(() {
        _isLoadingMoldOptions = false;
        _moldOptionsError = errorText.contains('http 404')
            ? 'No mold options found. Seed mold records in this environment first.'
            : 'Unable to load mold options right now.';
      });
    }
  }

  String _normalizeLabel(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  }

  String _firstAdditionalInfoMatch(
    MoldCatalogEntry entry,
    List<String> aliases,
  ) {
    final normalizedAliases = aliases.map(_normalizeLabel).toList();
    for (final item in entry.additionalInfo.entries) {
      final normalizedTitle = _normalizeLabel(item.key);
      for (final alias in normalizedAliases) {
        if (normalizedTitle == alias || normalizedTitle.contains(alias)) {
          if (item.value.trim().isNotEmpty) {
            return item.value.trim();
          }
        }
      }
    }
    return '';
  }

  List<Map<String, String>> _buildControlsFromCatalog(MoldCatalogEntry entry) {
    String readControl(String title) => entry.prevention[title]?.trim() ?? '';

    return [
      {'title': 'Physical Control', 'content': readControl('Physical Control')},
      {'title': 'Cultural Control', 'content': readControl('Cultural Control')},
      {
        'title': 'Biological Control',
        'content': readControl('Biological Control'),
      },
      {
        'title': 'Mechanical Control',
        'content': readControl('Mechanical Control'),
      },
      {'title': 'Chemical Control', 'content': readControl('Chemical Control')},
    ];
  }

  void _applyCatalogDetails(MoldCatalogEntry entry) {
    final controls = _buildControlsFromCatalog(entry);
    final preventionSummary = controls
        .where((control) => (control['content'] ?? '').trim().isNotEmpty)
        .map((control) => '${control['title']}: ${control['content']}')
        .join('\n\n');

    _analysisSections['OVERVIEW'] = entry.overview.trim().isNotEmpty
        ? entry.overview.trim()
        : _firstAdditionalInfoMatch(entry, ['overview']);
    _analysisSections['DESCRIPTION'] = entry.description.trim().isNotEmpty
        ? entry.description.trim()
        : _firstAdditionalInfoMatch(entry, ['description']);
    _analysisSections['HEALTH RISKS'] = entry.healthRisks.trim().isNotEmpty
        ? entry.healthRisks.trim()
        : _firstAdditionalInfoMatch(entry, ['health risks', 'risk']);
    _analysisSections['AFFECTED CROPS / HOSTS'] =
        entry.affectedHosts.trim().isNotEmpty
        ? entry.affectedHosts.trim()
        : _firstAdditionalInfoMatch(entry, [
            'affected crops',
            'hosts',
            'affected hosts',
          ]);
    _analysisSections['SYMPTOMS & SIGNS'] =
        entry.symptomsAndSigns.trim().isNotEmpty
        ? entry.symptomsAndSigns.trim()
        : _firstAdditionalInfoMatch(entry, ['symptoms', 'signs']);
    _analysisSections['DISEASE CYCLE / SPREAD'] =
        entry.diseaseCycleSpreadImpact.trim().isNotEmpty
        ? entry.diseaseCycleSpreadImpact.trim()
        : _firstAdditionalInfoMatch(entry, ['disease cycle', 'spread']);
    _analysisSections['IMPACT'] = _firstAdditionalInfoMatch(entry, ['impact']);
    _analysisSections['PREVENTION'] = preventionSummary.isNotEmpty
        ? preventionSummary
        : entry.preventionSummary.trim();

    _managementControls
      ..clear()
      ..addAll(controls);
  }

  void _restoreBaseMoldDetails() {
    _analysisSections
      ..clear()
      ..addAll(_baseAnalysisSections);

    _managementControls
      ..clear()
      ..addAll(_baseManagementControls);
  }

  void _handleMoldSelectionChanged(String? selectedName) {
    if (selectedName == '+ Add New Mold') {
      _navigateToCreateMold();
      return;
    }

    setState(() {
      _selectedGenus = selectedName;

      if (selectedName == null || selectedName.trim().isEmpty) {
        _selectedMoldId = null;
        _restoreBaseMoldDetails();
        return;
      }

      final selected = _moldCatalogByName[selectedName.trim().toLowerCase()];
      if (selected == null) {
        _selectedMoldId = null;
        _restoreBaseMoldDetails();
        return;
      }

      _selectedMoldId = selected.id;
      _applyCatalogDetails(selected);
    });
  }

  Future<void> _navigateToCreateMold() async {
    // Reset dropdown so "+ Add New Mold" doesn't stay selected
    setState(() => _dropdownKey++);

    final result = await Navigator.of(context).pushNamed(RouteNames.createMold);
    if (result is! MoldCatalogEntry || !mounted) return;

    // Add to local catalog maps
    setState(() {
      final entry = result;
      final key = entry.name.toLowerCase();
      _moldCatalogByName[key] = entry;
      if (entry.id.trim().isNotEmpty) _moldCatalogById[entry.id.trim()] = entry;

      _genusOptions
        ..clear()
        ..addAll(
          _moldCatalogByName.values.map((e) => e.name).toList()
            ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())),
        )
        ..add('+ Add New Mold');

      _selectedGenus = entry.name;
      _selectedMoldId = entry.id;
      _dropdownKey++;
      _applyCatalogDetails(entry);
    });
  }

  void _initializeFromArgs() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _caseId = args['caseId']?.toString();
      _suggestedMoldId = args['suggestedMoldId']?.toString();
      _suggestedMoldName = args['suggestedMoldName']?.toString();
      final suggestedConfidenceRaw = args['suggestedConfidence'];
      if (suggestedConfidenceRaw is num) {
        _suggestedConfidence = suggestedConfidenceRaw.toDouble();
      } else {
        _suggestedConfidence = double.tryParse(
          suggestedConfidenceRaw?.toString() ?? '',
        );
      }
      _diseaseController.text = args['diseaseName']?.toString() ?? '';
      _selectedGenus = args['genus']?.toString();
      _selectedMoldId = _suggestedMoldId;

      if ((_selectedGenus == null || _selectedGenus!.trim().isEmpty) &&
          _suggestedMoldName != null &&
          _suggestedMoldName!.trim().isNotEmpty) {
        _selectedGenus = _suggestedMoldName!.trim();
      }

      final Map<String, dynamic>? analysis =
          args['analysis'] as Map<String, dynamic>?;

      if (analysis != null) {
        // Map all standard sections from the analysis payload
        for (final key in _analysisSections.keys) {
          _analysisSections[key] = analysis[key]?.toString() ?? '';
        }
      }

      final List<dynamic>? controls =
          args['managementControls'] as List<dynamic>?;
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

    _baseAnalysisSections
      ..clear()
      ..addAll(_analysisSections);

    _baseManagementControls
      ..clear()
      ..addAll(
        _managementControls.map((entry) => Map<String, String>.from(entry)),
      );
  }

  Future<String?> _resolveMoldipediaId(
    String moldName,
    String? sessionCookie,
  ) async {
    if (moldName.trim().isEmpty ||
        sessionCookie == null ||
        sessionCookie.isEmpty) {
      return null;
    }

    try {
      final wikiService = WikiService();
      final result = await wikiService.searchMoldipedia(
        search: moldName,
        limit: 20,
        sessionCookie: sessionCookie,
      );

      final rawArticles = result['articles'];
      if (rawArticles is! List) return null;

      final articles = rawArticles.whereType<WikiArticle>().toList();
      if (articles.isEmpty) return null;

      final target = _normalizeLabel(moldName);
      final exactMatch = articles.where(
        (article) => _normalizeLabel(article.title) == target,
      );
      if (exactMatch.isNotEmpty) return exactMatch.first.id;

      final titleContains = articles.where(
        (article) => _normalizeLabel(article.title).contains(target),
      );
      if (titleContains.isNotEmpty) return titleContains.first.id;

      final tagMatch = articles.where(
        (article) =>
            article.tags.any((tag) => _normalizeLabel(tag).contains(target)),
      );
      if (tagMatch.isNotEmpty) return tagMatch.first.id;

      return articles.first.id;
    } catch (_) {
      return null;
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
            Text(
              _screenTitle,
              style: const TextStyle(
                fontSize: 36,
                fontFamily: 'Montserrat-Black',
                color: MoldifyColors.primaryColor,
              ),
            ),
            Text(
              _screenSubtitle,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Bricolage-Grotesque-Regular',
                color: MoldifyColors.MoldifyBlack,
              ),
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
            if (_isLoadingMoldOptions)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: LinearProgressIndicator(
                  minHeight: 3,
                  color: MoldifyColors.primaryColor,
                  backgroundColor: MoldifyColors.taupe,
                ),
              )
            else if (_genusOptions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: MoldifyColors.taupe,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _moldOptionsError ?? 'No mold options available.',
                        style: const TextStyle(
                          fontFamily: 'Bricolage-Grotesque-Regular',
                          fontSize: 13,
                          color: MoldifyColors.MoldifyGrey,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadMoldOptions,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else
              BuildDropdown(
                key: ValueKey(_dropdownKey),
                hintText: "Select Genus",
                items: _genusOptions,
                initialValue: _selectedGenus,
                onChanged: _handleMoldSelectionChanged,
              ),

            const SizedBox(height: 50),

            _buildMajorSectionHeader("REVISED RESULTS ANALYSIS"),
            const SizedBox(height: 30),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(
                    color: MoldifyColors.primaryColor,
                  ),
                ),
              )
            else
              ..._analysisSections.entries.map(
                (entry) => _buildTextSection(
                  entry.key,
                  entry.value.trim().isNotEmpty
                      ? entry.value
                      : 'No data available yet.',
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
      if (normalized.contains('mechanical'))
        return Icons.settings_suggest_outlined;
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

  Widget _buildTextSection(
    String label,
    String body, {
    bool isWarning = false,
  }) {
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
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: Colors.redAccent,
                ),
              ],
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
        onPressed: () async {
          final selectedEntry =
              (_selectedGenus == null || _selectedGenus!.trim().isEmpty)
              ? null
              : _moldCatalogByName[_selectedGenus!.trim().toLowerCase()];

          final selectedMoldName =
              (selectedEntry?.name ?? _selectedGenus ?? _diseaseController.text)
                  .trim();
          if (selectedMoldName.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select a mold genus before submitting.'),
              ),
            );
            return;
          }

          final selectedMoldId =
              (selectedEntry?.id ?? _selectedMoldId ?? _suggestedMoldId ?? '')
                  .trim();
          if (selectedMoldId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Please select a valid mold from the list before submitting.',
                ),
              ),
            );
            return;
          }

          if (_caseId == null || _caseId!.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cannot submit final verdict: missing case ID.'),
              ),
            );
            return;
          }

          setState(() => _isLoading = true);
          try {
            final authProvider = Provider.of<AppAuthProvider>(
              context,
              listen: false,
            );
            final service = MoldCaseService();

            final confidence = (_suggestedConfidence ?? 0)
                .clamp(0, 100)
                .toDouble();

            final populatedSections = _analysisSections.entries
                .where((entry) => entry.value.trim().isNotEmpty)
                .map((entry) => '${entry.key}: ${entry.value.trim()}')
                .toList();
            final populatedControls = _managementControls
                .where((entry) => (entry['content'] ?? '').trim().isNotEmpty)
                .map(
                  (entry) =>
                      '${entry['title'] ?? 'Control'}: ${(entry['content'] ?? '').trim()}',
                )
                .toList();

            final combinedNotes = [
              ...populatedSections,
              ...populatedControls,
            ].join('\n\n');

            final moldipediaId = await _resolveMoldipediaId(
              selectedMoldName,
              authProvider.cookie,
            );

            await service.submitVerdict(
              _caseId!.trim(),
              moldId: selectedMoldId,
              moldipediaId: moldipediaId,
              moldName: selectedMoldName,
              confidence: confidence,
              notes: combinedNotes.isNotEmpty ? combinedNotes : null,
              sessionCookie: authProvider.cookie,
            );

            if (!mounted) return;
            Navigator.of(context).pop(
              const MutationResult.changed(tags: [MutationTags.moldCase]).toMap(),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to submit final verdict: $e')),
            );
          } finally {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          }
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
