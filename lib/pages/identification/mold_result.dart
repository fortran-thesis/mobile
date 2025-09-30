import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/colors.dart';
import '../misc/appbar/primary_app_bar.dart';
import 'package:intl/intl.dart';

class MoldResultScreen extends StatefulWidget {
  final String croppedImagePath;

  const MoldResultScreen({super.key, required this.croppedImagePath});

  @override
  State<MoldResultScreen> createState() => _MoldResultScreenState();
}

class _MoldResultScreenState extends State<MoldResultScreen> {
  String today = DateFormat('MMMM d, y').format(DateTime.now());
  String confidenceLevel = 90.toString() ?? 'N/A';
  String moldGenus = 'Aspergillus' ?? 'N/A';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(
        title: 'Mold Result',
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Image.file(
            File(widget.croppedImagePath),
            fit: BoxFit.contain,
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: MoldifyColors.backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Icon(
                                    Icons.verified,
                                    size: 14,
                                    color: MoldifyColors.accentColor
                                ),
                              ),
                              TextSpan(
                                text: "\t\t\tThis information is verified by experts.",
                                style: TextStyle(
                                    color: MoldifyColors.MoldifyGrey,
                                    fontSize: 10,
                                    fontFamily: 'Bricolage-Grotesque-Regular'
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            moldGenus,
                            style: TextStyle(
                              fontSize: 40,
                              fontFamily: 'Montserrat-Black',
                              color: MoldifyColors.primaryColor,
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: Row (
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              /// This displays the date of identification
                              RichText(
                                text: TextSpan(
                                  children: [
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Icon(
                                          FontAwesomeIcons.solidCalendar,
                                          size: 16,
                                          color: MoldifyColors.accentColor
                                      ),
                                    ),
                                    TextSpan(
                                      text: "\t\t\t$today",
                                      style: TextStyle(
                                          color: MoldifyColors.primaryColor,
                                          fontSize: 12,
                                          fontFamily: 'Bricolage-Grotesque-Regular'
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// This displays the Algorithm Confidence Level
                              RichText(
                                text: TextSpan(
                                  children: [
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Icon(
                                          FontAwesomeIcons.chartSimple,
                                          size: 16,
                                          color: MoldifyColors.accentColor
                                      ),
                                    ),
                                    TextSpan(
                                      text: "\t\t\tConfidence level: $confidenceLevel%",
                                      style: TextStyle(
                                          color: MoldifyColors.primaryColor,
                                          fontSize: 12,
                                          fontFamily: 'Bricolage-Grotesque-Regular'
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )

                    ],
                  ),
                ),
              ),
            ),
          )

        ],
      ),
    );
  }
}