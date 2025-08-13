import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/colors.dart';

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
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 30.0, top: 20.0),
          child: Column(
            children: [
              Row(
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