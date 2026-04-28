import 'package:flutter/material.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/language_toggle.dart';
import 'package:moldify/providers/auth_provider.dart';
import 'package:moldify/l10n/app_localizations.dart';
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

  /// Builds the list of onboarding pages with localized content
  List<OnboardingPageData> _buildPages(AppLocalizations l10n) {
    return [
      OnboardingPageData(
        type: PageType.welcome,
        image: 'assets/images/welcome_farmer.png',
        title: l10n.welcomeTo,
        titleLarge: 'MOLDIFY',
        subtitle: l10n.welcomeAppSubtitle,
      ),
      OnboardingPageData(
        type: PageType.standard,
        image: 'assets/images/onboarding_farmer.png',
        title: l10n.onboarding1Title,
        titleHighlight: l10n.onboarding1Highlight,
        subtitle: l10n.onboarding1Subtitle,
      ),
      OnboardingPageData(
        type: PageType.standard,
        image: 'assets/images/onboarding_scientist.png',
        title: l10n.onboarding2Title,
        titleHighlight: l10n.onboarding2Highlight,
        subtitle: l10n.onboarding2Subtitle,
        isLastPage: true,
      ),
    ];
  }

  /// Navigates to the next onboarding page
  void _nextPage(int pagesLength) {
    if (_currentPage < pagesLength - 1) {
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
    final l10n = AppLocalizations.of(context)!;
    final pages = _buildPages(l10n);

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
            itemCount: pages.length,
            itemBuilder: (context, index) {
              final page = pages[index];
              return page.type == PageType.welcome
                  ? _buildWelcomePage(page, screenHeight)
                  : _buildStandardPage(page);
            },
          ),

          /// -------------------------------
          /// LANGUAGE TOGGLE (TOP LEFT)
          /// -------------------------------
          Positioned(
            top: 30,
            left: 15,
            child: LanguageToggle(
              color: MoldifyColors.backgroundColor,
              fontSize: 12,
            ),
          ),

          /// -------------------------------
          /// SKIP BUTTON (TOP RIGHT)
          /// -------------------------------
          Positioned(
            top: 30,
            right: 5,
            child: TextButton(
              onPressed: _skip,
              child: Text(
                l10n.skip,
                style: const TextStyle(
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
                    pages.length,
                    (index) => _buildIndicator(index, pages.length),
                  ),
                ),

                // Next/Continue button
                BuildButton(
                  buttonText: pages[_currentPage].isLastPage
                      ? l10n.continueToApp
                      : l10n.next,
                  onPressed: pages[_currentPage].isLastPage
                      ? _finish
                      : () => _nextPage(pages.length),
                  backgroundColor: _currentPage == 0
                      ? MoldifyColors.backgroundColor
                      : MoldifyColors.accentColor,
                  textColor: _currentPage == 0
                      ? MoldifyColors.primaryColor
                      : MoldifyColors.MoldifyBlack,
                  buttonHeight: 35,
                  buttonRadius: 10,
                  rightIcon: Icons.arrow_forward,
                  rightIconColor: _currentPage == 0
                      ? MoldifyColors.primaryColor
                      : MoldifyColors.MoldifyBlack,
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
    final bottomSectionHeight = screenHeight * 0.35;
    final contentVerticalPadding = (bottomSectionHeight * 0.08).clamp(8.0, 18.0).toDouble();
    final contentHorizontalPadding = (bottomSectionHeight * 0.12).clamp(20.0, 30.0).toDouble();
    final introFontSize = (screenHeight * 0.018).clamp(12.0, 16.0).toDouble();
    final titleFontSize = (screenHeight * 0.048).clamp(28.0, 42.0).toDouble();
    final subtitleFontSize = (screenHeight * 0.017).clamp(12.0, 16.0).toDouble();

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
              height: bottomSectionHeight,
              width: double.infinity,
              decoration: const BoxDecoration(color: MoldifyColors.primaryColor),
              child: Padding(
                padding: EdgeInsets.only(
                  top: contentVerticalPadding,
                  left: contentHorizontalPadding,
                  right: contentHorizontalPadding,
                  bottom: contentVerticalPadding,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      page.title,
                      style: TextStyle(
                        color: MoldifyColors.backgroundColor,
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        fontSize: introFontSize,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      page.titleLarge ?? '',
                      style: TextStyle(
                        color: MoldifyColors.backgroundColor,
                        fontFamily: 'Montserrat-Black',
                        fontSize: titleFontSize,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      page.subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: MoldifyColors.backgroundColor,
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        fontSize: subtitleFontSize,
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
  Widget _buildIndicator(int index, int totalPages) {
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