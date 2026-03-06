import 'package:flutter/material.dart';
import 'package:moldify/l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';
import '../misc/appbar/secondary_appbar.dart';
import '../misc/colors.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: SecondaryAppBar(
        title: l10n.languagePageTitle,
        color: MoldifyColors.backgroundColor,
        themeColor: MoldifyColors.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.languagePageTitle,
              style: const TextStyle(
                fontSize: 28,
                fontFamily: 'Montserrat-Black',
                color: MoldifyColors.primaryColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.languagePageSubtitle,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Bricolage-Grotesque-Regular',
                color: MoldifyColors.MoldifyBlack,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              height: 1.0,
              color: MoldifyColors.MoldifySoftGrey,
            ),
            const SizedBox(height: 20),
            Consumer<LanguageProvider>(
              builder: (context, langProvider, _) {
                return Column(
                  children: [
                    _LanguageOption(
                      label: l10n.english,
                      locale: const Locale('en'),
                      selected: langProvider.selectedLocale.languageCode == 'en',
                      onTap: () => langProvider.setLocale(const Locale('en')),
                    ),
                    const SizedBox(height: 12),
                    _LanguageOption(
                      label: l10n.filipino,
                      locale: const Locale('fil'),
                      selected: langProvider.selectedLocale.languageCode == 'fil',
                      onTap: () => langProvider.setLocale(const Locale('fil')),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final Locale locale;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.locale,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: selected
              ? MoldifyColors.primaryColor.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? MoldifyColors.primaryColor
                : MoldifyColors.MoldifySoftGrey,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              FontAwesomeIcons.globe,
              size: 18,
              color: selected
                  ? MoldifyColors.primaryColor
                  : MoldifyColors.MoldifyGrey,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: selected
                      ? 'Bricolage-Grotesque-SemiBold'
                      : 'Bricolage-Grotesque-Regular',
                  fontSize: 16,
                  color: selected
                      ? MoldifyColors.primaryColor
                      : MoldifyColors.MoldifyBlack,
                ),
              ),
            ),
            if (selected)
              const Icon(
                FontAwesomeIcons.circleCheck,
                size: 18,
                color: MoldifyColors.primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}
