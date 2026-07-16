import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/locale_font.dart';

class DateRangePickerValue {
  final String label;
  final DateTime from;
  final DateTime to;

  const DateRangePickerValue({
    required this.label,
    required this.from,
    required this.to,
  });
}

class KuberDateRangePicker extends StatelessWidget {
  final DateRangePickerValue value;
  final VoidCallback onTap;
  final VoidCallback? onReset;
  final bool canReset;
  final String resetTooltip;

  const KuberDateRangePicker({
    super.key,
    required this.value,
    required this.onTap,
    this.onReset,
    this.canReset = true,
    this.resetTooltip = 'Reset',
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(color: cs.primary.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.unfold_more_rounded, size: 14, color: cs.primary),
                  const SizedBox(width: 6),
                  Text(
                    value.label,
                    style: localeFont(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: cs.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: KuberSpacing.sm),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 16,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: KuberSpacing.sm),
                    Flexible(
                      child: Text(
                        formatKuberRangeLabel(value.from, value.to),
                        textAlign: TextAlign.center,
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (onReset != null) ...[
            const SizedBox(width: KuberSpacing.sm),
            Tooltip(
              message: resetTooltip,
              child: GestureDetector(
                onTap: canReset ? onReset : null,
                child: Opacity(
                  opacity: canReset ? 1 : 0.3,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                      border: Border.all(
                        color: cs.outline.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Icon(
                      Icons.replay_rounded,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String formatKuberRangeLabel(DateTime from, DateTime to) {
  if (from.year == to.year) {
    final fmtStart = DateFormat('MMM d');
    final fmtEnd = DateFormat('MMM d, yyyy');
    return '${fmtStart.format(from)} - ${fmtEnd.format(to)}';
  }
  final fmt = DateFormat('MMM d, yyyy');
  return '${fmt.format(from)} - ${fmt.format(to)}';
}
