import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moldify/core/features/mold_case/service/mold_case_service.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/tiles/main_case_tile.dart';
import 'package:moldify/providers/auth_provider.dart';
import 'package:provider/provider.dart';

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

  DateTime? _parseTimestamp(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    if (raw is String) {
      return DateTime.tryParse(raw);
    }
    if (raw is Map) {
      final seconds = raw['_seconds'] ?? raw['seconds'];
      if (seconds is int) {
        return DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000,
          isUtc: true,
        ).toLocal();
      }
    }
    return null;
  }

  String _formatCaseDate(Map<String, dynamic> entry) {
    final verdict = entry['final_verdict'];
    final metadata = entry['metadata'];

    final verdictTs = verdict is Map
        ? _parseTimestamp(verdict['verdict_timestamp'])
        : null;
    final createdTs = metadata is Map
        ? _parseTimestamp(metadata['created_at'])
        : null;
    final startTs = _parseTimestamp(entry['start_date']);

    final selected = verdictTs ?? createdTs ?? startTs;
    if (selected == null) return 'Unknown date';
    return DateFormat('MMMM dd, yyyy').format(selected);
  }

  String _resolveStatus(Map<String, dynamic> entry) {
    final isArchived = entry['is_archived'];
    if (isArchived is bool && isArchived) {
      return 'Resolved';
    }
    return 'In Progress';
  }

  String? _resolveImageUrl(Map<String, dynamic> entry) {
    final raw = entry['photo_url'];
    if (raw is String && raw.trim().isNotEmpty && raw.trim() != 'no_image') {
      return raw.trim();
    }
    return null;
  }

  Future<void> _openCase(Map<String, dynamic> entry) async {
    final reportId = (entry['mold_report_id'] ?? '').toString().trim();
    final caseId = (entry['id'] ?? '').toString().trim();
    final target = reportId.isNotEmpty ? reportId : caseId;

    if (target.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open case details.')),
      );
      return;
    }

    await Navigator.of(
      context,
    ).pushNamed('/view-case', arguments: {'id': target});
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
      return const Center(child: CircularProgressIndicator());
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
                  'No linked cases yet for ${widget.articleTitle}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Resolved cases will appear here once a verdict is linked to this WikiMold article.',
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
        return MainCaseTile(
          caseName: (entry['name'] ?? 'Unnamed Case').toString(),
          dateSubmitted: _formatCaseDate(entry),
          caseStatus: _resolveStatus(entry),
          imageUrl: _resolveImageUrl(entry),
          onTap: () => _openCase(entry),
          showPopupMenu: false,
        );
      },
    );
  }
}
