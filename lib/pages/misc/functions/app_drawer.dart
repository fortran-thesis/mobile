import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/auth/login.dart';
import 'package:moldify/pages/home/report_bug.dart';
import 'package:moldify/pages/home/send_feedback.dart';
import 'package:moldify/pages/misc/colors.dart';
import '../../settings/main_account_settings.dart';

/// AppDrawer is a custom side bar widget that provides navigation options
/// for the Moldify application.
/// It includes options for Terms of Use, Privacy Policy, Send Feedback,
/// Report A Bug, Contact Us, Account Settings, and Log Out.

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 270,
      child: Drawer(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        backgroundColor: MoldifyColors.backgroundColor,

        child: SafeArea(
          bottom: true,
          top: false,
          left: false,
          right: false,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              SizedBox(
                height: 170,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: MoldifyColors.primaryColor,
                  ),
                  child: Row (
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/images/profile.png'),
                        backgroundColor: MoldifyColors.accentColor,
                      ),
                      SizedBox(width: 20),
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontFamily: 'Montserrat-Black',
                            fontSize: 24,
                            color: MoldifyColors.accentColor,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(text: 'MOLDIFY\n'),
                            TextSpan(
                              text: 'Identify Mold With Moldify',
                              style: TextStyle(
                                fontFamily: 'Bricolage-Grotesque-Regular',
                                fontSize: 12,
                                color: MoldifyColors.backgroundColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),

              /// Terms of Use
              ListTile(
                leading: Icon(
                  FontAwesomeIcons.squarePen,
                  color: MoldifyColors.accentColor,
                  size: 24,
                ),
                title: const Text(
                  'Terms of Use',
                  style: TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Bold',
                    color: MoldifyColors.primaryColor,
                    fontSize: 12
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              /// Privacy Policy
              ListTile(
                leading: const Icon(
                  Icons.privacy_tip_rounded,
                  color: MoldifyColors.accentColor,
                  size: 24,
                ),
                title: const Text(
                  'Privacy Policy',
                  style: TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Bold',
                      color: MoldifyColors.primaryColor,
                      fontSize: 12
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Container(
                  height: 1,
                  color: MoldifyColors.MoldifySoftGrey,
                ),
              ),

              /// Send Feedback
              ListTile(
                leading: const Icon(
                  Icons.feedback,
                  color: MoldifyColors.accentColor,
                  size: 24,
                ),
                title: const Text(
                  'Send Feedback',
                  style: TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Bold',
                      color: MoldifyColors.primaryColor,
                      fontSize: 12
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SendFeedbackScreen(),
                    ),
                  );
                },
              ),

              /// Report A Bug
              ListTile(
                leading: const Icon(
                  Icons.bug_report_rounded,
                  color: MoldifyColors.accentColor,
                  size: 24,
                ),
                title: const Text('Report A Bug',
                  style: TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Bold',
                      color: MoldifyColors.primaryColor,
                      fontSize: 12
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ReportBugScreen(),
                    ),
                  );
                },
              ),

              /// Contact Us
              ListTile(
                leading: Icon(
                  FontAwesomeIcons.phone,
                  color: MoldifyColors.accentColor,
                  size: 20,
                ),
                title: const Text('Contact Us',
                  style: TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Bold',
                      color: MoldifyColors.primaryColor,
                      fontSize: 12
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 120.0, bottom: 20.0),
                child: Container(
                  height: 1,
                  color: MoldifyColors.MoldifySoftGrey,
                ),
              ),

              /// Account Settings
              ListTile(
                leading: Icon(
                  FontAwesomeIcons.solidUser,
                  color: MoldifyColors.accentColor,
                  size: 22,
                ),
                title: const Text(
                  'Account Settings',
                  style: TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Bold',
                      color: MoldifyColors.primaryColor,
                      fontSize: 12
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MainAccountSettingsScreen(),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Container(
                  height: 1,
                  color: MoldifyColors.MoldifySoftGrey,
                ),
              ),

              /// Log Out
              ListTile(
                leading: Icon(
                  FontAwesomeIcons.rightFromBracket,
                  color: MoldifyColors.accentColor,
                  size: 24,
                ),
                title: const Text(
                  'Log Out',
                  style: TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Bold',
                      color: MoldifyColors.primaryColor,
                      fontSize: 12
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}