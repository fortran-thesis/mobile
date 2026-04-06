import 'package:flutter/material.dart';
import 'package:moldify/core/constants/route_names.dart';

import '../../../misc/colors.dart';
import '../../../misc/overlays/loading_ui.dart';
import 'wikimold_section_header.dart';

/// Presentational Field Evidence section for the WikiMold detail page.
///
/// This widget does not fetch data from backend services. Data is provided by
/// the parent screen through constructor parameters.
///
/// Parameters:
/// - [linkedCases]: Backend-linked investigation records for this article.
/// - [isLoading]: Loading state controlled by the parent.
/// - [error]: Optional fetch error controlled by the parent.
/// - [onRetry]: Callback to trigger parent-managed retry.
/// - [retryLabel]: Localized text for the retry button.
class WikiMoldFieldEvidenceSection extends StatefulWidget {
  const WikiMoldFieldEvidenceSection({
    super.key,
    required this.linkedCases,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.retryLabel,
  });

  final List<Map<String, dynamic>> linkedCases;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  State<WikiMoldFieldEvidenceSection> createState() => _WikiMoldFieldEvidenceSectionState();
}

class _WikiMoldFieldEvidenceSectionState extends State<WikiMoldFieldEvidenceSection> {
  final Set<String> _expandedCaseIds = <String>{};

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading && widget.error == null && widget.linkedCases.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WikiMoldSectionHeader(
            phaseNumber: '04',
            superTitle: 'Fungal Analysis Phase',
            mainTitle: 'Field Evidence',
          ),
          if (widget.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: AppLoadingSpinner(),
              ),
            ),
          if (widget.error != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.error!,
                  style: const TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    fontSize: 14,
                    color: MoldifyColors.MoldifyBlack,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: widget.onRetry,
                  child: Text(widget.retryLabel),
                ),
              ],
            ),
          if (!widget.isLoading && widget.error == null && widget.linkedCases.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildLinkedInvestigationsHeader(),
            const SizedBox(height: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.linkedCases.length,
              itemBuilder: (context, index) {
                final caseData = widget.linkedCases[index];
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

                return _buildObservationCard(
                  index: index,
                  isExpanded: isExpanded,
                  caseKey: caseKey,
                  caseData: caseData,
                  initialDescription: initialDescription,
                  inVivoSummary: inVivoSummary,
                  inVitroSummary: inVitroSummary,
                  hasFinalVerdict: hasFinalVerdict,
                  finalVerdictMap: finalVerdictMap,
                  isLast: index == widget.linkedCases.length - 1,
                );
              },
            ),
          ],
        ],
    );
  }

  Widget _buildLinkedInvestigationsHeader() {
    final countString = widget.linkedCases.length.toString().padLeft(2, '0');

    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'LINKED',
                    style: TextStyle(
                      fontFamily: 'Bricolage-Grotesque',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: MoldifyColors.accentColor,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    'INVESTIGATIONS',
                    style: TextStyle(
                      fontFamily: 'Montserrat-Black',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: MoldifyColors.MoldifyGrey.withValues(alpha: 0.5),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 15),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Text(
                    countString,
                    style: const TextStyle(
                      fontFamily: 'Montserrat-Black',
                      fontSize: 32,
                      letterSpacing: -2,
                      color: MoldifyColors.primaryColor,
                      height: 1.0,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: -8,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: MoldifyColors.accentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: MoldifyColors.accentColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 180,
            height: 0.5,
            color: MoldifyColors.MoldifyGrey.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }

  String _caseKey(Map<String, dynamic> caseData, int index) {
    final id = (caseData['id'] ?? '').toString().trim();
    if (id.isNotEmpty) return id;
    final reportId = (caseData['mold_report_id'] ?? '').toString().trim();
    if (reportId.isNotEmpty) return reportId;
    return 'case_$index';
  }

  Widget _buildObservationCard({
    required int index,
    required bool isExpanded,
    required String caseKey,
    required Map<String, dynamic> caseData,
    required String initialDescription,
    required String inVivoSummary,
    required String inVitroSummary,
    required bool hasFinalVerdict,
    required Map<String, dynamic> finalVerdictMap,
    required bool isLast,
  }) {
    final cropName = _asText(
      caseData['crop_name'] ?? caseData['cropName'] ?? caseData['crop'],
    );
    final reportId = _asText(caseData['mold_report_id'] ?? caseData['id']);
    final caseImageUrl = _extractCaseImageUrl(caseData);

    const Color primaryGreen = MoldifyColors.primaryColor;
    const Color orangeAccent = MoldifyColors.accentColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (!isLast)
            Positioned(
              left: 4,
              top: 25,
              bottom: 0,
              child: Container(
                width: 1,
                color: orangeAccent.withValues(alpha: 0.3),
              ),
            ),
          Container(
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
        
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _CaseImagePreview(imageUrl: caseImageUrl),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'CROP NAME',
                                        style: TextStyle(
                                          fontFamily: 'Bricolage-Grotesque',
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.5,
                                          color: orangeAccent,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              cropName.isNotEmpty ? cropName.toUpperCase() : 'UNKNOWN',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: 'Montserrat-Black',
                                                fontSize: 22,
                                                color: primaryGreen,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            children: [
                              if (reportId.isNotEmpty)
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      RouteNames.viewCase,
                                      arguments: {'id': reportId},
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: primaryGreen,
                                    side: BorderSide(
                                      color: primaryGreen.withValues(alpha: 0.25),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    textStyle: const TextStyle(
                                      fontFamily: 'Montserrat-Bold',
                                      fontSize: 10,
                                    ),
                                  ),
                                  child: const Text('OPEN CASE'),
                                ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _toggleCaseExpanded(caseKey),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isExpanded ? orangeAccent : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: isExpanded
                                          ? orangeAccent
                                          : primaryGreen.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Text(
                                    isExpanded ? 'HIDE NOTES' : 'QUICK NOTES',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat-Bold',
                                      fontSize: 10,
                                      letterSpacing: 0.5,
                                      color: isExpanded ? Colors.white : primaryGreen,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEvidencePanel(
                          phase: '01',
                          title: 'Initial Observation',
                          description: initialDescription,
                          primaryColor: primaryGreen,
                          accentColor: orangeAccent,
                        ),
                        const SizedBox(height: 12),
                        _buildEvidencePanel(
                          phase: '02',
                          title: 'In Vivo Analysis',
                          description: inVivoSummary.isNotEmpty
                              ? inVivoSummary
                              : 'No active bio-logs.',
                          primaryColor: primaryGreen,
                          accentColor: orangeAccent,
                        ),
                        const SizedBox(height: 12),
                        _buildEvidencePanel(
                          phase: '03',
                          title: 'In Vitro Results',
                          description: inVitroSummary.isNotEmpty
                              ? inVitroSummary
                              : 'Laboratory culture pending.',
                          primaryColor: primaryGreen,
                          accentColor: orangeAccent,
                        ),
                        if (hasFinalVerdict) ...[
                          const SizedBox(height: 12),
                          _buildVerdictSection(
                            context: context,
                            verdict: finalVerdictMap,
                            primaryColor: primaryGreen,
                            accentColor: orangeAccent,
                            moldipediaId: _asText(
                              finalVerdictMap['moldipedia_id'] ?? '',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
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

    final filtered = rawLogs.whereType<Map>().map((item) => _asMap(item)).where((log) {
      final normalized = _normalizeLogType(log['type']);
      if (type == 'vivo') {
        return normalized == 'vivo' || normalized == 'invivo';
      }
      return normalized == 'vitro' || normalized == 'invitro';
    }).toList();

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
    final dynamic coverPhoto = caseData['cover_photo'] ?? caseData['report_cover_photo'];

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
    required String phase,
    required String title,
    required String description,
    required Color primaryColor,
    required Color accentColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '[$phase] ${title.toUpperCase()}',
            style: const TextStyle(
              fontFamily: 'Bricolage-Grotesque-Extrabold',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: MoldifyColors.accentColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              fontFamily: 'Bricolage-Grotesque-Regular',
              fontSize: 15,
              height: 1.5,
              color: MoldifyColors.MoldifyBlack.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerdictSection({
    required BuildContext context,
    required Map<String, dynamic> verdict,
    required Color primaryColor,
    required Color accentColor,
    required String? moldipediaId,
  }) {
    final moldName = _asText(verdict['moldName'] ?? verdict['mold_name']);
    final confidenceValue = _asDouble(verdict['confidence']);
    final notes = _asText(verdict['mycologist_notes'] ?? '');
    final verdictTs = verdict['verdict_timestamp'] ?? verdict['verdictTimestamp'];

    String verdictDateStr = '';
    if (verdictTs != null) {
      try {
        DateTime? verdictDate;
        if (verdictTs is String) {
          verdictDate = DateTime.parse(verdictTs);
        } else if (verdictTs is Map) {
          final seconds = verdictTs['_seconds'] ?? verdictTs['seconds'];
          if (seconds is int) {
            verdictDate = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
          }
        }
        if (verdictDate != null) {
          verdictDateStr = '${verdictDate.month}/${verdictDate.day}/${verdictDate.year}';
        }
      } catch (_) {
        // Ignore date parsing errors.
      }
    }

    final summaryParts = <String>[];
    if (moldName.isNotEmpty) summaryParts.add('Identified Mold: $moldName');
    if (confidenceValue != null) {
      summaryParts.add('Confidence: ${(confidenceValue * 100).toStringAsFixed(1)}%');
    }
    if (verdictDateStr.isNotEmpty) summaryParts.add('Verdict Date: $verdictDateStr');
    if (notes.isNotEmpty) summaryParts.add('Mycologist Notes: $notes');
    if (summaryParts.isEmpty) summaryParts.add('Pending identification.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEvidencePanel(
          phase: '04',
          title: 'Final Verdict',
          description: summaryParts.join('\n\n'),
          primaryColor: primaryColor,
          accentColor: accentColor,
        ),
        if (moldipediaId != null && moldipediaId.isNotEmpty) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  RouteNames.viewWikiMold,
                  arguments: {'id': moldipediaId},
                );
              },
              icon: const Icon(Icons.description, size: 16),
              label: const Text('View Article'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor.withValues(alpha: 0.25)),
                textStyle: const TextStyle(
                  fontFamily: 'Bricolage-Grotesque-Bold',
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ],
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
