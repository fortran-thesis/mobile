import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:moldify/pages/misc/colors.dart';

class HomeBanner extends StatelessWidget {
  final String title;
  final String subtitle;

  const HomeBanner({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      // 2. Allow the image to draw outside the stack's bounds
      clipBehavior: Clip.none,
      children: [
        // 3. The main banner container (Bottom Layer)
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
                // Text section
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
                      SizedBox(height: 2.0,),
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
                // Reserve space for the image that will be placed on top
                const SizedBox(width: 170),
              ],
            ),
          ),
        ),

        // 4. The image
        Positioned(
          right: -4.0,
          top: -12.0,
          bottom: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.asset(
              'assets/images/mold_home_banner.png',
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