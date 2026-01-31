import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();

    // Navigate after animation
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
        final isAuthenticated = authProvider.cookie != null && authProvider.cookie!.isNotEmpty;
        final hasSeenIntro = authProvider.hasSeenIntro;

        String route;

        if (isAuthenticated) {
          // User is logged in -> go to main
          route = RouteNames.main;
        } else if (hasSeenIntro) {
          // Not logged in, but has seen intro -> go to login
          route = RouteNames.login;
        } else {
          // First time user -> show welcome screen
          route = RouteNames.welcome;
        }

        Navigator.of(context).pushReplacementNamed(route);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      body: Stack(
        children: [
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/moldify-logo-v2.png',
                    width: 60,
                    height: 60,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'MOLDIFY',
                    style: TextStyle(
                      color: MoldifyColors.primaryColor,
                      fontFamily: 'Montserrat-Black',
                      fontSize: 36,
                      letterSpacing: -1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: SvgPicture.asset(
                'assets/images/bacteria_with_leaves.svg',
                width: MediaQuery.of(context).size.width,
                height: 250, // Give it a height
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}