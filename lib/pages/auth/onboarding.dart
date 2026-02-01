import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../misc/colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      image: 'assets/images/onboarding_farmer.png',
      title: 'Submit Mold Cases with ',
      titleHighlight: 'Ease',
      subtitle: 'Moldify is a digital system that enables farmers to submit suspected mold cases for structured expert investigation.',
    ),
    OnboardingPage(
      image: 'assets/images/onboarding_scientist.png',
      title: 'Expert Review by ',
      titleHighlight: 'Mycologists',
      subtitle: 'Moldify supports expert assessment and informed agricultural decision. Got mold worries? Use Moldify and take action today.',
      isLastPage: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    await authProvider.markIntroAsSeen();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(RouteNames.login);
    }
  }

  void _finish() async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    await authProvider.markIntroAsSeen();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Skip button
            Positioned(
              top: 5,
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

            // MOLDIFY text at top
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

            // PageView
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Bottom section - indicators and button in ROW
            Positioned(
              bottom: 40,
              left: 15,
              right: 15,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicators (showing 3 total: welcome + 2 onboarding)
                  Row(
                    children: [
                      _buildIndicator(false), // Welcome page (already passed)
                      _buildIndicator(_currentPage == 0),
                      _buildIndicator(_currentPage == 1),
                    ],
                  ),

                  // Next/Continue button
                  BuildButton(
                    buttonText: _pages[_currentPage].isLastPage ? 'Continue To App' : 'Next',
                    onPressed: _pages[_currentPage].isLastPage ? _finish : _nextPage,
                    backgroundColor: MoldifyColors.accentColor,
                    textColor: MoldifyColors.MoldifyBlack,
                    buttonHeight: 35,
                    buttonRadius: 10,
                    rightIcon: Icons.arrow_forward,
                    rightIconColor: MoldifyColors.MoldifyBlack,
                    rightIconSize: 18,
                    paddingIconText: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Column(
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

        // Text content - LEFT aligned
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with highlight
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
                      TextSpan(
                        text: page.titleHighlight,
                        style: const TextStyle(
                          color: MoldifyColors.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Subtitle
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
    );
  }

  Widget _buildIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? MoldifyColors.primaryColor
            : MoldifyColors.primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final String image;
  final String title;
  final String titleHighlight;
  final String subtitle;
  final bool isLastPage;

  OnboardingPage({
    required this.image,
    required this.title,
    required this.titleHighlight,
    required this.subtitle,
    this.isLastPage = false,
  });
}