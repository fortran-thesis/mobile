import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moldify/l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/core/features/user/logic/user_bloc.dart';
import 'package:moldify/core/features/user/services/user_services.dart';
import 'package:moldify/core/utils/image_utils.dart';
import 'package:moldify/pages/misc/appbar/secondary_appbar.dart';
import 'package:moldify/pages/misc/images/profile_image.dart';
import 'package:moldify/pages/settings/case_history.dart';
import 'package:moldify/pages/settings/change_password.dart';
import 'package:moldify/pages/settings/edit_profile.dart';
import 'package:moldify/pages/settings/language_settings.dart';
import 'package:provider/provider.dart';
import 'package:moldify/core/utils/logger.dart';

import '../misc/colors.dart';
import '../misc/tiles/account_settings_tiles.dart';
import 'package:moldify/providers/auth_provider.dart';

import 'flag_history.dart';

/// MainAccountSettingsScreen is the main screen for account settings.
/// It displays the user's profile image, username, email, and various account settings options.

class MainAccountSettingsScreen extends StatefulWidget {
  const MainAccountSettingsScreen({super.key});

  @override
  State<MainAccountSettingsScreen> createState() =>
      _MainAccountSettingsScreenState();
}

class _MainAccountSettingsScreenState extends State<MainAccountSettingsScreen> {
  late UserBloc _userBloc;

  @override
  void initState() {
    super.initState();
    _userBloc = UserBloc(userService: UserService());
    // Use post-frame callback to access Provider context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;
      AppLogger.d('MainAccountSettingsScreen: Dispatching FetchUserProfile with sessionCookie: $sessionCookie');
      _userBloc.add(FetchUserProfile(sessionCookie: sessionCookie));
    });
  }

  @override
  void dispose() {
    _userBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final double profileImageWidth = screenWidth * 0.50; // 50% of screen width
    final double profileImageHeight = profileImageWidth * (180.0 / 170.0);
    /// The overhang is calculated as 55% of the profile image height
    /// to ensure it looks good on different screen sizes.
    final double responsiveOverhang = profileImageHeight * (50.0 / 180.0);

    return BlocProvider<UserBloc>.value(
      value: _userBloc,
      child: Scaffold(
        backgroundColor: MoldifyColors.backgroundColor,
        extendBodyBehindAppBar: true,
        appBar: SecondaryAppBar(
          title: l10n.accountSettings,
          color: MoldifyColors.backgroundColor,
          themeColor: MoldifyColors.backgroundColor,
        ),
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            String username = '';
            String email = '';
            String? photoUrl;
            bool isMycologist = false;
            if (state is UserProfileLoaded) {
              username = state.profile.username;
              email = state.profile.email;
              photoUrl = state.profile.photoUrl;
              isMycologist = state.profile.role.toLowerCase() == 'mycologist';
            }
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ----------- H E A D E R ------------
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SvgPicture.asset(
                        'assets/images/Yellow.svg',
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                      SvgPicture.asset(
                        'assets/images/Green.svg',
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),

                      /// Profile Picture
                      /// Url is null, so it will use the default profile image
                      /// Call the [profilePhotoFile] function to get the profile image URL
                      /// and pass it to the BuildProfileImage widget.
                      Positioned(
                        bottom: -responsiveOverhang,
                        left: 0,
                        right: 0,
                        child: Align(
                          alignment: Alignment.center,
                          child: BuildProfileImage(
                            imageFromUrlOrNull(photoUrl),
                            height: profileImageHeight,
                            width: profileImageWidth,
                          ),
                        ),
                      ),
                    ],
                  ),
                  /// ----------- E N D  H E A D E R ------------
                  Padding(
                    padding: EdgeInsets.only(top: responsiveOverhang + 20.0, left: 15, right: 15, bottom: 30),
                    child: Column(
                      children: [
                        /// ----------- U S E R  I N F O ------------
                        Align(
                          alignment: Alignment.center,
                          child: state is UserProfileLoading
                              ? CircularProgressIndicator()
                              : Text(
                            username,
                            style: TextStyle(
                              fontFamily: 'Montserrat-Black',
                              fontSize: 24,
                              color: MoldifyColors.primaryColor,
                            ),
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: state is UserProfileLoading
                              ? SizedBox.shrink()
                              : Text(
                            email,
                            style: TextStyle(
                              fontFamily: 'Bricolage-Grotesque-Regular',
                              fontSize: 16,
                              color: MoldifyColors.MoldifyBlack,
                            ),
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (state is UserProfileError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              state.message,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30.0, bottom: 20),
                          child: Container(
                            height: 1.0,
                            width: MediaQuery.of(context).size.width,
                            color: MoldifyColors.MoldifySoftGrey,
                          ),
                        ),
                        /// ----------- E N D  U S E R  I N F O ------------

                        ///Edit Profile Tile
                        BuildAccountSettingsTiles(
                          leftIcon: FontAwesomeIcons.userPen,
                          rightIcon: FontAwesomeIcons.angleRight,
                          title: l10n.editProfile,
                          onTap: () async {
                            // CHANGE: Wait for result and refresh if updated
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );

                            // If profile was updated, refresh this page
                            if (!context.mounted) return;
                            if (result == true) {
                              final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
                              final sessionCookie = authProvider.cookie;
                              _userBloc.add(FetchUserProfile(sessionCookie: sessionCookie));
                            }
                          },
                        ),

                        ///Edit Password Tile
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: BuildAccountSettingsTiles(
                            leftIcon: FontAwesomeIcons.lock,
                            rightIcon: FontAwesomeIcons.angleRight,
                            title: l10n.changePassword,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const ChangePasswordScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Container(
                            height: 1.0,
                            width: MediaQuery.of(context).size.width,
                            color: MoldifyColors.MoldifySoftGrey,
                          ),
                        ),

                        /// Case History Tile
                        BuildAccountSettingsTiles(
                          leftIcon: FontAwesomeIcons.clipboardCheck,
                          rightIcon: FontAwesomeIcons.angleRight,
                          title: l10n.caseHistory,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const CaseHistoryScreen(),
                              ),
                            );
                          },
                        ),

                        /// Language Tile (Farmer only)
                        if (!isMycologist)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: BuildAccountSettingsTiles(
                              leftIcon: FontAwesomeIcons.globe,
                              rightIcon: FontAwesomeIcons.angleRight,
                              title: l10n.language,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const LanguageSettingsScreen(),
                                  ),
                                );
                              },
                            ),
                          ),

                        /// Flagged Tile (Mycologist only)
                        if (isMycologist)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: BuildAccountSettingsTiles(
                              leftIcon: FontAwesomeIcons.solidFlag,
                              rightIcon: FontAwesomeIcons.angleRight,
                              title: l10n.flagHistory,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const FlagHistoryScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
