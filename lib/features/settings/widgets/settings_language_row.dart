import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../core/utils/supported_locales.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import 'settings_section.dart' show SettingsTile;
import 'language_picker_bottom_sheet.dart';

/// A settings row that displays the current language selection and opens
/// the language picker bottom sheet when tapped.
class SettingsLanguageRow extends ConsumerWidget {
  const SettingsLanguageRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);
    final lang = kSupportedLanguages.firstWhere(
      (l) => l.locale.languageCode == locale.languageCode,
      orElse: () => kSupportedLanguages.first,
    );

    final localizations = lookupAppLocalizations(locale);
    final labelText = localizations.language;

    // Same plain-icon row as every other setting (board 3.11); it shows a
    // value, so it drops its description.
    return SettingsTile(
      icon: Icons.language_rounded,
      label: labelText,
      onTap: () => showLanguagePicker(
        context: context,
        ref: ref,
        currentLocale: locale,
        onSelected: (newLocale) {
          ref.read(settingsProvider.notifier).setLocale(newLocale);
        },
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            lang.nativeName,
            style: localeFont(
              locale: lang.locale,
              fontSize: 14,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: KuberSpace.sm),
          Icon(
            Icons.chevron_right_rounded,
            color: cs.onSurfaceVariant,
            size: 20,
          ),
        ],
      ),
    );
  }
}
