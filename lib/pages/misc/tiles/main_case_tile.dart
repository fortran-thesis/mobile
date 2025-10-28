import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../buttons/popmenu_button.dart';
import '../colors.dart';
import 'status_tile.dart';

class MainCaseTile extends StatefulWidget {
  final String caseName;
  final String dateSubmitted;
  final String? priorityLevel;
  final String caseStatus;
  final String? imageUrl;
  final VoidCallback onTap;
  final double? imageWidth, imageHeight;
  final String? dateLabel;

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
    this.priorityLevel,
    required this.caseStatus,
    this.imageUrl,
    required this.onTap,
    this.showPopupMenu = false,
    this.popupMenuItems,
    this.popupMenuIcons,
    this.onPopupMenuItemSelected,
    this.popupMenuIcon,
    this.imageWidth,
    this.imageHeight,
    this.dateLabel,
  });

  @override
  _MainCaseTileState createState() => _MainCaseTileState();
}

class _MainCaseTileState extends State<MainCaseTile> {
  late Color _containerColor;

  @override
  void initState() {
    super.initState();
    _containerColor = MoldifyColors.taupe;
  }

  @override
  Widget build(BuildContext context) {
    final String defaultImageUrl = 'assets/images/Branding2.png';

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          // Make the tile slightly darker on tap.
          _containerColor = MoldifyColors.taupe.withOpacity(0.7);
        });
      },
      onTapUp: (_) {
        setState(() {
          _containerColor = MoldifyColors.taupe;
        });
        widget.onTap();
      },
      onTapCancel: () {
        setState(() {
          _containerColor = MoldifyColors.taupe;
        });
      },
      child: Material(
        color: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(7.0),
          decoration: BoxDecoration(
            color: _containerColor,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: widget.imageWidth ?? 90,
                    height: widget.imageHeight ?? 90,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.asset(
                        (widget.imageUrl != null && widget.imageUrl != "no_image")
                            ? widget.imageUrl!
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
                          padding: const EdgeInsets.only(top: 15.0, right: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.caseName,
                                style: const TextStyle(
                                    fontSize: 16.0,
                                    fontFamily: 'Montserrat-Black',
                                    color: MoldifyColors.primaryColor
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: [
                                  AutoSizeText(
                                    widget.dateLabel ?? 'Date Submitted: ',
                                    style: const TextStyle(
                                      fontSize: 10.0,
                                      color: MoldifyColors.primaryColor,
                                      fontFamily: 'Bricolage-Grotesque-Bold',
                                    ),
                                    maxLines: 1,
                                    minFontSize: 8,
                                  ),
                                  AutoSizeText(
                                    widget.dateSubmitted,
                                    style: const TextStyle(
                                      fontSize: 10.0,
                                      color: MoldifyColors.MoldifyBlack,
                                      fontFamily: 'Bricolage-Grotesque-Regular',
                                    ),
                                    maxLines: 1,
                                    minFontSize: 8,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Positioned(
                          top: -14,
                          right: 5,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.priorityLevel != null) ...[
                                StatusBox(status: widget.priorityLevel!),
                                const SizedBox(width: 5),
                              ],
                              const SizedBox(width: 5),
                              StatusBox(status: widget.caseStatus),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Optional PopupMenu positioned at the bottom right
              if (widget.showPopupMenu == true &&
                  widget.popupMenuItems != null &&
                  widget.popupMenuItems!.isNotEmpty &&
                  widget.onPopupMenuItemSelected != null)
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
                          popMenuIcon: widget.popupMenuIcon,
                          items: widget.popupMenuItems!,
                          icons: widget.popupMenuIcons,
                          onItemSelected: widget.onPopupMenuItemSelected!,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
