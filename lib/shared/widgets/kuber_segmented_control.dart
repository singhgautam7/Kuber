import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// M3 segmented button (components/controls.md): 40 high, stadium, 1dp
/// outline dividers; the selected segment takes secondaryContainer with a check
/// (no check for 4+ segments).
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

  /// Draw the check on the selected segment (spec: no check for 4+ segments
  /// and for Bar | Line).
  final bool showCheck;

  /// Hug content (in-card toggles) instead of filling the width.
  final bool compact;

  const KuberSegmentedControl({
    super.key,
    required this.values,
    required this.labels,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
    this.height = 48,
    this.showCheck = true,
    this.compact = false,
  }) : assert(values.length == labels.length);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;

    // The outline is a foreground decoration so the selected segment's fill
    // sits inside it instead of painting over the stadium edge.
    return Container(
      height: height < 48 ? height : 40,
      decoration: const BoxDecoration(borderRadius: KuberShape.fullR),
      foregroundDecoration: BoxDecoration(
        borderRadius: KuberShape.fullR,
        border: Border.all(color: cs.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        children: List.generate(values.length, (i) {
          final isSelected = values[i] == selected;
          final fg = isSelected
              ? cs.onSecondaryContainer
              : cs.onSurface.withValues(alpha: enabled ? 1.0 : 0.38);
          final segment = GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: enabled ? () => onSelected(values[i]) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (enabled
                          ? cs.secondaryContainer
                          : cs.onSurface.withValues(alpha: 0.12))
                      : Colors.transparent,
                  border: i == 0
                      ? null
                      : Border(left: BorderSide(color: cs.outline)),
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected && showCheck && values.length < 4) ...[
                      Icon(Icons.check_rounded, size: 18, color: fg),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        labels[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelLarge?.copyWith(color: fg),
                      ),
                    ),
                  ],
                ),
              ),
            );
          return compact ? segment : Expanded(child: segment);
        }),
      ),
    );
  }
}
