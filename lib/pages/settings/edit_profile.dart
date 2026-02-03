import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moldify/core/utils/image_utils.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/buttons/icon_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/images/profile_image.dart';
import 'package:moldify/pages/misc/overlays/modals/confirmation_dialog.dart';
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

  // late UserBloc _userBloc;
  // StreamSubscription? _userSub;
  bool _isExpert = false;
  bool _isLoading = true;
  String? _profileImageUrl;
  File? _selectedPhoto;
  Image? _selectedPhotoWidget;
  bool _isSaving = false;
  UserProfile? _initialProfile;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AppAuthProvider>();
      context.read<UserBloc>().add(
        FetchUserProfile(sessionCookie: authProvider.cookie),
      );
    });
  }


  // Handles photo selection
  Future<void> _handlePhotoSelection(String action) async {
    if (action == 'upload') {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedPhoto = File(image.path);
          _selectedPhotoWidget = Image.file(File(image.path)); // ADD THIS
        });
      }
    } else if (action == 'remove') {
      setState(() {
        _selectedPhoto = null;
        _profileImageUrl = null;
        _selectedPhotoWidget = null; // ADD THIS
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final authProvider = context.read<AppAuthProvider>();
      final sessionCookie = authProvider.cookie;

      if (sessionCookie == null || sessionCookie.isEmpty) {
        _showSnackBar('User not authenticated. Please log in again.');
        setState(() => _isSaving = false);
        return;
      }

      // Get values
      final username = usernameController.text.trim();
      final firstName = fnameController.text.trim();
      final lastName = lnameController.text.trim();

      // Auto-generate displayName from firstName + lastName
      final displayName = '$firstName $lastName'.trim();

      print('🔵 Saving profile:');
      print('   Username: $username');
      print('   First Name: $firstName');
      print('   Last Name: $lastName');
      print('   Display Name: $displayName');

      final result = await UserService().editProfile(
        sessionCookie: sessionCookie,
        username: username, // Send username
        firstName: firstName,
        lastName: lastName,
        displayName: displayName, // Send displayName (auto-generated)
        address: _isExpert ? null : addressController.text.trim(),
        phoneNumber: _isExpert ? null : phoneNumController.text.trim(),
        photoFile: _selectedPhoto,
      );

      print('🔵 Got result: $result');

      if (!mounted) return;

      if (result['success'] == true) {
        _showSnackBar('Profile updated successfully!');

        await Future.delayed(const Duration(milliseconds: 500));
        // Refresh profile
        context.read<UserBloc>().add(
          FetchUserProfile(sessionCookie: sessionCookie),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) Navigator.pop(context, true);
      } else {
        print('❌ Failed: ${result['error']}');
        _showSnackBar(result['error'] ?? 'Failed to update profile');
      }
    } catch (e, stackTrace) {
      print('💥 Exception: $e');
      print('📚 Stack trace: $stackTrace');
      _showSnackBar('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  @override
  void dispose() {
    // Clean up controllers and stream subscription
    // _userSub?.cancel();
    // _userBloc.close();
    usernameController.dispose();
    fnameController.dispose();
    lnameController.dispose();
    phoneNumController.dispose();
    addressController.dispose();
    emailController.dispose();
    super.dispose();
  }
  List<String> _getChangedFields() {
    if (_initialProfile == null) return [];
    List<String> changes = [];

    if (usernameController.text.trim() != _initialProfile!.username) changes.add("Username");
    if (fnameController.text.trim() != _initialProfile!.firstName) changes.add("First Name");
    if (lnameController.text.trim() != _initialProfile!.lastName) changes.add("Last Name");

    if (!_isExpert) {
      if (phoneNumController.text.trim() != _initialProfile!.phoneNumber) changes.add("Phone Number");
      if (addressController.text.trim() != _initialProfile!.address) changes.add("Location");
    }

    if (_selectedPhoto != null) changes.add("Profile Picture");

    return changes;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserProfileLoaded) {
            final profile = state.profile;
            _initialProfile = profile;
            final role = profile.role.toLowerCase();
            final isExpert = !(role == 'farmer' || role == 'user');

            setState(() {
              _isExpert = isExpert;
              _profileImageUrl = profile.photoUrl;

              usernameController.text = profile.username;
              fnameController.text = profile.firstName;
              lnameController.text = profile.lastName;
              emailController.text = profile.email;

              if (!isExpert) {
                phoneNumController.text = profile.phoneNumber;
                addressController.text = profile.address;
              }

              _isLoading = false;
            });
          }
        },
        child: Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(
        title: 'Edit Profile',
      ),
      body: Stack(
        children: [ _isLoading
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
                            _selectedPhotoWidget ?? imageFromUrlOrNull(_profileImageUrl),
                            width: 180,
                            height: 190,
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: BuildIconButton(
                              icon: FontAwesomeIcons.pen,
                              color: MoldifyColors.accentColor,
                              onPressed: () async { // ADD async here
                                final action = await showModalBottomSheet<
                                    String>( // ADD await and capture result
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (BuildContext bc) {
                                    return BuildBottomSheet(
                                      child: PhotoOptionsBottomSheetContent(
                                        onUploadPhoto: () {
                                          print(
                                              'Upload Photo Tapped in EditProfileScreen');
                                          Navigator.of(context).pop('upload');
                                        },
                                        onRemovePhoto: () {
                                          print(
                                              'Remove Photo Tapped in EditProfileScreen');
                                          Navigator.of(context).pop('remove');
                                        },
                                      ),
                                    );
                                  },
                                );

                                // ADD: Handle the action after bottom sheet closes
                                if (action != null) {
                                  _handlePhotoSelection(action);
                                }
                              }
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

                  // /// Email Label
                  // const Padding(
                  //   padding: EdgeInsets.only(top: 20.0),
                  //   child: AutoSizeText(
                  //     'Email',
                  //     style: TextStyle(
                  //       fontSize: 16,
                  //       fontFamily: 'Bricolage-Grotesque-SemiBold',
                  //       color: MoldifyColors.primaryColor,
                  //     ),
                  //     maxLines: 1,
                  //     minFontSize: 12,
                  //   ),
                  // ),
                  //
                  // /// Email TextBox
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 8.0),
                  //   child: BuildTextBox(
                  //     hintText: 'Enter Email',
                  //     controller: emailController,
                  //     showPassword: false,
                  //     keyboardType: TextInputType.emailAddress,
                  //   ),
                  // ),

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
                          final changedFields = _getChangedFields();

                          if (changedFields.isEmpty) {
                            _showSnackBar('No changes detected.');
                            return;
                          }

                          String subtitle = "Are you sure you want to change your ${changedFields.join(', ')}?";
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return BuildConfirmationDialog(
                                title: 'Save Changes?',
                                subtitle: subtitle,
                                confirmText: 'Save',
                                cancelText: 'Cancel',
                                onCancel: () => Navigator.of(context).pop(),
                                onConfirm: () {
                                  Navigator.of(context).pop();
                                  _saveProfile();
                                },
                              );
                            },
                          );
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
          if (_isSaving)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(MoldifyColors.backgroundColor),
                ),
              ),
            ),
        ],
      ),
    )
    );
  }
}