import 'package:flutter/material.dart';
import 'package:moldify/core/utils/route_utils.dart';
import '../../core/constants/route_names.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            navigateTo(context, RouteNames.main);
          },
          child: const Text('Go to Main Page'),
        ),
      ),
    );
  }
}
