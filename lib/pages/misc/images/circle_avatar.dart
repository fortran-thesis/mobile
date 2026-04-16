import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/colors.dart';

class CircleAvatarImage extends StatelessWidget {
  final String? profilePhotoUrl;
  final Image? profilePhotoFile;
  final double radius;

  const CircleAvatarImage({
    super.key,
    this.profilePhotoUrl,
    this.profilePhotoFile,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final imageProvider = profilePhotoFile?.image ??
        (profilePhotoUrl != null && profilePhotoUrl!.trim().isNotEmpty
            ? NetworkImage(profilePhotoUrl!.trim())
            : null);

    return CircleAvatar(
      radius: radius,
      backgroundColor: MoldifyColors.taupe,
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Icon(
              FontAwesomeIcons.solidUser,
              size: radius * 0.9,
              color: MoldifyColors.accentColor,
            )
          : null,
    );
  }
}