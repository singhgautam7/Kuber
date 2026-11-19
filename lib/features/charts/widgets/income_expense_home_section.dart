import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/expressive_chart/expressive_chart.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_home_widget_title.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../providers/home_income_expense_provider.dart';
import 'income_expense_parts.dart';

/// The Home "Income & expense" block: title outside the card, 7D / 6M / 1Y and
/// Bar / Line menus, the [ExpressiveChart], legend, and the empty / single
/// states. Drop-in for the old `_SevenDayChartSection`.
class IncomeExpenseHomeSection extends ConsumerWidget {
  const IncomeExpenseHomeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final range = ref.watch(homeChartRangeProvider);
    final mode = ref.watch(homeChartModeProvider);
    // Exactly the range's periods: 7 days, 6 or 12 months (no older ones).
    final all = range == HomeChartRange.days7
        ? ref.watch(dailyChartPeriodsProvider)
        : ref.watch(monthlyChartPeriodsProvider);
    final fmt = chartFormats(ref);
    final shown = all.length <= range.window
        ? all
        : all.sublist(all.length - range.window);
    final series = incomeExpenseSeries(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KuberHomeWidgetTitle(title: l10n.chartTitle),
        RepaintBoundary(
          child: KuberCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: KuberSpace.sm,
                  runSpacing: KuberSpace.sm,
                  children: [
                    KuberDropdownChip<HomeChartRange>(
                      value: range,
                      options: [
                        KuberDropdownOption(HomeChartRange.days7, l10n.chartPeriod7d,
                            subtitle: l10n.chartPeriod7dSub),
                        KuberDropdownOption(HomeChartRange.months6, l10n.chartPeriod6m,
                            subtitle: l10n.chartPeriod6mSub),
                        KuberDropdownOption(HomeChartRange.months12, l10n.chartPeriod1y,
                            subtitle: l10n.chartPeriod1ySub),
                      ],
                      onChanged: (r) =>
                          ref.read(homeChartRangeProvider.notifier).state = r,
                    ),
                    ChartModeChip(
                      mode: mode,
                      onChanged: (m) =>
                          ref.read(homeChartModeProvider.notifier).state = m,
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpace.xl),
                ExpressiveChart(
                  series: series,
                  periods: shown,
                  mode: mode,
                  window: range.window,
                  formatAmount: fmt.amount,
                  formatAxis: fmt.axis,
                  emptyTitle: l10n.chartEmptyTitle,
                  emptyBody: l10n.chartEmptyBody,
                  singleNote: l10n.chartSingle,
                ),
                const SizedBox(height: KuberSpace.md),
                IncomeExpenseLegend(series: series, showOrder: all.isNotEmpty),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
