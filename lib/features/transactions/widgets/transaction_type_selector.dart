import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final labels = [
      context.l10n.expenseLabel,
      context.l10n.incomeLabel,
      context.l10n.transferLabel,
    ];

    // M3 Expressive connected toggle (board 3.4): surfaceContainerHigh track
    // h48 pad 4, the selected segment a primary pill.
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: KuberShape.fullR,
      ),
      child: Row(
        spacing: 4,
        children: List.generate(_types.length, (i) {
          final isSelected = _types[i] == selected;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: enabled ? () => onSelected(_types[i]) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (enabled
                            ? cs.primary
                            : cs.onSurface.withValues(alpha: 0.12))
                      : Colors.transparent,
                  borderRadius: KuberShape.fullR,
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[i],
                  style: textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? (enabled
                              ? cs.onPrimary
                              : cs.onSurface.withValues(alpha: 0.38))
                        : cs.onSurfaceVariant.withValues(
                            alpha: enabled ? 1.0 : 0.38,
                          ),
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
