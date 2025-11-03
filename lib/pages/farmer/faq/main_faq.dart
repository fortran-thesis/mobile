import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';

import '../../misc/colors.dart';
import '../../misc/functions/empty_state.dart';
import '../../misc/textboxes/textboxes.dart';
import '../../misc/tiles/expansion_tile.dart';

class MainFAQSCreen extends StatefulWidget {
  const MainFAQSCreen({super.key});

  @override
  State<MainFAQSCreen> createState() => _MainFAQSCreenState();
}
class _MainFAQSCreenState extends State<MainFAQSCreen> {
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, String?>> faq = [
    {
      'title': 'What is Moldify and how can it help me as a farmer?',
      'content': 'Moldify helps farmers monitor their crops, record mold occurrences, and learn preventive measures to keep plants healthy and disease-free.',
    },
    {
      'title': 'How do I create a new report?',
      'content': 'Go to the “Reports” section and click the "Submit Report" button. You can add details about your crop, the affected part, and any visible signs of mold.',
    },
    {
      'title': 'Can I track the progress of my crops over time?',
      'content': 'Yes. Moldify allows you to review your previous reports so you can monitor how your crops improve or worsen over time.',
    },
    {
      'title': 'What should I do if I notice mold on my plants?',
      'content': 'Document it immediately using Moldify’s report feature, then follow the prevention and treatment advice given by the app.',
    },
    {
      'title': 'Are the recommended fungicides safe to use?',
      'content': 'Yes. All recommended fungicides listed in Moldify are verified and approved by experts from the Bureau of Plant Industry (BPI). Always follow product labels and safety instructions when applying them.',
    },
    {
      'title': 'Can I use household remedies instead of fungicides?',
      'content': 'Yes, you can. Moldify also suggests alternative or organic treatment methods when available. These can be helpful for small-scale or organic farmers.',
    },
    {
      'title': 'How can I prevent mold growth on my crops?',
      'content': 'Avoid overcrowding plants, provide good air circulation, remove infected leaves immediately, and water early in the morning to allow faster drying.',
    },
    {
      'title': 'How often should I inspect my crops for molds?',
      'content': 'Inspect your crops at least once a week, especially during humid or rainy seasons when molds spread quickly.',
    },
    {
      'title': 'Can I use Moldify for any kind of plant?',
      'content': 'Moldify currently focuses on common agricultural crops such as rice, corn, and vegetables. More crops will be added in future updates.',
    },
    {
      'title': 'Can I get advice from experts through the app?',
      'content': 'Moldify provides expert-reviewed content and recommendations from agricultural specialists. Future updates may include direct expert consultation.',
    },
    {
      'title': 'Who can I contact for app support?',
      'content': 'For technical issues or feedback, open the sidebar and choose either “Send Feedback” or “Report a Bug”. Our team will review your message.',
    },
  ];

  // This list will hold the filtered results
  late List<Map<String, String?>> filteredFaq;

  @override
  void initState() {
    super.initState();
    filteredFaq = faq; // initially, all FAQs are shown


    // Add search listener
    searchController.addListener(() {
      final query = searchController.text.toLowerCase();
      setState(() {
        if (query.isEmpty) {
          filteredFaq = List.from(faq);
        } else {
          filteredFaq = faq.where((item) {
            final title = item['title']?.toLowerCase() ?? '';
            final content = item['content']?.toLowerCase() ?? '';
            return title.contains(query) || content.contains(query);
          }).toList();
        }
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: const PrimaryAppBar(title: 'FAQ'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// FAQ Header
              const Text(
                'FAQ',
                style: TextStyle(
                  fontSize: 36,
                  fontFamily: 'Montserrat-Black',
                  color: MoldifyColors.primaryColor,
                ),
              ),
              const Text(
                'Got a question? Find quick answers here.',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Bricolage-Grotesque-Regular',
                  color: MoldifyColors.MoldifyBlack,
                ),
              ),
              /// End of Header

              /// Search Box
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: BuildTextBox(
                  hintText: 'Search FAQ',
                  controller: searchController,
                  showPassword: false,
                  rightIcon: FontAwesomeIcons.magnifyingGlass,
                ),
              ),

                filteredFaq.isEmpty
                    ? EmptyState(
                  message: 'No FAQs matched your search.',
                  height: MediaQuery.of(context).size.height - 300,
                  icon: FontAwesomeIcons.solidCircleXmark,
                ):
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredFaq.length,
                  itemBuilder: (context, index) {
                    final question = filteredFaq[index];
                    return Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: CustomExpansionTile(
                        title: question['title'] ?? '',
                        content: question['content'] ?? '',
                      ),
                    );

                  },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
