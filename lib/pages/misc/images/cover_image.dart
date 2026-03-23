import 'package:flutter/material.dart';

class BuildCoverImage extends StatelessWidget {
  final String? imageUrl;
  final double borderRadiusContainer;
  final double borderRadiusImage;
  final bool isHeader;

  const BuildCoverImage({
    super.key,
    this.imageUrl,
    this.borderRadiusContainer = 0,
    this.borderRadiusImage = 0,
    this.isHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    // Check if imageUrl is valid
    final bool hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    const String fallbackAsset = 'assets/images/Branding2.png';

    return Container(
      height: 350,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadiusContainer),
        color: Colors.grey.shade300,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadiusImage),
        child: hasImage
            ? Image.network(
          imageUrl!.trim(),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // If the network image fails, fallback to asset
            return Image.asset(
              fallbackAsset,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            );
          },
        )
            : Image.asset(
          fallbackAsset,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
