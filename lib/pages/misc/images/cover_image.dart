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
    final bool hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadiusContainer),
        color: hasImage ? null : Colors.grey.shade300,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadiusImage),
        child: hasImage
            ? Image.network(
          imageUrl!,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _fallbackWidget();
          },
        )
            : _fallbackWidget(),
      ),
    );
  }

  Widget _fallbackWidget() {
    return Container(
      color: Colors.grey.shade300,
      child: Center(
        child: Icon(
          isHeader ? Icons.photo : Icons.add_a_photo,
          size: 50,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}
