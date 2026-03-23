import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:moldify/pages/misc/colors.dart';

class HomeBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  // 1. Define the variable for the image path
  final String imagePath;

  const HomeBanner({
    super.key,
    required this.title,
    required this.subtitle,
    // 2. Add it to the constructor
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: 170.0,
          decoration: BoxDecoration(
            color: MoldifyColors.primaryColor,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutoSizeText(
                        title,
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Montserrat-Black',
                          fontWeight: FontWeight.bold,
                          color: MoldifyColors.backgroundColor,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        minFontSize: 16,
                      ),
                      const SizedBox(height: 2.0,),
                      AutoSizeText(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Bricolage-Grotesque-Regular',
                          color: MoldifyColors.backgroundColor,
                        ),
                        maxLines: 2,
                        minFontSize: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 170),
              ],
            ),
          ),
        ),

        Positioned(
          right: -4.0,
          top: -12.0,
          bottom: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.asset(
              // 3. Use the variable here
              imagePath,
              width: 170,
              height: 170,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}