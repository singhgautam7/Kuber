import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/utils/chart_bucket.dart';
import '../../../shared/widgets/expressive_chart/expressive_chart.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../analytics/providers/analytics_provider.dart';
import '../providers/analytics_chart_provider.dart';
import 'income_expense_parts.dart';

/// Analytics "Income & expense" card: title, the filter-driven bucket menu
/// (Day / Week / Month / Quarter / Year), Bar / Line, and the same
/// [ExpressiveChart] as Home.
class AnalyticsIncomeExpenseChart extends ConsumerStatefulWidget {
  const AnalyticsIncomeExpenseChart({super.key});

  @override
  ConsumerState<AnalyticsIncomeExpenseChart> createState() =>
      _AnalyticsIncomeExpenseChartState();
}

class _AnalyticsIncomeExpenseChartState
    extends ConsumerState<AnalyticsIncomeExpenseChart> {
  ExpressiveChartMode _mode = ExpressiveChartMode.bar;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final filter = ref.watch(analyticsFilterProvider);
    final buckets = ref.watch(analyticsBucketsProvider);
    final fmt = chartFormats(ref);
    final series = incomeExpenseSeries(context);
    final isToday = filter.type == FilterType.today;
    final available = availableBucketsForRange(filter.from, filter.to);
    final entries = [
      for (final b in KuberChartBucket.values)
        if (available.contains(b)) b,
    ];
    final slotNames = [
      l10n.bucketDawn,
      l10n.bucketMorning,
      l10n.bucketNoon,
      l10n.bucketEvening,
      l10n.bucketNight,
    ];
    final periods = [
      for (var i = 0; i < buckets.length; i++)
        () {
          final b = buckets[i];
          final label = b.timeOfDaySlot != null ? slotNames[b.timeOfDaySlot!] : b.dayLabel;
          return ExpressivePeriod(
            key: i,
            label: label,
            fullLabel: b.timeOfDaySlot != null ? label : bucketFullLabel(b, label),
            values: [b.income, b.expense],
          );
        }(),
    ];
    final n = periods.length;
    return KuberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.chartTitle,
              style: theme.textTheme.titleMedium!.copyWith(color: theme.colorScheme.onSurface)),
          const SizedBox(height: KuberSpace.sm),
          Wrap(
            spacing: KuberSpace.sm,
            runSpacing: KuberSpace.sm,
            children: [
              if (!isToday && entries.length >= 2)
                KuberDropdownChip<KuberChartBucket>(
                  value: filter.effectiveBucket,
                  options: [
                    for (final b in entries)
                      KuberDropdownOption(b, bucketLabel(context, b)),
                  ],
                  onChanged: (b) =>
                      ref.read(analyticsFilterProvider.notifier).setBucket(b),
                ),
              ChartModeChip(
                mode: _mode,
                onChanged: (m) => setState(() => _mode = m),
              ),
            ],
          ),
          const SizedBox(height: KuberSpace.xl),
          ExpressiveChart(
            series: series,
            periods: periods,
            mode: _mode,
            // Short ranges fill the width; long ones scroll in 6-slot views.
            window: n >= 2 && n <= 6 ? n : 6,
            formatAmount: fmt.amount,
            formatAxis: fmt.axis,
            resetKey: (filter.type, filter.from, filter.to, filter.effectiveBucket),
          ),
          const SizedBox(height: KuberSpace.md),
          IncomeExpenseLegend(series: series),
        ],
      ),
    );
  }
}
