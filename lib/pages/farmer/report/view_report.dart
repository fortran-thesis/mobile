import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/farmer/report/content_tab/prevention_tactics_content.dart';

import '../../../core/constants/route_names.dart';
import '../../misc/appbar/primary_app_bar.dart';
import '../../misc/buttons/primary_button.dart';
import '../../misc/colors.dart';
import '../../misc/functions/tab_bar.dart';
import '../../misc/images/cover_image.dart';
import '../../misc/overlays/modals/confirmation_dialog.dart';
import '../../misc/tiles/status_tile.dart';
import '../../monitor/content_tab/case_details.dart';

class ViewReportScreen extends StatefulWidget {
  const ViewReportScreen({super.key});

  @override
  State<ViewReportScreen> createState() => _ViewReportScreenState();
}

class _ViewReportScreenState extends State<ViewReportScreen> {
  String? caseImageUrl = "https://aggie-horticulture.tamu.edu/wp-content/uploads/sites/10/2012/01/black_mold.jpg";
  // Change the status to 'Resolved', 'Closed', 'In Progress', or 'Rejected' to see different UI states.
  String caseStatus = 'Resolved';

  /// Builds a centered text widget to display messages for non-resolved statuses.
  Widget _buildStatusMessageWidget(String status) {
    String message;
    switch (status) {
      case 'Pending':
        message = 'Your report has been sent in and is now waiting to be checked.';
        break;
      case 'In Progress':
        message = 'We\'re checking your report now. You\'ll see the results when it\'s ready.';
        break;
      case 'Rejected':
        message = 'Sorry, your report was rejected and can\'t be processed.';
        break;
      default:
      // Return an empty widget if the status is not one of the above.
        return const SizedBox.shrink();
    }

    return Center(
      child: SizedBox(
          height: MediaQuery.of(context).size.height - 400,
          child: Center(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Bricolage-Grotesque-Regular',
                color: MoldifyColors.MoldifyGrey,
                height: 1.5,
              ),
            ),
          )
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MoldifyColors.backgroundColor,
        appBar: PrimaryAppBar(
            title: 'View Case',
            showPopupMenu: true,
            popupMenuItems: ['Treatment History', 'Export PDF'],
            popupMenuIcons: [FontAwesomeIcons.clockRotateLeft, FontAwesomeIcons.sprayCan],
            onPopupMenuItemSelected: (index) {
              // Handle the selection based on the index

              /// Treatment History
              if (index == 0) {
                Navigator.pushNamed(
                  context,
                  '/treatment-history',
                );
              }
              /// End of Identification History

              /// Export PDF
              else if (index == 1) {
                // Navigator.pushNamed(
                //   context,
                //   '/treatment-history',
                // );
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
                    padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                            alignment: Alignment.centerRight,
                            child: StatusBox(status: caseStatus)
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
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

                        // Conditional UI based on case status
                        if (caseStatus == 'Resolved' || caseStatus == 'Closed')
                          Column(
                            children: [
                              // Buttons are only visible if the case is 'Resolved'
                              if (caseStatus == 'Resolved')
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Row (
                                    children: [
                                      /// Close Case Button
                                      BuildButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return BuildConfirmationDialog(
                                                title: 'Are you sure you want to close this report?',
                                                subtitle: 'Once closed, you will not be able to add follow-ups.',
                                                onConfirm: () {
                                                  Navigator.of(context).pop();
                                                  Navigator.of(context).pop();
                                                },
                                                onCancel: (){
                                                  Navigator.of(context).pop();
                                                },
                                              );
                                            },
                                          );
                                        },
                                        buttonText: 'Close Case',
                                        fontSize: 12,
                                        backgroundColor: MoldifyColors.primaryColor,
                                        textColor: MoldifyColors.backgroundColor,
                                        leftIcon: FontAwesomeIcons.solidCircleCheck,
                                        iconSize: 12,
                                        iconColor: MoldifyColors.backgroundColor,
                                        paddingIconText: 10,
                                        buttonHeight: 30,
                                        buttonWidth: 120,
                                        buttonRadius: 7,
                                      ),
                                      SizedBox(width: 5),

                                      /// Create Follow-up Button
                                      BuildButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/add-follow-up',
                                          );
                                        },
                                        buttonText: 'Add Follow-up',
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
                                // Add top padding if the buttons are hidden
                                padding: EdgeInsets.only(top: caseStatus == 'Closed' ? 20.0 : 10.0),
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.7,
                                  child: BuildTabBar(
                                    tabs: ['Case Details', 'Prevention Tactics'],
                                    tabContents: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                        child: CaseDetailsTab(),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                        child: PreventionTacticsContent(
                                          recommendedFungicides: [
                                            'Mancozeb',
                                            'Chlorothalonil',
                                            'Copper-based fungicides',
                                            'Azoxystrobin'
                                          ],
                                          additionalInformation: 'To prevent future outbreaks, ensure proper plant spacing for good air circulation, water at the base of plants to keep foliage dry, and promptly remove and destroy any infected plant debris. Rotate crops annually and consider using resistant varieties if available.',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )
                        else
                          _buildStatusMessageWidget(caseStatus),
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