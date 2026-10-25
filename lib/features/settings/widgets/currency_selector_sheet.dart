import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'dart:ui' show PlatformDispatcher;

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
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(KuberShape.extraLarge),
      ),
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

  /// Current + the phone's region currency, shown above the full list while
  /// not searching.
  late final List<KuberCurrency> _suggested = {
    currencyFromCode(widget.currentCode),
    ?currencyForRegion(PlatformDispatcher.instance.locale.countryCode),
  }.toList();

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
          : kCurrencies.where((c) => c.matches(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return KuberBottomSheet(
      title: context.l10n.selectCurrency,
      // ListTile ink needs a Material between it and the sheet's background.
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchCtrl,
              onChanged: _onSearch,
              style: localeFont(fontSize: 14, color: cs.onSurface),
              decoration: InputDecoration(
                hintText: context.l10n.currencySearchHint,
                hintStyle: localeFont(fontSize: 14, color: cs.onSurfaceVariant),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: cs.onSurfaceVariant,
                ),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: cs.onSurfaceVariant,
                        ),
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
            const SizedBox(height: KuberSpace.sm),
            if (_filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: KuberSpace.xl),
                child: Center(
                  child: Text(
                    context.l10n.currencyNoMatch,
                    style: localeFont(fontSize: 14, color: cs.onSurfaceVariant),
                  ),
                ),
              )
            else ...[
              if (_searchCtrl.text.trim().isEmpty) ...[
                _header(context, context.l10n.currencySuggested),
                for (final c in _suggested) _row(context, c),
                _header(context, context.l10n.currencyAll),
              ],
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filtered.length,
                itemBuilder: (ctx, i) => _row(ctx, _filtered[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(top: KuberSpace.md, bottom: KuberSpace.xs),
    child: Text(
      text.toUpperCase(),
      style: localeFont(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );

  Widget _row(BuildContext context, KuberCurrency c) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = c.code == widget.currentCode;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? cs.secondaryContainer : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KuberShape.medium),
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
  }
}
