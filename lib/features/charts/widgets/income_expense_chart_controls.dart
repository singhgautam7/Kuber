import 'package:flutter/material.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../shared/utils/chart_bucket.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_segmented_control.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, privacyModeProvider;

/// A generic range tab for the compact (Home) chart, e.g. 7D / 4W / 6M.
class ChartRangeTab {
  final String id;
  final String label;

  /// Menu line under the label ("Last 7 days").
  final String? subtitle;
  const ChartRangeTab(this.id, this.label, [this.subtitle]);
}

enum IncomeExpenseChartMode { bar, line }

/// In-card segmented control (Bar | Line, Category | Group, Expense | Income):
/// the M3 segmented button (h40, stadium, secondaryContainer). Bar | Line is
/// the only one without a check (feedback round 1).
class KuberSegmentedTabs extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool showCheck;

  const KuberSegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.showCheck = true,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: KuberSegmentedControl<int>(
        values: [for (var i = 0; i < labels.length; i++) i],
        labels: labels,
        selected: selectedIndex,
        onSelected: onChanged,
        height: 40,
        showCheck: showCheck,
        compact: true,
      ),
    );
  }
}

/// Bar | Line toggle.
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
    return KuberSegmentedTabs(
      labels: const ['Bar', 'Line'],
      selectedIndex: mode == IncomeExpenseChartMode.bar ? 0 : 1,
      showCheck: false,
      onChanged: (i) => onChanged(
        i == 0 ? IncomeExpenseChartMode.bar : IncomeExpenseChartMode.line,
      ),
    );
  }
}

/// Day / Week / Month / Year as a dropdown chip + menu (Analytics). Only
/// buckets valid for the active date range are offered.
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

    return KuberDropdownChip<KuberChartBucket>(
      value: selected,
      options: [for (final b in entries) KuberDropdownOption(b, _labels[b]!)],
      onChanged: onChanged,
    );
  }
}

/// Y-axis on the right (tokens.md §6): max / mid / 0 labels right-aligned in a
/// 36 column, aligned to the gridlines.
class IncomeExpenseYAxis extends ConsumerWidget {
  final double maxY;
  final double plotHeight;

  const IncomeExpenseYAxis({
    super.key,
    required this.maxY,
    required this.plotHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final fmt = ref.watch(formatterProvider);
    final isPrivate = ref.watch(privacyModeProvider);
    String label(double v) => v == 0
        ? '0'
        : maskAmount(
            fmt.formatCompactCurrency(v, symbol: '').trim(),
            isPrivate,
          );

    Widget tick(double v) => Text(
      label(v),
      textAlign: TextAlign.right,
      maxLines: 1,
      style: theme.textTheme.labelSmall!.copyWith(
        color: cs.onSurfaceVariant,
        letterSpacing: 0,
      ),
    );

    return SizedBox(
      height: plotHeight + 22,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(top: -8, right: 0, left: 4, child: tick(maxY)),
          Positioned(
            top: plotHeight / 2 - 8,
            right: 0,
            left: 4,
            child: tick(maxY / 2),
          ),
          Positioned(top: plotHeight - 8, right: 0, left: 4, child: tick(0)),
        ],
      ),
    );
  }
}

/// Compact-mode range (7D / 4W / 6M) for the Home chart: a dropdown chip that
/// opens the period menu (feedback round 1).
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
    return KuberDropdownChip<String>(
      value: selectedId ?? tabs.first.id,
      options: [
        for (final t in tabs)
          KuberDropdownOption(t.id, t.label, subtitle: t.subtitle),
      ],
      onChanged: onSelected,
    );
  }
}

/// Selection highlight behind a chart group: a rounded column in onSurface at
/// 5% (light) / 8% (dark) (feedback round 1).
Color chartSelectionColumn(ColorScheme cs) => cs.onSurface.withValues(
  alpha: cs.brightness == Brightness.dark ? 0.08 : 0.05,
);

const double kChartSelectionRadius = KuberShape.medium;
