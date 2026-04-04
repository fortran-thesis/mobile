import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/l10n/app_localizations.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/functions/scrollable_tab_bar.dart';
import 'package:moldify/pages/misc/tiles/control_management_tile.dart';
import 'package:moldify/pages/support/report_a_curator.dart';
import 'package:provider/provider.dart';
import 'package:moldify/pages/farmer/wikimold/similar_cases.dart';
import '../../../core/features/wikimold/models/wikimold.dart';
import '../../../core/features/wikimold/services/wikimold_services.dart';
import '../../../providers/auth_provider.dart';
import '../../misc/colors.dart';
import 'package:moldify/core/utils/logger.dart';

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
  static const String _stagePrefix = 'STAGE_';

  // UI dimension constants
  static const double _heroImageHeight = 330.0;
  static const double _contentTopOffset = -40.0;
  static const double _contentBorderRadius = 40.0;

  // Toggle to use dummy data when backend content is unavailable
  // Set to false when backend provides structured findings/treatments data
  static const bool _forceDummySectionContent = false;

  static const List<String> _canonicalStageLabels = [
    'Initial Observation',
    'In Vivo',
    'In Vitro',
  ];

  WikiArticle? _article;
  bool _isLoading = true;
  String? _error;
  int _selectedStageIndex = 0;

  // Cached parsed data to avoid re-parsing on every build
  List<Map<String, String>> _cachedFindingStages = [];
  List<Widget> _cachedHostImpactTiles = [];
  List<Widget> _cachedTreatmentTiles = [];

  // Supporting cases
  List<Map<String, dynamic>> _linkedCases = [];
  bool _casesLoading = false;
  String? _casesError;
  final Set<String> _expandedCaseIds = <String>{};

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
    setState(() => _casesLoading = true);

    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final cookie = authProvider.cookie;

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
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: MoldifyColors.primaryColor),
        ),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SimilarCasesScreen(
                articleId: article.id,
                articleTitle: article.title,
              ),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              decoration: BoxDecoration(
                color: MoldifyColors.primaryColor.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: MoldifyColors.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.travel_explore_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Explore Similar Cases'.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Bricolage-Grotesque-Bold',
                      fontSize: 11,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
                      _buildAuthorRow(
                        author: article.author,
                        publishedDate: publishedDate,
                      ),
                      const SizedBox(height: 35),

                      // DESCRIPTION
                      _buildSectionHeader('Description'),
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
                      _buildSectionHeader('Host & Pathogen Impact'),
                      ..._cachedHostImpactTiles,
                      const SizedBox(height: 30),

                      // --- 4. TREATMENT SECTION WITH CONTROL MANAGEMENT TILES ---
                      _buildSectionHeader('Treatment Recommendations'),
                      ..._cachedTreatmentTiles,
                      const SizedBox(height: 30),

                      // --- 5. FINDINGS TABS ---
                      _buildSectionHeader('Findings'),
                      Text(
                        article.title,
                        style: const TextStyle(
                          fontFamily: 'Montserrat-Black',
                          fontSize: 24,
                          fontStyle: FontStyle.italic,
                          color: MoldifyColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),

                      ScrollableTabBar(
                        tabs: _cachedFindingStages
                            .map((s) => s['label']!)
                            .toList(),
                        currentIndex: _selectedStageIndex,
                        onTabSelected: (index) =>
                            setState(() => _selectedStageIndex = index),
                      ),

                      const SizedBox(height: 30),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Container(
                          key: ValueKey(_selectedStageIndex),
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '0${_selectedStageIndex + 1}',
                                style: TextStyle(
                                  fontFamily: 'Montserrat-Black',
                                  fontSize: 60,
                                  color: MoldifyColors.primaryColor.withValues(
                                    alpha: 0.05,
                                  ),
                                  height: 0.5,
                                ),
                              ),
                              Text(
                                _cachedFindingStages[_selectedStageIndex]['title']!
                                    .toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'Montserrat-Black',
                                  fontSize: 18,
                                  letterSpacing: -0.5,
                                  color: MoldifyColors.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _cachedFindingStages[_selectedStageIndex]['content']!,
                                style: const TextStyle(
                                  fontFamily: 'Bricolage-Grotesque-Regular',
                                  fontSize: 16,
                                  height: 1.6,
                                  color: MoldifyColors.MoldifyBlack,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // --- FIELD & LAB EVIDENCE SECTION ---
                      if (_linkedCases.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 60),
                              Text(
                                'Field & Lab Evidence'.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'Montserrat-Black',
                                  fontSize: 18,
                                  letterSpacing: 0.5,
                                  color: MoldifyColors.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Based on ${_linkedCases.length} linked investigation${_linkedCases.length == 1 ? '' : 's'}',
                                style: const TextStyle(
                                  fontFamily: 'Bricolage-Grotesque-Regular',
                                  fontSize: 14,
                                  color: MoldifyColors.MoldifyBlack,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _linkedCases.length,
                                itemBuilder: (context, index) {
                                  final caseData = _linkedCases[index];
                                  final caseKey = _caseKey(caseData, index);
                                  final isExpanded = _expandedCaseIds.contains(caseKey);

                                  final details = _asMap(caseData['cultivation_details']);
                                  final initialMicroscopic = _asText(details['initial_microscopic']);
                                  final initialMacroscopic = _asText(details['initial_macroscopic']);
                                  final initialSymptoms = _asTextList(
                                    details['initial_symptoms'] ?? details['initial_macroscopic_symptoms'],
                                  );
                                  final initialCharacteristics = _asTextList(
                                    details['initial_characteristics'] ?? details['initial_macroscopic_characteristics'],
                                  );

                                  final inVivo = _latestLog(caseData, 'vivo');
                                  final inVitro = _latestLog(caseData, 'vitro');
                                  final inVivoCharacteristics = _asMap(inVivo?['characteristics']);
                                  final inVitroCharacteristics = _asMap(inVitro?['characteristics']);

                                  final inVivoSummary = _asText(
                                    inVivoCharacteristics['symptoms'] ??
                                        inVivoCharacteristics['characteristics'] ??
                                        inVivoCharacteristics['lesion_color'] ??
                                        inVivoCharacteristics['lesion_size'],
                                  );
                                  final inVitroSummary = _asText(
                                    inVitroCharacteristics['characteristics'] ??
                                        inVitroCharacteristics['colony_color'] ??
                                        inVitroCharacteristics['colony_diameter'],
                                  );
                                  final initialDescription = initialMicroscopic.isNotEmpty || initialMacroscopic.isNotEmpty
                                      ? [initialMicroscopic, initialMacroscopic]
                                          .where((t) => t.isNotEmpty)
                                          .join(' | ')
                                      : (initialSymptoms.isNotEmpty
                                          ? initialSymptoms.join(', ')
                                          : (initialCharacteristics.isNotEmpty
                                              ? initialCharacteristics.join(', ')
                                              : 'No initial observation evidence recorded.'));

                                  final finalVerdictMap = _asMap(caseData['final_verdict']);
                                  final hasFinalVerdict = finalVerdictMap.isNotEmpty;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: MoldifyColors.primaryColor.withValues(alpha: 0.2),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.white,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Observation #${index + 1}',
                                              style: const TextStyle(
                                                fontFamily: 'Montserrat-Bold',
                                                fontSize: 14,
                                                color: MoldifyColors.primaryColor,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            OutlinedButton.icon(
                                              onPressed: () => _toggleCaseExpanded(caseKey),
                                              icon: Icon(
                                                isExpanded ? Icons.expand_less : Icons.expand_more,
                                                size: 16,
                                              ),
                                              label: Text(isExpanded ? 'Hide Evidence' : 'Show Evidence'),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: MoldifyColors.primaryColor,
                                                side: BorderSide(
                                                  color: MoldifyColors.primaryColor.withValues(alpha: 0.25),
                                                ),
                                                textStyle: const TextStyle(
                                                  fontFamily: 'Montserrat-Bold',
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                            AnimatedCrossFade(
                                              duration: const Duration(milliseconds: 220),
                                              crossFadeState: isExpanded
                                                  ? CrossFadeState.showSecond
                                                  : CrossFadeState.showFirst,
                                              firstChild: const SizedBox.shrink(),
                                              secondChild: Padding(
                                                padding: const EdgeInsets.only(top: 14),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    _buildEvidencePanel(
                                                      title: 'Initial Observation',
                                                      description: initialDescription,
                                                    ),
                                                    const SizedBox(height: 10),
                                                    _buildEvidencePanel(
                                                      title: 'In Vivo',
                                                      description: inVivoSummary.isNotEmpty
                                                          ? inVivoSummary
                                                          : 'No in vivo evidence log available.',
                                                    ),
                                                    const SizedBox(height: 10),
                                                    _buildEvidencePanel(
                                                      title: 'In Vitro',
                                                      description: inVitroSummary.isNotEmpty
                                                          ? inVitroSummary
                                                          : 'No in vitro evidence log available.',
                                                    ),
                                                    if (hasFinalVerdict) ...[
                                                      const SizedBox(height: 10),
                                                      _buildVerdictSection(
                                                        verdict: finalVerdictMap,
                                                        moldipediaId: _asText(finalVerdictMap['moldipedia_id'] ?? ''),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
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

  // --- Helpers ---

  String _caseKey(Map<String, dynamic> caseData, int index) {
    final id = (caseData['id'] ?? '').toString().trim();
    if (id.isNotEmpty) return id;
    final reportId = (caseData['mold_report_id'] ?? '').toString().trim();
    if (reportId.isNotEmpty) return reportId;
    return 'case_$index';
  }

  void _toggleCaseExpanded(String caseKey) {
    setState(() {
      if (_expandedCaseIds.contains(caseKey)) {
        _expandedCaseIds.remove(caseKey);
      } else {
        _expandedCaseIds.add(caseKey);
      }
    });
  }

String _asText(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    if (value is num || value is bool) return value.toString();
    if (value is List) {
      return value
          .map((item) => _asText(item))
          .where((item) => item.isNotEmpty)
          .join(', ');
    }
    return '';
  }

  List<String> _asTextList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => _asText(item))
          .where((item) => item.isNotEmpty)
          .toList();
    }
    final text = _asText(value);
    return text.isEmpty ? <String>[] : <String>[text];
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return <String, dynamic>{};
  }

  String _normalizeLogType(dynamic rawType) {
    return _asText(rawType).toLowerCase().replaceAll(RegExp(r'[_\s-]+'), '');
  }

  int _timestampMillis(dynamic raw) {
    if (raw == null) return 0;
    if (raw is String) {
      final parsed = DateTime.tryParse(raw);
      return parsed?.millisecondsSinceEpoch ?? 0;
    }
    if (raw is Map) {
      final seconds = raw['_seconds'] ?? raw['seconds'];
      if (seconds is int) return seconds * 1000;
    }
    return 0;
  }

  Map<String, dynamic>? _latestLog(Map<String, dynamic> caseData, String type) {
    final rawLogs = caseData['cultivation_logs'];
    if (rawLogs is! List) return null;

    final filtered = rawLogs.whereType<Map>().map((item) => _asMap(item)).where(
      (log) {
        final normalized = _normalizeLogType(log['type']);
        if (type == 'vivo')
          return normalized == 'vivo' || normalized == 'invivo';
        return normalized == 'vitro' || normalized == 'invitro';
      },
    ).toList();

    if (filtered.isEmpty) return null;

    filtered.sort((a, b) {
      final aTs = _timestampMillis(
        a['created_at'] ?? _asMap(a['metadata'])['created_at'],
      );
      final bTs = _timestampMillis(
        b['created_at'] ?? _asMap(b['metadata'])['created_at'],
      );
      return bTs.compareTo(aTs);
    });

    return filtered.first;
  }

  Widget _buildEvidencePanel({
    required String title,
    required String description,
    bool isMuted = true,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMuted
            ? MoldifyColors.primaryColor.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: MoldifyColors.primaryColor.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Montserrat-Bold',
              fontSize: 10,
              letterSpacing: 0.8,
              color: MoldifyColors.primaryColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'Bricolage-Grotesque-Regular',
              fontSize: 12,
              color: MoldifyColors.MoldifyBlack,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerdictSection({
    required Map<String, dynamic> verdict,
    required String? moldipediaId,
  }) {
    final moldName = _asText(verdict['moldName'] ?? verdict['mold_name']);
    final confidence = verdict['confidence'];
    final notes = _asText(verdict['mycologist_notes'] ?? '');
    final verdictTs = verdict['verdict_timestamp'] ?? verdict['verdictTimestamp'];

    String verdictDateStr = '';
    if (verdictTs != null) {
      try {
        late DateTime verdictDate;
        if (verdictTs is String) {
          verdictDate = DateTime.parse(verdictTs);
        } else if (verdictTs is Map) {
          final seconds = verdictTs['_seconds'] ?? verdictTs['seconds'];
          if (seconds is int) {
            verdictDate = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
          }
        }
        verdictDateStr = '${verdictDate.month}/${verdictDate.day}/${verdictDate.year}';
      } catch (e) {
        // Ignore date parsing errors
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: MoldifyColors.primaryColor.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FINAL VERDICT',
            style: const TextStyle(
              fontFamily: 'Montserrat-Bold',
              fontSize: 10,
              letterSpacing: 0.8,
              color: MoldifyColors.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          if (moldName.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Identified Mold',
                  style: TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    fontSize: 11,
                    color: MoldifyColors.MoldifyGrey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  moldName,
                  style: const TextStyle(
                    fontFamily: 'Montserrat-Bold',
                    fontSize: 13,
                    color: MoldifyColors.MoldifyBlack,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Pending identification',
                style: TextStyle(
                  fontFamily: 'Bricolage-Grotesque-Regular',
                  fontSize: 12,
                  color: MoldifyColors.MoldifyGrey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          if (confidence != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confidence',
                  style: TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    fontSize: 11,
                    color: MoldifyColors.MoldifyGrey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${(confidence * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontFamily: 'Montserrat-Bold',
                    fontSize: 13,
                    color: MoldifyColors.MoldifyBlack,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          if (verdictDateStr.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verdict Date',
                  style: TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    fontSize: 11,
                    color: MoldifyColors.MoldifyGrey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  verdictDateStr,
                  style: const TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    fontSize: 12,
                    color: MoldifyColors.MoldifyBlack,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          if (notes.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mycologist Notes',
                  style: TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    fontSize: 11,
                    color: MoldifyColors.MoldifyGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notes,
                  style: const TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    fontSize: 12,
                    color: MoldifyColors.MoldifyBlack,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          if (moldipediaId != null && moldipediaId.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  RouteNames.viewWikiMold,
                  arguments: {'id': moldipediaId},
                );
              },
              icon: const Icon(Icons.description, size: 16),
              label: const Text('View Article'),
              style: ElevatedButton.styleFrom(
                backgroundColor: MoldifyColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: const TextStyle(
                  fontFamily: 'Montserrat-Bold',
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Updates cached parsed data when article changes
  /// This prevents re-parsing on every build, improving performance
  void _updateCachedData(WikiArticle article) {
    final String findingsContent = article.findings.trim().isNotEmpty
        ? article.findings
        : (_forceDummySectionContent ? _dummyFindingsHtml : '');

    final String treatmentsContent = article.treatments.trim().isNotEmpty
        ? article.treatments
        : (_forceDummySectionContent ? _dummyTreatmentsHtml : '');

    final hostImpactData = article.hostPathogenImpact.isNotEmpty
        ? article.hostPathogenImpact
        : (_forceDummySectionContent
              ? _dummyHostPathogenImpact
              : <String, String>{});

    _cachedFindingStages = _parseFindings(findingsContent);
    _cachedHostImpactTiles = _buildHostImpactTiles(hostImpactData);
    _cachedTreatmentTiles = _buildTreatmentTiles(treatmentsContent);
  }

  List<Map<String, String>> _parseFindings(String content) {
    if (content.trim().isEmpty) {
      return List.generate(_canonicalStageLabels.length, (index) {
        return {
          'label': _canonicalStageLabels[index],
          'title': _canonicalStageLabels[index],
          'content': 'No data available yet.',
        };
      });
    }

    if (!content.contains(_stagePrefix)) {
      final fallback = content
          .split(_stageDelimiter)
          .where((s) => s.trim().isNotEmpty)
          .toList();
      if (fallback.length >= 3) {
        return List.generate(3, (index) {
          return {
            'label': _canonicalStageLabels[index],
            'title': _canonicalStageLabels[index],
            'content': fallback[index],
          };
        });
      }
      return [
        {
          'label': 'Initial Observation',
          'title': 'Initial Observation',
          'content': content,
        },
      ];
    }

    final parsed = content
        .split(_stageDelimiter)
        .where((s) => s.trim().isNotEmpty)
        .map((s) {
          final parts = s.split(_fieldDelimiter);
          return {
            'label': parts[0],
            'title': parts.length > 1 ? parts[1] : 'Analysis',
            'content': parts.length > 2 ? parts[2] : '',
          };
        })
        .toList();

    final normalized = <Map<String, String>>[];
    for (var index = 0; index < parsed.length; index++) {
      final label = index < _canonicalStageLabels.length
          ? _canonicalStageLabels[index]
          : parsed[index]['label']!.replaceAll(_stagePrefix, 'Stage ');
      normalized.add({
        'label': label,
        'title': label,
        'content': parsed[index]['content'] ?? '',
      });
    }
    return normalized;
  }

  List<Widget> _buildHostImpactTiles(Map<String, String> content) {
    if (content.isEmpty) return const [];

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
        ),
      );
    }
    if (symptomsSigns.isNotEmpty) {
      tiles.add(
        ControlManagementTile(
          title: 'Symptoms & Signs',
          icon: Icons.coronavirus_outlined,
          description: symptomsSigns,
        ),
      );
    }
    if (transmissionCycle.isNotEmpty) {
      tiles.add(
        ControlManagementTile(
          title: 'Transmission Cycle',
          icon: Icons.sync_alt,
          description: transmissionCycle,
        ),
      );
    }
    if (impactAnalysis.isNotEmpty) {
      tiles.add(
        ControlManagementTile(
          title: 'Impact Analysis',
          icon: Icons.insights_outlined,
          description: impactAnalysis,
        ),
      );
    }

    return tiles;
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Montserrat-Black',
          fontSize: 12,
          letterSpacing: 4,
          color: MoldifyColors.accentColor,
        ),
      ),
    );
  }

  Widget _buildAuthorRow({
    required String author,
    required String publishedDate,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: MoldifyColors.taupe,
          child: Text(
            author.isNotEmpty ? author[0] : '?',
            style: const TextStyle(
              color: MoldifyColors.accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'By $author',
              style: const TextStyle(
                fontFamily: 'Bricolage-Grotesque-Extrabold',
                color: MoldifyColors.primaryColor,
                fontSize: 14,
              ),
            ),
            Text(
              publishedDate,
              style: const TextStyle(
                fontFamily: 'Bricolage-Grotesque-Regular',
                fontSize: 12,
                color: MoldifyColors.MoldifyGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }

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
          final desc = parts[2].replaceAll(RegExp(r'<[^>]*>'), '').trim();
          final icon = _getIconForTreatmentType(type);

          widgets.add(
            ControlManagementTile(title: title, icon: icon, description: desc),
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

  // Dummy data for development/testing
  static const String _dummyFindingsHtml =
      'STAGE_1::Early Detection::White cotton-like patches appear on damp surfaces. Musty odor detectable in enclosed spaces.|'
      'STAGE_2::Colony Expansion::Dark speckles form around edges after 48-72 hours. Rapid spread in poorly ventilated areas.|'
      'STAGE_3::Advanced Growth::Thick mold layers forming. Structural damage may occur if untreated.';

  static const String _dummyTreatmentsHtml =
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
