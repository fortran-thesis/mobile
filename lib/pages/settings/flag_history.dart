import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../misc/appbar/primary_app_bar.dart';
import '../misc/colors.dart';
import '../misc/functions/empty_state.dart';
import '../misc/overlays/loading_ui.dart';
import '../misc/textboxes/textboxes.dart';
import '../misc/tiles/flag_history_tile.dart';
import '../../../core/features/flag_report/services/flag_report_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/auth_provider.dart';

class FlagHistoryScreen extends StatefulWidget {
  const FlagHistoryScreen({super.key});

  @override
  State<FlagHistoryScreen> createState() => _FlagHistoryScreenState();
}

class _FlagHistoryScreenState extends State<FlagHistoryScreen> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlagReportService _flagReportService = FlagReportService();
  static const int _pageSize = 20;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  String? _nextPageToken;

  List<Map<String, String>> _flagReports = [];
  List<Map<String, String>> _filteredReports = [];

  @override
  void initState() {
    super.initState();
    _loadInitial();
    searchController.addListener(_filterReports);

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final pos = _scrollController.position.pixels;
      final max = _scrollController.position.maxScrollExtent;
      if (pos >= max - 200) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    searchController.removeListener(_filterReports);
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _parseDate(dynamic rawDate) {
    if (rawDate is String) return formatIsoDateToDisplay(rawDate);
    if (rawDate is Map<String, dynamic>) return formatFirestoreTimestampToDisplay(rawDate);
    return 'Unknown Date';
  }

  Future<void> _loadInitial() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _nextPageToken = null;
      _flagReports = [];
      _filteredReports = [];
    });
    await _fetchReports();
  }

  Future<void> _loadMore() async {
    if (_isLoading || _isLoadingMore || _nextPageToken == null || !mounted) return;
    setState(() => _isLoadingMore = true);
    await _fetchReports(pageToken: _nextPageToken);
    if (!mounted) return;
    setState(() => _isLoadingMore = false);
  }

  Future<void> _fetchReports({String? pageToken}) async {
    try {
      final sessionCookie =
          Provider.of<AppAuthProvider>(context, listen: false).cookie;
      if (sessionCookie == null || sessionCookie.isEmpty) {
        if (!mounted) return;
        setState(() {
          _error = 'Authentication error. Please log in again.';
          _isLoading = false;
          _isLoadingMore = false;
        });
        return;
      }

      final result = await _flagReportService.getFlagReports(
        sessionCookie: sessionCookie,
        limit: _pageSize,
        pageToken: pageToken,
      );

      final snapshot = result['snapshot'];
      final List<dynamic> rawList = snapshot is List ? snapshot : [];

      final pageItems = rawList.whereType<Map>().map((item) {
        final map = Map<String, dynamic>.from(item);
        return <String, String>{
          'systemPredicted': (map['content_type'] as String? ?? 'Unknown'),
          'correctedGenus': (map['details'] as String? ??
              map['reason'] as String? ??
              'N/A'),
          'dateFlagged': _parseDate(map['created_at']),
        };
      }).toList();

      final nextTokenValue = result['nextPageToken'];
      final String? nextToken =
          (nextTokenValue == null || nextTokenValue.toString().trim().isEmpty)
              ? null
              : nextTokenValue.toString();

      if (!mounted) return;
      setState(() {
        if (pageToken == null) {
          _flagReports = pageItems;
        } else {
          _flagReports = [..._flagReports, ...pageItems];
        }
        _nextPageToken = nextToken;
        _error = null;
        _isLoading = false;
      });

      _filterReports();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load flag history: ${e.toString()}';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _filterReports() {
    final query = searchController.text.toLowerCase();
    setState(() {
      _filteredReports = _flagReports.where((report) {
        return (report['systemPredicted'] ?? '').toLowerCase().contains(query) ||
            (report['correctedGenus'] ?? '').toLowerCase().contains(query) ||
            (report['dateFlagged'] ?? '').toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(
        title: 'Flagged History',
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 15.0,
          right: 15.0,
          top: 20.0,
          bottom: 30.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flagged History',
              style: TextStyle(
                fontSize: 36,
                fontFamily: 'Montserrat-Black',
                color: MoldifyColors.primaryColor,
              ),
            ),
            Text(
              'View your previously flagged mold identifications below.',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Bricolage-Grotesque-Regular',
                color: MoldifyColors.MoldifyBlack,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: BuildTextBox(
                hintText: 'Search History',
                controller: searchController,
                showPassword: false,
                rightIcon: FontAwesomeIcons.magnifyingGlass,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: AppLoadingSpinner())
                  : _error != null
                      ? EmptyState(
                          message: _error!,
                          height: MediaQuery.of(context).size.height - 300,
                          icon: FontAwesomeIcons.flag,
                        )
                      : _filteredReports.isEmpty
                          ? EmptyState(
                              message: 'No flagged mold history available.',
                              height: MediaQuery.of(context).size.height - 300,
                              icon: FontAwesomeIcons.flag,
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              itemCount: _filteredReports.length +
                                  (_isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _filteredReports.length) {
                                  return const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 20.0),
                                    child: Center(child: AppLoadingSpinner()),
                                  );
                                }
                                final flagged = _filteredReports[index];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: FlagHistoryTile(
                                    systemPredicted:
                                        flagged['systemPredicted']!,
                                    correctedGenus: flagged['correctedGenus']!,
                                    dateFlagged: flagged['dateFlagged']!,
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
