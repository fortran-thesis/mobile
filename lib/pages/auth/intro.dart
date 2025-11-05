import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../core/constants/route_names.dart';
import '../misc/buttons/primary_button.dart';
import '../misc/colors.dart';
import 'login.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/images/bacteria-with-spores.svg',
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 50,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                      'CHOOSE ROLE',
                      style: TextStyle(
                        fontSize: 32,
                        fontFamily: 'Montserrat-Black',
                        color: MoldifyColors.primaryColor,
                      )
                  ),
                ),
                Text(
                    'Please select your role to proceed to login',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Bricolage-Grotesque-Regular',
                      color: MoldifyColors.MoldifyBlack,
                    )
                ),
                SizedBox(height: 30,),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: BuildButton(
                      buttonText: 'Farmer',
                      onPressed: () {
                        Navigator.pushNamed(context, RouteNames.login, arguments: {'userRole': 'farmer'});
                      },
                      backgroundColor: MoldifyColors.primaryColor,
                      textColor: MoldifyColors.backgroundColor,
                      buttonHeight: 40.0,
                      buttonWidth: MediaQuery.of(context).size.width,
                      buttonRadius: 10.0),
                ),
                Padding(
                  padding:
                  EdgeInsets.only(top: 10.0),
                  child: BuildButton(
                      buttonText: 'Mycologist',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(userRole: 'mycologist'),
                          ),
                        );
                      },
                      backgroundColor: MoldifyColors.accentColor,
                      textColor: MoldifyColors.MoldifyBlack,
                      buttonHeight: 40.0,
                      buttonWidth: MediaQuery.of(context).size.width,
                      buttonRadius: 10.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
