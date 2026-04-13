import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:moldify/l10n/app_localizations.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/tiles/control_management_tile.dart';
import 'package:moldify/pages/support/report_a_curator.dart';
import 'package:provider/provider.dart';
import 'package:moldify/pages/farmer/wikimold/widgets/wikimold_author_row.dart';
import 'package:moldify/pages/farmer/wikimold/widgets/wikimold_field_evidence_section.dart';
import 'package:moldify/pages/farmer/wikimold/widgets/wikimold_section_header.dart';
import '../../../core/features/wikimold/models/wikimold.dart';
import '../../../core/features/wikimold/services/wikimold_services.dart';
import '../../../providers/auth_provider.dart';
import '../../misc/colors.dart';
import '../../misc/overlays/loading_ui.dart';
import 'package:moldify/core/utils/logger.dart';

/// Detailed WikiMold article screen.
///
/// Responsibilities:
/// - Fetches article content from backend using [articleId].
/// - Fetches linked field-evidence cases from backend.
/// - Owns loading/error state for both article and linked cases.
/// - Passes linked case data to [WikiMoldFieldEvidenceSection] as props.
///
/// Child widgets in this feature are intentionally presentational and should
/// not perform backend fetching to keep parent-child data flow predictable.
class ViewWikiMoldScreen extends StatefulWidget {
  final String articleId;

  const ViewWikiMoldScreen({super.key, required this.articleId});

  @override
  State<ViewWikiMoldScreen> createState() => _ViewWikiMoldScreenState();
}

class _ViewWikiMoldScreenState extends State<ViewWikiMoldScreen> {
  final WikiService _wikiService = WikiService();

  // Parsing delimiters for structured data
  static const String _stageDelimiter = '|';
  static const String _fieldDelimiter = '::';

  // UI dimension constants
  static const double _heroImageHeight = 330.0;
  static const double _contentTopOffset = -40.0;
  static const double _contentBorderRadius = 40.0;

  // Toggle to use dummy data when backend content is unavailable
  // Set to false when backend provides structured findings/treatments data
  static const bool _forceDummySectionContent = false;

  WikiArticle? _article;
  bool _isLoading = true;
  String? _error;

  // Cached parsed data to avoid re-parsing on every build
  List<Widget> _cachedHostImpactTiles = [];
  List<Widget> _cachedTreatmentTiles = [];

  // Supporting cases
  List<Map<String, dynamic>> _linkedCases = [];
  bool _casesLoading = false;
  String? _casesError;

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final cookie = authProvider.cookie;

      if (cookie == null) {
        setState(() {
          _error = 'Authentication error. Please log in again.';
          _isLoading = false;
        });
        return;
      }

      AppLogger.d('Fetching article with ID: ${widget.articleId}');
      final article = await _wikiService.fetchWikiArticleById(
        articleId: widget.articleId,
        sessionCookie: cookie,
      );
      AppLogger.d('Article loaded successfully: ${article.title}');

      if (!mounted) return;
      setState(() {
        _article = article;
        _error = null;
        _isLoading = false;

        // Parse and cache data once when article is loaded
        _updateCachedData(article);
      });

      // Load linked cases in background
      _loadLinkedCases(article.id);
    } catch (e) {
      AppLogger.e('Error loading article', error: e);
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLinkedCases(String moldipediaId) async {
    if (!mounted) return;
    setState(() {
      _casesLoading = true;
      _casesError = null;
    });

    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final cookie = authProvider.cookie;

      if (cookie == null) {
        setState(() {
          _casesError = 'Authentication error. Please log in again.';
          _casesLoading = false;
        });
        return;
      }

      final cases = await _wikiService.fetchMoldipediaCases(
        moldipediaId: moldipediaId,
        sessionCookie: cookie,
      );

      if (!mounted) return;
      setState(() {
        _linkedCases = cases;
        _casesError = null;
        _casesLoading = false;
      });
    } catch (e) {
      AppLogger.e('Error loading linked cases', error: e);
      if (!mounted) return;
      setState(() {
        _casesError = e.toString();
        _casesLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppLoadingOverlay(
        message: 'Loading WikiMold...',
      );
    }

    if (_error != null) {
      final l10n = AppLocalizations.of(context)!;
      return Scaffold(
        appBar: PrimaryAppBar(title: l10n.viewWikiMold),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loadArticle,
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final article = _article;
    if (article == null) {
      final l10n = AppLocalizations.of(context)!;
      return Scaffold(body: Center(child: Text(l10n.articleDataUnavailable)));
    }

    final l10n = AppLocalizations.of(context)!;
    final String publishedDate = article.createdAt != null
        ? DateFormat('MMMM d, yyyy').format(article.createdAt!.toLocal())
        : l10n.unknownDate;

    // Use cached parsed data instead of parsing on every build

    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(
        title: 'View WikiMold',
        rightIcon: const Icon(Icons.report),
        rightIconColor: MoldifyColors.primaryColor,
        onRightIconPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ReportACuratorScreen(
                contentId: article.id,
                contentType: 'wikimold_article',
              ),
            ),
          );
        },
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // --- 1. HERO SECTION  ---
            Stack(
              children: [
                SizedBox(
                  height: _heroImageHeight,
                  width: double.infinity,
                  child:
                      article.coverPhoto != null &&
                          article.coverPhoto!.isNotEmpty
                      ? Image.network(article.coverPhoto!, fit: BoxFit.cover)
                      : Container(color: MoldifyColors.taupe),
                ),
                Container(
                  height: _heroImageHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 70),
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    article.title.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Montserrat-Black',
                      fontSize: 32,
                      height: 0.9,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            // --- 2. MAIN CONTENT BODY ---
            Transform.translate(
              offset: const Offset(0, _contentTopOffset),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: MoldifyColors.backgroundColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(_contentBorderRadius),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 35,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WikiMoldAuthorRow(
                        author: article.author,
                        publishedDate: publishedDate,
                      ),
                      const SizedBox(height: 35),

                      // DESCRIPTION
                      const WikiMoldSectionHeader(
                        phaseNumber: '01',
                        superTitle: 'Fungal Analysis Phase',
                        mainTitle: 'Biological Description',
                      ),
                      Html(
                        data: article.body,
                        style: {
                          'body': Style(
                            fontFamily: 'Bricolage-Grotesque-Regular',
                            fontSize: FontSize(16),
                            lineHeight: LineHeight(1.6),
                            color: MoldifyColors.MoldifyBlack,
                          ),
                        },
                      ),
                      const SizedBox(height: 30),

                      // --- 3. HOST & PATHOGEN IMPACT ---
                      const WikiMoldSectionHeader(
                        phaseNumber: '02',
                        superTitle: 'Fungal Analysis Phase',
                        mainTitle: 'Host & Pathogen Impact',
                        subtitle: 'Technical Analysis & Observations',
                      ),
                      ..._cachedHostImpactTiles,
                      const SizedBox(height: 30),

                      // --- 4. TREATMENT SECTION WITH CONTROL MANAGEMENT TILES ---
                      const WikiMoldSectionHeader(
                        phaseNumber: '03',
                        superTitle: 'Fungal Analysis Phase',
                        mainTitle: 'Treatment Protocols',
                      ),
                      ..._cachedTreatmentTiles,
                      const SizedBox(height: 30),

                      // Parent owns fetching/integration and passes data down.
                      WikiMoldFieldEvidenceSection(
                        linkedCases: _linkedCases,
                        isLoading: _casesLoading,
                        error: _casesError,
                        onRetry: () => _loadLinkedCases(article.id),
                        retryLabel: l10n.retry,
                      ),
                      const SizedBox(height: 100), // Bottom padding
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Updates cached parsed data when article changes
  /// This prevents re-parsing on every build, improving performance
  void _updateCachedData(WikiArticle article) {
    final String treatmentsContent = article.treatments.trim().isNotEmpty
        ? article.treatments
        : (_forceDummySectionContent ? _dummyTreatmentsHtml : '');

    final hostImpactData = article.hostPathogenImpact.isNotEmpty
        ? article.hostPathogenImpact
        : (_forceDummySectionContent
              ? _dummyHostPathogenImpact
              : <String, String>{});

    _cachedHostImpactTiles = _buildHostImpactTiles(hostImpactData);
    _cachedTreatmentTiles = _buildTreatmentTiles(treatmentsContent);
  }

  List<Widget> _buildHostImpactTiles(Map<String, String> content) {
    if (content.isEmpty) return const [];

    String raw(String key) => (content[key] ?? '').trim();
    String clean(String key) =>
        (content[key] ?? '').replaceAll(RegExp(r'<[^>]*>'), '').trim();

    final affectedHosts = clean('affected_hosts');
    final symptomsSigns = clean('symptoms_signs');
    final transmissionCycle = clean('transmission_cycle');
    final impactAnalysis = clean('impact_analysis');

    final tiles = <Widget>[];
    if (affectedHosts.isNotEmpty) {
      tiles.add(
        ControlManagementTile(
          title: 'Affected Hosts',
          icon: Icons.grass_outlined,
          description: affectedHosts,
          proseHtml: raw('affected_hosts'),
        ),
      );
    }
    if (symptomsSigns.isNotEmpty) {
      tiles.add(
        ControlManagementTile(
          title: 'Symptoms & Signs',
          icon: Icons.coronavirus_outlined,
          description: symptomsSigns,
          proseHtml: raw('symptoms_signs'),
        ),
      );
    }
    if (transmissionCycle.isNotEmpty) {
      tiles.add(
        ControlManagementTile(
          title: 'Transmission Cycle',
          icon: Icons.sync_alt,
          description: transmissionCycle,
          proseHtml: raw('transmission_cycle'),
        ),
      );
    }
    if (impactAnalysis.isNotEmpty) {
      tiles.add(
        ControlManagementTile(
          title: 'Impact Analysis',
          icon: Icons.insights_outlined,
          description: impactAnalysis,
          proseHtml: raw('impact_analysis'),
        ),
      );
    }

    return tiles;
  }


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

  List<Widget> _buildTreatmentTiles(String content) {
    if (content.isEmpty) return [];

    // Parse structured treatment format: TYPE::Title::Description|TYPE::...
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
          final prose = parts[2].trim();
          final desc = prose.replaceAll(RegExp(r'<[^>]*>'), '').trim();
          final icon = _getIconForTreatmentType(type);

          widgets.add(
            ControlManagementTile(
              title: title,
              icon: icon,
              description: desc,
              proseHtml: prose,
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
        proseHtml: content,
      ),
    ];
  }

  // Dummy data for development/testing
  static const String _dummyTreatmentsHtml =
      'PREVENTION::Prevention Summary::Keep affected areas dry, improve airflow, remove crop debris, and sanitize tools between field visits.|'
      'MECHANICAL::Physical Removal::Remove visible mold using brushes and HEPA vacuum. Dispose contaminated materials in sealed bags. Wear protective gear during cleanup.|'
      'BIOLOGICAL::Natural Solutions::Apply beneficial microorganisms that compete with mold. Use vinegar or tea tree oil solutions for surface treatment.|'
      'CHEMICAL::Antimicrobial Treatment::Use EPA-approved fungicides for severe cases. Ensure proper ventilation during application. Follow manufacturer instructions carefully.';

  static const Map<String, String> _dummyHostPathogenImpact = {
    'affected_hosts':
        'Tomato, eggplant, pepper, and selected cucurbit crops are commonly affected in humid field setups.',
    'symptoms_signs':
        'Leaf spotting, discoloration, lesion expansion, and visible fungal growth become more evident with prolonged moisture.',
    'transmission_cycle':
        'Spores spread through air flow, splashing water, and contaminated tools, then establish on susceptible host tissue.',
    'impact_analysis':
        'Unchecked progression can reduce yield quality, increase treatment costs, and trigger broader field-level contamination.',
  };
}
