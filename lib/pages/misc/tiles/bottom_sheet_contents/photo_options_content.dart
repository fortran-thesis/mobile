import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/colors.dart';

/// Content widget specifically for photo options.
/// To be used as a child of [BuildBottomSheet] or directly in [showModalBottomSheet].
/// It provides options to upload or remove a photo with appropriate icons and styles.
/// Parameters:
/// - [onUploadPhoto]: Callback for upload photo action.
/// - [onRemovePhoto]: Callback for remove photo action.

class PhotoOptionsBottomSheetContent extends StatelessWidget {
  final VoidCallback? onUploadPhoto;
  final VoidCallback? onRemovePhoto;
  final String? label2;
  final IconData? label2Icon;

  const PhotoOptionsBottomSheetContent({
    super.key,
    this.onUploadPhoto,
    this.onRemovePhoto,
    this.label2,
    this.label2Icon,
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
          title: AutoSizeText(
            'Upload Photo',
            style: TextStyle(
                fontFamily: 'Bricolage-Grotesque-Bold',
                color: MoldifyColors.primaryColor,
                fontSize: 16
            ),
            maxLines: 1,
            minFontSize: 10,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: onUploadPhoto
        ),
        ListTile(
          leading: Icon(
            label2Icon ?? FontAwesomeIcons.solidTrashCan,
            color: MoldifyColors.accentColor,
            size: 20.0
          ),
          title: AutoSizeText(
            label2 ?? 'Remove Photo',
            style: TextStyle(
              fontFamily: 'Bricolage-Grotesque-Bold',
              color: MoldifyColors.primaryColor,
              fontSize: 16
            ),
            maxLines: 1,
            minFontSize: 10,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: onRemovePhoto
        ),
      ],
    );
  }
}
