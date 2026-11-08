import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/locale_font.dart';
import '../../../core/utils/supported_locales.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_list.dart' show kuberPressedLayer;

Future<void> showLanguagePicker({
  required BuildContext context,
  required WidgetRef ref,
  required Locale currentLocale,
  required ValueChanged<Locale> onSelected,
}) {
  final cs = Theme.of(context).colorScheme;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: cs.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(KuberShape.extraLarge),
      ),
    ),
    builder: (_) => _LanguagePickerSheet(
      ref: ref,
      currentLocale: currentLocale,
      onSelected: onSelected,
    ),
  );
}

/// The welcome language sheet: every language in one list with its radio.
Future<void> showWelcomeLanguageSheet({
  required BuildContext context,
  required Locale currentLocale,
  required ValueChanged<Locale> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    sheetAnimationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 300),
      reverseDuration: Duration(milliseconds: 200),
    ),
    builder: (ctx) {
      final l = ctx.l10n;
      return KuberBottomSheet(
        title: l.obLangTitle,
        description: l.obLangSub,
        bodyPadding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
        child: Column(
          children: [
            for (final lang in kSupportedLanguages)
              _RadioLanguageRow(
                lang: lang,
                selected: lang.locale.languageCode == currentLocale.languageCode,
                onTap: () {
                  Navigator.of(ctx, rootNavigator: true).pop();
                  // The strings change once the sheet is out of the way.
                  Future<void>.delayed(const Duration(milliseconds: 200), () => onSelected(lang.locale));
                },
              ),
          ],
        ),
      );
    },
  );
}

class _RadioLanguageRow extends StatelessWidget {
  final KuberLanguage lang;
  final bool selected;
  final VoidCallback onTap;
  const _RadioLanguageRow({required this.lang, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = selected ? cs.onSecondaryContainer : cs.onSurface;
    final fg2 = selected ? cs.onSecondaryContainer : cs.onSurfaceVariant;
    final showEnglish = lang.englishName.toLowerCase() != lang.nativeName.toLowerCase();
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? cs.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(KuberShape.large),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          overlayColor: kuberPressedLayer(cs),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: KuberSpace.listItem1),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 12, 0),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                      size: 22,
                      color: selected ? cs.primary : cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: KuberSpace.sm),
                  Expanded(
                    child: Wrap(
                      spacing: KuberSpace.sm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(lang.nativeName,
                            style: localeFont(locale: lang.locale, fontSize: 16, fontWeight: FontWeight.w600, color: fg)),
                        if (showEnglish) Text(lang.englishName, style: localeFont(fontSize: 14, color: fg2)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguagePickerSheet extends StatefulWidget {
  final WidgetRef ref;
  final Locale currentLocale;
  final ValueChanged<Locale> onSelected;

  const _LanguagePickerSheet({
    required this.ref,
    required this.currentLocale,
    required this.onSelected,
  });

  @override
  State<_LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<_LanguagePickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<KuberLanguage> _filtered = kSupportedLanguages;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = kSupportedLanguages;
        return;
      }
      _filtered = kSupportedLanguages.where((lang) {
        return lang.nativeName.toLowerCase().contains(q) ||
            lang.englishName.toLowerCase().contains(q) ||
            lang.locale.languageCode.toLowerCase().contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = lookupAppLocalizations(widget.currentLocale);

    return KuberBottomSheet(
      title: l10n.selectLanguage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchCtrl,
            onChanged: _onSearch,
            style: localeFont(fontSize: 14, color: cs.onSurface),
            decoration: InputDecoration(
              hintText: l10n.searchLanguage,
              hintStyle: localeFont(fontSize: 14, color: cs.onSurfaceVariant),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 20,
                color: cs.onSurfaceVariant,
              ),
              filled: true,
              fillColor: cs.surfaceContainerHigh,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KuberShape.large),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KuberShape.large),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KuberShape.large),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
            ),
          ),
          const SizedBox(height: KuberSpace.md),

          if (_filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  l10n.noLanguagesFound,
                  style: localeFont(fontSize: 14, color: cs.onSurfaceVariant),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final lang = _filtered[i];
                final isSelected =
                    lang.locale.languageCode ==
                    widget.currentLocale.languageCode;
                return _LanguageRow(
                  lang: lang,
                  isSelected: isSelected,
                  onTap: () {
                    widget.onSelected(lang.locale);
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  final KuberLanguage lang;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageRow({
    required this.lang,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final nativeStyle = localeFont(
      locale: lang.locale,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: isSelected ? cs.primary : cs.onSurface,
    );

    final showEnglishSubtitle =
        lang.englishName.toLowerCase() != lang.nativeName.toLowerCase();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KuberShape.medium),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KuberSpace.md,
            vertical: 14,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(lang.nativeName, style: nativeStyle),
                    if (showEnglishSubtitle) ...[
                      const SizedBox(height: 2),
                      Text(
                        lang.englishName,
                        style: localeFont(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_rounded, color: cs.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
