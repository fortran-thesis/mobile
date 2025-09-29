import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/home/notification_page.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/functions/app_drawer.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  int _unReadNotifications = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
          child: Column(
            children: [
              /// Header with Menu and Notification Icons
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
                              size: 24.0
                          )
                      );
                    }
                  ),
                  const Spacer(),
                  Stack(
                    children: [
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _unReadNotifications = 0;
                            });
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const NotificationScreen(),
                              ),
                            );
                          },
                          icon: const Icon
                            (
                              FontAwesomeIcons.solidBell,
                              color: MoldifyColors.primaryColor,
                              size: 24.0
                          )
                      ),
                      if (_unReadNotifications > 0)
                        Positioned(
                          right: 7,
                          top: 15,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: MoldifyColors.backgroundColor,
                                width: 2.0,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 5.0,
                              backgroundColor: MoldifyColors.MoldifyRed,
                            ),
                          ),
                        )
                    ],
                  ),
                ],
              ),
              /// End Of Header with Menu and Notification Icons
              const Row(
                children: [

                ],
              )
            ],
          ),
        ),
      )
    );
  }
}