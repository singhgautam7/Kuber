import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuber/l10n/app_localizations.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_data.dart';
import '../../../core/utils/formatters.dart';
import '../../settings/providers/settings_provider.dart';
import '../../settings/widgets/currency_selector_sheet.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_segmented_control.dart';
import '../widgets/onboarding_fit.dart';
import '../widgets/setup_language_row.dart';

class OnboardingPageFour extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final String selectedCurrencyCode;
  final ThemeMode selectedTheme;
  final Locale selectedLocale;
  final ValueChanged<String> onCurrencyChanged;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<Locale> onLocaleChanged;
  final VoidCallback onNameChanged;

  const OnboardingPageFour({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.selectedCurrencyCode,
    required this.selectedTheme,
    required this.selectedLocale,
    required this.onCurrencyChanged,
    required this.onThemeChanged,
    required this.onLocaleChanged,
    required this.onNameChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context);

    final titleText = localizations?.makeItYours ?? 'Make it yours.';
    final subtitleText =
        localizations?.threeQuickChoices ??
        "Three quick choices and you're in.";
    final nameLabel = localizations?.yourName ?? 'YOUR NAME';
    final namePlaceholder = localizations?.namePlaceholder ?? 'Your name';
    final nameRequired =
        localizations?.nameRequired ?? 'Please enter your name';
    final nameTooLong =
        localizations?.nameTooLong ?? 'Name must be 15 characters or fewer';
    final currencyLabel = localizations?.currency ?? 'CURRENCY';
    final themeLabel = localizations?.theme ?? 'THEME';
    final themeLight = localizations?.themeLight ?? 'LIGHT';
    final themeDark = localizations?.themeDark ?? 'DARK';
    final themeSystem = localizations?.themeSystem ?? 'SYSTEM';

    return Column(
      children: [
        // Ghost header — same height as OnboardingSkipButton on pages 1–3
        // so "Make it yours." doesn't glue to the status bar.
        const SizedBox(height: 48),
        Expanded(
          child: OnboardingFit(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleText,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineLarge!.copyWith(color: cs.onSurface),
                  ),
                  const SizedBox(height: KuberSpace.md),
                  Text(
                    subtitleText,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: KuberSpace.xl),
                  _SectionLabel(nameLabel),
                  const SizedBox(height: KuberSpace.sectionHeaderGap),
                  TextFormField(
                    controller: nameController,
                    onChanged: (_) => onNameChanged(),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(15),
                      TitleCaseInputFormatter(),
                    ],
                    maxLength: 15,
                    textCapitalization: TextCapitalization.words,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.copyWith(color: cs.onSurface),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) {
                        return nameRequired;
                      }
                      if (text.length > 15) {
                        return nameTooLong;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: namePlaceholder,
                      counterText:
                          '${nameController.text.characters.length}/15',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: KuberSpace.sm),
                  KuberGroup(
                    children: [
                      SetupLanguageRow(
                        selectedLocale: selectedLocale,
                        onLocaleChanged: onLocaleChanged,
                      ),
                      _CurrencyTile(
                        code: selectedCurrencyCode,
                        label: currencyLabel,
                        onTap: () {
                          showCurrencyPicker(
                            context: context,
                            ref: ref,
                            currentCode: selectedCurrencyCode,
                            onSelected: onCurrencyChanged,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: KuberSpace.xl),
                  _SectionLabel(themeLabel),
                  const SizedBox(height: KuberSpace.sectionHeaderGap),
                  KuberSegmentedControl<ThemeMode>(
                    values: const [
                      ThemeMode.light,
                      ThemeMode.dark,
                      ThemeMode.system,
                    ],
                    labels: [
                      sentenceCase(themeLight),
                      sentenceCase(themeDark),
                      sentenceCase(themeSystem),
                    ],
                    selected: selectedTheme,
                    onSelected: (mode) {
                      onThemeChanged(mode);
                      ref.read(settingsProvider.notifier).setThemeMode(mode);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(label.toUpperCase(), style: sectionHeaderStyle(context));
  }
}

class _CurrencyTile extends StatelessWidget {
  final String code;
  final String label;
  final VoidCallback onTap;

  const _CurrencyTile({
    required this.code,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currency = currencyFromCode(code);

    return KuberListRow(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: cs.secondaryContainer,
          shape: BoxShape.circle,
        ),
        child: Text(
          currency.symbol,
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(color: cs.onSecondaryContainer),
        ),
      ),
      title: currency.name,
      subtitle:
          '${sentenceCase(label)} · ${currency.code}${_currencyFlag(currency.code)}',
      trailing: const KuberChevron(),
    );
  }
}

String _currencyFlag(String code) {
  return switch (code) {
    'INR' => ' · 🇮🇳',
    'USD' => ' · 🇺🇸',
    'EUR' => ' · 🇪🇺',
    'GBP' => ' · 🇬🇧',
    'JPY' => ' · 🇯🇵',
    'CNY' => ' · 🇨🇳',
    'KRW' => ' · 🇰🇷',
    'AUD' => ' · 🇦🇺',
    'CAD' => ' · 🇨🇦',
    'CHF' => ' · 🇨🇭',
    'SGD' => ' · 🇸🇬',
    'HKD' => ' · 🇭🇰',
    'MYR' => ' · 🇲🇾',
    'THB' => ' · 🇹🇭',
    'PHP' => ' · 🇵🇭',
    'IDR' => ' · 🇮🇩',
    'BRL' => ' · 🇧🇷',
    'MXN' => ' · 🇲🇽',
    'ZAR' => ' · 🇿🇦',
    'AED' => ' · 🇦🇪',
    'SAR' => ' · 🇸🇦',
    'TRY' => ' · 🇹🇷',
    _ => '',
  };
}
