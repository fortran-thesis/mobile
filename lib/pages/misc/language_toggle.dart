import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moldify/providers/language_provider.dart';

/// A small language toggle widget that allows switching between English and Filipino.
/// Can be placed in the top corner of auth screens.
///
/// Usage:
/// ```
/// LanguageToggle(color: MoldifyColors.backgroundColor)
/// ```
class LanguageToggle extends StatelessWidget {
  final Color? color;
  final double fontSize;

  const LanguageToggle({
    super.key,
    this.color,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final isFilipino =
            languageProvider.selectedLocale.languageCode == 'fil';

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // English button
            InkWell(
              onTap: isFilipino
                  ? () => languageProvider.setLocale(const Locale('en'))
                  : null,
              child: Text(
                'EN',
                style: TextStyle(
                  color: !isFilipino
                      ? (color ?? Colors.white)
                      : (color ?? Colors.white).withValues(alpha: 0.5),
                  fontSize: fontSize,
                  fontWeight: !isFilipino ? FontWeight.bold : FontWeight.normal,
                  fontFamily: 'Bricolage-Grotesque-SemiBold',
                ),
              ),
            ),
            SizedBox(width: 8),
            // Divider
            Text(
              '|',
              style: TextStyle(
                color: color ?? Colors.white,
                fontSize: fontSize,
              ),
            ),
            SizedBox(width: 8),
            // Filipino button
            InkWell(
              onTap: !isFilipino
                  ? () => languageProvider.setLocale(const Locale('fil'))
                  : null,
              child: Text(
                'FIL',
                style: TextStyle(
                  color: isFilipino
                      ? (color ?? Colors.white)
                      : (color ?? Colors.white).withValues(alpha: 0.5),
                  fontSize: fontSize,
                  fontWeight: isFilipino ? FontWeight.bold : FontWeight.normal,
                  fontFamily: 'Bricolage-Grotesque-SemiBold',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
