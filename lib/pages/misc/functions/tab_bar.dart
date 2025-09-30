import 'package:flutter/material.dart';

class TabBar extends StatelessWidget {
  final List<Widget> tabs;
  final TabController controller;

  const TabBar({super.key, required this.tabs, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: controller,
        tabs: tabs,

      ),
    );
  }
}