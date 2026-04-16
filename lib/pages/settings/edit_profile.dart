import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moldify/l10n/app_localizations.dart';
import 'package:moldify/core/utils/image_utils.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/buttons/icon_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/images/profile_image.dart';
import 'package:moldify/pages/misc/overlays/app_feedback.dart';
import 'package:moldify/pages/misc/overlays/loading_ui.dart';
import 'package:moldify/pages/misc/overlays/modals/confirmation_dialog.dart';
import 'package:moldify/pages/misc/overlays/modals/chip_selection_modal.dart';
import 'package:moldify/pages/misc/tiles/bottom_sheet.dart';
import '../../core/features/user/logic/user_bloc.dart';
import '../../core/features/user/models/user_profile.dart';
import '../../core/features/user/services/user_services.dart';
import '../../providers/auth_provider.dart';
import '../misc/buttons/primary_button.dart';
import '../misc/textboxes/textboxes.dart';
import '../misc/tiles/bottom_sheet_contents/photo_options_content.dart';
import 'package:moldify/core/utils/logger.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('-', '');

    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    if (text.length <= 3) {
      return newValue.copyWith(text: text);
    } else if (text.length <= 6) {
      final formatted = '${text.substring(0, 3)}-${text.substring(3)}';
      return newValue.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } else {
      final formatted =
          '${text.substring(0, 3)}-${text.substring(3, 6)}-${text.substring(6, 10)}';
      return newValue.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }
}

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
  final TextEditingController occupationController = TextEditingController();

  // late UserBloc _userBloc;
  // StreamSubscription? _userSub;
  bool _isExpert = false;
  bool _isLoading = true;
  String? _profileImageUrl;
  File? _selectedPhoto;
  Image? _selectedPhotoWidget;
  bool _isSaving = false;
  UserProfile? _initialProfile;
  final List<String> _occupationOptions = [
    'Farmer',
    'Horticulturist',
    'Student',
    'Agricultural Worker',
    'Business Owner',
  ];

  String get _defaultOccupation => _occupationOptions.first;

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
        phoneNumController.text = _formatPhoneNumberForDisplay(profile.phoneNumber);
        addressController.text = profile.address;
        occupationController.text = profile.occupation ?? _defaultOccupation;
      }

      _isLoading = false;
    });
  }

  String _normalizePhoneNumber(String phoneNumber) {
    var digits = phoneNumber.replaceAll('-', '').trim();

    if (digits.startsWith('+63')) {
      digits = digits.substring(3);
    }

    if (digits.startsWith('0') && digits.length == 11) {
      digits = digits.substring(1);
    }

    return digits;
  }

  String _formatPhoneNumberForDisplay(String phoneNumber) {
    final digits = _normalizePhoneNumber(phoneNumber);
    if (digits.isEmpty) {
      return '';
    }

    if (digits.length <= 3) {
      return digits;
    }

    if (digits.length <= 6) {
      return '${digits.substring(0, 3)}-${digits.substring(3)}';
    }

    final endIndex = digits.length > 10 ? 10 : digits.length;
    return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6, endIndex)}';
  }

  Future<void> _selectOccupation() async {
    final l10n = AppLocalizations.of(context)!;
    final selectedOccupation = await showChipSelectionModal(
      context: context,
      title: l10n.occupation,
      options: _occupationOptions,
      currentSelection: occupationController.text,
      customInputHint: l10n.enterOccupation,
      othersLabel: l10n.othersLabel,
      isMultiLine: false,
    );

    if (selectedOccupation != null && selectedOccupation.isNotEmpty) {
      setState(() {
        occupationController.text = selectedOccupation;
      });
    }
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
      final occupation = occupationController.text.trim();
          final normalizedPhoneNumber = _normalizePhoneNumber(phoneNumber);

      if (username.isEmpty) {
        _showSnackBar('Username is required.');
        return;
      }

      if (firstName.isEmpty) {
        _showSnackBar('First name is required.');
        return;
      }

      if (lastName.isEmpty) {
        _showSnackBar('Last name is required.');
        return;
      }

      if (!_isExpert) {
        if (phoneNumber.isEmpty) {
          _showSnackBar('Phone number is required.');
          return;
        }

        if (address.isEmpty) {
          _showSnackBar('Location is required.');
          return;
        }

        if (occupation.isEmpty) {
          _showSnackBar('Occupation is required.');
          return;
        }
      }

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
        phoneNumber: _isExpert
          ? null
          : (_normalizePhoneNumber(phoneNumber) == _normalizePhoneNumber(_initialProfile?.phoneNumber ?? '')
            ? null
                : normalizedPhoneNumber),
        occupation: _isExpert ? null : (occupation == _initialProfile?.occupation ? null : occupation),
        photoFile: _selectedPhoto,
      );

      AppLogger.d('🔵 Got result: $result');

      if (!mounted) return;

      if (result['success'] == true) {
        AppFeedback.showSuccess(context, l10n.profileUpdated);

        final userBloc = context.read<UserBloc>();
        final refreshedProfile = userBloc.stream.firstWhere(
          (blocState) => blocState is UserProfileLoaded,
        );
        userBloc.add(FetchUserProfile(sessionCookie: sessionCookie));
        try {
          await refreshedProfile.timeout(const Duration(seconds: 10));
        } catch (_) {
          AppLogger.w('EditProfileScreen: profile refresh timed out after save');
        }

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
    AppFeedback.showInfo(context, message);
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
    occupationController.dispose();
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
      if (_normalizePhoneNumber(phoneNumController.text) != _normalizePhoneNumber(_initialProfile!.phoneNumber)) changes.add(l10n.phoneNumber);
      if (addressController.text.trim() != _initialProfile!.address) changes.add(l10n.locationLabel);
      if (occupationController.text.trim() != (_initialProfile!.occupation ?? '')) changes.add('Occupation');
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
            ? const Center(child: AppLoadingSpinner())
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
                        hintText: '9__-___-____',
                        controller: phoneNumController,
                        showPassword: false,
                        keyboardType: TextInputType.phone,
                        showPhoneNumberPrefix: true,
                        maxLength: 12,
                        customInputFormatters: [PhoneNumberFormatter()],
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

                    /// Occupation Label
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: AutoSizeText(
                        AppLocalizations.of(context)!.occupation,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Bricolage-Grotesque-SemiBold',
                          color: MoldifyColors.primaryColor,
                        ),
                        maxLines: 1,
                        minFontSize: 12,
                      ),
                    ),

                    /// Occupation TextBox (for farmers only)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: BuildTextBox(
                        hintText: AppLocalizations.of(context)!.enterOccupation,
                        controller: occupationController,
                        showPassword: false,
                        rightIcon: FontAwesomeIcons.angleRight,
                        rightIconColor: MoldifyColors.accentColor,
                        readOnly: true,
                        onTap: _selectOccupation,
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
            const AppLoadingOverlay(
              message: 'Saving profile changes...',
            ),
        ],
      ),
    )
    );
  }
}