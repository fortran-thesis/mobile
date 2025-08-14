import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/colors.dart';

import '../auth/email_recover_account.dart';
import '../misc/buttons/primary_button.dart';
import '../misc/textboxes/textboxes.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(
          title: 'Change Password',
      ),
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0, bottom: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ----------- Edit Profile Header -----------
              Text(
                  'CHANGE PASSWORD',
                  style: TextStyle(
                    fontSize: 36,
                    fontFamily: 'Montserrat-Black',
                    color: MoldifyColors.primaryColor,
                  )
              ),
              Text(
                  'Type a new password to update your account.',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    color: MoldifyColors.MoldifyBlack,
                  )
              ),
              /// ----------- End of Edit Profile Header -----------

              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: const Text(
                  'Old Password',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Bricolage-Grotesque-SemiBold',
                    color: MoldifyColors.primaryColor,
                  ),
                ),
              ),

              /// Password TextBox
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 3.0),
                child: BuildTextBox(
                  hintText: 'Enter Old Password',
                  controller: oldPasswordController,
                  showPassword: true,
                ),
              ),

              /// Forgot Password Button
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const EmailRecoverAccountScreen(pageTitle: 'Forgot Password',),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  splashColor: MoldifyColors.primaryColor.withValues(alpha: 0.2),
                  highlightColor: MoldifyColors.primaryColor.withValues(alpha: 0.2),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 4, horizontal: 6),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        fontSize: 12,
                        color: MoldifyColors.MoldifyBlack,
                      ),
                    ),
                  ),
                ),
              ),

              /// New Password Label
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: const Text(
                  'New Password',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Bricolage-Grotesque-SemiBold',
                    color: MoldifyColors.primaryColor,
                  ),
                ),
              ),

              /// New Password TextBox
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: BuildTextBox(
                  hintText: 'Enter New Password',
                  controller: newPasswordController,
                  showPassword: true,
                ),
              ),

              /// Confirm New Password Label
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: const Text(
                  'Confirm New Password',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Bricolage-Grotesque-SemiBold',
                    color: MoldifyColors.primaryColor,
                  ),
                ),
              ),

              /// Confirm Password TextBox
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: BuildTextBox(
                  hintText: 'Enter Confirm New Password',
                  controller: confirmNewPasswordController,
                  showPassword: true,
                ),
              ),

              /// Save Changes Button
              Padding(
                padding: const EdgeInsets.only(top: 160.0),
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
        )
      )
    );
  }
}