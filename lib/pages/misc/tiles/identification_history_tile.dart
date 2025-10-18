import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../buttons/popmenu_button.dart';
import '../colors.dart';

class IdentificationHistoryTile extends StatefulWidget {
  final String moldName;
  final String dateIdentified;
  final String? imageUrl;
  final VoidCallback onTap;

  const IdentificationHistoryTile({
    super.key,
    required this.moldName,
    required this.dateIdentified,
    this.imageUrl,
    required this.onTap,

  });

  @override
  _IdentificationHistoryTileState createState() => _IdentificationHistoryTileState();
}

class _IdentificationHistoryTileState extends State<IdentificationHistoryTile> {
  late Color _containerColor;

  @override
  void initState() {
    super.initState();
    _containerColor = MoldifyColors.taupe;
  }

  @override
  Widget build(BuildContext context) {
    final String defaultImageUrl = 'assets/images/Branding2.png';

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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(7.0),
        decoration: BoxDecoration(
          color: _containerColor,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.asset(
                      (widget.imageUrl != null && widget.imageUrl != "no_image")
                          ? widget.imageUrl!
                          : defaultImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: MoldifyColors.MoldifySoftGrey,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: MoldifyColors.primaryColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 15.0),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0, right: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.moldName,
                          style: const TextStyle(
                              fontSize: 16.0,
                              fontFamily: 'Montserrat-Black',
                              color: MoldifyColors.primaryColor),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Date Identified: ',
                                style: const TextStyle(
                                  fontSize: 10.0,
                                  color: MoldifyColors.primaryColor,
                                  fontFamily: 'Bricolage-Grotesque-Bold',
                                ),
                              ),
                              TextSpan(
                                text: widget.dateIdentified,
                                style: const TextStyle(
                                  fontSize: 10.0,
                                  color: MoldifyColors.MoldifyBlack,
                                  fontFamily: 'Bricolage-Grotesque-Regular',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}