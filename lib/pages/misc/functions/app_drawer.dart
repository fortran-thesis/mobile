import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/core/features/user/logic/user_bloc.dart';
import 'package:moldify/core/features/user/services/user_services.dart';
import 'package:moldify/pages/farmer/faq/main_faq.dart';
import 'package:moldify/pages/support/contact_us.dart';
import 'package:moldify/pages/support/privacy_policy.dart';
import 'package:moldify/pages/support/report_bug.dart';
import 'package:moldify/pages/support/send_feedback.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/support/terms_of_agreement.dart';
import '../../../core/constants/route_names.dart';
import '../../settings/main_account_settings.dart';
import 'package:provider/provider.dart';
import 'package:moldify/providers/auth_provider.dart';
import 'package:moldify/core/utils/auth_navigation.dart';
import 'package:moldify/l10n/app_localizations.dart';

/// AppDrawer is a custom side bar widget that provides navigation options
/// for the Moldify application.
/// It includes options for Terms of Use, Privacy Policy, Send Feedback,
/// Report A Bug, Contact Us, Account Settings, and Log Out.

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late UserBloc _userBloc;
  StreamSubscription? _userSub;
  bool _isExpert = false; // Default to non-expert

  @override
  void initState() {
    super.initState();
    _userBloc = UserBloc(userService: UserService());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;
      if (sessionCookie != null) {
        _userBloc.add(FetchUserProfile(sessionCookie: sessionCookie));
      }
    });

    _userSub = _userBloc.stream.listen((state) {
      if (state is UserProfileLoaded) {
        final role = state.profile.role.toLowerCase();
        final isExpertUser = !(role == 'farmer' || role == 'user');
        if (mounted && isExpertUser != _isExpert) {
          setState(() {
            _isExpert = isExpertUser;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _userBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: SizedBox(
        width: 270,
        child: Drawer(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
                    decoration: const BoxDecoration(
                      color: MoldifyColors.primaryColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/images/moldify-logo.png',
                          height: 70,
                          width: 70,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: AutoSizeText.rich(
                            TextSpan(
                              style: const TextStyle(
                                fontFamily: 'Montserrat-Black',
                                fontSize: 24,
                                color: MoldifyColors.backgroundColor,
                                height: 1.5,
                              ),
                              children: [
                                const TextSpan(text: 'MOLDIFY\n'),
                                TextSpan(
                                  text: l10n.drawerTitle,
                                  style: const TextStyle(
                                    fontFamily: 'Bricolage-Grotesque-Regular',
                                    fontSize: 12,
                                    color: MoldifyColors.backgroundColor,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 3,
                            minFontSize: 10,
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// Terms of Use
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.squarePen,
                    color: MoldifyColors.accentColor,
                    size: 24,
                  ),
                  title: AutoSizeText(
                    l10n.termsOfAgreement,
                    style: const TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Bold',
                      color: MoldifyColors.primaryColor,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    minFontSize: 10,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TermsOfAgreementScreen(),
                      ),
                    );
                  },
                ),

                /// Privacy Policy
                ListTile(
                  leading: const Icon(
                    Icons.privacy_tip_rounded,
                    color: MoldifyColors.accentColor,
                    size: 24,
                  ),
                  title: AutoSizeText(
                    l10n.privacyPolicy,
                    style: const TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Bold',
                      color: MoldifyColors.primaryColor,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    minFontSize: 10,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyScreen(),
                      ),
                    );
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
                  title: AutoSizeText(
                    l10n.sendFeedback,
                    style: const TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Bold',
                      color: MoldifyColors.primaryColor,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    minFontSize: 10,
                    overflow: TextOverflow.ellipsis,
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
                  title: AutoSizeText(
                    l10n.reportABug,
                    style: const TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Bold',
                      color: MoldifyColors.primaryColor,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    minFontSize: 10,
                    overflow: TextOverflow.ellipsis,
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
                  leading: const Icon(
                    FontAwesomeIcons.phone,
                    color: MoldifyColors.accentColor,
                    size: 20,
                  ),
                  title: AutoSizeText(
                    l10n.contactUs,
                    style: const TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Bold',
                      color: MoldifyColors.primaryColor,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    minFontSize: 10,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ContactUsScreen(),
                      ),
                    );
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
                  leading: const Icon(
                    FontAwesomeIcons.solidUser,
                    color: MoldifyColors.accentColor,
                    size: 22,
                  ),
                  title: AutoSizeText(
                    l10n.accountSettings,
                    style: const TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Bold',
                      color: MoldifyColors.primaryColor,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    minFontSize: 10,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MainAccountSettingsScreen(),
                      ),
                    );
                    // Re-fetch profile so role-based menu items reflect any changes.
                    if (mounted) {
                      final authProvider = Provider.of<AppAuthProvider>(
                        context,
                        listen: false,
                      );
                      final sessionCookie = authProvider.cookie;
                      if (sessionCookie != null) {
                        _userBloc.add(
                          FetchUserProfile(sessionCookie: sessionCookie),
                        );
                      }
                    }
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
                  leading: const Icon(
                    FontAwesomeIcons.rightFromBracket,
                    color: MoldifyColors.accentColor,
                    size: 24,
                  ),
                  title: AutoSizeText(
                    l10n.logOut,
                    style: const TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Bold',
                      color: MoldifyColors.primaryColor,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    minFontSize: 10,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () async {
                    final authProvider = Provider.of<AppAuthProvider>(
                      context,
                      listen: false,
                    );
                    await authProvider.logout();
                    if (context.mounted) {
                      AuthNavigation.resetToLoginFromContext(context);
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
