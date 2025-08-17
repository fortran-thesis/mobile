import 'package:flutter/material.dart';

import '../misc/colors.dart';

class MainCameraScreen extends StatefulWidget {
  const MainCameraScreen({super.key});

  @override
  State<MainCameraScreen> createState() => _MainCameraScreenState();
}

class _MainCameraScreenState extends State<MainCameraScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      body: Center(
        child: Text(
          'Welcome to the Camera1 Screen',
        ),
      ),
    );
  }
}