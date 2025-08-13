import 'package:flutter/material.dart';
import '../../core/constants/route_names.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(RouteNames.login);
          },
          child: const Text('Go to Login'),
        ),
      ),
    );
  }
}
