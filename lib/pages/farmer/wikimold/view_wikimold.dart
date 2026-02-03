import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/images/circle_avatar.dart';
import 'package:moldify/pages/support/report_a_curator.dart';
import 'package:provider/provider.dart';
import '../../../core/features/wikimold/models/wikimold.dart';
import '../../../core/features/wikimold/services/wikimold_services.dart';
import '../../../providers/auth_provider.dart';
import '../../misc/colors.dart';
import '../../misc/images/cover_image.dart';


class ViewWikiMoldScreen extends StatefulWidget {
  final String articleId;

  const ViewWikiMoldScreen({super.key, required this.articleId});

  @override
  State<ViewWikiMoldScreen> createState() => _ViewWikiMoldScreenState();
}

class _ViewWikiMoldScreenState extends State<ViewWikiMoldScreen> {
  final WikiService _wikiService = WikiService();
  WikiArticle? _article;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    setState(() => _isLoading = true);
    try {
      final authProvider =
      Provider.of<AppAuthProvider>(context, listen: false);
      final cookie = authProvider.cookie;

      if (cookie == null) {
        setState(() {
          _error = 'Authentication error. Please log in again.';
          _isLoading = false;
        });
        return;
      }

      final article = await _wikiService.fetchWikiArticleById(
        articleId: widget.articleId,
        sessionCookie: cookie,
      );

      if (!mounted) return;
      setState(() {
        _article = article;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(title: _article!.title),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_article!.coverPhoto != null)
                BuildCoverImage(
                  imageUrl: _article!.coverPhoto!,
                  borderRadiusContainer: 8,
                  borderRadiusImage: 8,
                  isHeader: true,
                ),
              const SizedBox(height: 20),
              Text(
                _article!.title,
                style: const TextStyle(
                  fontFamily: 'Montserrat-Black',
                  fontSize: 24,
                  color: MoldifyColors.primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'By ${_article!.authorId}',
                style: const TextStyle(
                  fontFamily: 'Bricolage-Grotesque-Regular',
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _article!.body,
                style: const TextStyle(
                  fontFamily: 'Bricolage-Grotesque-Regular',
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
