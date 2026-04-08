import 'package:flutter/material.dart';
import 'package:moldify/core/features/mold_case/service/mold_case_service.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/overlays/loading_ui.dart';
import 'package:moldify/providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// Full-screen list of investigations linked to a WikiMold article.
///
/// Purpose:
/// - Gives users a dedicated screen to browse linked cases in detail.
/// - Reuses the same evidence semantics shown in the embedded Field Evidence
///   section, but with an independent full-screen experience.
///
/// Parameters:
/// - [articleId]: WikiMold article ID used for backend linked-case queries.
/// - [articleTitle]: Human-readable article title for empty-state messaging.
///
/// Relation to `wikimold_field_evidence_section.dart`:
/// - The embedded section is a child widget rendered inside `view_wikimold`.
/// - This file is a standalone route/screen opened via FAB.
class SimilarCasesScreen extends StatefulWidget {
  final String articleId;
  final String articleTitle;

  const SimilarCasesScreen({
    super.key,
    required this.articleId,
    required this.articleTitle,
  });

  @override
  State<SimilarCasesScreen> createState() => _SimilarCasesScreenState();
}

class _SimilarCasesScreenState extends State<SimilarCasesScreen> {
  final MoldCaseService _moldCaseService = MoldCaseService();

  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _cases = const [];
  final Set<String> _expandedCaseIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final cookie = authProvider.cookie;
      if (cookie == null || cookie.trim().isEmpty) {
        throw Exception('Authentication error. Please log in again.');
      }

      final linkedCases = await _moldCaseService.getMoldCasesByMoldipediaId(
        widget.articleId,
        sessionCookie: cookie,
      );

      if (!mounted) return;
      setState(() {
        _cases = linkedCases;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

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
        if (type == 'vivo') {
          return normalized == 'vivo' || normalized == 'invivo';
        }
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

  String _extractCaseImageUrl(Map<String, dynamic> caseData) {
    final details = _asMap(caseData['cultivation_details']);
    final dynamic coverPhoto =
        caseData['cover_photo'] ?? caseData['report_cover_photo'];

    final candidates = <String>[
      _asText(details['initial_macroscopic_image_url']),
      _asText(details['initial_microscopic_image_url']),
    ];

    if (coverPhoto is List && coverPhoto.isNotEmpty) {
      candidates.add(_asText(coverPhoto.first));
    } else {
      candidates.add(_asText(coverPhoto));
    }

    return candidates.firstWhere((item) => item.isNotEmpty, orElse: () => '');
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

  Widget _buildVerdictSection({required Map<String, dynamic> verdict}) {
    final moldName = _asText(verdict['moldName'] ?? verdict['mold_name']);
    final confidence = verdict['confidence'];
    final notes = _asText(verdict['mycologist_notes'] ?? '');
    final verdictTs =
        verdict['verdict_timestamp'] ?? verdict['verdictTimestamp'];

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
        verdictDateStr =
            '${verdictDate.month}/${verdictDate.day}/${verdictDate.year}';
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PrimaryAppBar(title: 'Similar Cases'),
      body: RefreshIndicator(onRefresh: _loadCases, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: AppLoadingSpinner());
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loadCases,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_cases.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
            child: Column(
              children: [
                Text(
                  'No linked field evidence yet for ${widget.articleTitle}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Resolved investigations will contribute evidence here once linked to this WikiMold article.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
      itemCount: _cases.length,
      itemBuilder: (context, index) {
        final entry = _cases[index];
        final caseKey = _caseKey(entry, index);
        final isExpanded = _expandedCaseIds.contains(caseKey);
        final caseImageUrl = _extractCaseImageUrl(entry);

        final details = _asMap(entry['cultivation_details']);
        final initialMicroscopic = _asText(details['initial_microscopic']);
        final initialMacroscopic = _asText(details['initial_macroscopic']);
        final initialSymptoms = _asTextList(
          details['initial_symptoms'] ??
              details['initial_macroscopic_symptoms'],
        );
        final initialCharacteristics = _asTextList(
          details['initial_characteristics'] ??
              details['initial_macroscopic_characteristics'],
        );

        final inVivo = _latestLog(entry, 'vivo');
        final inVitro = _latestLog(entry, 'vitro');
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
        final initialDescription =
            initialMicroscopic.isNotEmpty || initialMacroscopic.isNotEmpty
            ? [
                initialMicroscopic,
                initialMacroscopic,
              ].where((t) => t.isNotEmpty).join(' | ')
            : (initialSymptoms.isNotEmpty
                  ? initialSymptoms.join(', ')
                  : (initialCharacteristics.isNotEmpty
                        ? initialCharacteristics.join(', ')
                        : 'No initial observation evidence recorded.'));

        final finalVerdictMap = _asMap(entry['final_verdict']);
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CaseImagePreview(imageUrl: caseImageUrl),
                      const SizedBox(width: 12),
                      Expanded(
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
                          ],
                        ),
                      ),
                    ],
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
                        color: MoldifyColors.primaryColor.withValues(
                          alpha: 0.25,
                        ),
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
                            _buildVerdictSection(verdict: finalVerdictMap),
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
    );
  }
}

class _CaseImagePreview extends StatelessWidget {
  const _CaseImagePreview({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 64,
        height: 64,
        color: MoldifyColors.primaryColor.withValues(alpha: 0.08),
        child: imageUrl.isEmpty
            ? Icon(
                Icons.image_not_supported_outlined,
                color: MoldifyColors.primaryColor.withValues(alpha: 0.5),
                size: 20,
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image_not_supported_outlined,
                    color: MoldifyColors.primaryColor.withValues(alpha: 0.5),
                    size: 20,
                  );
                },
              ),
      ),
    );
  }
}
