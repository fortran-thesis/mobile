import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../misc/appbar/primary_app_bar.dart';
import '../misc/colors.dart';

/// [LanguageSettingsScreen] provides a clean interface for users to toggle
/// between supported application locales. It uses [LanguageProvider] to 
/// persist changes globally.
class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(
        title: l10n.languagePageTitle,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.languagePageTitle,
              style: const TextStyle(
                fontSize: 32,
                fontFamily: 'Montserrat-Black',
                color: MoldifyColors.primaryColor,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.languagePageSubtitle,
              style: const TextStyle(
                fontSize: 15,
                fontFamily: 'Bricolage-Grotesque-Regular',
                color: MoldifyColors.MoldifyGrey,
              ),
            ),
            const SizedBox(height: 40),
            Consumer<LanguageProvider>(
              builder: (context, langProvider, _) {
                return Column(
                  children: [
                    _LanguageOption(
                      label: l10n.english,
                      localeCode: 'EN',
                      selected: langProvider.selectedLocale.languageCode == 'en',
                      onTap: () => langProvider.setLocale(const Locale('en')),
                    ),
                    const SizedBox(height: 16),
                    _LanguageOption(
                      label: l10n.filipino,
                      localeCode: 'PH',
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

/// A private helper widget to render individual language selection rows.
/// 
/// Parameters:
/// - [label]: The display name of the language (e.g., English).
/// - [localeCode]: Short string used for the leading badge (e.g., EN).
/// - [selected]: Boolean flag to toggle active styling.
/// - [onTap]: Callback triggered when the user selects this option.
class _LanguageOption extends StatelessWidget {
  final String label;
  final String localeCode;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.localeCode,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
        decoration: BoxDecoration(
          color: MoldifyColors.taupe,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected 
                ? MoldifyColors.primaryColor 
                : MoldifyColors.MoldifySoftGrey.withValues(alpha: 0.5),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Subtly use of Accent Color as a vertical indicator bar for selection
            if (selected)
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: MoldifyColors.accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            if (selected) const SizedBox(width: 12),
            
            // Leading language badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected 
                    ? MoldifyColors.primaryColor.withValues(alpha: 0.1) 
                    : MoldifyColors.backgroundColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                localeCode,
                style: TextStyle(
                  fontFamily: 'Bricolage-Grotesque-Bold',
                  fontSize: 12,
                  color: selected ? MoldifyColors.primaryColor : MoldifyColors.MoldifyGrey,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Language Name
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: selected 
                      ? 'Bricolage-Grotesque-SemiBold' 
                      : 'Bricolage-Grotesque-Regular',
                  fontSize: 17,
                  color: MoldifyColors.MoldifyBlack,
                ),
              ),
            ),
            
            // Functional Icon - Accent color used sparingly here for the "check"
            if (selected)
              const Icon(
                FontAwesomeIcons.solidCircleCheck,
                size: 20,
                color: MoldifyColors.accentColor,
              )
            else
              Icon(
                FontAwesomeIcons.circle,
                size: 20,
                color: MoldifyColors.MoldifySoftGrey,
              ),
          ],
        ),
      ),
    );
  }
}