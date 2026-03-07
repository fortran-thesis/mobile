import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moldify/l10n/app_localizations.dart';
import 'package:moldify/core/utils/image_utils.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/buttons/icon_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/images/profile_image.dart';
import 'package:moldify/pages/misc/overlays/modals/confirmation_dialog.dart';
import 'package:moldify/pages/misc/tiles/bottom_sheet.dart';
import '../../core/features/user/logic/user_bloc.dart';
import '../../core/features/user/models/user_profile.dart';
import '../../core/features/user/services/user_services.dart';
import '../../providers/auth_provider.dart';
import '../misc/buttons/primary_button.dart';
import '../misc/textboxes/textboxes.dart';
import '../misc/tiles/bottom_sheet_contents/photo_options_content.dart';
import 'package:moldify/core/utils/logger.dart';

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
      final userBloc = context.read<UserBloc>();
      
      // Check if profile already loaded in the bloc
      final state = userBloc.state;
      if (state is UserProfileLoaded) {
        _populateControllers(state.profile);
      } else {
        // Fetch profile if not already loaded
        userBloc.add(
          FetchUserProfile(sessionCookie: authProvider.cookie),
        );
      }
    });
  }

  void _populateControllers(UserProfile profile) {
    final role = profile.role.toLowerCase();
    final isExpert = !(role == 'farmer' || role == 'user');

    setState(() {
      _isExpert = isExpert;
      _profileImageUrl = profile.photoUrl;
      _initialProfile = profile;

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
    final l10n = AppLocalizations.of(context)!;

    try {
      final authProvider = context.read<AppAuthProvider>();
      final sessionCookie = authProvider.cookie;

      if (sessionCookie == null || sessionCookie.isEmpty) {
        _showSnackBar(l10n.authErrorPleaseLogin);
        setState(() => _isSaving = false);
        return;
      }

      // Get values
      final username = usernameController.text.trim();
      final firstName = fnameController.text.trim();
      final lastName = lnameController.text.trim();
      final address = addressController.text.trim();
      final phoneNumber = phoneNumController.text.trim();

      // Auto-generate displayName from firstName + lastName
      final displayName = '$firstName $lastName'.trim();

      AppLogger.d('🔵 Saving profile:');
      AppLogger.d('   Username: $username');
      AppLogger.d('   First Name: $firstName');
      AppLogger.d('   Last Name: $lastName');
      AppLogger.d('   Display Name: $displayName');

      final result = await UserService().editProfile(
        sessionCookie: sessionCookie,
        username: username == _initialProfile?.username ? null : username,
        firstName: firstName == _initialProfile?.firstName ? null : firstName,
        lastName: lastName == _initialProfile?.lastName ? null : lastName,
        displayName:
            (firstName == _initialProfile?.firstName && lastName == _initialProfile?.lastName)
                ? null
                : displayName,
        address: _isExpert ? null : (address == _initialProfile?.address ? null : address),
        phoneNumber:
            _isExpert ? null : (phoneNumber == _initialProfile?.phoneNumber ? null : phoneNumber),
        photoFile: _selectedPhoto,
      );

      AppLogger.d('🔵 Got result: $result');

      if (!mounted) return;

      if (result['success'] == true) {
        _showSnackBar(l10n.profileUpdated);

        await Future.delayed(const Duration(milliseconds: 500));
        // Refresh profile
        if (!mounted) return;
        context.read<UserBloc>().add(
          FetchUserProfile(sessionCookie: sessionCookie),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) Navigator.pop(context, true);
      } else {
        AppLogger.e('❌ Failed: ${result['error']}');
        _showSnackBar(result['error'] != null ? l10n.failedToUpdateProfile(result['error']) : l10n.somethingWentWrong);
      }
    } catch (e, stackTrace) {
      AppLogger.e('💥 Exception', error: e);
      AppLogger.e('📚 Stack trace', error: stackTrace);
      _showSnackBar(l10n.somethingWentWrong);
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
    final l10n = AppLocalizations.of(context)!;
    List<String> changes = [];

    if (usernameController.text.trim() != _initialProfile!.username) changes.add(l10n.username);
    if (fnameController.text.trim() != _initialProfile!.firstName) changes.add(l10n.firstName);
    if (lnameController.text.trim() != _initialProfile!.lastName) changes.add(l10n.lastName);

    if (!_isExpert) {
      if (phoneNumController.text.trim() != _initialProfile!.phoneNumber) changes.add(l10n.phoneNumber);
      if (addressController.text.trim() != _initialProfile!.address) changes.add(l10n.locationLabel);
    }

    if (_selectedPhoto != null) changes.add(l10n.uploadPhoto);

    return changes;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserProfileLoaded) {
            _populateControllers(state.profile);
          }
        },
        child: Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(
        title: AppLocalizations.of(context)!.editProfileTitle,
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
                  Text(
                      AppLocalizations.of(context)!.editProfileTitle,
                      style: const TextStyle(
                        fontSize: 36,
                        fontFamily: 'Montserrat-Black',
                        color: MoldifyColors.primaryColor,
                      )
                  ),
                  Text(
                      AppLocalizations.of(context)!.editProfileSubtitle,
                      style: const TextStyle(
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
                                          AppLogger.d(
                                              'Upload Photo Tapped in EditProfileScreen');
                                          Navigator.of(context).pop('upload');
                                        },
                                        onRemovePhoto: () {
                                          AppLogger.d(
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
                  Text(
                    AppLocalizations.of(context)!.username,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Bricolage-Grotesque-SemiBold',
                      color: MoldifyColors.primaryColor,
                    ),
                  ),

                  /// Username TextBox
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: BuildTextBox(
                      hintText: AppLocalizations.of(context)!.enterUsername,
                      controller: usernameController,
                      showPassword: false,
                    ),
                  ),

                  /// First Name Label
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      AppLocalizations.of(context)!.firstName,
                      style: const TextStyle(
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
                      hintText: AppLocalizations.of(context)!.enterFirstName,
                      controller: fnameController,
                      showPassword: false,
                    ),
                  ),

                  /// LastName Label
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: AutoSizeText(
                      AppLocalizations.of(context)!.lastName,
                      style: const TextStyle(
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
                      hintText: AppLocalizations.of(context)!.enterLastName,
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
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: AutoSizeText(
                        AppLocalizations.of(context)!.phoneNumber,
                        style: const TextStyle(
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
                        hintText: AppLocalizations.of(context)!.enterPhoneNumber,
                        controller: phoneNumController,
                        showPassword: false,
                        keyboardType: TextInputType.phone,
                        showPhoneNumberPrefix: true,
                      ),
                    ),

                    /// Location Label
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: AutoSizeText(
                        AppLocalizations.of(context)!.locationLabel,
                        style: const TextStyle(
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
                        hintText: AppLocalizations.of(context)!.enterLocation,
                        controller: addressController,
                        showPassword: false,
                      ),
                    ),
                  ],

                  /// Save Changes Button
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: BuildButton(
                        buttonText: AppLocalizations.of(context)!.saveChanges,
                        onPressed: () {
                          final changedFields = _getChangedFields();

                          if (changedFields.isEmpty) {
                            _showSnackBar(AppLocalizations.of(context)!.noChangesDetected);
                            return;
                          }

                          String subtitle = AppLocalizations.of(context)!.confirmProfileUpdateSubtitle(changedFields.join(', '));
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return BuildConfirmationDialog(
                                title: AppLocalizations.of(context)!.confirmProfileUpdateTitle,
                                subtitle: subtitle,
                                confirmText: AppLocalizations.of(context)!.yes,
                                cancelText: AppLocalizations.of(context)!.no,
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