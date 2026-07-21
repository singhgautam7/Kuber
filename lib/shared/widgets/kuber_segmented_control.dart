import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Reusable segmented control matching the Add Transaction type selector: a
/// `surfaceContainerHigh` track with a `1px outline` border and `KuberRadius.md`
/// corners, 4px inner padding. The selected segment is a solid `primary` fill
/// with `onPrimary` text; unselected segments are transparent with
/// `onSurfaceVariant` text. Not a raised/elevated pill.
///
/// Generalized from `TransactionTypeSelector` so the Quick Actions configure
/// screen (Arrange | Add shortcuts) and the transaction type picker share one
/// primitive.
class KuberSegmentedControl<T> extends StatelessWidget {
  final List<T> values;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onSelected;
  final bool enabled;
  final double height;

  const KuberSegmentedControl({
    super.key,
    required this.values,
    required this.labels,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
    this.height = 48,
  }) : assert(values.length == labels.length);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: List.generate(values.length, (i) {
          final isSelected = values[i] == selected;
          return Expanded(
            child: GestureDetector(
              onTap: enabled ? () => onSelected(values[i]) : null,
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
                  labels[i],
                  style: textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? (enabled ? cs.onPrimary : cs.onSurface)
                        : cs.onSurfaceVariant
                            .withValues(alpha: enabled ? 1.0 : 0.5),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
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
