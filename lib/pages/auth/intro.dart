import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/language_toggle.dart';
import 'package:moldify/l10n/app_localizations.dart';
import 'login.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'assets/images/bacteria_with_leaves_upsidedown.svg',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 90,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                          l10n.chooseRole,
                          style: TextStyle(
                            fontSize: 32,
                            fontFamily: 'Montserrat-Black',
                            color: MoldifyColors.primaryColor,
                          )
                      ),
                    ),
                    Text(
                        l10n.chooseRoleSubtitle,
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
                          buttonText: l10n.farmer,
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
                          buttonText: l10n.mycologist,
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
          /// Language Toggle (Top Right)
          Positioned(
            top: 20,
            right: 15,
            child: LanguageToggle(
              color: MoldifyColors.primaryColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
