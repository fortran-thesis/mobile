import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/support/report_a_curator.dart';
import 'package:provider/provider.dart';
import '../../../core/features/wikimold/models/wikimold.dart';
import '../../../core/features/wikimold/services/wikimold_services.dart';
import '../../../providers/auth_provider.dart';
import '../../misc/colors.dart';
import '../../misc/images/cover_image.dart';
import 'package:moldify/core/utils/logger.dart';


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

      AppLogger.d('Fetching article with ID: ${widget.articleId}');
      final article = await _wikiService.fetchWikiArticleById(
        articleId: widget.articleId,
        sessionCookie: cookie,
      );
      AppLogger.d('Article loaded successfully: ${article.title}');

      if (!mounted) return;
      setState(() {
        _article = article;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.e('Error loading article', error: e);
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String publishedDate = _article?.createdAt != null
        ? DateFormat('MMMM d, yyyy').format(_article!.createdAt!.toLocal())
        : 'Unknown date';

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: MoldifyColors.primaryColor,
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(
        title: 'View Wikimold',
        rightIcon: const Icon(Icons.report),
        rightIconColor: MoldifyColors.MoldifyRed,
        onRightIconPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ReportACuratorScreen(
                contentId: _article!.id,
                contentType: 'wiki-article',
              ),
            ),
          );
        },
      ),
      body: SingleChildScrollView(
  child: Stack(
    children: [
      // Header cover image section
      if (_article!.coverPhoto != null)
        BuildCoverImage(
          imageUrl: _article!.coverPhoto!,
          borderRadiusContainer: 0, // Set to 0 to fill top edges like the screenshot
          borderRadiusImage: 0,
          isHeader: true,
        )
      else
        Container(
          height: 220,
          color: MoldifyColors.MoldifySoftGrey,
        ),

      // Main content section with overlapping rounded top corners
      Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.23,
        ),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: MoldifyColors.backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0), // Increased for the screenshot look
              topRight: Radius.circular(30.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author Profile Section
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: MoldifyColors.MoldifySoftGrey,
                      child: Icon(Icons.person, color: MoldifyColors.primaryColor), 
                      // Replace Icon with BackgroundImage: NetworkImage(_article!.authorPfp) if available
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _article!.author,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Bricolage-Grotesque-SemiBold',
                            color: MoldifyColors.MoldifyBlack,
                          ),
                        ),
                        Text(
                          publishedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: MoldifyColors.MoldifySoftGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                
                // Article Title
                Text(
                  _article!.title,
                  style: const TextStyle(
                    fontFamily: 'Montserrat-Black',
                    fontSize: 24, // Increased for emphasis
                    fontWeight: FontWeight.bold,
                    color: MoldifyColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 20),

                // Body Content with Drop Cap and HTML rendering
                Html(
                  data: _article!.body,
                  style: {
                    'body': Style(
                      fontFamily: 'Bricolage-Grotesque-Regular',
                      fontSize: FontSize(16),
                      lineHeight: LineHeight(1.6),
                      color: MoldifyColors.MoldifyBlack,
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                    ),
                    // Drop Cap logic: targets the first paragraph's first-letter
                    'p:first-child::first-letter': Style(
                      fontSize: FontSize(45),
                      fontWeight: FontWeight.bold,
                      margin: Margins.only(right: 8, top: 4),
                      fontFamily: 'Montserrat-Black',
                    ),
                    'h2': Style(
                      fontFamily: 'Montserrat-Black',
                      fontSize: FontSize(20),
                      color: MoldifyColors.primaryColor,
                      margin: Margins.only(top: 20, bottom: 8),
                    ),
                    'h3': Style(
                      fontFamily: 'Montserrat-Black',
                      fontSize: FontSize(17),
                      color: MoldifyColors.accentColor,
                      margin: Margins.only(top: 16, bottom: 6),
                    ),
                    'p': Style(
                      margin: Margins.only(bottom: 12),
                      textAlign: TextAlign.justify,
                    ),
                    'strong': Style(
                      fontFamily: 'Bricolage-Grotesque-SemiBold',
                    ),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  ),
)
    );
  }
}
