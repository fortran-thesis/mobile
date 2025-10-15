import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../buttons/popmenu_button.dart';
import '../colors.dart';

class MainCaseTile extends StatelessWidget {
  final String caseName;
  final String dateSubmitted;
  final String status;
  final String? imageUrl;
  final VoidCallback onTap;
  final double? imageWidth, imageHeight;

  // Properties for the optional PopupMenu
  final bool showPopupMenu;
  final List<String>? popupMenuItems;
  final List<IconData>? popupMenuIcons;
  final ValueChanged<int>? onPopupMenuItemSelected;
  final Widget? popupMenuIcon;

  const MainCaseTile({
    super.key,
    required this.caseName,
    required this.dateSubmitted,
    required this.status,
    this.imageUrl,
    required this.onTap,
    this.showPopupMenu = false,
    this.popupMenuItems,
    this.popupMenuIcons,
    this.onPopupMenuItemSelected,
    this.popupMenuIcon,
    this.imageWidth,
    this.imageHeight,
  });

  // Helper method to get color based on status
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: imageWidth ?? 90,
                  height: imageHeight ?? 90,
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
                      // This Padding widget prevents the text from overlapping with the status label.
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, right: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              caseName,
                              style: const TextStyle(
                                  fontSize: 16.0,
                                  fontFamily: 'Montserrat-Black',
                                  color: MoldifyColors.primaryColor),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
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
                      ),
                      Positioned(
                        top: -16,
                        right: 5,
                        child: Container(
                          width: 75,
                          // 2. Styled the container
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
                                  color: status == 'Pending'
                                      ? MoldifyColors.MoldifyBlack
                                      : MoldifyColors.backgroundColor),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
            // Optional PopupMenu positioned at the bottom right
            if (showPopupMenu == true &&
                popupMenuItems != null &&
                popupMenuItems!.isNotEmpty &&
                onPopupMenuItemSelected != null)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Column(
                  children: [
                    Divider(
                      color: MoldifyColors.MoldifySoftGrey,
                      thickness: 1.0,
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: PopupMenu(
                        popMenuIcon: popupMenuIcon,
                        items: popupMenuItems!,
                        icons: popupMenuIcons,
                        onItemSelected: onPopupMenuItemSelected!,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
