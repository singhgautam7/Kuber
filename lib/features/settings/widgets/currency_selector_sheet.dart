import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_data.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../providers/settings_provider.dart';

void showCurrencyPicker({
  required BuildContext context,
  required WidgetRef ref,
  required String currentCode,
  required Function(String) onSelected,
}) {
  final cs = Theme.of(context).colorScheme;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: cs.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
    ),
    builder: (_) => _CurrencyPickerSheet(
      ref: ref,
      currentCode: currentCode,
      onSelected: onSelected,
    ),
  );
}

class _CurrencyPickerSheet extends StatefulWidget {
  final WidgetRef ref;
  final String currentCode;
  final Function(String) onSelected;

  const _CurrencyPickerSheet({
    required this.ref,
    required this.currentCode,
    required this.onSelected,
  });

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<KuberCurrency> _filtered = kCurrencies;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? kCurrencies
          : kCurrencies.where((c) {
              return c.code.toLowerCase().contains(q) ||
                  c.name.toLowerCase().contains(q) ||
                  c.symbol.toLowerCase().contains(q);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return KuberBottomSheet(
      title: context.l10n.selectCurrency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _searchCtrl,
            onChanged: _onSearch,
            style: localeFont(fontSize: 14, color: cs.onSurface),
            decoration: InputDecoration(
              hintText: context.l10n.searchCurrencyHint,
              hintStyle: localeFont(fontSize: 14, color: cs.onSurfaceVariant),
              prefixIcon: Icon(Icons.search_rounded, size: 20, color: cs.onSurfaceVariant),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close_rounded, size: 18, color: cs.onSurfaceVariant),
                      onPressed: () {
                        _searchCtrl.clear();
                        _onSearch('');
                      },
                    )
                  : null,
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
          const SizedBox(height: KuberSpacing.sm),
          if (_filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: KuberSpacing.xl),
              child: Center(
                child: Text(
                  context.l10n.noCurrenciesFound,
                  style: localeFont(fontSize: 14, color: cs.onSurfaceVariant),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) {
                final c = _filtered[i];
                final isSelected = c.code == widget.currentCode;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                  leading: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? cs.primaryContainer : cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                    ),
                    child: Text(
                      c.symbol,
                      style: localeFont(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? cs.primary : cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  title: Text(
                    c.name,
                    style: localeFont(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: cs.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    c.code,
                    style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_rounded, color: cs.primary, size: 20)
                      : null,
                  onTap: () {
                    widget.onSelected(c.code);
                    widget.ref.read(settingsProvider.notifier).setCurrency(c.code);
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