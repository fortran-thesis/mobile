import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/images/circle_avatar.dart';
import 'package:moldify/pages/support/report_a_curator.dart';

import '../misc/colors.dart';

class ViewWikiMoldScreen extends StatefulWidget {
  final String articleTitle;
  final String articleAuthor;
  final String articleImageUrl;

  const ViewWikiMoldScreen({super.key,
    required this.articleTitle,
    required this.articleAuthor,
    required this.articleImageUrl,
  });

  @override
  State<ViewWikiMoldScreen> createState() => _ViewWikiMoldScreenState();
}


class _ViewWikiMoldScreenState extends State<ViewWikiMoldScreen> {
  String datePublished = 'June 1, 2024';
  String articleContent = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
      'Ut et massa mi. Aliquam in hendrerit urna. Pellentesque sit amet sapien fringilla,'
      ' mattis ligula consectetur, ultrices mauris. Maecenas vitae mattis tellus. Nullam quis '
      'imperdiet augue. Vestibulum auctor ornare leo, non suscipit magna interdum eu. Curabitur '
      'pellentesque nibh nibh, at maximus ante fermentum sit amet. Pellentesque commodo lacus at '
      'sodales sodales. Quisque sagittis orci ut diam condimentum, vel euismod erat placerat. '
      'In iaculis arcu eros, eget tempus orci facilisis id.Lorem ipsum dolor sit amet, consectetur '
      'adipiscing elit. Ut et massa mi. Aliquam in hendrerit urna. Pellentesque sit amet sapien '
      'fringilla, mattis ligula consectetur, ultrices mauris. Maecenas vitae mattis tellus. '
      'Nullam quis imperdiet augue. Vestibulum auctor ornare leo, non suscipit magna interdum eu. '
      'Curabitur pellentesque nibh nibh, at maximus ante fermentum sit amet. Pellentesque commodo lacus at '
      'sodales sodales. Quisque sagittis orci ut diam condimentum, vel euismod erat placerat. In iaculis arcu eros, '
      'eget tempus orci facilisis id. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut et massa mi. '
      'Aliquam in hendrerit urna. Pellentesque sit amet sapien fringilla, mattis ligula consectetur, ultrices'
      ' mauris. Maecenas vitae mattis tellus. Nullam quis imperdiet augue. Vestibulum auctor ornare leo, non s'
      'uscipit magna interdum eu. Curabitur pellentesque nibh nibh, at maximus ante fermentum sit amet. Pellentesque commodo ';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(
        title: 'View WikiMold',
        rightIcon: Icon(
          Icons.report,
        ),
        onRightIconPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ReportACuratorScreen(),
            ),
          );
        },
        rightIconColor: MoldifyColors.MoldifyRed,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: Stack(
            children: [
              /// 1. Article Image
              Image.asset(
                widget.articleImageUrl,
                height: MediaQuery.of(context).size.height * 0.3,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    color: MoldifyColors.MoldifySoftGrey,
                    child: const Center(
                        child: Icon(Icons.broken_image,
                            color: MoldifyColors.primaryColor)),
                  );
                },
              ),

              /// 2. Article Information and Content
              Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: MoldifyColors.backgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.articleTitle,
                          style: TextStyle(
                            fontFamily: 'Montserrat-Black',
                            fontSize: 20,
                            color: MoldifyColors.primaryColor,
                            height: 1.2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),

                          /// Author and Date Published
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [

                              /// Author's Profile Image and Author Name
                              Row(
                                children: [
                                  CircleAvatarImage(
                                    radius: 15.0,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'By ${widget.articleAuthor}',
                                    style: TextStyle(
                                      fontFamily: 'Bricolage-Grotesque-Regular',
                                      fontSize: 14,
                                      color: MoldifyColors.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              /// End of Author's Profile Image and Author Name

                              /// Date Published
                              Row(
                                children: [
                                  Icon (
                                    FontAwesomeIcons.solidCalendar,
                                    size: 12,
                                    color: MoldifyColors.accentColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    datePublished ?? 'Unknown Date',
                                    style: TextStyle(
                                      fontFamily: 'Bricolage-Grotesque-Regular',
                                      fontSize: 14,
                                      color: MoldifyColors.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          /// End of Author and Date Published
                        ),

                        /// Article Content
                        Text(
                          articleContent,
                          style: TextStyle(
                            fontFamily: 'Bricolage-Grotesque-Regular',
                            fontSize: 16,
                            color: MoldifyColors.MoldifyBlack,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}