import 'package:flutter/material.dart';
import 'package:moldify/l10n/app_localizations.dart';
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

  final bool showPopupMenu;
  final List<String>? popupMenuItems;
  final List<IconData>? popupMenuIcons;
  final ValueChanged<int>? onPopupMenuItemSelected;
  final Widget? popupMenuIcon;
  final IconData? rightActionIcon;
  final VoidCallback? onRightActionPressed;

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
    this.rightActionIcon,
    this.onRightActionPressed,
    this.imageWidth,
    this.imageHeight,
    this.dateLabel,
  });

  @override
  State<MainCaseTile> createState() => _MainCaseTileState();
}

class _MainCaseTileState extends State<MainCaseTile> {
  Color _containerColor = MoldifyColors.taupe;

  @override
  Widget build(BuildContext context) {
    const String defaultImageUrl = 'assets/images/Branding2.png';
    final String caseImageUrl = widget.imageUrl ?? '';
    final bool isNetworkImage = caseImageUrl.startsWith('http');
    final bool hasValidPath = caseImageUrl.isNotEmpty && caseImageUrl != 'no_image';

    return GestureDetector(
      onTapDown: (_) => setState(() => _containerColor = MoldifyColors.taupe.withValues(alpha: 0.8)),
      onTapUp: (_) {
        setState(() => _containerColor = MoldifyColors.taupe);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _containerColor = MoldifyColors.taupe),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: _containerColor,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: isNetworkImage
                      ? Image.network(
                          caseImageUrl,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(defaultImageUrl, width: 90, height: 90, fit: BoxFit.cover),
                        )
                      : Image.asset(
                          hasValidPath ? caseImageUrl : defaultImageUrl,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(defaultImageUrl, width: 90, height: 90, fit: BoxFit.cover),
                        ),
                ),
                const SizedBox(width: 12),

                // 2. Content Column
                Expanded(
                  child: SizedBox(
                    height: 90, 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center, // Centers the entire group
                      children: [
                        // Text Group
                        Padding(
                          padding: const EdgeInsets.only(right: 28.0),
                          child: Text(
                            widget.caseName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Montserrat-Black',
                              color: MoldifyColors.primaryColor,
                            ),
                          ),
                        ),
                        
                        // Bold Label with Regular Variable
                        Text.rich(
                          TextSpan(
                            style: const TextStyle(
                              fontSize: 11,
                              color: MoldifyColors.MoldifyBlack,
                              fontFamily: 'Bricolage-Grotesque-Regular',
                            ),
                            children: [
                              TextSpan(
                                text: "${widget.dateLabel ?? AppLocalizations.of(context)!.dateLabel}: ",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: widget.dateSubmitted,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 12), // This creates the "Lift" for the tiles

                        // 3. Status Tile
                        Row(
                          children: [
                            StatusBox(status: widget.caseStatus),
                          ],
                        ),
                        
                        const SizedBox(height: 4), // Small buffer at the very bottom
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 4. Popup Menu - Adjusted position to prevent cutting
            if (widget.showPopupMenu)
              Positioned(
                top: -4,
                right: -4,
                child: PopupMenu(
                  popMenuIcon: widget.popupMenuIcon,
                  items: widget.popupMenuItems!,
                  icons: widget.popupMenuIcons,
                  onItemSelected: widget.onPopupMenuItemSelected!,
                ),
              ),

            if (!widget.showPopupMenu &&
                widget.rightActionIcon != null &&
                widget.onRightActionPressed != null)
              Positioned(
                top: -4,
                right: -4,
                child: IconButton(
                  onPressed: widget.onRightActionPressed,
                  icon: Icon(
                    widget.rightActionIcon,
                    size: 18,
                    color: MoldifyColors.primaryColor,
                  ),
                  splashRadius: 18,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}