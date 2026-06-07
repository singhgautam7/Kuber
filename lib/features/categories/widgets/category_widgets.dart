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

import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    // Container (rather than SizedBox + ColoredBox) so the segment expands
    // to fill both axes inside its Expanded parent. The earlier ColoredBox
    // had no intrinsic height and collapsed to 0 px under the Row's default
    // CrossAxisAlignment.center, hiding the entire stacked bar.
    Widget seg(Color color) => Container(color: color);

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.xl),
        border: Border.all(color: cs.outline),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color.alphaBlend(
              cs.primary.withValues(alpha: 0.16),
              cs.surfaceContainer,
            ),
            cs.surfaceContainer,
          ],
          stops: const [0.0, 0.75],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
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
                        style: localeFont(
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
                        style: localeFont(
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
                          style: localeFont(
                            fontSize: 11.5,
                            color: cs.onSurfaceVariant,
                          ),
                          children: [
                            const TextSpan(text: 'across '),
                            TextSpan(
                              text: '$categoryCount categories',
                              style: localeFont(
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final s in top)
                      Expanded(
                        flex: ((s.amount / total) * 1000).round().clamp(
                          1,
                          1000,
                        ),
                        child: seg(s.color),
                      ),
                    if (hasOthers)
                      Expanded(
                        flex: ((othersAmount / total) * 1000).round().clamp(
                          1,
                          1000,
                        ),
                        child: seg(cs.outlineVariant),
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
    // Per product call: tint by sign — negative percentages render in
    // error (red), positive in tertiary (green) — regardless of whether the
    // underlying metric is spend (UP = bad) or income (UP = good).
    final color = up ? cs.tertiary : cs.error;
    final bg = up
        ? cs.tertiary.withValues(alpha: 0.12)
        : cs.error.withValues(alpha: 0.12);
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
            style: localeFont(
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
                style: localeFont(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              maskAmount(fmt.formatCurrency(s.amount), masked),
              style: localeFont(
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

  /// This category's expense for the current month — sourced from the
  /// shared `txns.aggregate(filter)` helper so the row total matches the
  /// hero exactly. Pass `null` to fall back to all-time `stats.totalSpent`
  /// (income rows do this since there's no monthly income hero to align
  /// with).
  final double? thisMonthSpent;

  /// This category's transaction count for the current month. Pass `null`
  /// to fall back to all-time `stats.transactionCount`.
  final int? thisMonthTxnCount;

  /// Parent group name. Shown inline in the row's meta line so the user can
  /// see which group a category belongs to without scrolling up to the
  /// header — important when search flattens the grouped layout. Pass null
  /// for ungrouped categories.
  final String? groupName;

  const CategoryListItem({
    super.key,
    required this.category,
    required this.onTap,
    this.thisMonthSpent,
    this.thisMonthTxnCount,
    this.groupName,
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
    // Expense rows prefer this-month aggregates (consistent with the hero);
    // income rows still surface all-time stats since there's no monthly
    // income hero to align with.
    final amountSpent = isIncome
        ? stats.totalSpent
        : (thisMonthSpent ?? stats.totalSpent);
    final txnCount = isIncome
        ? stats.transactionCount
        : (thisMonthTxnCount ?? stats.transactionCount);
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
                          style: localeFont(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        _MetaRow(
                          type: category.effectiveType,
                          txnCount: txnCount,
                        ),
                        if (groupName != null && groupName!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _GroupTag(name: groupName!),
                          ),
                        ],
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
                        style: localeFont(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isIncome ? cs.tertiary : cs.onSurface,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (hasActiveBudget)
                        Text(
                          'of ${maskAmount(fmt.formatCurrency(budget.amount), masked)}',
                          style: localeFont(
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
                const _NoBudgetChip(),
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
          style: localeFont(
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
          style: localeFont(fontSize: 11, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Folder-icon chip below the meta row that surfaces the parent group of a
/// category. Lives on its own line so a long group name doesn't have to
/// compete with TYPE / txn count / the amount column for width.
class _GroupTag extends StatelessWidget {
  final String name;
  const _GroupTag({required this.name});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.folder_outlined,
            size: 10,
            color: cs.onSurfaceVariant.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: localeFont(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
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
        ? context.kuberColors.warning
        : cs.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                Container(color: cs.outline.withValues(alpha: 0.55)),
                FractionallySizedBox(
                  widthFactor: clampedPct,
                  child: Container(color: fillColor),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: localeFont(
                    fontSize: 10.5,
                    color: isOver ? cs.error : cs.onSurfaceVariant,
                  ),
                  children: [
                    TextSpan(
                      text: '${(pct * 100).toStringAsFixed(0)}%',
                      style: localeFont(
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
              style: localeFont(
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
  const _NoBudgetChip();

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
              context.l10n.noBudgetSet,
              style: localeFont(
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