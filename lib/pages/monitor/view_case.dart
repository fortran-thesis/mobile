import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/functions/tab_bar.dart';
import 'package:moldify/pages/monitor/content_tab/case_details.dart';
import 'package:moldify/pages/monitor/content_tab/in_vitro.dart';
import 'package:moldify/pages/monitor/content_tab/in_vivo.dart';

import '../misc/appbar/primary_app_bar.dart';
import '../misc/images/cover_image.dart';
import '../misc/tiles/status_tile.dart';

class ViewCaseScreen extends StatefulWidget {

  const ViewCaseScreen({super.key});

  @override
  _ViewCaseScreenState createState() => _ViewCaseScreenState();
}
class _ViewCaseScreenState extends State<ViewCaseScreen> {
  String? caseImageUrl = "https://aggie-horticulture.tamu.edu/wp-content/uploads/sites/10/2012/01/black_mold.jpg";
  String caseStatus = 'In Progress';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(
        title: 'Set Monitoring Details',
          showPopupMenu: true,
          popupMenuItems: ['Set Monitoring Details', 'Identification History', 'Treatment History'],
          popupMenuIcons: [FontAwesomeIcons.circleInfo, FontAwesomeIcons.clockRotateLeft, FontAwesomeIcons.sprayCan],
          onPopupMenuItemSelected: (index) {
            // Handle the selection based on the index

            /// Edit Monitoring Details
            if (index == 0) {
              Navigator.pushNamed(
                context,
                '/set-monitoring-details',
              );
            }
            /// End of Monitoring Details

            /// Identification History
            else if (index == 1) {
              Navigator.pushNamed(
                context,
                '/identification-history',
              );
            }
            /// End of Identification History

            /// Treatment History
            else if (index == 2) {
              Navigator.pushNamed(
                context,
                '/treatment-history',
              );
            }
            /// End of Treatment History
          }
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [

            ///1. Cover image for the case
            BuildCoverImage(
              imageUrl: caseImageUrl,
              borderRadiusContainer: 8,
              borderRadiusImage: 8,
              isHeader: true,
            ),

            ///2. Case details
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.23),
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
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0, bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: StatusBox(
                            status: caseStatus
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Tomato Mold',
                          style: TextStyle(
                            fontFamily: 'Montserrat-Black',
                            fontSize: 24,
                            color: MoldifyColors.primaryColor,
                            height: 1.2,
                          ),
                        ),
                      ),
                      /// Crop Name
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: RichText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Icon(
                                      FontAwesomeIcons.seedling,
                                      size: 16,
                                      color: MoldifyColors.accentColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "			Kamatis Tagalog",
                                    style: TextStyle(
                                      color: MoldifyColors.primaryColor,
                                      fontSize: 12,
                                      fontFamily:
                                      'Bricolage-Grotesque-Regular',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: RichText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Icon(
                                      FontAwesomeIcons.locationDot,
                                      size: 16,
                                      color: MoldifyColors.accentColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "			Ilocos Region",
                                    style: TextStyle(
                                      color: MoldifyColors.primaryColor,
                                      fontSize: 12,
                                      fontFamily:
                                      'Bricolage-Grotesque-Regular',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Row (
                          children: [
                            BuildButton(
                                onPressed: () {
                                  // Navigator.pushNamed(
                                  //   context,
                                  //   '/set-monitoring-details',
                                  // );
                                },
                                buttonText: 'Identify Mold',
                                fontSize: 12,
                                backgroundColor: MoldifyColors.primaryColor,
                                textColor: MoldifyColors.backgroundColor,
                                leftIcon: FontAwesomeIcons.camera,
                                iconSize: 12,
                                iconColor: MoldifyColors.backgroundColor,
                                paddingIconText: 10,
                                buttonHeight: 30,
                                buttonWidth: 120,
                                buttonRadius: 7,
                            ),
                            SizedBox(width: 5),
                            BuildButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/add-treatment',
                                );
                              },
                              buttonText: 'Add Treatment',
                              fontSize: 12,
                              backgroundColor: MoldifyColors.accentColor,
                              textColor: MoldifyColors.MoldifyBlack,
                              leftIcon: FontAwesomeIcons.plus,
                              iconSize: 12,
                              iconColor: MoldifyColors.MoldifyBlack,
                              paddingIconText: 10,
                              buttonHeight: 30,
                              buttonWidth: 120,
                              buttonRadius: 7,
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: BuildTabBar(
                            tabs: ['Case Details', 'In Vitro', 'In Vivo'],
                            tabContents: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                child: CaseDetailsTab(),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                child: InVitroTab(),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                child: InVivoTab(),
                              ),
                            ],
                          ),
                        ),
                      )
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