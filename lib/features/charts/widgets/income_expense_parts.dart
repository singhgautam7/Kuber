import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/utils/chart_bucket.dart';
import '../../../shared/widgets/expressive_chart/chart_model.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, privacyModeProvider;

/// Income then Expense, in the money colours.
List<ExpressiveSeries> incomeExpenseSeries(BuildContext context) {
  final m = context.kuberMoney;
  return [
    ExpressiveSeries(
        name: context.l10n.incomeLabel, color: m.income, inverseColor: m.inverseIncome),
    ExpressiveSeries(
        name: context.l10n.expenseLabel, color: m.expense, inverseColor: m.inverseExpense),
  ];
}

/// Amount and axis formatters (currency formatter + privacy mask).
({String Function(double) amount, String Function(double) axis}) chartFormats(
    WidgetRef ref) {
  final fmt = ref.watch(formatterProvider);
  final isPrivate = ref.watch(privacyModeProvider);
  return (
    amount: (v) => maskAmount(fmt.formatCurrency(v.round()), isPrivate),
    axis: (v) => maskAmount(fmt.formatCompactCurrency(v, symbol: '').trim(), isPrivate),
  );
}

/// Bar / Line dropdown chip.
class ChartModeChip extends StatelessWidget {
  const ChartModeChip({super.key, required this.mode, required this.onChanged});
  final ExpressiveChartMode mode;
  final ValueChanged<ExpressiveChartMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return KuberDropdownChip<ExpressiveChartMode>(
      value: mode,
      icon: mode == ExpressiveChartMode.bar ? Icons.bar_chart_rounded : Icons.show_chart_rounded,
      options: [
        KuberDropdownOption(ExpressiveChartMode.bar, l10n.chartModeBar,
            icon: Icons.bar_chart_rounded),
        KuberDropdownOption(ExpressiveChartMode.line, l10n.chartModeLine,
            icon: Icons.show_chart_rounded),
      ],
      onChanged: onChanged,
    );
  }
}

/// Income, Expense and "Higher one on top".
class IncomeExpenseLegend extends StatelessWidget {
  const IncomeExpenseLegend({super.key, required this.series, this.showOrder = true});
  final List<ExpressiveSeries> series;
  final bool showOrder;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final style = tt.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
    Widget item(ExpressiveSeries s) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
            ),
            const SizedBox(width: KuberSpace.sm),
            Text(s.name, style: style),
          ],
        );
    return Wrap(
      spacing: KuberSpace.lg,
      runSpacing: KuberSpace.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final s in series) item(s),
        if (showOrder && series.length == 2)
          Text(context.l10n.chartLegendOrder, style: style),
      ],
    );
  }
}

/// Tooltip title of an Analytics bucket: "June 2026", a date, a range, or the
/// year.
String bucketFullLabel(KuberBarBucket b, String fallback) {
  final d = b.date;
  if (d == null) return fallback;
  final e = b.endDate ?? d;
  if (d.year == e.year && d.month == e.month && d.day == e.day) {
    return DateFormat('d MMM yyyy').format(d);
  }
  final wholeMonth = d.day == 1 &&
      d.month == e.month &&
      d.year == e.year &&
      e.day >= DateTime(d.year, d.month + 1, 0).day - 1;
  if (wholeMonth) return DateFormat('MMMM yyyy').format(d);
  if (d.year == e.year && d.month == 1 && d.day == 1 && e.month == 12 && e.day >= 30) {
    return '${d.year}';
  }
  return '${DateFormat('d MMM').format(d)} - ${DateFormat('d MMM').format(e)}';
}

String bucketLabel(BuildContext context, KuberChartBucket b) {
  final l = context.l10n;
  return switch (b) {
    KuberChartBucket.day => l.chartBucketDay,
    KuberChartBucket.week => l.chartBucketWeek,
    KuberChartBucket.month => l.chartBucketMonth,
    KuberChartBucket.quarter => l.chartBucketQuarter,
    KuberChartBucket.year => l.chartBucketYear,
  };
}
