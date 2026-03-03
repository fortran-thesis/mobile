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
  State<MainCaseTile> createState() => _MainCaseTileState();
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
  final String caseImageUrl = widget.imageUrl ?? '';
  
  final bool isNetworkImage = caseImageUrl.startsWith('http');
  final bool hasValidPath = caseImageUrl.isNotEmpty && caseImageUrl != 'no_image';

  final String priorityDisplay = (widget.priorityLevel == null || widget.priorityLevel!.isEmpty)
      ? "Not Available"
      : widget.priorityLevel!;

  return GestureDetector(
    onTapDown: (_) => setState(() => _containerColor = MoldifyColors.taupe.withValues(alpha: 0.8)),
    onTapUp: (_) {
      setState(() => _containerColor = MoldifyColors.taupe);
      widget.onTap();
    },
    onTapCancel: () => setState(() => _containerColor = MoldifyColors.taupe),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: _containerColor,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Stack( // Using Stack to keep PopupMenu from affecting text layout
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: isNetworkImage
                    ? Image.network(
                        caseImageUrl,
                        width: 95,
                        height: 95,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(defaultImageUrl, width: 95, height: 95, fit: BoxFit.cover),
                      )
                    : Image.asset(
                        hasValidPath ? caseImageUrl : defaultImageUrl,
                        width: 95,
                        height: 95,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(defaultImageUrl, width: 95, height: 95, fit: BoxFit.cover),
                      ),
              ),

              const SizedBox(width: 12),

              // 2. Content
              Expanded(
                child: SizedBox(
                  height: 95, // Matches image height
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text Group (Pinned to top)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min, // Takes only required space
                        children: [
                          Text(
                            widget.caseName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Montserrat-Black',
                              color: MoldifyColors.primaryColor,
                              height: 1.0, // Removes extra vertical padding from font
                            ),
                          ),
                          // Minimal spacing here
                          const SizedBox(height: 2), 
                          Text(
                            "${widget.dateLabel ?? 'Date'}: ${widget.dateSubmitted}",
                            style: const TextStyle(
                              fontSize: 10,
                              color: MoldifyColors.MoldifyBlack,
                              fontFamily: 'Bricolage-Grotesque-Regular',
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(), // Pushes the status tiles to the bottom

                      // 3. Status Tiles
                      Row(
                        children: [
                          Expanded(
                            child: StatusBox(status: priorityDisplay),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: StatusBox(status: widget.caseStatus),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 4. Popup Menu (Positioned so it doesn't push text)
          if (widget.showPopupMenu)
            Positioned(
              top: -10,
              right: -5,
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
