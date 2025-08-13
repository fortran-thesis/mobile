import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/functions/app_drawer.dart'; // Added import

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
          child: Column(
            children: [
              Row(
                children: [
                  Builder(
                    builder: (BuildContext newContext) {
                      return IconButton(
                          onPressed: () {
                            Scaffold.of(newContext).openDrawer();
                          },
                          icon: const Icon(
                              FontAwesomeIcons.bars,
                              color: MoldifyColors.primaryColor,
                              size: 20.0
                          )
                      );
                    }
                  ),
                  const Spacer(),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon
                        (
                          FontAwesomeIcons.solidBell,
                          color: MoldifyColors.primaryColor,
                          size: 20.0
                      )
                  ),
                ],
              ),
              const Row(
                children: [
                  // You can add more widgets here if needed
                ],
              )
            ],
          ),
        ),
      )
    );
  }
}