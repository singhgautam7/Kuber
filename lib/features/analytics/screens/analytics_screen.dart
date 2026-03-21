import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../categories/data/category.dart';
import '../../categories/providers/category_provider.dart';
import '../../transactions/data/transaction.dart';
import '../providers/analytics_provider.dart';

// ---------------------------------------------------------------------------
// Private data classes
// ---------------------------------------------------------------------------

class _Bucket {
  final String label;
  double income = 0;
  double expense = 0;
  _Bucket(this.label);
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
  int? _selectedTrendBarIndex;
  int? _selectedDonutSliceIndex;
  int _biggestTab = 0; // 0 = expense, 1 = income

  // ---- bucket helpers -----------------------------------------------------

  List<_Bucket> _buildBuckets(List<Transaction> txns) {
    final now = DateTime.now();
    switch (_period) {
      case AnalyticsPeriod.today:
        // 5 named time-of-day slots
        final slotLabels = ['Dawn', 'Morning', 'Noon', 'Evening', 'Night'];
        final buckets = slotLabels.map((l) => _Bucket(l)).toList();
        for (final t in txns) {
          final h = t.createdAt.hour;
          int idx;
          if (h < 6) {
            idx = 0; // Dawn 00-05
          } else if (h < 11) {
            idx = 1; // Morning 06-10
          } else if (h < 14) {
            idx = 2; // Noon 11-13
          } else if (h < 19) {
            idx = 3; // Evening 14-18
          } else {
            idx = 4; // Night 19-23
          }
          if (t.type == 'income') {
            buckets[idx].income += t.amount;
          } else {
            buckets[idx].expense += t.amount;
          }
        }
        return buckets;

      case AnalyticsPeriod.week:
        final buckets = List.generate(7, (i) {
          final d = now.subtract(Duration(days: 6 - i));
          return _Bucket(DateFormat.E().format(d));
        });
        for (final t in txns) {
          final diff = now.difference(t.createdAt).inDays;
          if (diff < 0 || diff > 6) continue;
          final idx = 6 - diff;
          if (t.type == 'income') {
            buckets[idx].income += t.amount;
          } else {
            buckets[idx].expense += t.amount;
          }
        }
        return buckets;

      case AnalyticsPeriod.month:
      case AnalyticsPeriod.lastMonth:
        final buckets = List.generate(5, (i) => _Bucket('W${i + 1}'));
        for (final t in txns) {
          final week = ((t.createdAt.day - 1) / 7).floor();
          final idx = week.clamp(0, 4);
          if (t.type == 'income') {
            buckets[idx].income += t.amount;
          } else {
            buckets[idx].expense += t.amount;
          }
        }
        return buckets;

      case AnalyticsPeriod.threeMonths:
        final buckets = List.generate(3, (i) {
          final m = DateTime(now.year, now.month - 2 + i, 1);
          return _Bucket(DateFormat.MMM().format(m));
        });
        for (final t in txns) {
          final monthDiff = (now.year - t.createdAt.year) * 12 +
              now.month -
              t.createdAt.month;
          final idx = 2 - monthDiff;
          if (idx < 0 || idx > 2) continue;
          if (t.type == 'income') {
            buckets[idx].income += t.amount;
          } else {
            buckets[idx].expense += t.amount;
          }
        }
        return buckets;

      case AnalyticsPeriod.year:
        // 4 quarterly buckets for the current year
        final buckets = List.generate(4, (i) => _Bucket('Q${i + 1}'));
        for (final t in txns) {
          if (t.createdAt.year != now.year) continue;
          final idx = ((t.createdAt.month - 1) / 3).floor();
          if (t.type == 'income') {
            buckets[idx].income += t.amount;
          } else {
            buckets[idx].expense += t.amount;
          }
        }
        return buckets;

      case AnalyticsPeriod.all:
        // Last 4 quarters
        final buckets = List.generate(4, (i) {
          final qOffset = 3 - i; // 3, 2, 1, 0
          final qStartMonth = now.month - qOffset * 3;
          final qStart = DateTime(now.year, qStartMonth, 1);
          final label = "${DateFormat.MMM().format(qStart)}'${DateFormat('yy').format(qStart)}";
          return _Bucket(label);
        });
        for (final t in txns) {
          // Determine which quarter bucket this transaction falls into
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
        return buckets;

      case AnalyticsPeriod.custom:
        // Group by month across custom range
        if (txns.isEmpty) return [];
        final sorted = List<Transaction>.from(txns)
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        final first = sorted.first.createdAt;
        final last = sorted.last.createdAt;
        final monthCount = (last.year - first.year) * 12 +
            last.month -
            first.month +
            1;
        final cBuckets = List.generate(monthCount, (i) {
          final m = DateTime(first.year, first.month + i, 1);
          return _Bucket(DateFormat('MMM yy').format(m));
        });
        for (final t in txns) {
          final idx = (t.createdAt.year - first.year) * 12 +
              t.createdAt.month -
              first.month;
          if (idx < 0 || idx >= cBuckets.length) continue;
          if (t.type == 'income') {
            cBuckets[idx].income += t.amount;
          } else {
            cBuckets[idx].expense += t.amount;
          }
        }
        return cBuckets;
    }
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
    if (v >= 100000) {
      return '₹${(v / 1000).toStringAsFixed(0)}K';
    }
    return '₹${v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2)}';
  }

  String _formatPercent(double v) => '${v.toStringAsFixed(1)}%';

  String _formatYAxis(double value) {
    if (value >= 10000000) {
      final cr = value / 10000000;
      return '₹${cr.toStringAsFixed(cr.truncateToDouble() == cr ? 0 : 1)}Cr';
    }
    if (value >= 100000) {
      final l = value / 100000;
      return '₹${l.toStringAsFixed(l.truncateToDouble() == l ? 0 : 1)}L';
    }
    if (value >= 1000) {
      final k = value / 1000;
      return '₹${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}k';
    }
    return '₹${value.toInt()}';
  }

  // ---- build --------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final periodTxns = ref.watch(analyticsTransactionsProvider(_period));
    final categoryMap = ref.watch(categoryMapProvider).valueOrNull ?? {};

    final colorScheme = Theme.of(context).colorScheme;
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
    final buckets = _buildBuckets(periodTxns);

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
                    child: isCustom
                        ? FilterChip.elevated(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.date_range, size: 14,
                                  color: isSelected ? KuberColors.primary : KuberColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(label),
                              ],
                            ),
                            selected: isSelected,
                            onSelected: (_) => _pickCustomRange(),
                            side: BorderSide(
                              color: isSelected
                                  ? KuberColors.primary.withValues(alpha: 0.5)
                                  : KuberColors.surfaceDivider,
                            ),
                            backgroundColor: KuberColors.surfaceElement,
                            selectedColor: KuberColors.primary.withValues(alpha: 0.12),
                            labelStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? KuberColors.primary : KuberColors.textSecondary,
                            ),
                            elevation: 0,
                            pressElevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          )
                        : FilterChip(
                            label: Text(label),
                            selected: isSelected,
                            onSelected: (val) {
                              if (_period == p) return;
                              setState(() {
                                _period = p;
                                _selectedTrendBarIndex = null;
                                _selectedDonutSliceIndex = null;
                              });
                            },
                            labelStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? KuberColors.primary : KuberColors.textSecondary,
                            ),
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
                subtitle: 'No transactions found for this period',
              ),
            ] else ...[

            // [B] Summary Card
            _buildSummaryCard(
                colorScheme, textTheme, totalIncome, totalExpense, netAmount),
            const SizedBox(height: KuberSpacing.lg),

            // [C] Spending Trend
            _AnalyticsCard(
              title: 'Spending Trend',
              child: Column(
                children: [
                  Builder(
                    builder: (context) {
                      final needsScroll = buckets.length > 7;
                      final chartWidth = needsScroll
                          ? buckets.length * 60.0
                          : null; // null = fill parent
                      final chart = SizedBox(
                        height: 200,
                        width: chartWidth,
                        child: _buildTrendChart(buckets, colorScheme),
                      );
                      if (needsScroll) {
                        return SizedBox(
                          height: 200,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            reverse: true, // start from the latest month
                            child: chart,
                          ),
                        );
                      }
                      return chart;
                    },
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _selectedTrendBarIndex != null &&
                            _selectedTrendBarIndex! < buckets.length
                        ? _TrendDetailPanel(
                            bucket: buckets[_selectedTrendBarIndex!],
                            formatAmount: _formatAmount,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
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
                          CategoryIcon.circle(
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
                mainAxisSpacing: KuberSpacing.md,
                crossAxisSpacing: KuberSpacing.md,
                childAspectRatio: 1.5,
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
                            color: KuberColors.textSecondary,
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
                                CategoryIcon.circle(
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

            const SizedBox(height: 100),
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
        _selectedTrendBarIndex = null;
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
        color: KuberColors.card,
        borderRadius: BorderRadius.circular(16),
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
                  color: KuberColors.income,
                  icon: Icons.arrow_downward,
                ),
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: _SummaryTile(
                  label: 'Expense',
                  amount: _formatAmount(expense),
                  color: KuberColors.expense,
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
              color: KuberColors.cardLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Net: ',
                  style: GoogleFonts.plusJakartaSans(
                    color: KuberColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${net >= 0 ? '+' : ''}${_formatAmount(net)}',
                  style: GoogleFonts.plusJakartaSans(
                    color: net >= 0 ? KuberColors.income : KuberColors.expense,
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

  // ---- trend chart --------------------------------------------------------

  Widget _buildTrendChart(List<_Bucket> buckets, ColorScheme cs) {
    if (buckets.isEmpty) return const SizedBox.shrink();

    final maxVal = buckets.fold<double>(
        0, (m, b) => max(m, max(b.income, b.expense)));

    return BarChart(
      BarChartData(
        maxY: maxVal * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBorderRadius: BorderRadius.circular(8),
            getTooltipItem: (_, _, rod, _) => null,
          ),
          touchCallback: (event, response) {
            if (event is FlTapUpEvent && response?.spot != null) {
              final idx = response!.spot!.touchedBarGroupIndex;
              setState(() {
                _selectedTrendBarIndex =
                    _selectedTrendBarIndex == idx ? null : idx;
              });
            }
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: maxVal > 0 ? (maxVal * 1.2 / 3).ceilToDouble() : 1.0,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  _formatYAxis(value),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: KuberColors.textSecondary,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) {
                final idx = val.toInt();
                if (idx < 0 || idx >= buckets.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    buckets[idx].label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: KuberColors.textSecondary,
                    ),
                  ),
                );
              },
              reservedSize: 24,
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(buckets.length, (i) {
          final b = buckets[i];
          final isSelected =
              _selectedTrendBarIndex == null || _selectedTrendBarIndex == i;
          final alpha = isSelected ? 1.0 : 0.45;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: b.income,
                color: KuberColors.income.withValues(alpha: alpha),
                width: 14,
                borderRadius: BorderRadius.circular(4),
              ),
              BarChartRodData(
                toY: b.expense,
                color: cs.error.withValues(alpha: alpha),
                width: 14,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
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
            titleStyle: GoogleFonts.plusJakartaSans(
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
        color: KuberColors.cardLight,
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
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? cs.primary : KuberColors.textSecondary,
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
    final tt = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KuberSpacing.lg),
      decoration: BoxDecoration(
        color: KuberColors.card,
        borderRadius: BorderRadius.circular(16),
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
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: KuberColors.textSecondary,
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
    return Container(
      padding: const EdgeInsets.all(KuberSpacing.md),
      decoration: BoxDecoration(
        color: KuberColors.cardLight,
        borderRadius: BorderRadius.circular(12),
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
                style: GoogleFonts.plusJakartaSans(
                  color: KuberColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpacing.xs),
          Text(
            amount,
            style: GoogleFonts.plusJakartaSans(
              color: KuberColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendDetailPanel extends StatelessWidget {
  final _Bucket bucket;
  final String Function(double) formatAmount;

  const _TrendDetailPanel({
    required this.bucket,
    required this.formatAmount,
  });

  @override
  Widget build(BuildContext context) {
    final net = bucket.income - bucket.expense;
    final maxVal = max(bucket.income, bucket.expense).clamp(1.0, double.infinity);
    return Padding(
      padding: const EdgeInsets.only(top: KuberSpacing.md),
      child: Column(
        children: [
          _DetailBar(
            label: 'Income',
            amount: formatAmount(bucket.income),
            ratio: bucket.income / maxVal,
            color: KuberColors.income,
          ),
          const SizedBox(height: KuberSpacing.sm),
          _DetailBar(
            label: 'Expense',
            amount: formatAmount(bucket.expense),
            ratio: bucket.expense / maxVal,
            color: KuberColors.expense,
          ),
          const SizedBox(height: KuberSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: KuberColors.textSecondary,
                ),
              ),
              Text(
                '${net >= 0 ? '+' : ''}${formatAmount(net)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: net >= 0 ? KuberColors.income : KuberColors.expense,
                ),
              ),
            ],
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: KuberColors.textSecondary,
              ),
            ),
            Text(
              amount,
              style: GoogleFonts.plusJakartaSans(
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
            color: KuberColors.income,
          ),
          const SizedBox(height: KuberSpacing.sm),
          _DetailBar(
            label: 'Expense',
            amount: formatAmount(expense),
            ratio: expense / maxVal,
            color: KuberColors.expense,
          ),
          const SizedBox(height: KuberSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: KuberColors.textSecondary,
                ),
              ),
              Text(
                '${catTxns.length}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: KuberColors.textPrimary,
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
    return Container(
      padding: const EdgeInsets.all(KuberSpacing.md),
      decoration: BoxDecoration(
        color: KuberColors.cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: KuberColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: KuberColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
