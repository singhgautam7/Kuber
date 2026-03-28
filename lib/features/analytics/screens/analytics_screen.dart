import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../../shared/widgets/kuber_bar_chart.dart';
import '../../categories/providers/category_provider.dart';
import '../../transactions/data/transaction.dart';
import '../../settings/providers/settings_provider.dart' show formatterProvider;
import '../providers/analytics_provider.dart';
import '../widgets/category_group_stats.dart';
import '../widgets/analytics_toggle.dart';
import '../widgets/avg_weekly_heatmap.dart';
import '../widgets/transaction_size_distribution.dart';
import '../widgets/tag_wise_analytics.dart';
import '../widgets/top_filter_row.dart';
import '../../../shared/widgets/wip_bottom_sheet.dart';

// ---------------------------------------------------------------------------
// Private data classes
// ---------------------------------------------------------------------------

class _MutableBucket {
  final String day;
  final String month;
  double income = 0;
  double expense = 0;
  _MutableBucket(this.day, this.month);
}

// ---------------------------------------------------------------------------
// Analytics Screen
// ---------------------------------------------------------------------------

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _biggestTab = 0; // 0 = expense, 1 = income

  // ---- bucket helpers -----------------------------------------------------

  List<KuberBarBucket> _buildPeriodBuckets(List<Transaction> txns, AnalyticsFilter filter) {
    txns = txns.where((t) => t.type != 'transfer' && !t.isBalanceAdjustment).toList();
    List<_MutableBucket> buckets = [];

    switch (filter.type) {
      case FilterType.today:
        final labels = ['Dawn', 'Morning', 'Noon', 'Evening', 'Night'];
        buckets = labels.map((l) => _MutableBucket(l, '')).toList();
        for (final t in txns) {
          final h = t.createdAt.hour;
          int idx;
          if (h < 6) {
            idx = 0;
          } else if (h < 11) {
            idx = 1;
          } else if (h < 14) {
            idx = 2;
          } else if (h < 19) {
            idx = 3;
          } else {
            idx = 4;
          }
          if (t.type == 'income') {
            buckets[idx].income += t.amount;
          } else {
            buckets[idx].expense += t.amount;
          }
        }
        break;

      case FilterType.thisWeek:
      case FilterType.lastWeek:
        // Show 7 days range
        final daysCount = filter.to.difference(filter.from).inDays + 1;
        buckets = List.generate(daysCount, (i) {
          final d = filter.from.add(Duration(days: i));
          return _MutableBucket(DateFormat('d').format(d), DateFormat('MMM').format(d).toUpperCase());
        });
        for (final t in txns) {
          final diff = t.createdAt.difference(filter.from).inDays;
          if (diff < 0 || diff >= daysCount) continue;
          if (t.type == 'income') {
            buckets[diff].income += t.amount;
          } else {
            buckets[diff].expense += t.amount;
          }
        }
        break;

      case FilterType.thisMonth:
      case FilterType.lastMonth:
        // Divide into 4 or 5 weeks
        final daysInMonth = filter.to.difference(filter.from).inDays + 1;
        final weekCount = (daysInMonth / 7).ceil();
        buckets = List.generate(weekCount, (i) => _MutableBucket('Week', '${i + 1}'));
        for (final t in txns) {
          final dayDiff = t.createdAt.difference(filter.from).inDays;
          final week = (dayDiff / 7).floor();
          final idx = week.clamp(0, weekCount - 1);
          if (t.type == 'income') {
            buckets[idx].income += t.amount;
          } else {
            buckets[idx].expense += t.amount;
          }
        }
        break;

      case FilterType.thisYear:
      case FilterType.all:
      case FilterType.custom:
        // If > 6 months, show months. Otherwise show weeks.
        final monthsDiff = (filter.to.year - filter.from.year) * 12 + filter.to.month - filter.from.month;
        if (monthsDiff >= 6 || filter.type == FilterType.all || filter.type == FilterType.thisYear) {
             // Quarterly or monthly depending on range
             if (monthsDiff > 12) {
               // Show Quarters
               final quarters = (monthsDiff / 3).ceil().clamp(1, 12);
               buckets = List.generate(quarters, (i) {
                  final m = DateTime(filter.from.year, filter.from.month + i * 3, 1);
                  return _MutableBucket('Q${((m.month - 1) / 3).floor() + 1}', DateFormat('yy').format(m));
               });
               for (final t in txns) {
                 final mDiff = (t.createdAt.year - filter.from.year) * 12 + t.createdAt.month - filter.from.month;
                 final idx = (mDiff / 3).floor().clamp(0, quarters - 1);
                 if (t.type == 'income') {
                   buckets[idx].income += t.amount;
                 } else {
                   buckets[idx].expense += t.amount;
                 }
               }
             } else {
               // Show Months
               final count = monthsDiff + 1;
               buckets = List.generate(count, (i) {
                 final m = DateTime(filter.from.year, filter.from.month + i, 1);
                 return _MutableBucket(DateFormat('MMM').format(m), DateFormat('yy').format(m));
               });
               for (final t in txns) {
                 final idx = (t.createdAt.year - filter.from.year) * 12 + t.createdAt.month - filter.from.month;
                 if (idx >= 0 && idx < count) {
                   if (t.type == 'income') {
                     buckets[idx].income += t.amount;
                   } else {
                     buckets[idx].expense += t.amount;
                   }
                 }
               }
             }
        } else {
          // Show weeks
          final days = filter.to.difference(filter.from).inDays + 1;
          final weeks = (days / 7).ceil();
          buckets = List.generate(weeks, (i) => _MutableBucket('Week', '${i + 1}'));
          for (final t in txns) {
            final idx = (t.createdAt.difference(filter.from).inDays / 7).floor().clamp(0, weeks - 1);
            if (t.type == 'income') {
              buckets[idx].income += t.amount;
            } else {
              buckets[idx].expense += t.amount;
            }
          }
        }
        break;
    }

    return List.generate(buckets.length, (i) {
      final b = buckets[i];
      return KuberBarBucket(
        dayLabel: b.day,
        monthLabel: b.month,
        income: b.income,
        expense: b.expense,
        isHighlighted: i == buckets.length - 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(analyticsFilterProvider);
    final periodTxns = ref.watch(analyticsTransactionsProvider);
    final categoryMap = ref.watch(categoryMapProvider).valueOrNull ?? {};

    final cs = Theme.of(context).colorScheme;
    final colorScheme = cs;
    final textTheme = Theme.of(context).textTheme;

    final isEmpty = periodTxns.isEmpty;

    // Totals
    double totalIncome = 0, totalExpense = 0;
    for (final t in periodTxns) {
      if (t.type == 'income') {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
      }
    }
    final netAmount = totalIncome - totalExpense;

    // Buckets
    final buckets = _buildPeriodBuckets(periodTxns, filter);

    // Category totals (expense only)
    final catMap = <int, double>{};
    for (final t in periodTxns) {
      if (t.type != 'expense') continue;
      final catId = int.tryParse(t.categoryId) ?? -1;
      catMap[catId] = (catMap[catId] ?? 0) + t.amount;
    }

    // Top 5 biggest transactions (filtered by tab)
    final biggestType = _biggestTab == 0 ? 'expense' : 'income';
    final biggest = periodTxns
        .where((t) => t.type == biggestType)
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final top5 = biggest.take(5).toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: KuberSpacing.lg,
          right: KuberSpacing.lg,
          bottom: KuberSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KuberAppBar(title: 'Analytics'),
            KuberPageHeader(
              title: 'Spending\nAnalytics',
              description: 'Visualize your spending patterns',
              actionIcon: Icons.file_download_outlined,
              actionTooltip: 'Export',
              onAction: () {
                final cs = Theme.of(context).colorScheme;
                showWIPBottomSheet(
                  context: context,
                  icon: Icons.rocket_launch_rounded,
                  title: 'Export Report',
                  content: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        height: 1.6,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        const TextSpan(text: "We are currently building this feature to help you export your financial reports in "),
                        TextSpan(
                          text: "PDF",
                          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w800),
                        ),
                        const TextSpan(text: " and "),
                        TextSpan(
                          text: "CSV",
                          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w800),
                        ),
                        const TextSpan(text: " formats. Stay tuned!"),
                      ],
                    ),
                  ),
                );
              },
            ),

            // [A] New Unified Filter Row
            const TopFilterRow(),
            const SizedBox(height: KuberSpacing.lg),

            // If no data for this period, show inline empty state
            if (isEmpty) ...[
              const SizedBox(height: KuberSpacing.xl),
              const KuberEmptyState(
                icon: Icons.bar_chart,
                title: 'No data',
                description: 'No transactions found for this period',
              ),
            ] else ...[

            // [B] Summary Card
            _buildSummaryCard(
                colorScheme, textTheme, totalIncome, totalExpense, netAmount),
            const SizedBox(height: KuberSpacing.lg),

            // [C] Spending Trend
            KuberBarChart(
              title: 'Spending Trend',
              buckets: buckets,
              height: 200,
            ),
            const SizedBox(height: KuberSpacing.lg),

            // [D] Avg Weekly Heatmap
            AvgWeeklyHeatmap(transactions: periodTxns),
            const SizedBox(height: KuberSpacing.lg),

            // [E] Transaction Size Distribution
            TransactionSizeDistribution(transactions: periodTxns),
            const SizedBox(height: KuberSpacing.lg),

            // [F] Spending Distribution (Category/Group Toggle)
            const CategoryGroupStatsWidget(),
            const SizedBox(height: KuberSpacing.lg),

            // [G] Tag-wise Analytics
            TagWiseAnalytics(transactions: periodTxns),
            const SizedBox(height: KuberSpacing.lg),

            // // [E] Budget vs Actual
            // const BudgetVsActualCard(),
            // const SizedBox(height: KuberSpacing.lg),

            // // [G] Highlights (2x3 grid)
            // _AnalyticsCard(
            //   title: 'Highlights',
            //   child: GridView.count(
            //     crossAxisCount: 2,
            //     shrinkWrap: true,
            //     physics: const NeverScrollableScrollPhysics(),
            //     mainAxisSpacing: KuberSpacing.sm,
            //     crossAxisSpacing: KuberSpacing.md,
            //     childAspectRatio: 2.1,
            //     children: [
            //       _StatTile(
            //         label: 'Avg. Daily',
            //         value: _formatAmount(avgDaily),
            //         icon: Icons.calendar_today,
            //         color: colorScheme.primary,
            //       ),
            //       _StatTile(
            //         label: 'Largest Expense',
            //         value: _formatAmount(largestExpense),
            //         icon: Icons.trending_down,
            //         color: colorScheme.error,
            //       ),
            //       _StatTile(
            //         label: 'Largest Income',
            //         value: _formatAmount(largestIncome),
            //         icon: Icons.trending_up,
            //         color: colorScheme.tertiary,
            //       ),
            //       _StatTile(
            //         label: 'Expense Ratio',
            //         value: _formatPercent(expenseRatio),
            //         icon: Icons.pie_chart,
            //         color: colorScheme.primary,
            //       ),
            //       _StatTile(
            //         label: 'Savings Rate',
            //         value: _formatPercent(savingsRate),
            //         icon: Icons.savings,
            //         color: colorScheme.tertiary,
            //       ),
            //       _StatTile(
            //         label: 'Transactions',
            //         value: '${periodTxns.length}',
            //         icon: Icons.receipt_long,
            //         color: colorScheme.onSurfaceVariant,
            //       ),
            //     ],
            //   ),
            // ),
            // [H] Biggest Transactions
            _AnalyticsCard(
              title: 'Biggest Transactions',
              trailing: AnalyticsCardSmallTabs(
                labels: const ['Expense', 'Income'],
                selectedIndex: _biggestTab,
                onChanged: (i) => setState(() => _biggestTab = i),
              ),
              child: top5.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: KuberSpacing.xl),
                      child: Center(
                        child: Text(
                          'No $biggestType transactions',
                          style: textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: List.generate(top5.length, (i) {
                        final t = top5[i];
                        final cat =
                            categoryMap[int.tryParse(t.categoryId)];
                        final isExpense = t.type == 'expense';
                        final rankColor = i == 0
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant;
                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: KuberSpacing.md),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color:
                                      rankColor.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '#${i + 1}',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: rankColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: KuberSpacing.md),
                              if (cat != null)
                                CategoryIcon.square(
                                  icon:
                                      IconMapper.fromString(cat.icon),
                                  rawColor: harmonizeCategory(context,
                                      Color(cat.colorValue)),
                                  size: 36,
                                ),
                              const SizedBox(width: KuberSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.name,
                                      style: textTheme.bodyMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (cat != null)
                                      Text(
                                        cat.name,
                                        style: textTheme.bodySmall
                                            ?.copyWith(
                                          color: colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                '${isExpense ? '-' : '+'}${ref.watch(formatterProvider).formatCurrency(t.amount)}',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isExpense
                                      ? colorScheme.error
                                      : colorScheme.tertiary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
            ),

            SizedBox(height: navBarBottomPadding(context)),
            ], // end else (has data)
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ---- summary card -------------------------------------------------------

  Widget _buildSummaryCard(ColorScheme cs, TextTheme tt, double income,
      double expense, double net) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
      ),
      padding: const EdgeInsets.all(KuberSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  label: 'Income',
                  amount: ref.watch(formatterProvider).formatCurrency(income),
                  color: cs.tertiary,
                  icon: Icons.arrow_downward,
                ),
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: _SummaryTile(
                  label: 'Expense',
                  amount: ref.watch(formatterProvider).formatCurrency(expense),
                  color: cs.error,
                  icon: Icons.arrow_upward,
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                vertical: KuberSpacing.sm, horizontal: KuberSpacing.md),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Net: ',
                  style: GoogleFonts.inter(
                    color: cs.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${net >= 0 ? '+' : ''}${ref.watch(formatterProvider).formatCurrency(net)}',
                  style: GoogleFonts.inter(
                    color: net >= 0 ? cs.tertiary : cs.error,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;

  const _AnalyticsCard({
    required this.title,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KuberSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              // ignore: use_null_aware_elements
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: KuberSpacing.xl),
          child,
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final IconData icon;

  const _SummaryTile({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(KuberSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: KuberSpacing.xs),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpacing.xs),
          Text(
            amount,
            style: GoogleFonts.inter(
              color: cs.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}



