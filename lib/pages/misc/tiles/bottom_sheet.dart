import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    this.showDragHandle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MoldifyColors.backgroundColor,
        borderRadius: BorderRadius.vertical(
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
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Content widget specifically for photo options.
/// To be used as a child of [BuildBottomSheet] or directly in [showModalBottomSheet].
/// It provides options to upload or remove a photo with appropriate icons and styles.
/// Parameters:
/// - [onUploadPhoto]: Callback for upload photo action.
/// - [onRemovePhoto]: Callback for remove photo action.

class PhotoOptionsBottomSheetContent extends StatelessWidget {
  final VoidCallback? onUploadPhoto;
  final VoidCallback? onRemovePhoto;

  const PhotoOptionsBottomSheetContent({
    super.key,
    this.onUploadPhoto,
    this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(
            FontAwesomeIcons.arrowUpFromBracket,
            color: MoldifyColors.accentColor,
            size: 20.0
          ),
          title: Text(
            'Upload Photo',
            style: TextStyle(
                fontFamily: 'Bricolage-Grotesque-Bold',
                color: MoldifyColors.primaryColor,
                fontSize: 16
            )
          ),
          onTap: onUploadPhoto
        ),
        ListTile(
          leading: Icon(
            FontAwesomeIcons.solidTrashCan,
            color: MoldifyColors.accentColor,
            size: 20.0
          ),
          title: Text(
            'Remove Photo',
            style: TextStyle(
              fontFamily: 'Bricolage-Grotesque-Bold',
              color: MoldifyColors.primaryColor,
              fontSize: 16
            )
          ),
          onTap: onRemovePhoto
        ),
      ],
    );
  }
}
