import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_bar_chart.dart';
import '../../categories/data/category.dart';
import '../../categories/providers/category_provider.dart';
import '../../transactions/data/transaction.dart';
import '../../settings/providers/settings_provider.dart' show currencyProvider;
import '../providers/analytics_provider.dart';

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

class _CatTotal {
  final Category category;
  final double expense;
  final double percentage;
  const _CatTotal(this.category, this.expense, this.percentage);
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
  AnalyticsPeriod _period = AnalyticsPeriod.today;
  int? _selectedDonutSliceIndex;
  int _biggestTab = 0; // 0 = expense, 1 = income

  // ---- bucket helpers -----------------------------------------------------

  List<KuberBarBucket> _buildPeriodBuckets(List<Transaction> txns) {
    txns = txns.where((t) => t.type != 'transfer').toList();
    final now = DateTime.now();
    List<_MutableBucket> buckets;

    switch (_period) {
      case AnalyticsPeriod.today:
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

      case AnalyticsPeriod.week:
        buckets = List.generate(7, (i) {
          final d = now.subtract(Duration(days: 6 - i));
          return _MutableBucket(DateFormat('d').format(d), DateFormat('MMM').format(d).toUpperCase());
        });
        final todayStart = DateTime(now.year, now.month, now.day);
        for (final t in txns) {
          final txnDay = DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day);
          final diff = todayStart.difference(txnDay).inDays;
          if (diff < 0 || diff > 6) continue;
          final idx = 6 - diff;
          if (t.type == 'income') {
            buckets[idx].income += t.amount;
          } else {
            buckets[idx].expense += t.amount;
          }
        }
        break;

      case AnalyticsPeriod.month:
      case AnalyticsPeriod.lastMonth:
        buckets = List.generate(5, (i) => _MutableBucket('Week', '${i + 1}'));
        for (final t in txns) {
          final week = ((t.createdAt.day - 1) / 7).floor();
          final idx = week.clamp(0, 4);
          if (t.type == 'income') {
            buckets[idx].income += t.amount;
          } else {
            buckets[idx].expense += t.amount;
          }
        }
        break;

      case AnalyticsPeriod.threeMonths:
        buckets = List.generate(3, (i) {
          final m = DateTime(now.year, now.month - 2 + i, 1);
          return _MutableBucket(DateFormat('MMM').format(m), DateFormat('yy').format(m));
        });
        for (final t in txns) {
          final monthDiff = (now.year - t.createdAt.year) * 12 + now.month - t.createdAt.month;
          final idx = 2 - monthDiff;
          if (idx < 0 || idx > 2) continue;
          if (t.type == 'income') {
            buckets[idx].income += t.amount;
          } else {
            buckets[idx].expense += t.amount;
          }
        }
        break;

      case AnalyticsPeriod.year:
        buckets = List.generate(4, (i) => _MutableBucket('Q${i + 1}', '${now.year}'));
        for (final t in txns) {
          if (t.createdAt.year != now.year) continue;
          final idx = ((t.createdAt.month - 1) / 3).floor();
          if (t.type == 'income') {
            buckets[idx].income += t.amount;
          } else {
            buckets[idx].expense += t.amount;
          }
        }
        break;

      case AnalyticsPeriod.all:
        buckets = List.generate(4, (i) {
          final qOffset = 3 - i;
          final qStartMonth = now.month - qOffset * 3;
          final qStart = DateTime(now.year, qStartMonth, 1);
          final labelDay = "Q${((qStart.month - 1) / 3).floor() + 1}";
          final labelMonth = DateFormat('yy').format(qStart);
          return _MutableBucket(labelDay, labelMonth);
        });
        for (final t in txns) {
          bool placed = false;
          for (int i = 0; i < 4 && !placed; i++) {
            final qOffset = 3 - i;
            final qStartMonth = now.month - qOffset * 3;
            final qStart = DateTime(now.year, qStartMonth, 1);
            final qEnd = DateTime(now.year, qStartMonth + 3, 1);
            if (!t.createdAt.isBefore(qStart) && t.createdAt.isBefore(qEnd)) {
              if (t.type == 'income') {
                buckets[i].income += t.amount;
              } else {
                buckets[i].expense += t.amount;
              }
              placed = true;
            }
          }
        }
        break;

      case AnalyticsPeriod.custom:
        if (txns.isEmpty) {
          buckets = [];
          break;
        }
        final sorted = List<Transaction>.from(txns)..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        final first = sorted.first.createdAt;
        final last = sorted.last.createdAt;
        final monthCount = (last.year - first.year) * 12 + last.month - first.month + 1;
        buckets = List.generate(monthCount, (i) {
          final m = DateTime(first.year, first.month + i, 1);
          return _MutableBucket(DateFormat('MMM').format(m), DateFormat('yy').format(m));
        });
        for (final t in txns) {
          final idx = (t.createdAt.year - first.year) * 12 + t.createdAt.month - first.month;
          if (idx < 0 || idx >= buckets.length) continue;
          if (t.type == 'income') {
            buckets[idx].income += t.amount;
          } else {
            buckets[idx].expense += t.amount;
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

  int _periodDays() {
    final now = DateTime.now();
    switch (_period) {
      case AnalyticsPeriod.all:
        return max(now.difference(DateTime(now.year - 1, now.month, now.day)).inDays, 1);
      case AnalyticsPeriod.today:
        return 1;
      case AnalyticsPeriod.week:
        return 7;
      case AnalyticsPeriod.month:
        return now.day;
      case AnalyticsPeriod.lastMonth:
        final lastMonthStart = DateTime(now.year, now.month - 1, 1);
        final thisMonthStart = DateTime(now.year, now.month, 1);
        return thisMonthStart.difference(lastMonthStart).inDays;
      case AnalyticsPeriod.threeMonths:
        return now
            .difference(DateTime(now.year, now.month - 2, 1))
            .inDays
            .clamp(1, 92);
      case AnalyticsPeriod.year:
        return now.difference(DateTime(now.year, 1, 1)).inDays.clamp(1, 366);
      case AnalyticsPeriod.custom:
        final range = ref.read(customDateRangeProvider);
        if (range == null) return 1;
        return range.end.difference(range.start).inDays.clamp(1, 3650);
    }
  }

  // ---- format helpers -----------------------------------------------------

  String _formatAmount(double v) {
    final symbol = ref.read(currencyProvider).symbol;
    if (v >= 100000) {
      return '$symbol${(v / 1000).toStringAsFixed(0)}K';
    }
    return '$symbol${v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2)}';
  }

  String _formatPercent(double v) => '${v.toStringAsFixed(1)}%';



  // ---- build --------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final periodTxns = ref.watch(analyticsTransactionsProvider(_period));
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
    final buckets = _buildPeriodBuckets(periodTxns);

    // Category totals (expense only)
    final catMap = <int, double>{};
    for (final t in periodTxns) {
      if (t.type != 'expense') continue;
      final catId = int.tryParse(t.categoryId) ?? -1;
      catMap[catId] = (catMap[catId] ?? 0) + t.amount;
    }
    final catTotals = catMap.entries
        .where((e) => categoryMap.containsKey(e.key))
        .map((e) => _CatTotal(
              categoryMap[e.key]!,
              e.value,
              totalExpense > 0 ? e.value / totalExpense * 100 : 0,
            ))
        .toList()
      ..sort((a, b) => b.expense.compareTo(a.expense));

    // Key stats
    final days = _periodDays();
    final avgDaily = totalExpense / days;
    final largestExpense = periodTxns
        .where((t) => t.type == 'expense')
        .fold<double>(0, (prev, t) => max(prev, t.amount));
    final largestIncome = periodTxns
        .where((t) => t.type == 'income')
        .fold<double>(0, (prev, t) => max(prev, t.amount));
    final expenseRatio =
        totalIncome > 0 ? (totalExpense / totalIncome * 100) : 0.0;
    final savingsRate =
        totalIncome > 0 ? ((totalIncome - totalExpense) / totalIncome * 100).clamp(0.0, 100.0) : 0.0;

    // Top 5 biggest transactions (filtered by tab)
    final biggestType = _biggestTab == 0 ? 'expense' : 'income';
    final biggest = periodTxns
        .where((t) => t.type == biggestType)
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final top5 = biggest.take(5).toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KuberAppBar(title: 'Analytics'),
            const SizedBox(height: KuberSpacing.sm),

            // [A] Period selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: AnalyticsPeriod.values.map((p) {
                  final isCustom = p == AnalyticsPeriod.custom;
                  final isCustomActive = isCustom && _period == AnalyticsPeriod.custom;
                  final label = isCustomActive
                      ? _customRangeLabel()
                      : _periodLabel(p);
                  final isSelected = _period == p;

                  return Padding(
                    padding: const EdgeInsets.only(right: KuberSpacing.sm),
                    child: _KuberFilterChip(
                      label: label,
                      selected: isSelected,
                      onTap: isCustom
                          ? () => _pickCustomRange()
                          : () {
                              if (_period == p) return;
                              setState(() {
                                _period = p;
                                _selectedDonutSliceIndex = null;
                              });
                            },
                      icon: isCustom
                          ? Icon(Icons.date_range, size: 14,
                              color: isSelected ? cs.primary : cs.onSurfaceVariant)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: KuberSpacing.lg),

            // If no data for this period, show inline empty state
            if (isEmpty) ...[
              const SizedBox(height: KuberSpacing.xl),
              const EmptyState(
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
              currencySymbol: ref.watch(currencyProvider).symbol,
            ),
            const SizedBox(height: KuberSpacing.lg),

            // [D] Spending by Category (donut)
            if (catTotals.isNotEmpty) ...[
              _AnalyticsCard(
                title: 'Spending by Category',
                child: Column(
                  children: [
                    SizedBox(
                      height: 220,
                      child: _buildDonutChart(catTotals, colorScheme),
                    ),
                    const SizedBox(height: KuberSpacing.sm),
                    Wrap(
                      spacing: KuberSpacing.lg,
                      runSpacing: KuberSpacing.xs,
                      children: catTotals.take(6).map((ct) {
                        final color = harmonizeCategory(
                            context, Color(ct.category.colorValue));
                        return _ChartLegend(color: color, label: ct.category.name);
                      }).toList(),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _selectedDonutSliceIndex != null &&
                              _selectedDonutSliceIndex! < catTotals.length
                          ? _DonutDetailPanel(
                              catTotal: catTotals[_selectedDonutSliceIndex!],
                              transactions: periodTxns,
                              formatAmount: _formatAmount,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: KuberSpacing.lg),
            ],

            // [E] Top Categories
            if (catTotals.isNotEmpty) ...[
              _AnalyticsCard(
                title: 'Top Categories',
                child: Column(
                  children: catTotals.take(5).map((ct) {
                    final color = harmonizeCategory(
                        context, Color(ct.category.colorValue));
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: KuberSpacing.md),
                      child: Row(
                        children: [
                          CategoryIcon.square(
                            icon:
                                IconMapper.fromString(ct.category.icon),
                            rawColor: color,
                            size: 36,
                          ),
                          const SizedBox(width: KuberSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      ct.category.name,
                                      style: textTheme.bodyMedium,
                                    ),
                                    Text(
                                      _formatAmount(ct.expense),
                                      style: textTheme.bodyMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: KuberSpacing.xs),
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: catTotals.first.expense > 0
                                        ? ct.expense /
                                            catTotals.first.expense
                                        : 0,
                                    backgroundColor:
                                        color.withValues(alpha: 0.15),
                                    color: color,
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: KuberSpacing.lg),
            ],

            // [G] Highlights (2x3 grid)
            _AnalyticsCard(
              title: 'Highlights',
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: KuberSpacing.sm,
                crossAxisSpacing: KuberSpacing.md,
                childAspectRatio: 2.1,
                children: [
                  _StatTile(
                    label: 'Avg. Daily',
                    value: _formatAmount(avgDaily),
                    icon: Icons.calendar_today,
                    color: colorScheme.primary,
                  ),
                  _StatTile(
                    label: 'Largest Expense',
                    value: _formatAmount(largestExpense),
                    icon: Icons.trending_down,
                    color: colorScheme.error,
                  ),
                  _StatTile(
                    label: 'Largest Income',
                    value: _formatAmount(largestIncome),
                    icon: Icons.trending_up,
                    color: colorScheme.tertiary,
                  ),
                  _StatTile(
                    label: 'Expense Ratio',
                    value: _formatPercent(expenseRatio),
                    icon: Icons.pie_chart,
                    color: colorScheme.primary,
                  ),
                  _StatTile(
                    label: 'Savings Rate',
                    value: _formatPercent(savingsRate),
                    icon: Icons.savings,
                    color: colorScheme.tertiary,
                  ),
                  _StatTile(
                    label: 'Transactions',
                    value: '${periodTxns.length}',
                    icon: Icons.receipt_long,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            const SizedBox(height: KuberSpacing.lg),

            // [H] Biggest Transactions
            _AnalyticsCard(
              title: 'Biggest Transactions',
              trailing: _TabToggle(
                labels: const ['Expense', 'Income'],
                selected: _biggestTab,
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
                                '${isExpense ? '-' : '+'}${_formatAmount(t.amount)}',
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

  // ---- custom range helpers -----------------------------------------------

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: ref.read(customDateRangeProvider) ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          ),
    );
    if (range != null) {
      ref.read(customDateRangeProvider.notifier).state = range;
      setState(() {
        _period = AnalyticsPeriod.custom;
        _selectedDonutSliceIndex = null;
      });
    }
  }

  String _customRangeLabel() {
    final range = ref.read(customDateRangeProvider);
    if (range == null) return 'Custom Range';
    final fmt = DateFormat('MMM d');
    return '${fmt.format(range.start)} - ${fmt.format(range.end)}';
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
                  amount: _formatAmount(income),
                  color: cs.tertiary,
                  icon: Icons.arrow_downward,
                ),
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: _SummaryTile(
                  label: 'Expense',
                  amount: _formatAmount(expense),
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
                  '${net >= 0 ? '+' : ''}${_formatAmount(net)}',
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

  // ---- donut chart --------------------------------------------------------

  Widget _buildDonutChart(List<_CatTotal> cats, ColorScheme cs) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        pieTouchData: PieTouchData(
          touchCallback: (event, response) {
            if (event is FlTapUpEvent && response?.touchedSection != null) {
              final idx =
                  response!.touchedSection!.touchedSectionIndex;
              if (idx < 0) return;
              setState(() {
                _selectedDonutSliceIndex =
                    _selectedDonutSliceIndex == idx ? null : idx;
              });
            }
          },
        ),
        sections: List.generate(cats.length, (i) {
          final ct = cats[i];
          final isSelected = _selectedDonutSliceIndex == i;
          final color =
              harmonizeCategory(context, Color(ct.category.colorValue));
          return PieChartSectionData(
            value: ct.expense,
            color: color,
            radius: isSelected ? 60 : 50,
            title: isSelected ? ct.category.name : '',
            titleStyle: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            badgeWidget: isSelected
                ? null
                : null,
          );
        }),
      ),
    );
  }

  // ---- period label -------------------------------------------------------

  String _periodLabel(AnalyticsPeriod p) {
    switch (p) {
      case AnalyticsPeriod.all:
        return 'All';
      case AnalyticsPeriod.today:
        return 'Today';
      case AnalyticsPeriod.week:
        return 'Week';
      case AnalyticsPeriod.month:
        return 'Month';
      case AnalyticsPeriod.lastMonth:
        return 'Last Month';
      case AnalyticsPeriod.threeMonths:
        return '3 Months';
      case AnalyticsPeriod.year:
        return 'Year';
      case AnalyticsPeriod.custom:
        return 'Custom Range';
    }
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _KuberFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? icon;

  const _KuberFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? cs.primary.withValues(alpha: 0.18)
              : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabToggle extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  const _TabToggle({
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(labels.length, (i) {
          final isSelected = selected == i;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: KuberSpacing.md, vertical: KuberSpacing.xs),
              decoration: BoxDecoration(
                color: isSelected
                    ? cs.primary.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                labels[i],
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? cs.primary : cs.onSurfaceVariant,
                ),
              ),
            ),
          );
        }),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
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

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: KuberSpacing.xs),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
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


class _DetailBar extends StatelessWidget {
  final String label;
  final String amount;
  final double ratio;
  final Color color;

  const _DetailBar({
    required this.label,
    required this.amount,
    required this.ratio,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: cs.onSurfaceVariant,
              ),
            ),
            Text(
              amount,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: KuberSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: ratio.clamp(0, 1),
            backgroundColor: color.withValues(alpha: 0.15),
            color: color,
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}

class _DonutDetailPanel extends StatelessWidget {
  final _CatTotal catTotal;
  final List<Transaction> transactions;
  final String Function(double) formatAmount;

  const _DonutDetailPanel({
    required this.catTotal,
    required this.transactions,
    required this.formatAmount,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final catIdStr = catTotal.category.id.toString();
    final catTxns =
        transactions.where((t) => t.categoryId == catIdStr).toList();
    final income =
        catTxns.where((t) => t.type == 'income').fold<double>(0, (s, t) => s + t.amount);
    final expense =
        catTxns.where((t) => t.type == 'expense').fold<double>(0, (s, t) => s + t.amount);
    final maxVal = max(income, expense).clamp(1.0, double.infinity);

    return Padding(
      padding: const EdgeInsets.only(top: KuberSpacing.md),
      child: Column(
        children: [
          _DetailBar(
            label: 'Income',
            amount: formatAmount(income),
            ratio: income / maxVal,
            color: cs.tertiary,
          ),
          const SizedBox(height: KuberSpacing.sm),
          _DetailBar(
            label: 'Expense',
            amount: formatAmount(expense),
            ratio: expense / maxVal,
            color: cs.error,
          ),
          const SizedBox(height: KuberSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                ),
              ),
              Text(
                '${catTxns.length}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.md, vertical: KuberSpacing.sm),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
