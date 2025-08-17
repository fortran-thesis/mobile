import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/colors.dart';


/// BuildProfileImage is a method for Profile Photo
/// This widget displays a profile image with a fallback icon if the image is not available.
/// Parameters:
/// - [profilePhotoFile]: An optional Image object representing the profile photo.
/// - [width]: The width of the profile image container.
/// - [height]: The height of the profile image container.

class BuildProfileImage extends StatelessWidget {
  final Image? profilePhotoFile;
  final double width, height;

  const BuildProfileImage(
      this.profilePhotoFile, {
        super.key,
        required this.width,
        required this.height,
      });

  @override
  Widget build(BuildContext context) {
    final imageProvider = profilePhotoFile?.image;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: width,
          height: height,
          color: MoldifyColors.backgroundColor,
          child: imageProvider != null
              ? Image(
            image: imageProvider,
            fit: BoxFit.cover,
          )
              : Center(
            child: Icon(
              FontAwesomeIcons.solidUser,
              size: 70,
              color: MoldifyColors.accentColor,
            ),
          ),
        ),
      ),
    );
  }
}
