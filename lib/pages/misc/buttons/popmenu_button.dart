import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/colors.dart';

/// A custom popup menu button that displays a list of items with icons.
class PopupMenu extends StatelessWidget {
  final List<String> items;
  final List<IconData>? icons;
  final ValueChanged<int>? onItemSelected;
  final Widget? popMenuIcon;
  final Color? popMenuColor;
  final double offset;

  const PopupMenu({
    super.key,
    required this.items,
    this.icons,
    this.onItemSelected,
    this.offset = 40.0,
    this.popMenuIcon,
    this.popMenuColor,
  })  : assert(icons == null || icons.length == items.length,
  'Each item must have a corresponding icon if icons are provided');

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      offset: Offset(0, offset),
      padding: EdgeInsets.zero,
      color: MoldifyColors.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onSelected: onItemSelected,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        // Use the provided icon or a default one. The size is set on the icon itself.
        child: popMenuIcon ??
            Icon(
              FontAwesomeIcons.ellipsis,
              color: popMenuColor ?? MoldifyColors.primaryColor,
            ),
      ),
      itemBuilder: (BuildContext context) {
        // ... (itemBuilder remains the same)
        final List<PopupMenuEntry<int>> menuItems = [];
        for (var i = 0; i < items.length; i++) {
          menuItems.add(
            PopupMenuItem<int>(
              value: i,
              child: Row(
                children: [
                  if (icons != null)
                    Icon(
                      icons![i],
                      color: MoldifyColors.accentColor,
                      size: 20,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      items[i],
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Bricolage-Grotesque-SemiBold',
                        color: MoldifyColors.MoldifyBlack,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
          if (i < items.length - 1) {
            menuItems.add(const PopupMenuDivider(
              height: 1,
              endIndent: 10,
              indent: 10,
            ));
          }
        }
        return menuItems;
      },
    );
  }
}