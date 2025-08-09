import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../misc/colors.dart';

/// This is the login screen of the app.
/// It allows users to log in with their username and password.

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            ///----------- H E A D E R ------------
            Stack(
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
                Positioned(
                  top: 70,
                  left: 15,
                  child: Column(
                    children: [
                      Text(
                        'LOG IN',
                        style: TextStyle(
                            fontSize: 48,
                            fontFamily: 'Montserrat-Black',
                            color: MoldifyColors.backgroundColor,
                          ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 120,
                  left: 15,
                  child: Text(
                    'Please enter username and password.',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Bricolage-Grotesque-Regular',
                      color: MoldifyColors.backgroundColor,
                    ),
                  ),
                ),
              ],
            ),
            ///----------- E N D  H E A D E R ------------


            Padding(padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: const Text(
                      'Username',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Bricolage-Grotesque-SemiBold',
                        color: MoldifyColors.primaryColor,
                      ),
                    ),

                  ),
                ],
              )
            ),
          ],
        )
      ),
    );
  }
}
