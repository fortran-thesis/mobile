import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/farmer/wikimold/view_wikimold.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/textboxes/textboxes.dart';
import '../../misc/functions/empty_state.dart';
import '../../misc/tiles/wikimold_tiles.dart';


class MainWikiMoldScreen extends StatefulWidget {
  const MainWikiMoldScreen({super.key});

  @override
  State<MainWikiMoldScreen> createState() => _MainWikiMoldScreenState();
}
class _MainWikiMoldScreenState extends State<MainWikiMoldScreen> {
  final TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {

    /// Sample data for WikiMold articles
    final List<Map<String, String?>> wikiArticles = [
      {
        'title': 'The Rise of Molds: Dive into the Microscopic Landscape of Growing Fungi',
        'authorName': 'Karl Manuel Diata',
        'imageUrl': null,
      },
      {
        'title': 'Understanding Aspergillus: A Common Household Mold',
        'authorName': 'Jane Doe',
        'imageUrl': null,
      },
      {
        'title': 'Penicillium: The Fungus That Gave Us Penicillin',
        'authorName': 'John Smith',
        'imageUrl': null,
      },
      {
        'title': 'Stachybotrys (Black Mold): Risks and Remediation',
        'authorName': 'Dr. Emily Carter',
        'imageUrl': null,
      },
      {
        'title': 'The Colorful World of Fusarium',
        'authorName': 'Dr. Alan Grant',
        'imageUrl': null,
      },
    ];
    /// End of sample data

    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(
          title: 'WikiMold',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ----------- WikiMold Header -----------
              Text(
                  'WikiMold',
                  style: TextStyle(
                    fontSize: 36,
                    fontFamily: 'Montserrat-Black',
                    color: MoldifyColors.primaryColor,
                  )
              ),
              Text(
                  'Your go-to mold encyclopedia.',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    color: MoldifyColors.MoldifyBlack,
                  )
              ),
              /// ----------- End of WikiMold Header -----------
              /// Search Box
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: BuildTextBox(
                    hintText: 'Search WikiMold',
                    controller: searchController,
                    showPassword: false,
                    rightIcon: FontAwesomeIcons.magnifyingGlass,
                ),
              ),

              /// List of WikiMold Articles
              wikiArticles.isEmpty
                  ? EmptyState(
                message: 'No WikiMold is published yet.',
                height: MediaQuery.of(context).size.height - 300,
                icon: FontAwesomeIcons.bookOpen,
              ):
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: wikiArticles.length,
                itemBuilder: (context, index) {
                  final article = wikiArticles[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: WikiMoldTile(
                      title: article['title']!,
                      authorName: article['authorName']!,
                      imageUrl: article['imageUrl'],
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ViewWikiMoldScreen(
                              articleAuthor: article['authorName']!,
                              articleTitle: article['title']!,
                              articleImageUrl: article['imageUrl'] ?? 'assets/images/Branding2.png',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              )
              /// End of List of WikiMold Articles
            ],
          ),
        ),
      ),
    );
  }
}