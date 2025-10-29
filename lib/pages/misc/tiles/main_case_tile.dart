import 'package:auto_size_text/auto_size_text.dart';
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

  // PopupMenu properties
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
          _containerColor = MoldifyColors.taupe.withOpacity(0.8);
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: _containerColor,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Stack(
          children: [
            // Main row (image + content)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.asset(
                    (widget.imageUrl != null && widget.imageUrl != "no_image")
                        ? widget.imageUrl!
                        : defaultImageUrl,
                    width: widget.imageWidth ?? 105,
                    height: widget.imageHeight ?? 105,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: widget.imageWidth ?? 105,
                        height: widget.imageHeight ?? 105,
                        color: MoldifyColors.MoldifySoftGrey,
                        child: const Icon(
                          Icons.broken_image,
                          color: MoldifyColors.primaryColor,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 15),

                // Text + Status section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),

                      // Case name
                      Text(
                        widget.caseName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Montserrat-Black',
                          color: MoldifyColors.primaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Date row
                      Row(
                        children: [
                          AutoSizeText(
                            widget.dateLabel ?? 'Date Submitted: ',
                            style: const TextStyle(
                              fontSize: 10,
                              color: MoldifyColors.primaryColor,
                              fontFamily: 'Bricolage-Grotesque-Bold',
                            ),
                            maxLines: 1,
                            minFontSize: 8,
                          ),
                          AutoSizeText(
                            widget.dateSubmitted,
                            style: const TextStyle(
                              fontSize: 10,
                              color: MoldifyColors.MoldifyBlack,
                              fontFamily: 'Bricolage-Grotesque-Regular',
                            ),
                            maxLines: 1,
                            minFontSize: 8,
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Status labels
                      Row(
                        children: [
                          if (widget.priorityLevel != null) ...[
                            Flexible(
                              fit: FlexFit.tight,
                              child: StatusBox(status: widget.priorityLevel!),
                            ),
                            const SizedBox(width: 5),
                          ],
                          Flexible(
                            fit: FlexFit.tight,
                            child: StatusBox(status: widget.caseStatus),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),

            // Popup menu floated on top right
            if (widget.showPopupMenu == true &&
                widget.popupMenuItems != null &&
                widget.popupMenuItems!.isNotEmpty &&
                widget.onPopupMenuItemSelected != null)
              Positioned(
                top: -10  ,
                right: 0,
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
    );
  }
}
