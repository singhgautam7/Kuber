import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../core/utils/supported_locales.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/providers/settings_provider.dart';
import '../../settings/widgets/language_picker_bottom_sheet.dart';

/// Drop-in replacement for the "LANGUAGE" section on OnboardingPageFour.
/// Insert between the YOUR NAME and CURRENCY sections.
class SetupLanguageRow extends ConsumerWidget {
  /// Locale currently selected in the form state. Owned by OnboardingFlow.
  final Locale selectedLocale;
  final ValueChanged<Locale> onLocaleChanged;

  const SetupLanguageRow({
    super.key,
    required this.selectedLocale,
    required this.onLocaleChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final lang = kSupportedLanguages.firstWhere(
      (l) => l.locale.languageCode == selectedLocale.languageCode,
      orElse: () => kSupportedLanguages.first,
    );

    final localizations = lookupAppLocalizations(selectedLocale);
    final labelText = localizations.language;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: KuberSpacing.xs),
          child: Text(
            labelText,
            style: localeFont(
              locale: selectedLocale,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        _LanguageTile(
          lang: lang,
          onTap: () => showLanguagePicker(
            context: context,
            ref: ref,
            currentLocale: selectedLocale,
            onSelected: (locale) {
              onLocaleChanged(locale);
              ref.read(settingsProvider.notifier).setLocale(locale);
            },
          ),
        ),
      ],
    );
  }
}

/// Matches the existing `_CurrencyTile` from onboarding_page_4.dart 1:1 in
/// height, padding, and corner radius so the rows stack cleanly.
class _LanguageTile extends StatelessWidget {
  final KuberLanguage lang;
  final VoidCallback onTap;

  const _LanguageTile({required this.lang, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // First grapheme of the native name doubles as the leading "monogram",
    // mirroring the currency symbol slot. Devanagari "अ", Gurmukhi "ਪ" etc.
    final monogram = lang.nativeName.characters.first;
    final monogramStyle = localeFont(
      locale: lang.locale,
      fontSize: 22,
      fontWeight: FontWeight.w800,
      color: cs.primary,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        child: Ink(
          padding: const EdgeInsets.all(KuberSpacing.md),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            border: Border.all(color: cs.outline),
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.outline),
                ),
                child: Text(monogram, style: monogramStyle),
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lang.nativeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: localeFont(
                        locale: lang.locale,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lang.englishName,
                      style: localeFont(
                        locale: const Locale('en'),
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
