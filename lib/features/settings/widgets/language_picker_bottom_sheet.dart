import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../core/utils/supported_locales.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';

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
      borderRadius: BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
    ),
    builder: (_) => _LanguagePickerSheet(
      ref: ref,
      currentLocale: currentLocale,
      onSelected: onSelected,
    ),
  );
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
              hintStyle: localeFont(
                fontSize: 14,
                color: cs.onSurfaceVariant,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 20,
                color: cs.onSurfaceVariant,
              ),
              filled: true,
              fillColor: cs.surfaceContainerHigh,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KuberRadius.md),
                borderSide: BorderSide(color: cs.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KuberRadius.md),
                borderSide: BorderSide(color: cs.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KuberRadius.md),
                borderSide: BorderSide(color: cs.outline),
              ),
            ),
          ),
          const SizedBox(height: KuberSpacing.md),

          if (_filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  l10n.noLanguagesFound,
                  style: localeFont(
                    fontSize: 14,
                    color: cs.onSurfaceVariant,
                  ),
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
                    lang.locale.languageCode == widget.currentLocale.languageCode;
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
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: isSelected ? cs.primary : cs.onSurface,
    );

    final showEnglishSubtitle =
        lang.englishName.toLowerCase() != lang.nativeName.toLowerCase();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KuberSpacing.md,
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
