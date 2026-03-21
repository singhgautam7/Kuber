import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/account_helpers.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/transaction_detail_sheet.dart';
import '../../../shared/widgets/transaction_list_item.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final summaryAsync = ref.watch(monthlySummaryProvider);
    final accountsAsync = ref.watch(accountListProvider);
    final recentAsync = ref.watch(recentTransactionsProvider);
    final chartAsync = ref.watch(last7DaysSummaryProvider);
    final categoryMapAsync = ref.watch(categoryMapProvider);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(
          left: KuberSpacing.lg,
          right: KuberSpacing.lg,
          bottom: navBarBottomPadding(context),
        ),
        children: [
          const KuberAppBar(),
          const SizedBox(height: KuberSpacing.lg),

            // [A] Balance Hero Card
            summaryAsync.when(
              loading: () => const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (summary) => _BalanceHeroCard(summary: summary),
            ),
            const SizedBox(height: KuberSpacing.xl),

            // [B] Bank Accounts
            accountsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => const SizedBox.shrink(),
              data: (accounts) {
                if (accounts.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Bank Accounts',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            )),
                        TextButton(
                          onPressed: () => context.go('/accounts'),
                          child: Text('View All',
                              style: textTheme.labelMedium?.copyWith(
                                color: colorScheme.primary,
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: KuberSpacing.sm),
                    SizedBox(
                      height: 130,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: accounts.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: KuberSpacing.md),
                        itemBuilder: (context, i) {
                          final account = accounts[i];
                          final balanceAsync =
                              ref.watch(accountBalanceProvider(account.id));
                          final acctColor = resolveAccountColor(account);
                          final cardWidth =
                              (MediaQuery.of(context).size.width -
                                      2 * KuberSpacing.lg -
                                      KuberSpacing.md) /
                                  2;
                          return SizedBox(
                            width: cardWidth,
                            child: Container(
                              padding: const EdgeInsets.all(KuberSpacing.lg),
                              decoration: BoxDecoration(
                                color: KuberColors.surfaceCard,
                                borderRadius: BorderRadius.circular(KuberRadius.md),
                                border: Border.all(
                                  color: KuberColors.border,
                                  width: 0.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: acctColor
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          resolveAccountIcon(account),
                                          size: 18,
                                          color: acctColor,
                                        ),
                                      ),
                                      const SizedBox(width: KuberSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          account.name,
                                          style:
                                              textTheme.labelMedium?.copyWith(
                                            color:
                                                colorScheme.onSurfaceVariant,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: KuberSpacing.sm),
                                  balanceAsync.when(
                                    loading: () => Text('...',
                                        style: textTheme.titleMedium),
                                    error: (e, _) => Text('-',
                                        style: textTheme.titleMedium),
                                    data: (balance) {
                                      final Color? balanceColor;
                                      if (account.isCreditCard) {
                                        balanceColor = balance > 0
                                            ? KuberColors.expense
                                            : balance < 0
                                                ? KuberColors.income
                                                : null;
                                      } else {
                                        balanceColor = balance < 0
                                            ? KuberColors.expense
                                            : null;
                                      }
                                      final prefix = balance < 0 ? '-' : '';
                                      return Text(
                                        '$prefix${CurrencyFormatter.format(balance)}',
                                        style:
                                            textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: balanceColor,
                                        ),
                                      );
                                    },
                                  ),
                                  if (account.last4Digits != null)
                                    Text(
                                      '**** ${account.last4Digits}',
                                      style: textTheme.labelSmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: KuberSpacing.xl),
                  ],
                );
              },
            ),

            // [C] 7-Day Chart
            chartAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => const SizedBox.shrink(),
              data: (days) => _WeeklyChart(days: days),
            ),
            const SizedBox(height: KuberSpacing.xl),

            // [D] Recent Transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Transactions',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                TextButton(
                  onPressed: () => context.go('/transactions'),
                  child: Text('View All',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                      )),
                ),
              ],
            ),
            const SizedBox(height: KuberSpacing.md),
            recentAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(KuberSpacing.xl),
                    decoration: BoxDecoration(
                      color: KuberColors.surfaceCard,
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                    ),
                    child: Center(
                      child: Text(
                        'No transactions yet',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KuberSpacing.lg,
                    vertical: KuberSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: KuberColors.surfaceCard,
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                  ),
                  child: categoryMapAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (e, _) => const SizedBox.shrink(),
                    data: (categories) => Column(
                      children: transactions.map((t) {
                        final catId = int.tryParse(t.categoryId);
                        final cat =
                            catId != null ? categories[catId] : null;
                        return DashboardTransactionItem(
                          transaction: t,
                          category: cat,
                          onTap: () => showTransactionDetailSheet(
                            context,
                            ref,
                            t,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ],
      ),
    );
  }

}

class _BalanceHeroCard extends StatelessWidget {
  final MonthlySummary summary;

  const _BalanceHeroCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(KuberSpacing.xl),
      decoration: BoxDecoration(
        color: KuberColors.surfaceCard,
        border: Border.all(color: KuberColors.border),
        borderRadius: BorderRadius.circular(KuberRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Total Balance',
            style: textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: KuberSpacing.sm),
          Text(
            '${summary.net < 0 ? '-' : ''}${CurrencyFormatter.format(summary.net)}',
            style: textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: KuberSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _BalanceTile(
                  label: 'Income',
                  amount: summary.totalIncome,
                  icon: Icons.arrow_downward_rounded,
                  iconColor: KuberColors.income,
                ),
              ),
              const SizedBox(width: KuberSpacing.lg),
              Expanded(
                child: _BalanceTile(
                  label: 'Expense',
                  amount: summary.totalExpense,
                  icon: Icons.arrow_upward_rounded,
                  iconColor: KuberColors.expense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceTile extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color iconColor;

  const _BalanceTile({
    required this.label,
    required this.amount,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(KuberSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(KuberRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
               color: Colors.black.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: KuberSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  CurrencyFormatter.format(amount),
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatefulWidget {
  final List<DaySummary> days;

  const _WeeklyChart({required this.days});

  @override
  State<_WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<_WeeklyChart> {
  int _touchedIndex = -1;

  String _formatYAxis(double value) {
    if (value >= 1000) {
      final k = value / 1000;
      return '₹${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}k';
    }
    return '₹${value.toInt()}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final days = widget.days;

    final hasData = days.any((d) => d.income > 0 || d.expense > 0);
    if (!hasData) return const SizedBox.shrink();

    final maxVal = days.fold<double>(
        0, (prev, d) => max(prev, max(d.income, d.expense)));

    final yInterval = maxVal > 0 ? (maxVal * 1.2 / 3).ceilToDouble() : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(KuberSpacing.lg),
          decoration: BoxDecoration(
            color: KuberColors.surfaceCard,
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text('Last 7 Days',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                  const Spacer(),
                  _ChartLegendDot(color: KuberColors.income, label: 'Inc'),
                  const SizedBox(width: KuberSpacing.md),
                  _ChartLegendDot(color: KuberColors.expense, label: 'Exp'),
                ],
              ),
              const SizedBox(height: KuberSpacing.lg),
              SizedBox(
                height: 200,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final slotWidth = constraints.maxWidth / days.length;
                    final barWidth = (slotWidth * 0.35).clamp(10.0, 22.0);
                    return BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxVal * 1.2,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchCallback: (event, response) {
                            if (event is! FlTapUpEvent) return;
                            setState(() {
                              if (response == null || response.spot == null) {
                                _touchedIndex = -1;
                              } else {
                                final tapped =
                                    response.spot!.touchedBarGroupIndex;
                                _touchedIndex =
                                    tapped == _touchedIndex ? -1 : tapped;
                              }
                            });
                          },
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => Colors.transparent,
                            tooltipPadding: EdgeInsets.zero,
                            getTooltipItem: (_, _, _, _) => null,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles:
                              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles:
                              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: yInterval,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  _formatYAxis(value),
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx < 0 || idx >= days.length) {
                                  return const SizedBox.shrink();
                                }
                                final isToday = idx == days.length - 1;
                                final isTouched = idx == _touchedIndex;
                                final highlight = isToday || isTouched;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        DateFormat('d').format(days[idx].date),
                                        style: textTheme.labelSmall?.copyWith(
                                          color: highlight
                                              ? Colors.white
                                              : colorScheme.onSurfaceVariant,
                                          fontWeight: highlight
                                              ? FontWeight.w700
                                              : FontWeight.normal,
                                          fontSize: 10,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('MMM').format(days[idx].date).toUpperCase(),
                                        style: textTheme.labelSmall?.copyWith(
                                          color: highlight
                                              ? Colors.white
                                              : KuberColors.textSecondary,
                                          fontWeight: highlight
                                              ? FontWeight.w700
                                              : FontWeight.normal,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: days.asMap().entries.map((entry) {
                          final i = entry.key;
                          final d = entry.value;
                          return BarChartGroupData(
                            x: i,
                            barsSpace: 3,
                            barRods: [
                              BarChartRodData(
                                toY: d.income,
                                color: KuberColors.income,
                                width: barWidth,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              BarChartRodData(
                                toY: d.expense,
                                color: KuberColors.expense,
                                width: barWidth,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _touchedIndex >= 0 && _touchedIndex < days.length
              ? _WeeklyDetailPanel(day: days[_touchedIndex])
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _WeeklyDetailPanel extends StatelessWidget {
  final DaySummary day;

  const _WeeklyDetailPanel({required this.day});

  String _formatAmount(double v) {
    if (v >= 100000) {
      return '₹${(v / 1000).toStringAsFixed(0)}K';
    }
    return '₹${v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2)}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final net = day.income - day.expense;
    final maxVal = (day.income > day.expense ? day.income : day.expense)
        .clamp(1.0, double.infinity);

    return Padding(
      padding: const EdgeInsets.only(top: KuberSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.md),
        decoration: BoxDecoration(
          color: KuberColors.surfaceCard,
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, d MMM').format(day.date),
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: KuberSpacing.sm),
            _WeeklyDetailBar(
              label: 'Income',
              amount: _formatAmount(day.income),
              ratio: day.income / maxVal,
              color: KuberColors.income,
            ),
            const SizedBox(height: KuberSpacing.xs),
            _WeeklyDetailBar(
              label: 'Expense',
              amount: _formatAmount(day.expense),
              ratio: day.expense / maxVal,
              color: KuberColors.expense,
            ),
            const SizedBox(height: KuberSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Net',
                  style: textTheme.labelSmall?.copyWith(
                    color: KuberColors.textSecondary,
                  ),
                ),
                Text(
                  '${net >= 0 ? '+' : ''}${_formatAmount(net)}',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: net >= 0 ? KuberColors.income : KuberColors.expense,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyDetailBar extends StatelessWidget {
  final String label;
  final String amount;
  final double ratio;
  final Color color;

  const _WeeklyDetailBar({
    required this.label,
    required this.amount,
    required this.ratio,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: textTheme.labelSmall
                    ?.copyWith(color: KuberColors.textSecondary)),
            Text(amount,
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                )),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 4,
            backgroundColor: KuberColors.surfaceMuted,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _ChartLegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _ChartLegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: KuberSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
