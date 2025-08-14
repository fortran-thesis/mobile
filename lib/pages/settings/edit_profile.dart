import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/buttons/icon_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/images/profile_image.dart';
import 'package:moldify/pages/misc/tiles/bottom_sheet.dart';
import '../misc/buttons/primary_button.dart';
import '../misc/textboxes/textboxes.dart';

/// This screen allows users to edit their profile information such as username and email.
/// It includes a profile image section where users can upload or remove their profile photo.

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(
          title: 'Edit Profile',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0, bottom: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// ----------- Edit Profile Header -----------
              Text(
                  'EDIT PROFILE',
                  style: TextStyle(
                    fontSize: 36,
                    fontFamily: 'Montserrat-Black',
                    color: MoldifyColors.primaryColor,
                  )
              ),
              Text(
                  'Edit the fields to update your information.',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    color: MoldifyColors.MoldifyBlack,
                  )
              ),
              /// ----------- End of Edit Profile Header -----------

              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Center(
                  child: Stack(
                    children: [
                      /// Profile Image
                      /// If the user has a profile image, it will be displayed.
                      /// If not, a default profile image will be displayed.
                      /// Call the [profilePhotoFile] function to get the profile image URL
                      BuildProfileImage(
                          null,
                          width: 180,
                          height: 190
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,

                        /// Edit Icon Button
                        /// This button will open a bottom sheet with options to upload or remove the profile photo.
                        child: BuildIconButton(
                            icon: FontAwesomeIcons.pen,
                            color: MoldifyColors.accentColor,
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (BuildContext bc) {
                                  /// Bottom Sheet with options to upload or remove photo
                                  return BuildBottomSheet(
                                    child: PhotoOptionsBottomSheetContent(
                                      /// This function will be called when the user taps on the upload photo option
                                      onUploadPhoto: () {
                                        print('Upload Photo Tapped in EditProfileScreen');
                                        Navigator.of(context).pop('upload');
                                      },
                                      /// This function will be called when the user taps on the remove photo option
                                      onRemovePhoto: () {
                                        print('Remove Photo Tapped in EditProfileScreen');
                                        Navigator.of(context).pop('remove');
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Container(
                  height: 1.0,
                  width: MediaQuery.of(context).size.width,
                  color: MoldifyColors.MoldifySoftGrey,
                ),
              ),

              /// Username Label
              const Text(
                'Username',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Bricolage-Grotesque-SemiBold',
                  color: MoldifyColors.primaryColor,
                ),
              ),

              /// Username TextBox
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: BuildTextBox(
                  hintText: 'Enter Username',
                  controller: usernameController,
                  showPassword: false,
                ),
              ),

              /// Email Label
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Bricolage-Grotesque-SemiBold',
                    color: MoldifyColors.primaryColor,
                  ),
                ),
              ),

              /// Email TextBox
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: BuildTextBox(
                  hintText: 'Enter Email',
                  controller: emailController,
                  showPassword: false,
                ),
              ),

              /// Save Changes Button
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: BuildButton(
                    buttonText: 'Save Changes',
                    onPressed: () {

                    },
                    backgroundColor: MoldifyColors.primaryColor,
                    textColor: MoldifyColors.backgroundColor,
                    buttonHeight: 45,
                    buttonWidth: MediaQuery.of(context).size.width,
                    buttonRadius: 10
                ),
              ),
            ],
          ),
        ),

      ),
    );
  }
}
