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
import '../../settings/widgets/settings_widgets.dart';
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
    final subtitleText = localizations?.threeQuickChoices ?? "Three quick choices and you're in.";
    final nameLabel = localizations?.yourName ?? 'YOUR NAME';
    final namePlaceholder = localizations?.namePlaceholder ?? 'Your name';
    final nameRequired = localizations?.nameRequired ?? 'Please enter your name';
    final nameTooLong = localizations?.nameTooLong ?? 'Name must be 15 characters or fewer';
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
                    style: localeFont(
                      fontSize: 28,
                      height: 1.08,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -0.9,
                    ),
                  ),
                  const SizedBox(height: KuberSpacing.md),
                  Text(
                    subtitleText,
                    style: localeFont(
                      fontSize: 14,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: KuberSpacing.lg),
                  _SectionLabel(nameLabel),
                  const SizedBox(height: KuberSpacing.xs),
                  TextFormField(
                    controller: nameController,
                    onChanged: (_) => onNameChanged(),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(15),
                      TitleCaseInputFormatter(),
                    ],
                    maxLength: 15,
                    textCapitalization: TextCapitalization.words,
                    style: localeFont(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
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
                      hintStyle: localeFont(color: cs.onSurfaceVariant),
                      filled: true,
                      fillColor: cs.surfaceContainer,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: KuberSpacing.lg,
                        vertical: KuberSpacing.md,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                        borderSide: BorderSide(color: cs.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                        borderSide: BorderSide(color: cs.outline),
                      ),
                    ),
                  ),
                  const SizedBox(height: KuberSpacing.md),
                  SetupLanguageRow(
                    selectedLocale: selectedLocale,
                    onLocaleChanged: onLocaleChanged,
                  ),
                  const SizedBox(height: KuberSpacing.md),
                  _SectionLabel(currencyLabel),
                  const SizedBox(height: KuberSpacing.xs),
                  _CurrencyTile(
                    code: selectedCurrencyCode,
                    onTap: () {
                      showCurrencyPicker(
                        context: context,
                        ref: ref,
                        currentCode: selectedCurrencyCode,
                        onSelected: onCurrencyChanged,
                      );
                    },
                  ),
                  const SizedBox(height: KuberSpacing.md),
                  _SectionLabel(themeLabel),
                  const SizedBox(height: KuberSpacing.xs),
                  SettingsCardSelector<ThemeMode>(
                    options: [
                      SelectorOption(
                        value: ThemeMode.light,
                        label: themeLight,
                        icon: Icons.light_mode_outlined,
                      ),
                      SelectorOption(
                        value: ThemeMode.dark,
                        label: themeDark,
                        icon: Icons.dark_mode_outlined,
                      ),
                      SelectorOption(
                        value: ThemeMode.system,
                        label: themeSystem,
                        icon: Icons.phone_android_rounded,
                      ),
                    ],
                    selectedValue: selectedTheme,
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
    final cs = Theme.of(context).colorScheme;
    return Text(
      label,
      style: localeFont(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: cs.onSurfaceVariant,
        letterSpacing: 1.3,
      ),
    );
  }
}

class _CurrencyTile extends StatelessWidget {
  final String code;
  final VoidCallback onTap;

  const _CurrencyTile({required this.code, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currency = currencyFromCode(code);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        child: Ink(
          padding: const EdgeInsets.all(KuberSpacing.md),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: cs.outline),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.outline),
                ),
                alignment: Alignment.center,
                child: Text(
                  currency.symbol,
                  style: localeFont(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                  ),
                ),
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currency.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: localeFont(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${currency.code}${_currencyFlag(currency.code)}',
                      style: localeFont(
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