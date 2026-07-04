import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../../shared/utils/chart_bucket.dart';
import '../../../shared/widgets/edit_widgets_button.dart';
import '../../../shared/widgets/kuber_bar_chart.dart';
import '../../widget_editor/models/home_widget_config.dart';
import '../../widget_editor/providers/widget_editor_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/helpers/transaction_filters.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, privacyModeProvider;
import '../providers/analytics_provider.dart';
import '../../charts/widgets/category_donut_chart.dart';
import '../../charts/widgets/income_expense_chart.dart';
import '../../charts/widgets/income_expense_chart_controls.dart'
    show KuberSegmentedTabs;
import '../widgets/avg_weekly_heatmap.dart';
import '../widgets/transaction_size_distribution.dart';
import '../widgets/tag_wise_analytics.dart';
import '../widgets/top_filter_row.dart';
import '../../../shared/widgets/transaction_detail_sheet.dart';
import '../../tutorial/models/tutorial_step_keys.dart';

// ---------------------------------------------------------------------------
// Private data classes
// ---------------------------------------------------------------------------

class _MutableBucket {
  final String day;
  final String month;
  final DateTime? date;
  final DateTime? endDate;
  double income = 0;
  double expense = 0;
  _MutableBucket(this.day, this.month, {this.date, this.endDate});
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

  List<KuberBarBucket> _buildPeriodBuckets(
    List<Transaction> txns,
    AnalyticsFilter filter,
  ) {
    txns = txns.validForCalculations.toList();

    // "Today" remains a special case — its 5 time-of-day slots are more
    // useful than a single day bar. Only Day is available in the dropdown
    // for a 1-day range anyway, so the dropdown stays hidden here.
    if (filter.type == FilterType.today) {
      return _buildTimeOfDayBuckets(txns, filter);
    }

    switch (filter.effectiveBucket) {
      case KuberChartBucket.day:
        return _buildDayBuckets(txns, filter.from, filter.to);
      case KuberChartBucket.week:
        return _buildWeekBuckets(txns, filter.from, filter.to);
      case KuberChartBucket.month:
        return _buildMonthBuckets(txns, filter.from, filter.to);
      case KuberChartBucket.quarter:
        return _buildQuarterBuckets(txns, filter.from, filter.to);
      case KuberChartBucket.year:
        return _buildYearBuckets(txns, filter.from, filter.to);
    }
  }

  List<KuberBarBucket> _buildTimeOfDayBuckets(
      List<Transaction> txns, AnalyticsFilter filter) {
    final buckets = [
      _MutableBucket(context.l10n.bucketDawn, '',
          date: filter.from,
          endDate: filter.from.add(const Duration(hours: 5, minutes: 59))),
      _MutableBucket(context.l10n.bucketMorning, '',
          date: filter.from.add(const Duration(hours: 6)),
          endDate: filter.from.add(const Duration(hours: 10, minutes: 59))),
      _MutableBucket(context.l10n.bucketNoon, '',
          date: filter.from.add(const Duration(hours: 11)),
          endDate: filter.from.add(const Duration(hours: 13, minutes: 59))),
      _MutableBucket(context.l10n.bucketEvening, '',
          date: filter.from.add(const Duration(hours: 14)),
          endDate: filter.from.add(const Duration(hours: 18, minutes: 59))),
      _MutableBucket(context.l10n.bucketNight, '',
          date: filter.from.add(const Duration(hours: 19)),
          endDate: filter.to),
    ];
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
    return _toKuber(buckets);
  }

  List<KuberBarBucket> _buildDayBuckets(
      List<Transaction> txns, DateTime from, DateTime to) {
    final fromDay = DateTime(from.year, from.month, from.day);
    final daysCount = DateTime(to.year, to.month, to.day)
            .difference(fromDay)
            .inDays +
        1;
    final buckets = List.generate(daysCount, (i) {
      final d = fromDay.add(Duration(days: i));
      return _MutableBucket(
        DateFormat('d').format(d),
        DateFormat('MMM').format(d).toUpperCase(),
        date: d,
      );
    });
    for (final t in txns) {
      final txDay = DateTime(
          t.createdAt.year, t.createdAt.month, t.createdAt.day);
      final diff = txDay.difference(fromDay).inDays;
      if (diff < 0 || diff >= daysCount) continue;
      if (t.type == 'income') {
        buckets[diff].income += t.amount;
      } else {
        buckets[diff].expense += t.amount;
      }
    }
    return _toKuber(buckets);
  }

  List<KuberBarBucket> _buildWeekBuckets(
      List<Transaction> txns, DateTime from, DateTime to) {
    final fromDay = DateTime(from.year, from.month, from.day);
    final days = DateTime(to.year, to.month, to.day)
            .difference(fromDay)
            .inDays +
        1;
    final weeks = (days / 7).ceil().clamp(1, 1000);
    final buckets = List.generate(weeks, (i) {
      final start = fromDay.add(Duration(days: i * 7));
      final end =
          i == weeks - 1 ? to : start.add(const Duration(days: 6));
      return _MutableBucket(context.l10n.weekLabel, '${i + 1}', date: start, endDate: end);
    });
    for (final t in txns) {
      final dayDiff = t.createdAt.difference(fromDay).inDays;
      final idx = (dayDiff / 7).floor().clamp(0, weeks - 1);
      if (t.type == 'income') {
        buckets[idx].income += t.amount;
      } else {
        buckets[idx].expense += t.amount;
      }
    }
    return _toKuber(buckets);
  }

  List<KuberBarBucket> _buildMonthBuckets(
      List<Transaction> txns, DateTime from, DateTime to) {
    final monthsDiff =
        (to.year - from.year) * 12 + to.month - from.month;
    final count = (monthsDiff + 1).clamp(1, 240);
    final buckets = List.generate(count, (i) {
      final m = DateTime(from.year, from.month + i, 1);
      final endM = DateTime(m.year, m.month + 1, 0);
      return _MutableBucket(
        DateFormat('MMM').format(m),
        DateFormat('yy').format(m),
        date: m,
        endDate: endM.isAfter(to) ? to : endM,
      );
    });
    for (final t in txns) {
      final idx = (t.createdAt.year - from.year) * 12 +
          t.createdAt.month -
          from.month;
      if (idx < 0 || idx >= count) continue;
      if (t.type == 'income') {
        buckets[idx].income += t.amount;
      } else {
        buckets[idx].expense += t.amount;
      }
    }
    return _toKuber(buckets);
  }

  List<KuberBarBucket> _buildQuarterBuckets(
      List<Transaction> txns, DateTime from, DateTime to) {
    final fromQStartMonth = ((from.month - 1) ~/ 3) * 3 + 1;
    final fromQ = DateTime(from.year, fromQStartMonth, 1);
    final toQStartMonth = ((to.month - 1) ~/ 3) * 3 + 1;
    final toQ = DateTime(to.year, toQStartMonth, 1);
    final monthsDiff = (toQ.year - fromQ.year) * 12 + toQ.month - fromQ.month;
    final count = (monthsDiff ~/ 3 + 1).clamp(1, 80);
    final buckets = List.generate(count, (i) {
      final qStart = DateTime(fromQ.year, fromQ.month + i * 3, 1);
      final qEnd = DateTime(qStart.year, qStart.month + 3, 0);
      final q = ((qStart.month - 1) ~/ 3) + 1;
      return _MutableBucket(
        'Q$q',
        DateFormat('yy').format(qStart),
        date: qStart,
        endDate: qEnd.isAfter(to) ? to : qEnd,
      );
    });
    for (final t in txns) {
      final tQStartMonth = ((t.createdAt.month - 1) ~/ 3) * 3 + 1;
      final tQ = DateTime(t.createdAt.year, tQStartMonth, 1);
      final mDiff = (tQ.year - fromQ.year) * 12 + tQ.month - fromQ.month;
      final idx = (mDiff ~/ 3).clamp(0, count - 1);
      if (t.type == 'income') {
        buckets[idx].income += t.amount;
      } else {
        buckets[idx].expense += t.amount;
      }
    }
    return _toKuber(buckets);
  }

  List<KuberBarBucket> _buildYearBuckets(
      List<Transaction> txns, DateTime from, DateTime to) {
    final years = (to.year - from.year + 1).clamp(1, 50);
    final buckets = List.generate(years, (i) {
      final yStart = DateTime(from.year + i, 1, 1);
      final yEnd = DateTime(from.year + i, 12, 31);
      return _MutableBucket(
        '${from.year + i}',
        '',
        date: yStart,
        endDate: yEnd.isAfter(to) ? to : yEnd,
      );
    });
    for (final t in txns) {
      final idx = (t.createdAt.year - from.year).clamp(0, years - 1);
      if (t.type == 'income') {
        buckets[idx].income += t.amount;
      } else {
        buckets[idx].expense += t.amount;
      }
    }
    return _toKuber(buckets);
  }

  List<KuberBarBucket> _toKuber(List<_MutableBucket> buckets) {
    return List.generate(buckets.length, (i) {
      final b = buckets[i];
      return KuberBarBucket(
        dayLabel: b.day,
        monthLabel: b.month,
        income: b.income,
        expense: b.expense,
        isHighlighted: i == buckets.length - 1,
        date: b.date,
        endDate: b.endDate,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(analyticsFilterProvider);
    final periodTxns = ref.watch(analyticsTransactionsProvider);
    final computed = ref.watch(analyticsComputedProvider);

    final cs = Theme.of(context).colorScheme;
    final colorScheme = cs;
    final textTheme = Theme.of(context).textTheme;

    final isEmpty = computed == null;

    // Totals — from cached provider (single O(n) pass)
    final totalIncome = computed?.totalIncome ?? 0.0;
    final totalExpense = computed?.totalExpense ?? 0.0;
    final netAmount = computed?.netAmount ?? 0.0;

    // Buckets — cached once per build
    final buckets = _buildPeriodBuckets(periodTxns, filter);

    // Category map — only watched when needed for biggest transactions
    final categoryMap = ref.watch(categoryMapProvider).valueOrNull ?? {};

    // Top 5 biggest transactions (filtered by tab)
    final biggestType = _biggestTab == 0 ? 'expense' : 'income';
    final biggest = periodTxns.where((t) => t.type == biggestType).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final top5 = biggest.take(5).toList();

    return Scaffold(
      body: CustomScrollView(
        key: TutorialStepKeys.analyticsPage,
        slivers: [
          // ── Header (always eager) ─────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: KuberSpacing.xl),
                // const KuberAppBar(title: 'Analytics'),
                KuberPageHeader(
                  title: context.l10n.analyticsTitle,
                  description: context.l10n.analyticsDescription,
                ),
                const TopFilterRow(),
                const SizedBox(height: KuberSpacing.lg),
              ]),
            ),
          ),

          // ── Analytics widgets (dynamic order + visibility from editor) ─
          if (isEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: KuberSpacing.xl),
                    KuberEmptyState(
                      icon: Icons.bar_chart,
                      title: context.l10n.noData,
                      description: context.l10n.noTransactionsForPeriod,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
              sliver: _AnalyticsWidgetList(
                filter: filter,
                buckets: buckets,
                periodTxns: periodTxns,
                computed: computed,
                top5: top5,
                biggestType: biggestType,
                categoryMap: categoryMap,
                totalIncome: totalIncome,
                totalExpense: totalExpense,
                netAmount: netAmount,
                colorScheme: colorScheme,
                textTheme: textTheme,
                buildSummary: (cs, tt, inc, exp, net) =>
                    _buildSummaryCard(ref, cs, tt, inc, exp, net),
                buildBiggest: (cs, tt, t5, bt, cm) =>
                    _buildBiggestTransactionsSection(
                  cs,
                  tt,
                  t5,
                  isMoreTab: false,
                  biggestType: bt,
                  categoryMap: cm,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBiggestTransactionsSection(
    ColorScheme cs,
    TextTheme tt,
    List<Transaction> top5, {
    required bool isMoreTab,
    required String biggestType,
    required Map<int, dynamic> categoryMap,
  }) {
    return _AnalyticsCard(
      title: context.l10n.biggestTransactions,
      trailing: KuberSegmentedTabs(
        labels: [context.l10n.expenseLabel, context.l10n.incomeLabel],
        selectedIndex: _biggestTab,
        onChanged: (i) => setState(() => _biggestTab = i),
      ),
      child: top5.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: KuberSpacing.xl),
              child: Center(
                child: Text(
                  'No $biggestType transactions',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            )
          : Column(
              children: List.generate(top5.length, (i) {
                final t = top5[i];
                final cat = categoryMap[int.tryParse(t.categoryId)];
                final isExpense = t.type == 'expense';
                final rankColor = i == 0 ? cs.primary : cs.onSurfaceVariant;
                return Padding(
                  padding: const EdgeInsets.only(bottom: KuberSpacing.sm),
                  child: InkWell(
                    onTap: () => showTransactionDetailSheet(context, ref, t),
                    borderRadius: BorderRadius.circular(KuberRadius.sm),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: KuberSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: rankColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '#${i + 1}',
                              style: tt.labelSmall?.copyWith(
                                color: rankColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: KuberSpacing.md),
                          if (cat != null)
                            CategoryIcon.square(
                              icon: IconMapper.fromString(cat.icon),
                              rawColor: harmonizeCategory(
                                context,
                                Color(cat.colorValue),
                              ),
                              size: 36,
                            ),
                          const SizedBox(width: KuberSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.name,
                                  style: tt.bodyMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (cat != null)
                                  Text(
                                    cat.name,
                                    style: tt.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            maskAmount(
                              '${isExpense ? '-' : '+'}${ref.watch(formatterProvider).formatCurrency(t.amount)}',
                              ref.watch(privacyModeProvider),
                            ),
                            style: tt.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isExpense ? cs.error : cs.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ---- summary card -------------------------------------------------------

  Widget _buildSummaryCard(
    WidgetRef ref,
    ColorScheme cs,
    TextTheme tt,
    double income,
    double expense,
    double net,
  ) {
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
                  label: context.l10n.incomeLabel,
                  amount: maskAmount(
                    ref.watch(formatterProvider).formatCurrency(income),
                    ref.watch(privacyModeProvider),
                  ),
                  color: cs.tertiary,
                  icon: Icons.arrow_downward,
                ),
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: _SummaryTile(
                  label: context.l10n.expenseLabel,
                  amount: maskAmount(
                    ref.watch(formatterProvider).formatCurrency(expense),
                    ref.watch(privacyModeProvider),
                  ),
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
              vertical: KuberSpacing.sm,
              horizontal: KuberSpacing.md,
            ),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Net: ',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                Text(
                  maskAmount(
                    '${net >= 0 ? '+' : ''}${ref.watch(formatterProvider).formatCurrency(net)}',
                    ref.watch(privacyModeProvider),
                  ),
                  style: tt.titleMedium?.copyWith(
                    color: net >= 0 ? cs.tertiary : cs.error,
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
          Text(
            title,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Tabs sit below the title (left-aligned), matching the chart cards.
          if (trailing != null) ...[
            const SizedBox(height: KuberSpacing.md),
            Align(alignment: Alignment.centerLeft, child: trailing!),
          ],
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
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: KuberSpacing.xs),
          Text(
            amount,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dynamic analytics widget list — order + enabled flags come from
/// `analyticsWidgetsProvider`. Hidden widgets are not constructed; their
/// underlying providers stay idle until re-enabled.
class _AnalyticsWidgetList extends ConsumerWidget {
  final AnalyticsFilter filter;
  final List<KuberBarBucket> buckets;
  final List<Transaction> periodTxns;
  final AnalyticsComputed computed;
  final List<Transaction> top5;
  final String biggestType;
  final Map<int, dynamic> categoryMap;
  final double totalIncome;
  final double totalExpense;
  final double netAmount;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  final Widget Function(ColorScheme cs, TextTheme tt, double inc, double exp,
      double net) buildSummary;
  final Widget Function(ColorScheme cs, TextTheme tt, List<Transaction> t5,
      String bt, Map<int, dynamic> cm) buildBiggest;

  const _AnalyticsWidgetList({
    required this.filter,
    required this.buckets,
    required this.periodTxns,
    required this.computed,
    required this.top5,
    required this.biggestType,
    required this.categoryMap,
    required this.totalIncome,
    required this.totalExpense,
    required this.netAmount,
    required this.colorScheme,
    required this.textTheme,
    required this.buildSummary,
    required this.buildBiggest,
  });

  Widget _buildWidget(BuildContext ctx, WidgetRef ref, String id) {
    final bottom = const EdgeInsets.only(bottom: KuberSpacing.lg);
    switch (id) {
      case 'summary_card':
        return Padding(
          padding: bottom,
          child: buildSummary(colorScheme, textTheme, totalIncome,
              totalExpense, netAmount),
        );
      case 'spending_trend':
        return Padding(
          padding: bottom,
          child: RepaintBoundary(
            child: IncomeExpenseChart(
              key: TutorialStepKeys.spendingTrendsChart,
              compact: false,
              points: [
                for (final b in buckets)
                  IncomeExpensePoint(
                    label: b.dayLabel,
                    income: b.income,
                    expense: b.expense,
                    date: b.date,
                    endDate: b.endDate,
                  ),
              ],
              bucket: filter.type == FilterType.today
                  ? null
                  : filter.effectiveBucket,
              availableBuckets:
                  availableBucketsForRange(filter.from, filter.to),
              onBucketChanged: (b) =>
                  ref.read(analyticsFilterProvider.notifier).setBucket(b),
            ),
          ),
        );
      case 'weekly_heatmap':
        return Padding(
          padding: bottom,
          child: RepaintBoundary(
            child: AvgWeeklyHeatmap(
              transactions: periodTxns,
              precomputedDailyAverages: computed.dailyAverages,
            ),
          ),
        );
      case 'size_distribution':
        return Padding(
          padding: bottom,
          child: RepaintBoundary(
            child: TransactionSizeDistribution(
              transactions: periodTxns,
              precomputedDistribution: computed.sizeDistribution,
            ),
          ),
        );
      case 'category_breakdown':
        return Padding(
          padding: bottom,
          child: RepaintBoundary(
            child: CategoryDonutChart(
              key: TutorialStepKeys.categoryBreakdownChart,
            ),
          ),
        );
      case 'tag_analytics':
        return Padding(
          padding: bottom,
          child: RepaintBoundary(
            child: TagWiseAnalytics(transactions: periodTxns),
          ),
        );
      case 'biggest_transactions':
        return buildBiggest(
            colorScheme, textTheme, top5, biggestType, categoryMap);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final widgetsAsync = ref.watch(analyticsWidgetsProvider);
    return widgetsAsync.when(
      loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
      data: (configs) {
        final visible = configs.where((c) => c.enabled).toList();
        return SliverList.builder(
          // +2 for EditWidgetsButton + bottom nav spacer.
          itemCount: visible.length + 2,
          itemBuilder: (ctx, i) {
            if (i == visible.length) {
              return const EditWidgetsButton(
                  scope: WidgetEditorScope.analytics);
            }
            if (i == visible.length + 1) {
              return SizedBox(height: navBarBottomPadding(ctx));
            }
            return _buildWidget(ctx, ref, visible[i].id);
          },
        );
      },
    );
  }
}
