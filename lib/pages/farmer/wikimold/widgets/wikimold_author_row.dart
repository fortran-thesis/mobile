import 'package:flutter/material.dart';

import '../../../misc/colors.dart';

class WikiMoldAuthorRow extends StatelessWidget {
  const WikiMoldAuthorRow({
    super.key,
    required this.author,
    required this.publishedDate,
  });

  final String author;
  final String publishedDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: MoldifyColors.taupe,
          child: Text(
            author.isNotEmpty ? author[0] : '?',
            style: const TextStyle(
              color: MoldifyColors.accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'By $author',
              style: const TextStyle(
                fontFamily: 'Bricolage-Grotesque-Extrabold',
                color: MoldifyColors.primaryColor,
                fontSize: 14,
              ),
            ),
            Text(
              publishedDate,
              style: const TextStyle(
                fontFamily: 'Bricolage-Grotesque-Regular',
                fontSize: 12,
                color: MoldifyColors.MoldifyGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
