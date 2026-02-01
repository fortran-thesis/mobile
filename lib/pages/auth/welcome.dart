import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      body: Stack(
        children: [
          // BIG Farmer illustration - positioned to show most of it
          Positioned(
            top: 25, // Start from very top
            left: -60,
            right: -5,
            bottom: screenHeight * 0.25, // Stop before green section fully covers it
            child: Image.asset(
              'assets/images/welcome_farmer.png',
              fit: BoxFit.contain,
            ),
          ),

          // Safe Area wrapper for UI elements
          SafeArea(
            child: Stack(
              children: [
                // Skip button - ON TOP
                Positioned(
                  top: 5,
                  right: 5,
                  child: TextButton(
                    onPressed: () async {
                      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
                      await authProvider.markIntroAsSeen();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed(RouteNames.login);
                      }
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: MoldifyColors.primaryColor,
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // MOLDIFY text at top - ON TOP
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'MOLDIFY',
                      style: TextStyle(
                        color: MoldifyColors.accentColor,
                        fontFamily: 'Montserrat-Bold',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),

                // Green bottom section - ON TOP
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ClipPath(
                    clipper: CurvedTopClipper(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.35,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                          color: MoldifyColors.primaryColor
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 60,
                          left: 30,
                          right: 30,
                          bottom: 40,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Welcome To',
                              style: TextStyle(
                                color: MoldifyColors.backgroundColor,
                                fontFamily: 'Bricolage-Grotesque-Regular',
                                fontSize: 16,
                              ),
                            ),
                            const Text(
                              'MOLDIFY',
                              style: TextStyle(
                                color: MoldifyColors.backgroundColor,
                                fontFamily: 'Montserrat-Black',
                                fontSize: 48,
                                letterSpacing: 2,
                              ),
                            ),
                            const Text(
                              'A Mold Investigation System for Agriculture',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: MoldifyColors.backgroundColor,
                                fontFamily: 'Bricolage-Grotesque-Regular',
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                            const Spacer(),

                            // Page indicators and Next button in a ROW
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Page indicators on the left
                                Row(
                                  children: [
                                    _buildIndicator(true),
                                    _buildIndicator(false),
                                    _buildIndicator(false),
                                  ],
                                ),

                                BuildButton(
                                  buttonText: "Next",
                                  onPressed: () {
                                    Navigator.of(context).pushReplacementNamed(
                                      RouteNames.onboarding,
                                    );
                                  },
                                  backgroundColor: MoldifyColors.backgroundColor,
                                  textColor: MoldifyColors.primaryColor,
                                  buttonHeight: 35,
                                  buttonRadius: 10,
                                  rightIcon: Icons.arrow_forward,
                                  rightIconColor: MoldifyColors.primaryColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? MoldifyColors.backgroundColor : MoldifyColors.backgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// Custom clipper for the curved top
class CurvedTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 50);

    var firstControlPoint = Offset(size.width / 4, 0);
    var firstEndPoint = Offset(size.width / 2, 0);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 3 / 4, 0);
    var secondEndPoint = Offset(size.width, 50);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}