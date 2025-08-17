import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../misc/appbar/secondary_appbar.dart';
import '../misc/colors.dart';

/// ReportBugScreen is a screen that allows users to report bugs in the application.

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final TextEditingController reportBugController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: SecondaryAppBar(
        title: 'Contact Us',
        color: MoldifyColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// -------- Contact Us Header Image --------
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: SvgPicture.asset(
                'assets/images/contact_us_curve.svg',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ),
            /// -------- End of Contact Us Header Image --------
            Padding(padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 30.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.0),
                    /// -------- Contact Us Header --------
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                          'CONTACT US',
                          style: TextStyle(
                            fontSize: 32,
                            fontFamily: 'Montserrat-Black',
                            color: MoldifyColors.primaryColor,
                          )
                      ),
                    ),
                    Text(
                        'Have mycology concerns? Contact their organization using details below.',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Bricolage-Grotesque-Regular',
                          color: MoldifyColors.MoldifyBlack,
                        )
                    ),
                    /// -------- End of Contact Us Header --------

                    Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.phoneVolume,
                            color: MoldifyColors.accentColor,
                            size: 24,
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            '+63 919 003 0344',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Bricolage-Grotesque-Regular',
                              color: MoldifyColors.MoldifyBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.solidEnvelope,
                            color: MoldifyColors.accentColor,
                            size: 24,
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            'mycologicalsoc.ph@gmail.com',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Bricolage-Grotesque-Regular',
                              color: MoldifyColors.MoldifyBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/facebook-icon.svg',
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            'Mycological Society of the Philippines',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Bricolage-Grotesque-Regular',
                              color: MoldifyColors.MoldifyBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/instagram-icon.svg',
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            'amagngpinas',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Bricolage-Grotesque-Regular',
                              color: MoldifyColors.MoldifyBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
              ),
            ),
          ],
        ),
      ),
    );
  }
}