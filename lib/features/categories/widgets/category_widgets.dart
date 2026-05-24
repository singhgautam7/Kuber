// Overhauled Categories screen.
//
// Replaces the body of `lib/features/more/screens/categories_screen.dart`.
// The screen-level chrome (KuberAppBar, KuberPageHeader, _showAddSelectionSheet
// helper, dialog flows for groups, _showCategoryDetails, _confirmDelete) is
// preserved unchanged — only the rendered body and the per-category row are
// new. The KPI grid is removed and replaced with the "Spend by Category" hero.
//
// New providers introduced (optional, see HANDOFF):
//   - `categorySpendBreakdownProvider(int monthOffset)` returns
//     `({double total, double trendPct, List<CategorySpendSlice> slices})`.
//
// CategorySpendSlice is small:
//   class CategorySpendSlice {
//     final int categoryId;
//     final String name;
//     final Color color;
//     final double amount;
//     CategorySpendSlice({required this.categoryId, required this.name,
//       required this.color, required this.amount});
//   }
//
// Both `categoryStatsProvider` and `budgetByCategoryProvider` continue to be
// consumed for per-row utilization.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../budgets/providers/budget_provider.dart';
import '../../categories/data/category.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, privacyModeProvider;

// ---------------------------------------------------------------------------
// Spend hero
// ---------------------------------------------------------------------------

/// Slice surfaced by the new `categorySpendBreakdownProvider` (see HANDOFF).
class CategorySpendSlice {
  final int categoryId;
  final String name;
  final Color color;
  final double amount;
  const CategorySpendSlice({
    required this.categoryId,
    required this.name,
    required this.color,
    required this.amount,
  });
}

class CategorySpendHero extends ConsumerWidget {
  /// Top 5 slices, sorted by amount descending. The 6th item "Others" is
  /// computed inside the widget if more than 5 categories were used.
  final List<CategorySpendSlice> topSlices;
  final double total;
  final double? trendPct;
  final int categoryCount;

  const CategorySpendHero({
    super.key,
    required this.topSlices,
    required this.total,
    required this.categoryCount,
    this.trendPct,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final masked = ref.watch(privacyModeProvider);

    final monthLabel = DateFormat('MMMM').format(DateTime.now());
    final top = topSlices.take(5).toList();
    final topSum = top.fold<double>(0, (a, b) => a + b.amount);
    final othersAmount = (total - topSum).clamp(0, double.infinity).toDouble();
    final hasOthers = othersAmount > 0 && categoryCount > top.length;

    Widget seg(double width, Color color) => SizedBox(
      width: width,
      child: ColoredBox(color: color),
    );

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.xl),
        border: Border.all(color: cs.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -50,
            child: IgnorePointer(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primary.withValues(alpha: 0.10),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$monthLabel Spend by Category'.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurfaceVariant,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            maskAmount(fmt.formatCurrency(total), masked),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                              letterSpacing: -0.6,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: cs.onSurfaceVariant,
                              ),
                              children: [
                                const TextSpan(text: 'across '),
                                TextSpan(
                                  text: '$categoryCount categories',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      ' · ${DateTime.now().day} day${DateTime.now().day == 1 ? '' : 's'} into $monthLabel',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (trendPct != null) _TrendChip(percent: trendPct!),
                  ],
                ),
                const SizedBox(height: 14),
                // Stacked bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 14,
                    child: Row(
                      children: [
                        for (final s in top)
                          Expanded(
                            flex: ((s.amount / total) * 1000).round().clamp(
                              1,
                              1000,
                            ),
                            child: seg(double.infinity, s.color),
                          ),
                        if (hasOthers)
                          Expanded(
                            flex: ((othersAmount / total) * 1000).round().clamp(
                              1,
                              1000,
                            ),
                            child: seg(double.infinity, cs.outlineVariant),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _LegendGrid(
                  slices: top,
                  others: hasOthers
                      ? CategorySpendSlice(
                          categoryId: -1,
                          name:
                              '${categoryCount - top.length} other${categoryCount - top.length == 1 ? '' : 's'}',
                          color: cs.outlineVariant,
                          amount: othersAmount,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendChip extends StatelessWidget {
  final double percent;
  const _TrendChip({required this.percent});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final up = percent >= 0;
    final color = up ? cs.error : cs.tertiary;
    // Note: trending UP on spend is bad — error tone is correct here.
    final bg = up
        ? cs.error.withValues(alpha: 0.12)
        : cs.tertiary.withValues(alpha: 0.12);
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 3, 8, 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(KuberRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            up ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            '${up ? '+' : '−'}${percent.abs().toStringAsFixed(0)}%',
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendGrid extends ConsumerWidget {
  final List<CategorySpendSlice> slices;
  final CategorySpendSlice? others;
  const _LegendGrid({required this.slices, this.others});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final masked = ref.watch(privacyModeProvider);

    final all = [...slices, ?others];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: all.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 8,
        childAspectRatio: 6,
      ),
      itemBuilder: (_, i) {
        final s = all[i];
        return Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: s.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                s.name,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              maskAmount(fmt.formatCurrency(s.amount), masked),
              style: GoogleFonts.inter(
                fontSize: 11,
                color: cs.onSurfaceVariant,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Category list item (overhaul)
// ---------------------------------------------------------------------------

class CategoryListItem extends ConsumerWidget {
  final Category category;
  final VoidCallback onTap;
  const CategoryListItem({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final masked = ref.watch(privacyModeProvider);

    final statsAsync = ref.watch(categoryStatsProvider);
    final stats =
        statsAsync.valueOrNull?[category.id] ??
        CategoryStats.empty(category.id);

    final budgetAsync = ref.watch(
      budgetByCategoryProvider(category.id.toString()),
    );
    final budget = budgetAsync.valueOrNull;
    final hasActiveBudget = budget != null && budget.isActive;

    final isIncome = category.effectiveType == 'income';
    final amountSpent = stats.totalSpent;
    final color = Color(category.colorValue);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KuberRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            border: Border.all(color: cs.outline),
            borderRadius: BorderRadius.circular(KuberRadius.lg),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CategoryIcon.square(
                    icon: IconMapper.fromString(category.icon),
                    rawColor: color,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        _MetaRow(
                          type: category.effectiveType,
                          txnCount: stats.transactionCount,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isIncome
                            ? '+${maskAmount(fmt.formatCurrency(amountSpent.abs()), masked)}'
                            : maskAmount(
                                fmt.formatCurrency(amountSpent),
                                masked,
                              ),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isIncome ? cs.tertiary : cs.onSurface,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (hasActiveBudget)
                        Text(
                          'of ${maskAmount(fmt.formatCurrency(budget.amount), masked)}',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if (hasActiveBudget && !isIncome) ...[
                const SizedBox(height: 10),
                _BudgetUtilization(
                  spent: amountSpent,
                  budget: budget.amount,
                  fmt: fmt,
                  masked: masked,
                ),
              ] else if (!isIncome) ...[
                const SizedBox(height: 10),
                _NoBudgetChip(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String type;
  final int txnCount;
  const _MetaRow({required this.type, required this.txnCount});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          type.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: cs.onSurfaceVariant,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 3,
          height: 3,
          decoration: BoxDecoration(
            color: cs.onSurfaceVariant.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          txnCount == 1 ? '1 txn' : '$txnCount txns',
          style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _BudgetUtilization extends StatelessWidget {
  final double spent;
  final double budget;
  final dynamic fmt;
  final bool masked;
  const _BudgetUtilization({
    required this.spent,
    required this.budget,
    required this.fmt,
    required this.masked,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pct = budget <= 0 ? 0.0 : (spent / budget);
    final isOver = pct > 1.0;
    final clampedPct = pct.clamp(0.0, 1.0);
    final fillColor = isOver
        ? cs.error
        : pct < 0.70
        ? cs.tertiary
        : pct < 0.95
        ? const Color(0xFFF59E0B)
        : cs.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            height: 4,
            child: Stack(
              children: [
                Container(color: cs.surfaceContainerHigh),
                FractionallySizedBox(
                  widthFactor: clampedPct,
                  child: Container(color: fillColor),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: isOver ? cs.error : cs.onSurfaceVariant,
                  ),
                  children: [
                    TextSpan(
                      text: '${(pct * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: isOver ? cs.error : cs.onSurface,
                      ),
                    ),
                    TextSpan(text: isOver ? ' over' : ' used'),
                  ],
                ),
              ),
            ),
            Text(
              isOver
                  ? '${maskAmount(fmt.formatCurrency(spent - budget), masked)} over'
                  : '${maskAmount(fmt.formatCurrency(budget - spent), masked)} left',
              style: GoogleFonts.inter(
                fontSize: 10.5,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NoBudgetChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KuberRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.remove_circle_outline_rounded,
              size: 12,
              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 5),
            Text(
              'No budget set',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
