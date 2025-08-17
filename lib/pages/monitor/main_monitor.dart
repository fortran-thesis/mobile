import 'package:flutter/material.dart';

import '../misc/colors.dart';

class MainMonitorScreen extends StatefulWidget {
  const MainMonitorScreen({super.key});

  @override
  State<MainMonitorScreen> createState() => _MainMonitorScreenState();
}

class _MainMonitorScreenState extends State<MainMonitorScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      body: Center(
        child: Text(
          'Welcome to the Monitor Screen',
        ),
      ),
    );
  }
}