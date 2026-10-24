// Account and category picker rows (KuberPickerRow + the existing picker
// sheets). One implementation for every form: transactions, recurring,
// loans, investments, withdraw / extra payment sheets.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import 'account_picker_sheet.dart';
import 'category_picker_sheet.dart';

class AccountPickerRow extends ConsumerWidget {
  final int? selectedId;
  final ValueChanged<int> onChanged;
  final String? label;

  const AccountPickerRow({
    super.key,
    required this.selectedId,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accs = ref.watch(accountListProvider).valueOrNull ?? [];
    final acc = selectedId == null
        ? null
        : accs.where((a) => a.id == selectedId).firstOrNull;
    return KuberPickerRow(
      leading: acc == null
          ? const KuberLeadingSwatch(
              color: Colors.transparent,
              icon: Icons.account_balance_outlined,
              empty: true,
            )
          : KuberLeadingSwatch(
              color: Color(acc.colorValue ?? 0xFF3B82F6),
              icon: IconMapper.fromString(acc.icon ?? 'account_balance'),
            ),
      label: label ?? context.l10n.accountTitle,
      value: acc?.name ?? context.l10n.selectAccountTitle,
      valueIsPlaceholder: acc == null,
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (sheet) => AccountPickerSheet(
          selectedAccountId: selectedId,
          onSelected: (id) {
            onChanged(id);
            Navigator.pop(sheet);
          },
        ),
      ).unfocusOnComplete(context),
    );
  }
}

class CategoryPickerRow extends ConsumerWidget {
  final int? selectedId;
  final ValueChanged<int> onChanged;
  final String type; // 'expense' | 'income'
  final String? label;

  const CategoryPickerRow({
    super.key,
    required this.selectedId,
    required this.onChanged,
    this.type = 'expense',
    this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = ref.watch(categoryListProvider).valueOrNull ?? [];
    final cat = selectedId == null
        ? null
        : cats.where((c) => c.id == selectedId).firstOrNull;
    return KuberPickerRow(
      leading: cat == null
          ? const KuberLeadingSwatch(
              color: Colors.transparent,
              icon: Icons.bookmark_border_rounded,
              empty: true,
            )
          : KuberLeadingSwatch(
              color: Color(cat.colorValue),
              icon: IconMapper.fromString(cat.icon),
            ),
      label: label ?? context.l10n.categoryLabel,
      value: cat?.name ?? context.l10n.selectCategoryTitle,
      valueIsPlaceholder: cat == null,
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (sheet) => CategoryPickerSheet(
          selectedCategoryId: selectedId,
          defaultType: type,
          onSelected: (id) {
            onChanged(id);
            Navigator.pop(sheet);
          },
        ),
      ).unfocusOnComplete(context),
    );
  }
}

/// A date row in the same style (When component consistency rule).
class DatePickerRow extends StatelessWidget {
  final String label;
  final String value;
  final DateTime initial;
  final ValueChanged<DateTime> onChanged;
  final DateTime? first;
  final DateTime? last;

  const DatePickerRow({
    super.key,
    required this.label,
    required this.value,
    required this.initial,
    required this.onChanged,
    this.first,
    this.last,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return KuberPickerRow(
      leading: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.event_rounded, size: 20, color: cs.onSecondaryContainer),
      ),
      label: label,
      value: value,
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: first ?? DateTime(1900),
          lastDate: last ?? DateTime(2100),
        ).unfocusOnComplete(context);
        if (d != null) onChanged(d);
      },
    );
  }
}
