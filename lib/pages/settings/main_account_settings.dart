import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/appbar/secondary_appbar.dart';
import 'package:moldify/pages/misc/images/profile_image.dart';
import 'package:moldify/pages/settings/edit_profile.dart';
import '../misc/colors.dart';
import '../misc/tiles/account_settings_tiles.dart';

/// MainAccountSettingsScreen is the main screen for account settings.
/// It displays the user's profile image, username, email, and various account settings options.

class MainAccountSettingsScreen extends StatefulWidget {
  const MainAccountSettingsScreen({super.key});

  @override
  State<MainAccountSettingsScreen> createState() =>
      _MainAccountSettingsScreenState();
}

class _MainAccountSettingsScreenState extends State<MainAccountSettingsScreen> {
  @override
  Widget build(BuildContext context) {

    /// Responsive design for profile image
    /// The profile image will take 50% of the screen width
    /// and maintain a height of 180px with a width of 170px.
    /// The overhang will be 50% of the profile image height.
    /// This ensures that the profile image is responsive and looks good on different screen sizes.
    final screenWidth = MediaQuery.of(context).size.width;
    final double profileImageWidth = screenWidth * 0.50; // 50% of screen width
    final double profileImageHeight = profileImageWidth * (180.0 / 170.0);
    /// The overhang is calculated as 55% of the profile image height
    /// to ensure it looks good on different screen sizes.
    final double responsiveOverhang = profileImageHeight * (50.0 / 180.0);

    /// This is temporary, will be replaced with the actual username and email
    /// when the user is logged in.
    String username = '';
    String email = '';

    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: SecondaryAppBar(
        title: 'Account Settings',
        color: MoldifyColors.backgroundColor,
        themeColor: MoldifyColors.backgroundColor,
      ),
      body: SingleChildScrollView(
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
                      null,
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
                    child: Text(
                      username.isEmpty ? 'Guest User' : username,
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
                    child: Text(
                      email.isEmpty ? 'emailguest@sample.com' : email,
                      style: TextStyle(
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        fontSize: 16,
                        color: MoldifyColors.MoldifyBlack,
                      ),
                      overflow: TextOverflow.visible,
                      textAlign: TextAlign.center,
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
                      title: 'Edit Profile',
                      onTap: () {
                        Navigator.of(context).push (
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                  ),

                  ///Edit Password Tile
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: BuildAccountSettingsTiles(
                      leftIcon: FontAwesomeIcons.lock,
                      rightIcon: FontAwesomeIcons.angleRight,
                      title: 'Edit Password',
                      onTap: () {

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

                  /// My Archive Tile
                  BuildAccountSettingsTiles(
                    leftIcon: FontAwesomeIcons.boxArchive,
                    rightIcon: FontAwesomeIcons.angleRight,
                    title: 'My Archive',
                    onTap: () {

                    },
                  ),

                  /// My History Tile
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: BuildAccountSettingsTiles(
                      leftIcon: FontAwesomeIcons.clockRotateLeft,
                      rightIcon: FontAwesomeIcons.angleRight,
                      title: 'My History',
                      onTap: () {

                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
