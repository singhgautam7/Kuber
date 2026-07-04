import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/utils/chart_bucket.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, privacyModeProvider;

/// A generic range tab for the compact (Home) chart, e.g. 7D / 4W / 6M.
class ChartRangeTab {
  final String id;
  final String label;
  const ChartRangeTab(this.id, this.label);
}

enum IncomeExpenseChartMode { bar, line }

/// Generic 2+ option segmented control matching the chart's Bar|Line toggle.
/// Reused by the analytics donut (Category|Group) and Biggest Transactions
/// (Expense|Income) so all in-card tabs look identical.
class KuberSegmentedTabs extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const KuberSegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 3),
            _Segment(
              label: labels[i],
              active: i == selectedIndex,
              onTap: () => onChanged(i),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small Bar/Line segmented toggle (screens 4a-4d top-right). Present in
/// both compact (Home) and expanded (Analytics) contexts.
class IncomeExpenseChartModeToggle extends StatelessWidget {
  final IncomeExpenseChartMode mode;
  final ValueChanged<IncomeExpenseChartMode> onChanged;

  const IncomeExpenseChartModeToggle({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            label: 'Bar',
            active: mode == IncomeExpenseChartMode.bar,
            onTap: () => onChanged(IncomeExpenseChartMode.bar),
          ),
          const SizedBox(width: 3),
          _Segment(
            label: 'Line',
            active: mode == IncomeExpenseChartMode.line,
            onTap: () => onChanged(IncomeExpenseChartMode.line),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? cs.primary.withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          label,
          style: localeFont(
            fontSize: 10.5,
            fontWeight: active ? FontWeight.w700 : FontWeight.w600,
            color: active ? cs.primary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Horizontally scrollable Day/Week/Month/Year chip strip (screens 4c/4d).
/// Only buckets valid for the active date range are offered.
class IncomeExpenseChartRangeSwitcher extends StatelessWidget {
  final KuberChartBucket selected;
  final List<KuberChartBucket> available;
  final ValueChanged<KuberChartBucket> onChanged;

  const IncomeExpenseChartRangeSwitcher({
    super.key,
    required this.selected,
    required this.available,
    required this.onChanged,
  });

  static const _labels = {
    KuberChartBucket.day: 'Day',
    KuberChartBucket.week: 'Week',
    KuberChartBucket.month: 'Month',
    KuberChartBucket.year: 'Year',
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // The redesign offers Day | Week | Month | Year (quarter dropped).
    final entries = [
      for (final b in const [
        KuberChartBucket.day,
        KuberChartBucket.week,
        KuberChartBucket.month,
        KuberChartBucket.year,
      ])
        if (available.contains(b)) b,
    ];
    if (entries.length < 2) return const SizedBox.shrink();

    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(width: 7),
        itemBuilder: (_, i) {
          final bucket = entries[i];
          final active = bucket == selected;
          return GestureDetector(
            onTap: () => onChanged(bucket),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
              decoration: BoxDecoration(
                color: active
                    ? cs.primary.withValues(alpha: 0.14)
                    : cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: active ? cs.primary : cs.outline,
                ),
              ),
              child: Text(
                _labels[bucket]!,
                style: localeFont(
                  fontSize: 11.5,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? cs.primary : cs.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Fixed left Y-axis: max / mid / 0 labels aligned to the gridlines.
class IncomeExpenseYAxis extends ConsumerWidget {
  final double maxY;
  final double plotHeight;

  const IncomeExpenseYAxis(
      {super.key, required this.maxY, required this.plotHeight});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final isPrivate = ref.watch(privacyModeProvider);
    String label(double v) => v == 0
        ? '0'
        : maskAmount(fmt.formatCompactCurrency(v, symbol: '').trim(), isPrivate);

    Widget tick(double v) => Text(
          label(v),
          textAlign: TextAlign.right,
          style: localeFont(
            fontSize: 9,
            color: cs.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        );

    // Labels sit at the top (max), middle (mid) and bottom (0) of the plot.
    // The top label is pinned at y:0 (not above the plot) so it never clips.
    return SizedBox(
      height: plotHeight + 22,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(top: 0, right: 4, child: tick(maxY)),
          Positioned(
              top: plotHeight / 2 - 6, right: 4, child: tick(maxY / 2)),
          Positioned(top: plotHeight - 12, right: 4, child: tick(0)),
        ],
      ),
    );
  }
}

/// Compact-mode range tab chips (7D / 4W / 6M) for the Home chart.
class CompactRangeTabs extends StatelessWidget {
  final List<ChartRangeTab> tabs;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  const CompactRangeTabs({
    super.key,
    required this.tabs,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 7),
        itemBuilder: (_, i) {
          final tab = tabs[i];
          final active = tab.id == selectedId;
          return GestureDetector(
            onTap: () => onSelected(tab.id),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
              decoration: BoxDecoration(
                color: active
                    ? cs.primary.withValues(alpha: 0.14)
                    : cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: active ? cs.primary : cs.outline),
              ),
              child: Text(
                tab.label,
                style: localeFont(
                  fontSize: 11.5,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? cs.primary : cs.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
