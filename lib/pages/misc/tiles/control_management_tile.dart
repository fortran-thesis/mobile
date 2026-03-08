import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/colors.dart';

class ControlManagementTile extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final int maxLines;

  const ControlManagementTile({
    super.key, 
    required this.title, 
    required this.description, 
    required this.icon,
    this.maxLines = 3,
  });

  @override
  State<ControlManagementTile> createState() => _ControlManagementTileState();
}

class _ControlManagementTileState extends State<ControlManagementTile> {
  bool _isExpanded = false;
  bool? _cachedIsOverflowing;
  String? _cachedDescription;
  int? _cachedMaxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(30),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(35),
      gradient: LinearGradient(
        colors: [
          MoldifyColors.primaryColor.withOpacity(0.05),
          MoldifyColors.primaryColor.withOpacity(0.01),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(
        color: MoldifyColors.primaryColor.withOpacity(0.1),
      ),
    ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.icon, color: MoldifyColors.accentColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.title, 
                  style: const TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Extrabold', 
                    fontSize: 17, 
                    color: MoldifyColors.primaryColor
                  )
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              // Only recalculate TextPainter if description or maxLines changed
              // This prevents expensive layout calculations on every rebuild
              final needsRecalculation = _cachedDescription != widget.description ||
                  _cachedMaxLines != widget.maxLines ||
                  _cachedIsOverflowing == null;
              
              if (needsRecalculation) {
                final textSpan = TextSpan(
                  text: widget.description,
                  style: const TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Regular', 
                    fontSize: 15, 
                    height: 1.6, 
                    color: MoldifyColors.MoldifyBlack
                  ),
                );
                
                final textPainter = TextPainter(
                  text: textSpan,
                  maxLines: widget.maxLines,
                  textDirection: TextDirection.ltr,
                )..layout(maxWidth: constraints.maxWidth);
                
                _cachedIsOverflowing = textPainter.didExceedMaxLines;
                _cachedDescription = widget.description;
                _cachedMaxLines = widget.maxLines;
              }
              
              final isTextOverflowing = _cachedIsOverflowing ?? false;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.description,
                    maxLines: _isExpanded ? null : widget.maxLines,
                    overflow: _isExpanded ? null : TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Regular', 
                      fontSize: 15, 
                      height: 1.6, 
                      color: MoldifyColors.MoldifyBlack
                    ),
                  ),
                  if (isTextOverflowing) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Text(
                        _isExpanded ? 'View Less' : 'View More',
                        style: const TextStyle(
                          fontFamily: 'Bricolage-Grotesque-Semibold',
                          fontSize: 14,
                          color: MoldifyColors.MoldifyBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}