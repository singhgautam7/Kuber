import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

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

  static const _types = ['expense', 'income', 'transfer'];
  static const _labels = ['Expense', 'Income', 'Transfer'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: List.generate(_types.length, (i) {
          final isSelected = _types[i] == selected;
          return Expanded(
            child: GestureDetector(
              onTap: enabled ? () => onSelected(_types[i]) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (enabled ? cs.primary : cs.surfaceContainerHighest)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                ),
                alignment: Alignment.center,
                child: Text(
                  _labels[i],
                  style: textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? (enabled ? cs.onPrimary : cs.onSurface)
                        : cs.onSurfaceVariant.withValues(alpha: enabled ? 1.0 : 0.5),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
