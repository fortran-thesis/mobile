import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/core/utils/image_utils.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/buttons/icon_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/images/profile_image.dart';
import 'package:moldify/pages/misc/tiles/bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../../core/features/user/logic/user_bloc.dart';
import '../../core/features/user/models/user_profile.dart';
import '../../core/features/user/services/user_services.dart';
import '../../providers/auth_provider.dart';
import '../misc/buttons/primary_button.dart';
import '../misc/textboxes/textboxes.dart';
import '../misc/tiles/bottom_sheet_contents/photo_options_content.dart';

/// This screen allows users to edit their profile information such as username and email.
/// It includes a profile image section where users can upload or remove their profile photo.

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController fnameController = TextEditingController();
  final TextEditingController lnameController = TextEditingController();
  final TextEditingController phoneNumController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  late UserBloc _userBloc;
  StreamSubscription? _userSub;
  bool _isExpert = false;
  bool _isLoading = true;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _userBloc = UserBloc(userService: UserService());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;
      if (sessionCookie != null) {
        _userBloc.add(FetchUserProfile(sessionCookie: sessionCookie));
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    });

    _userSub = _userBloc.stream.listen((state) {
      if (!mounted) return;
      if (state is UserProfileLoaded) {
        final UserProfile profile = state.profile;
        final String role = profile.role.toLowerCase();
        final bool isExpertUser = !(role == 'farmer' || role == 'user');

        setState(() {
          _isExpert = isExpertUser;
          _profileImageUrl = profile.photoUrl;

          usernameController.text = profile.username;
          fnameController.text = profile.firstName;
          lnameController.text = profile.lastName;
          emailController.text = profile.email;

          if (!isExpertUser) {
            phoneNumController.text = profile.phoneNumber;
            addressController.text = profile.address;
          }

          _isLoading = false;
        });
      } else if (state is UserProfileError) {

        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: ${state.message}')),
        );
      }
    });
  }

  @override
  void dispose() {
    // Clean up controllers and stream subscription
    _userSub?.cancel();
    _userBloc.close();
    usernameController.dispose();
    fnameController.dispose();
    lnameController.dispose();
    phoneNumController.dispose();
    addressController.dispose();
    emailController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(
        title: 'Edit Profile',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0, bottom: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// ----------- Edit Profile Header -----------
              const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 36,
                    fontFamily: 'Montserrat-Black',
                    color: MoldifyColors.primaryColor,
                  )
              ),
              const Text(
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
                      // FIX: Used the same working pattern from MainAccountSettingsScreen
                      BuildProfileImage(
                        imageFromUrlOrNull(_profileImageUrl),
                        width: 180,
                        height: 190,
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: BuildIconButton(
                          icon: FontAwesomeIcons.pen,
                          color: MoldifyColors.accentColor,
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (BuildContext bc) {
                                return BuildBottomSheet(
                                  child: PhotoOptionsBottomSheetContent(
                                    onUploadPhoto: () {
                                      print('Upload Photo Tapped in EditProfileScreen');
                                      Navigator.of(context).pop('upload');
                                    },
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
                  fontSize: 16,
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

              /// First Name Label
              const Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  'First Name',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Bricolage-Grotesque-SemiBold',
                    color: MoldifyColors.primaryColor,
                  ),
                ),
              ),

              /// First Name TextBox
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: BuildTextBox(
                  hintText: 'Enter First Name',
                  controller: fnameController,
                  showPassword: false,
                ),
              ),

              /// LastName Label
              const Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: AutoSizeText(
                  'Last Name',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Bricolage-Grotesque-SemiBold',
                    color: MoldifyColors.primaryColor,
                  ),
                  maxLines: 1,
                  minFontSize: 12,
                ),
              ),

              /// LastName TextBox
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: BuildTextBox(
                  hintText: 'Enter last name',
                  controller: lnameController,
                  showPassword: false,
                ),
              ),

              /// Email Label
              const Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: AutoSizeText(
                  'Email',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Bricolage-Grotesque-SemiBold',
                    color: MoldifyColors.primaryColor,
                  ),
                  maxLines: 1,
                  minFontSize: 12,
                ),
              ),

              /// Email TextBox
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: BuildTextBox(
                  hintText: 'Enter Email',
                  controller: emailController,
                  showPassword: false,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),

              // Show these fields only if the user is a Farmer
              if (!_isExpert) ...[
                /// Phone Number Label
                const Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: AutoSizeText(
                    'Phone Number',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Bricolage-Grotesque-SemiBold',
                      color: MoldifyColors.primaryColor,
                    ),
                    maxLines: 1,
                    minFontSize: 12,
                  ),
                ),

                /// Phone Number TextBox
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: BuildTextBox(
                    hintText: 'Enter phone number',
                    controller: phoneNumController,
                    showPassword: false,
                    keyboardType: TextInputType.phone,
                    showPhoneNumberPrefix: true,
                  ),
                ),

                /// Location Label
                const Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: AutoSizeText(
                    'Location(City/Province)',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Bricolage-Grotesque-SemiBold',
                      color: MoldifyColors.primaryColor,
                    ),
                    maxLines: 1,
                    minFontSize: 12,
                  ),
                ),

                /// Location TextBox
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: BuildTextBox(
                    hintText: 'Enter location',
                    controller: addressController,
                    showPassword: false,
                  ),
                ),
              ],

              /// Save Changes Button
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: BuildButton(
                    buttonText: 'Save Changes',
                    onPressed: () {
                      // TODO: Implement logic to save the updated profile
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