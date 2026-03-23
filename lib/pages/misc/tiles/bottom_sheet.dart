import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/colors.dart';

/// A reusable draggable bottom sheet widget.
///
/// It provides a consistent look with rounded top corners, an optional drag handle,
/// and padding for the content. The height is determined by the child content.
/// /// To use this widget, wrap your content in [BuildBottomSheet] and pass it to
/// [showModalBottomSheet] or use it directly in your widget tree.
/// Parameters:
/// - [child]: The content of the bottom sheet.
/// - [backgroundColor]: Optional background color for the bottom sheet.
/// - [showDragHandle]: Whether to show the drag handle at the top of the sheet

class BuildBottomSheet extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final bool showDragHandle;

  const BuildBottomSheet({
    super.key,
    required this.child,
    this.backgroundColor,
    this.showDragHandle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MoldifyColors.backgroundColor,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20.0)
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showDragHandle)
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                decoration: BoxDecoration(
                  color: MoldifyColors.MoldifySoftGrey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
            child: child,
          ),
        ],
      ),
    );
  }
}
