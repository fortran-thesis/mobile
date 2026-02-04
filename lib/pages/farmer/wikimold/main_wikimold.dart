import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/farmer/wikimold/view_wikimold.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/textboxes/textboxes.dart';
import 'package:provider/provider.dart';
import '../../../core/features/wikimold/models/wikimold.dart';
import '../../../core/features/wikimold/services/wikimold_services.dart';
import '../../../providers/auth_provider.dart';
import '../../misc/functions/empty_state.dart';
import '../../misc/tiles/wikimold_tiles.dart';


class MainWikiMoldScreen extends StatefulWidget {
  const MainWikiMoldScreen({super.key});

  @override
  State<MainWikiMoldScreen> createState() => _MainWikiMoldScreenState();
}

class _MainWikiMoldScreenState extends State<MainWikiMoldScreen> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final WikiService _wikiService = WikiService();

  List<WikiArticle> _articles = [];
  List<WikiArticle> _filteredArticles = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _nextPageToken;

  @override
  void initState() {
    super.initState();
    _loadData();

    // Search listener
    searchController.addListener(_filterArticles);

    // Scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreData();
      }
    });
  }

  @override
  void dispose() {
    searchController.removeListener(_filterArticles);
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _filterArticles() {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredArticles = List.from(_articles));
    } else {
      setState(() {
        _filteredArticles = _articles
            .where((article) => article.title.toLowerCase().contains(query))
            .toList();
      });
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;

      if (sessionCookie == null) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentication error. Please log in again.')),
          );
        }
        return;
      }

      final result = await _wikiService.fetchMoldipedia(
        sessionCookie: sessionCookie,
      );
      if (!mounted) return;
      setState(() {
        _articles = result['articles'];
        _filteredArticles = List.from(_articles);
        _nextPageToken = result['nextPageToken'];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading articles: $e')),
        );
      }
    }
  }

  Future<void> _loadMoreData() async {
    if (_nextPageToken == null || _isLoadingMore || !mounted) return;
    setState(() => _isLoadingMore = true);

    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;

      if (sessionCookie == null) {
        if(mounted) setState(() => _isLoadingMore = false);
        return;
      }

      final result = await _wikiService.fetchMoldipedia(
        pageToken: _nextPageToken,
        sessionCookie: sessionCookie,
      );
      if (!mounted) return;
      setState(() {
        _articles.addAll(result['articles']);
        _filterArticles(); // Update filtered list after loading more
        _nextPageToken = result['nextPageToken'];
        _isLoadingMore = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading more articles: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(title: 'WikiMold'),
      body: Column(
        children: [
          // Header + Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WikiMold',
                  style: TextStyle(
                    fontSize: 36,
                    fontFamily: 'Montserrat-Black',
                    color: MoldifyColors.primaryColor,
                  ),
                ),
                Text(
                  'Your go-to mold encyclopedia.',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    color: MoldifyColors.MoldifyBlack,
                  ),
                ),
                const SizedBox(height: 20),
                BuildTextBox(
                  hintText: 'Search WikiMold',
                  controller: searchController,
                  showPassword: false,
                  rightIcon: FontAwesomeIcons.magnifyingGlass,
                ),
              ],
            ),
          ),

          // List of articles
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredArticles.isEmpty
                ? EmptyState(
              message: 'No articles match your search.',
              height: MediaQuery.of(context).size.height - 300,
              icon: FontAwesomeIcons.bookOpen,
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: _filteredArticles.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _filteredArticles.length) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final article = _filteredArticles[index];
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: WikiMoldTile(
                    title: article.title,
                    authorName: 'Author: ${article.author}',
                    imageUrl: article.coverPhoto,
                      onTap: () {
                        if(article.id.length >= 22) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ViewWikiMoldScreen(articleId: article.id),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('This article is not available yet.'),
                            ),
                          );
                        }
                      }
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
