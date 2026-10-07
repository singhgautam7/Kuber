import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/locale_font.dart';
import '../../../core/utils/supported_locales.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/providers/settings_provider.dart';
import '../../settings/widgets/language_picker_bottom_sheet.dart';
import '../../../shared/widgets/kuber_list.dart';

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

    // A row of the onboarding preferences group (board 1d): native name as
    // the title, "Language · English name" under it.
    return KuberListRow(
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: cs.secondaryContainer,
          shape: BoxShape.circle,
        ),
        child: Text(
          lang.nativeName.characters.first,
          style: localeFont(
            locale: lang.locale,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: cs.onSecondaryContainer,
          ),
        ),
      ),
      title: lang.nativeName,
      subtitle: '${sentenceCase(labelText)} · ${lang.englishName}',
      trailing: const KuberChevron(),
      onTap: () => showLanguagePicker(
        context: context,
        ref: ref,
        currentLocale: selectedLocale,
        onSelected: (locale) {
          onLocaleChanged(locale);
          ref.read(settingsProvider.notifier).setLocale(locale);
        },
      ),
    );
  }
}
