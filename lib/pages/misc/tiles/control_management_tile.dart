import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:moldify/pages/misc/colors.dart';

class ControlManagementTile extends StatefulWidget {
  final String title;
  final String description;
  final String? proseHtml;
  final IconData icon;
  final int maxLines;

  const ControlManagementTile({
    super.key, 
    required this.title, 
    required this.description, 
    this.proseHtml,
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

  List<String> _extractBulletItems(String value) {
    final lines = value
        .split(RegExp(r'\n+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) return const <String>[];

    final bulletPattern = RegExp(r'^[•\-*]\s+');
    final allBulleted = lines.every((line) => bulletPattern.hasMatch(line));
    if (!allBulleted) return const <String>[];

    return lines
        .map((line) => line.replaceFirst(bulletPattern, '').trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  String _normalizeHtmlContent(String value) {
    return value
        .replaceAll('&amp;nbsp;', ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#160;', ' ');
  }

  String _stripHtmlTags(String value) {
    return value.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  bool _shouldShowHtmlToggle(String htmlContent) {
    final plainText = _stripHtmlTags(htmlContent);
    // Heuristic threshold for showing expand/collapse in HTML mode.
    return plainText.length > 260;
  }

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
            MoldifyColors.primaryColor.withValues(alpha: 0.05),
            MoldifyColors.primaryColor.withValues(alpha: 0.01),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: MoldifyColors.primaryColor.withValues(alpha: 0.1),
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
          _buildDescriptionBody(),
        ],
      ),
    );
  }

  Widget _buildDescriptionBody() {
    final proseHtml = widget.proseHtml == null
        ? null
        : _normalizeHtmlContent(widget.proseHtml!).trim();
    if (proseHtml != null && proseHtml.isNotEmpty) {
      final showToggle = _shouldShowHtmlToggle(proseHtml);
      final maxCollapsedHeight = widget.maxLines * 15.0 * 1.6;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRect(
            child: SizedBox(
              height: _isExpanded || !showToggle ? null : maxCollapsedHeight,
              child: Html(
                data: proseHtml,
                style: {
                  'body': Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    fontSize: FontSize(15),
                    lineHeight: LineHeight(1.6),
                    color: MoldifyColors.MoldifyBlack,
                    textAlign: TextAlign.justify,
                  ),
                  'p': Style(margin: Margins.zero, textAlign: TextAlign.justify),
                  'li': Style(textAlign: TextAlign.justify),
                  'ul': Style(margin: Margins.zero, padding: HtmlPaddings.zero),
                  'ol': Style(margin: Margins.zero, padding: HtmlPaddings.zero),
                },
              ),
            ),
          ),
          if (showToggle) ...[
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
    }

    final bulletItems = _extractBulletItems(widget.description);
    if (bulletItems.isNotEmpty) {
      final visibleItems = _isExpanded
          ? bulletItems
          : bulletItems.take(widget.maxLines).toList();
      final showToggle = bulletItems.length > widget.maxLines;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...visibleItems.asMap().entries.map(
            (entry) => Padding(
              padding: EdgeInsets.only(
                bottom: entry.key == visibleItems.length - 1 ? 0 : 10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 10.0),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: MoldifyColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        fontSize: 15,
                        height: 1.6,
                        color: MoldifyColors.MoldifyBlack,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showToggle) ...[
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
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Only recalculate TextPainter if description or maxLines changed.
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
              color: MoldifyColors.MoldifyBlack,
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
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontFamily: 'Bricolage-Grotesque-Regular',
                fontSize: 15,
                height: 1.6,
                color: MoldifyColors.MoldifyBlack,
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
    );
  }
}