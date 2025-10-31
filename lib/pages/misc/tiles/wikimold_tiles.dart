import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/colors.dart';

/// This is a tile widget for displaying wiki molds.
/// It shows an image, title, and author name, and handles tap interactions.
/// Parameters:
/// - [title]: The title of the wiki mold.
/// - [authorName]: The name of the author.
/// - [imageUrl]: The URL of the image to display (optional).
/// - [onTap]: A callback function that is called when the tile is tapped.

class WikiMoldTile extends StatefulWidget {
  final String title;
  final String authorName;
  final String? imageUrl;
  final VoidCallback onTap;

  const WikiMoldTile({
    super.key,
    required this.title,
    required this.authorName,
    this.imageUrl,
    required this.onTap,
  });

  @override
  State<WikiMoldTile> createState() => _WikiMoldTileState();
}

class _WikiMoldTileState extends State<WikiMoldTile> {
  Color _containerColor = MoldifyColors.taupe;
  final String defaultImageUrl =
      'assets/images/Branding2.png';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _containerColor = MoldifyColors.taupe.withValues(alpha: 0.7);
        });
      },
      onTapUp: (_) {
        setState(() {
          _containerColor = MoldifyColors.taupe;
        });
        widget.onTap();
      },
      onTapCancel: () {
        setState(() {
          _containerColor = MoldifyColors.taupe;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: _containerColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: (widget.imageUrl != null &&
                    widget.imageUrl != "no_image")
                    ? null
                    : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
              ),
              width: MediaQuery.of(context).size.width,
              height: 100,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                child: (widget.imageUrl != null && widget.imageUrl != "no_image")
                    ? Image.network(
                  widget.imageUrl!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      defaultImageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.transparent,
                          child: const Center(
                            child: Icon(Icons.broken_image,
                                color: MoldifyColors.primaryColor),
                          ),
                        );
                      },
                    );
                  },
                )
                    : Image.asset(
                    'assets/images/Branding2.png',
                    fit: BoxFit.cover
                ),
              ),
            ),
            Padding(
              padding:
              const EdgeInsets.only(top: 8.0, bottom: 15.0, left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Montserrat-Black',
                      fontSize: 16,
                      color: MoldifyColors.primaryColor,
                    ),
                  ),
                  Text(
                    'By: ${widget.authorName}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Regular',
                      fontSize: 12,
                      color: MoldifyColors.MoldifyBlack,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
