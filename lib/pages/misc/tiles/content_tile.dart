import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../colors.dart';

class ContentTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color iconColor;
  final Color backgroundColor;
  final Color textColor;
  final Color titleColor;
  final Color learnMoreColor;
  final int truncateWords;

  const ContentTile({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    this.iconColor = MoldifyColors.accentColor,
    this.backgroundColor = MoldifyColors.taupe,
    this.textColor = MoldifyColors.MoldifyBlack,
    this.titleColor = MoldifyColors.primaryColor,
    this.learnMoreColor = MoldifyColors.MoldifyBlue,
    this.truncateWords = 30,
  });

  @override
  State<ContentTile> createState() => _ContentTileState();
}

class _ContentTileState extends State<ContentTile> {
  bool _showFullText = false;
  late TapGestureRecognizer _tapRecognizer;

  @override
  void initState() {
    super.initState();
    _tapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        setState(() {
          _showFullText = !_showFullText;
        });
      };
  }

  @override
  void dispose() {
    _tapRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final words = widget.content.split(' ');
    final isLongText = words.length > widget.truncateWords;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title with icon
          Row(
            children: [
              Icon(
                widget.icon,
                color: widget.iconColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              AutoSizeText(
                widget.title,
                style: TextStyle(
                  fontFamily: 'Bricolage-Grotesque-Bold',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.titleColor,
                ),
                minFontSize: 10,
              ),
            ],
          ),
          const SizedBox(height: 8),

          /// Description with "Learn More" toggle
          AutoSizeText.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                color: widget.textColor,
              ),
              children: [
                TextSpan(
                  text: (isLongText && !_showFullText)
                      ? '${words.take(widget.truncateWords).join(' ')} '
                      : '${widget.content} ',
                ),
                if (isLongText)
                  TextSpan(
                    text: _showFullText ? 'Show Less' : 'Learn More',
                    style: TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Bold',
                      color: widget.learnMoreColor,
                    ),
                    recognizer: _tapRecognizer,
                  ),
              ],
            ),
            textAlign: TextAlign.justify,
            minFontSize: 10,
          ),
        ],
      ),
    );
  }
}
