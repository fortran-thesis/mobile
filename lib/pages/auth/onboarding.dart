import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/providers/auth_provider.dart';
import 'package:provider/provider.dart';

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
      image: 'assets/images/onboarding_camera.svg',
      title: 'Submit Mold Cases with ',
      titleHighlight: 'Ease',
      subtitle: 'Moldify is a digital system that enables farmers to submit suspected mold cases for structured expert investigation.',
    ),
    OnboardingPage(
      image: 'assets/images/onboarding_scientist.svg',
      title: 'Expert Review by ',
      titleHighlight: 'Mycologists',
      subtitle: 'Moldify supports expert assessment and informed agricultural decision.',
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
      backgroundColor: const Color(0xFFF5F5DC),
      body: SafeArea(
        child: Stack(
          children: [
            // Skip button
            Positioned(
              top: 20,
              right: 20,
              child: TextButton(
                onPressed: _skip,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Color(0xFF3D5A3C),
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
                    color: const Color(0xFFE8B23C),
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

            // Bottom section
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    // Page indicators (showing 3 total)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildIndicator(false), // Welcome page (already passed)
                        _buildIndicator(_currentPage == 0),
                        _buildIndicator(_currentPage == 1),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _pages[_currentPage].isLastPage ? _finish : _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8B23C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _pages[_currentPage].isLastPage ? 'Continue To App' : 'Next',
                              style: const TextStyle(
                                color: Color(0xFF3D5A3C),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward,
                              color: Color(0xFF3D5A3C),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Image
          Expanded(
            flex: 3,
            child: Center(
              child: SvgPicture.asset(
                page.image,
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Text content
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Title with highlight
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      color: Color(0xFF3D5A3C),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    children: [
                      TextSpan(text: page.title),
                      TextSpan(
                        text: page.titleHighlight,
                        style: const TextStyle(
                          color: Color(0xFFE8B23C),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Subtitle
                Text(
                  page.subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF3D5A3C),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 120), // Space for buttons
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
        color: isActive
            ? const Color(0xFF3D5A3C)
            : const Color(0xFF3D5A3C).withOpacity(0.3),
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