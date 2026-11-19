import 'package:flutter/material.dart';

import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/kuber_button_group.dart';

/// Expense / Income / Transfer: a [KuberButtonGroup] (v7.0.0 button-group
/// motion), same options and behaviour as before.
class TransactionTypeSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  final bool enabled;

  const TransactionTypeSelector({
    super.key,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return KuberButtonGroup<String>(
      height: 48,
      enabled: enabled,
      selected: selected,
      onChanged: onSelected,
      options: [
        KuberButtonOption(value: 'expense', label: l.expenseLabel),
        KuberButtonOption(value: 'income', label: l.incomeLabel),
        KuberButtonOption(value: 'transfer', label: l.transferLabel),
      ],
    );
  }
}
