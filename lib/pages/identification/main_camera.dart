import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';

import '../misc/colors.dart';

class MainCameraScreen extends StatefulWidget {
  const MainCameraScreen({super.key});

  @override
  State<MainCameraScreen> createState() => _MainCameraScreenState();
}

class _MainCameraScreenState extends State<MainCameraScreen> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: MoldifyColors.backgroundColor,
        child: SingleChildScrollView(
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ----------- Mold Scanner Header -----------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                      'Mold Scanner',
                      style: TextStyle(
                        fontSize: 36,
                        fontFamily: 'Montserrat-Black',
                        color: MoldifyColors.primaryColor,
                      )
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                      'Please capture or upload mold sample.',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        color: MoldifyColors.MoldifyBlack,
                      )
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: SvgPicture.asset(
                    'assets/images/mold_scanner_curve.svg',
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                ),
                /// ----------- End of Mold Scanner Header -----------

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Instructions Before Using',
                          style: TextStyle(
                            fontFamily: 'Montserrat-Black',
                            fontSize: 16,
                            color: MoldifyColors.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 10.0),

                        /// Start of Instructions Before Using
                        /// This section provides users with important guidelines to follow
                        /// before using the mold scanner feature.
                        /// The instructions are presented in a numbered list format for clarity.
                        Column(
                          children: [
                            'Make sure the mold sample is centered in the frame.',
                            'Ensure good lighting conditions for better accuracy.',
                            'Only photograph one mold species per image; avoid mixing species.',
                          ].asMap().entries.map((entry) {
                            int idx = entry.key;
                            String text = entry.value;
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${idx + 1}. ',
                                  style: const TextStyle(
                                    fontFamily: 'Bricolage-Grotesque-Regular',
                                    fontSize: 16,
                                    color: MoldifyColors.MoldifyBlack,
                                    letterSpacing: 0.5,
                                    height: 1.7,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    text,
                                    style: const TextStyle(
                                      fontFamily: 'Bricolage-Grotesque-Regular',
                                      fontSize: 16,
                                      color: MoldifyColors.MoldifyBlack,
                                      letterSpacing: 0.5,
                                      height: 1.7,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        /// End of Instructions Before Using

                        Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: BuildButton(
                              buttonText: 'Use Camera',
                              onPressed: () {
                                Navigator.pushNamed(context, '/camera');
                              },
                              backgroundColor: MoldifyColors.primaryColor,
                              textColor: MoldifyColors.backgroundColor,
                              buttonHeight: 40.0,
                              buttonWidth: MediaQuery.of(context).size.width,
                              buttonRadius: 10.0
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, bottom: 60.0),
                          child: BuildButton(
                              buttonText: 'Upload Image',
                              onPressed: () {
                                // Navigate to the next screen
                              },
                              backgroundColor: MoldifyColors.accentColor,
                              textColor: MoldifyColors.MoldifyBlack,
                              buttonHeight: 45.0,
                              buttonWidth: MediaQuery.of(context).size.width,
                              buttonRadius: 10.0
                          ),
                        ),
                      ]
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
