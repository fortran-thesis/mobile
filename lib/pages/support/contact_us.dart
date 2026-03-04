import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../misc/appbar/secondary_appbar.dart';
import '../misc/colors.dart';

/// ReportBugScreen is a screen that allows users to report bugs in the application.

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

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
                        'Reach out to us for any inquiries regarding agricultural mold detection. We\'re here to help you cultivate a healthier future for agriculture.',
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
                          Flexible(
                            child: InkWell(
                              onTap: () => _launchUrl('tel:282489130'),
                              child: Text(
                                '282489130',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Bricolage-Grotesque-Regular',
                                  color: MoldifyColors.MoldifyBlack,
                                  decoration: TextDecoration.underline,
                                ),
                                softWrap: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            FontAwesomeIcons.solidEnvelope,
                            color: MoldifyColors.accentColor,
                            size: 24,
                          ),
                          const SizedBox(width: 30.0),
                          Flexible(
                            child: InkWell(
                              onTap: () => _launchUrl('mailto:info@buplant.da.gov.ph'),
                              child: Text(
                                'info@buplant.da.gov.ph',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Bricolage-Grotesque-Regular',
                                  color: MoldifyColors.MoldifyBlack,
                                  decoration: TextDecoration.underline,
                                ),
                                softWrap: true,
                              ),
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
                          Flexible(
                            child: InkWell(
                              onTap: () => _launchUrl('https://web.facebook.com/BureauOfPlantIndustry'),
                              child: Text(
                                'Bureau of Plant Industry',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Bricolage-Grotesque-Regular',
                                  color: MoldifyColors.MoldifyBlack,
                                  decoration: TextDecoration.underline,
                                ),
                                softWrap: true,
                              ),
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
                            FontAwesomeIcons.locationDot,
                            color: MoldifyColors.accentColor,
                            size: 24,
                          ),
                          SizedBox(width: 30.0),
                          Flexible(
                            child: InkWell(
                              onTap: () => _launchUrl('https://maps.google.com/?q=692+San+Andres+St,+Malate,+Manila'),
                              child: Text(
                                '692 San Andres St, Malate, Manila.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Bricolage-Grotesque-Regular',
                                  color: MoldifyColors.MoldifyBlack,
                                  decoration: TextDecoration.underline,
                                ),
                                softWrap: true,
                              ),
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