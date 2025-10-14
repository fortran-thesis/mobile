import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/colors.dart';

class MainCaseTile extends StatelessWidget {
  final String caseName;
  final String dateSubmitted;
  final String status;
  final String? imageUrl;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onIconPressed;
  final VoidCallback onTap;

  const MainCaseTile({
    super.key,
    required this.caseName,
    required this.dateSubmitted,
    required this.status,
    this.icon,
    this.iconColor,
    this.onIconPressed,
    this.imageUrl,
    required this.onTap,
  });

  // 1. Helper method to get color based on status
  Color _getColorForStatus(String status) {
    switch (status) {
      case 'Resolved':
        return MoldifyColors.primaryColor;
      case 'Pending':
        return MoldifyColors.accentColor;
      case 'In Progress':
        return MoldifyColors.MoldifyBlue;
      case 'Rejected':
        return MoldifyColors.MoldifyRed;
      case 'Closed':
        return MoldifyColors.MoldifyGrey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String defaultImageUrl = 'assets/images/Branding2.png';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(7.0),
        decoration: BoxDecoration(
          color: MoldifyColors.taupe,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 70, // Set a fixed width to prevent overflow
              height: 70,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  (imageUrl != null && imageUrl != "no_image")
                      ? imageUrl!
                      : defaultImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: MoldifyColors.MoldifySoftGrey,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: MoldifyColors.primaryColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 15.0),
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        caseName,
                        style: const TextStyle(
                            fontSize: 18.0,
                            fontFamily: 'Montserrat-Black',
                            color: MoldifyColors.primaryColor),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Date Submitted: ',
                              style: const TextStyle(
                                fontSize: 10.0,
                                color: MoldifyColors.primaryColor,
                                fontFamily: 'Bricolage-Grotesque-Bold',
                              ),
                            ),
                            TextSpan(
                              text: dateSubmitted,
                              style: const TextStyle(
                                fontSize: 10.0,
                                color: MoldifyColors.MoldifyBlack,
                                fontFamily: 'Bricolage-Grotesque-Regular',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: -14,
                    right: 5,
                    child: Container(
                      width: 75,
                      // 2. Styled the container
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: _getColorForStatus(status),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Center(
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 10.0,
                            fontFamily: 'Bricolage-Grotesque-Bold',
                            color: status == 'Pending' ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (icon != null)
              IconButton(
                icon: Icon(
                  icon,
                  color: iconColor ?? MoldifyColors.primaryColor,
                ),
                onPressed: onIconPressed
              ),
          ],
        ),
      ),
    );
  }
}