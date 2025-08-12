import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:moldify/pages/misc/appbar/secondary_appbar.dart';
import 'package:moldify/pages/misc/colors.dart';

class SetNewPasswordScreen extends StatefulWidget{
  const SetNewPasswordScreen({super.key});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}
class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: SecondaryAppBar(
          title: 'Forgot Password',
          color: MoldifyColors.primaryColor
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// -------- New Password Header Image --------
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: SvgPicture.asset(
                'assets/images/code_phone_curve.svg',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ),
            /// -------- New Password Header Image --------
          ],
        ),
      ),
    );
  }
}