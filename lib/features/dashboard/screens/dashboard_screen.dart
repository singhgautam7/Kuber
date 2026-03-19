import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/account_helpers.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
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
        padding: const EdgeInsets.only(
          left: KuberSpacing.lg,
          right: KuberSpacing.lg,
          bottom: 100,
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
                                color: KuberColors.card,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: KuberColors.divider,
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
                                              BorderRadius.circular(10),
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
                                  const Spacer(),
                                  balanceAsync.when(
                                    loading: () => Text('...',
                                        style: textTheme.titleMedium),
                                    error: (e, _) => Text('-',
                                        style: textTheme.titleMedium),
                                    data: (balance) => Text(
                                      CurrencyFormatter.format(balance),
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
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
            Text('Recent Transactions',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
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
                      color: KuberColors.card,
                      borderRadius: BorderRadius.circular(16),
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
                    color: KuberColors.card,
                    borderRadius: BorderRadius.circular(16),
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [KuberColors.gradientStart, KuberColors.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(20),
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
            CurrencyFormatter.format(summary.net),
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
                  icon: Icons.arrow_downward,
                  iconColor: KuberColors.income,
                ),
              ),
              const SizedBox(width: KuberSpacing.lg),
              Expanded(
                child: _BalanceTile(
                  label: 'Expense',
                  amount: summary.totalExpense,
                  icon: Icons.arrow_upward,
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 16),
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

    final maxVal = days.fold<double>(0, (prev, d) {
      final m = d.income > d.expense ? d.income : d.expense;
      return m > prev ? m : prev;
    });

    final yInterval = maxVal > 0 ? (maxVal * 1.2 / 3).ceilToDouble() : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Last 7 Days',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(width: KuberSpacing.xs),
            Text('(Income vs Expense)',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                )),
            const Spacer(),
            _ChartLegendDot(color: KuberColors.income, label: 'Inc'),
            const SizedBox(width: KuberSpacing.md),
            _ChartLegendDot(color: KuberColors.expense, label: 'Exp'),
          ],
        ),
        const SizedBox(height: KuberSpacing.lg),
        Container(
          height: 240,
          padding: const EdgeInsets.all(KuberSpacing.lg),
          decoration: BoxDecoration(
            color: KuberColors.card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxVal * 1.2,
              barTouchData: BarTouchData(
                enabled: true,
                touchCallback: (event, response) {
                  setState(() {
                    if (response == null ||
                        response.spot == null ||
                        !event.isInterestedForInteractions) {
                      _touchedIndex = -1;
                    } else {
                      _touchedIndex =
                          response.spot!.touchedBarGroupIndex;
                    }
                  });
                },
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => KuberColors.cardLight,
                  tooltipRoundedRadius: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    if (rodIndex != 0) return null;
                    final d = days[group.x.toInt()];
                    return BarTooltipItem(
                      'Inc: ${CurrencyFormatter.format(d.income)}\nExp: ${CurrencyFormatter.format(d.expense)}',
                      textTheme.labelSmall!.copyWith(
                        color: KuberColors.textPrimary,
                      ),
                    );
                  },
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
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= days.length) {
                        return const SizedBox.shrink();
                      }
                      final isTouched = idx == _touchedIndex;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          DateFormat('d MMM').format(days[idx].date),
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: isTouched
                                ? FontWeight.w700
                                : FontWeight.normal,
                            fontSize: 9,
                          ),
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
                  barRods: [
                    BarChartRodData(
                      toY: d.income,
                      color: KuberColors.income,
                      width: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    BarChartRodData(
                      toY: d.expense,
                      color: KuberColors.expense,
                      width: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }).toList(),
            ),
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
