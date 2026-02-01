import 'package:flutter/material.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// ===============================
/// WELCOME / ONBOARDING SCREEN
/// ===============================
///
/// Displays a multi-page onboarding flow for Moldify.
/// Uses PageView for swipe navigation and shows:
/// 1. Welcome screen
/// 2. Feature explanation
/// 3. Expert validation overview
///

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// -------------------------------
  /// ONBOARDING PAGE DATA
  /// -------------------------------
  /// This makes the onboarding UI easy to update
  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      type: PageType.welcome,
      image: 'assets/images/welcome_farmer.png',
      title: 'Welcome To',
      titleLarge: 'MOLDIFY',
      subtitle: 'A Mold Investigation System for Agriculture',
    ),
    OnboardingPageData(
      type: PageType.standard,
      image: 'assets/images/onboarding_farmer.png',
      title: 'Submit Mold Cases with ',
      titleHighlight: 'Ease',
      subtitle: 'Moldify is a digital system that enables farmers to submit suspected mold cases for structured expert investigation.',
    ),
    OnboardingPageData(
      type: PageType.standard,
      image: 'assets/images/onboarding_scientist.png',
      title: 'Expert Review by ',
      titleHighlight: 'Mycologists',
      subtitle: 'Moldify supports expert assessment and informed agricultural decision. Got mold worries? Use Moldify and take action today.',
      isLastPage: true,
    ),
  ];

  /// Dispose controller to avoid memory leaks
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Updates the active page index when swiping
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  /// Navigates to the next onboarding page
  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Skips onboarding and marks it as seen in the app
  void _skip() async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    await authProvider.markIntroAsSeen();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(RouteNames.intro);
    }
  }

  /// Completes onboarding on the last page
  void _finish() async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    await authProvider.markIntroAsSeen();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(RouteNames.intro);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      body: Stack(
        children: [
          /// -------------------------------
          /// PAGE VIEW (MAIN CONTENT)
          /// -------------------------------
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return page.type == PageType.welcome
                  ? _buildWelcomePage(page, screenHeight)
                  : _buildStandardPage(page);
            },
          ),

          /// -------------------------------
          /// SKIP BUTTON (TOP RIGHT)
          /// -------------------------------
          Positioned(
            top: 30,
            right: 5,
            child: TextButton(
              onPressed: _skip,
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

          /// -------------------------------
          /// APP TITLE (TOP CENTER)
          /// -------------------------------
          Positioned(
            top: 45,
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

          /// -------------------------------
          /// BOTTOM CONTROLS
          /// (Indicators + Next Button)
          /// -------------------------------
          Positioned(
            bottom: 40,
            left: _currentPage == 0 ? 30 : 15,
            right: _currentPage == 0 ? 30 : 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Indicators
                Row(
                  children: List.generate(
                    _pages.length,
                        (index) => _buildIndicator(index),
                  ),
                ),

                // Next/Continue button
                BuildButton(
                  buttonText: _pages[_currentPage].isLastPage ? 'Continue To App' : 'Next',
                  onPressed: _pages[_currentPage].isLastPage ? _finish : _nextPage,
                  backgroundColor: _currentPage == 0 ? MoldifyColors.backgroundColor : MoldifyColors.accentColor,
                  textColor: _currentPage == 0 ? MoldifyColors.primaryColor : MoldifyColors.MoldifyBlack,
                  buttonHeight: 35,
                  buttonRadius: 10,
                  rightIcon: Icons.arrow_forward,
                  rightIconColor: _currentPage == 0 ? MoldifyColors.primaryColor : MoldifyColors.MoldifyBlack,
                  rightIconSize: 18,
                  paddingIconText: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ===============================
  /// WELCOME PAGE LAYOUT
  /// ===============================
  Widget _buildWelcomePage(OnboardingPageData page, double screenHeight) {
    return Stack(
      children: [
        // Farmer illustration
        Positioned(
          top: 25,
          left: -60,
          right: -5,
          bottom: screenHeight * 0.25,
          child: Image.asset(
            page.image,
            fit: BoxFit.contain,
          ),
        ),

        // Green bottom section
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ClipPath(
            clipper: CurvedTopClipper(),
            child: Container(
              height: screenHeight * 0.35,
              width: double.infinity,
              decoration: const BoxDecoration(color: MoldifyColors.primaryColor),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 60,
                  left: 30,
                  right: 30,
                  bottom: 100,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      page.title,
                      style: const TextStyle(
                        color: MoldifyColors.backgroundColor,
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      page.titleLarge ?? '',
                      style: const TextStyle(
                        color: MoldifyColors.backgroundColor,
                        fontFamily: 'Montserrat-Black',
                        fontSize: 48,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      page.subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: MoldifyColors.backgroundColor,
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// ===============================
  /// STANDARD ONBOARDING PAGE
  /// ===============================
  Widget _buildStandardPage(OnboardingPageData page) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Expanded(
            flex: 3,
            child: Image.asset(
              page.image,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      style: const TextStyle(
                        color: MoldifyColors.primaryColor,
                        fontFamily: 'Montserrat-Black',
                        fontSize: 32,
                        height: 1.2,
                      ),
                      children: [
                        TextSpan(text: page.title),
                        if (page.titleHighlight != null)
                          TextSpan(
                            text: page.titleHighlight,
                            style: const TextStyle(color: MoldifyColors.accentColor),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    page.subtitle,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: MoldifyColors.MoldifyBlack,
                      fontFamily: 'Bricolage-Grotesque-Regular',
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// ===============================
  /// PAGE INDICATOR DOT
  /// ===============================
  Widget _buildIndicator(int index) {
    final isActive = _currentPage == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? (_currentPage == 0 ? MoldifyColors.backgroundColor : MoldifyColors.primaryColor)
            : Colors.transparent,
        border: Border.all(
          color: _currentPage == 0 ? MoldifyColors.backgroundColor : MoldifyColors.primaryColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// ===============================
/// PAGE TYPE ENUM
/// ===============================
enum PageType { welcome, standard }

class OnboardingPageData {
  final PageType type;
  final String image;
  final String title;
  final String? titleLarge;
  final String? titleHighlight;
  final String subtitle;
  final bool isLastPage;

  OnboardingPageData({
    required this.type,
    required this.image,
    required this.title,
    this.titleLarge,
    this.titleHighlight,
    required this.subtitle,
    this.isLastPage = false,
  });
}

/// ===============================
/// CUSTOM CLIPPER FOR HALF CIRCLE SHAPE
/// ===============================
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