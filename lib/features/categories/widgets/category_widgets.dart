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

import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import '../../../shared/widgets/kuber_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
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
    Widget seg(Color color) => Container(
      decoration: BoxDecoration(color: color, borderRadius: KuberShape.fullR),
    );

    final tt = Theme.of(context).textTheme;
    // Board 3.16: "SEPTEMBER · SPENT", headlineMedium amount, gapped 8 bar,
    // then the top three as name + share.
    final legend = top.take(3).toList();
    return KuberCard(
      hero: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$monthLabel · SPENT'.toUpperCase(),
            style: tt.labelMedium!.copyWith(
              letterSpacing: 0.8,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            maskAmount(fmt.formatCurrency(total), masked),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.headlineMedium!.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: KuberSpace.md),
          SizedBox(
            height: 8,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, sl) in top.indexed) ...[
                  if (i > 0) const SizedBox(width: 4),
                  Expanded(
                    flex: ((sl.amount / total) * 1000).round().clamp(1, 1000),
                    child: seg(categoryVizColor(context, sl.color)),
                  ),
                ],
                if (hasOthers) ...[
                  const SizedBox(width: 4),
                  Expanded(
                    flex: ((othersAmount / total) * 1000).round().clamp(
                      1,
                      1000,
                    ),
                    child: seg(cs.outline),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: KuberSpace.md),
          Wrap(
            spacing: KuberSpace.lg,
            runSpacing: KuberSpace.sm,
            children: [
              for (final sl in legend)
                SizedBox(
                  width: 130,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: categoryVizColor(context, sl.color),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          sl.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.bodySmall!.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        total <= 0
                            ? '0%'
                            : '${(sl.amount / total * 100).round()}%',
                        style: tt.labelLarge!.copyWith(color: cs.onSurface),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One category row inside a group (board 3.16): 40 tile in the re-toned
/// category colour, name, "N transactions" (· group in search results),
/// amount on the right with a Budget pill when a budget is active.
class CategoryListItem extends ConsumerWidget {
  final Category category;
  final VoidCallback onTap;

  final double? thisMonthSpent;

  final int? thisMonthTxnCount;

  /// Shown on the supporting line (search results, where rows from many
  /// groups mix).
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final fmt = ref.watch(formatterProvider);
    final masked = ref.watch(privacyModeProvider);

    final statsAsync = ref.watch(categoryStatsProvider);
    final stats =
        statsAsync.valueOrNull?[category.id] ??
        CategoryStats.empty(category.id);

    final budget = ref
        .watch(budgetByCategoryProvider(category.id.toString()))
        .valueOrNull;
    final hasActiveBudget = budget != null && budget.isActive;

    final isIncome = category.effectiveType == 'income';
    final amountSpent = isIncome
        ? stats.totalSpent
        : (thisMonthSpent ?? stats.totalSpent);
    final txnCount = isIncome
        ? stats.transactionCount
        : (thisMonthTxnCount ?? stats.transactionCount);

    final sub = [
      context.l10n.nTransactions(txnCount),
      if (groupName != null && groupName!.isNotEmpty) groupName!,
    ].join(' · ');

    return KuberListRow(
      onTap: onTap,
      leading: CategoryIcon.square(
        icon: IconMapper.fromString(category.icon),
        rawColor: Color(category.colorValue),
        size: 40,
      ),
      title: category.name,
      subtitle: sub,
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            isIncome
                ? '+${maskAmount(fmt.formatCurrency(amountSpent.abs()), masked)}'
                : maskAmount(fmt.formatCurrency(amountSpent), masked),
            style: theme.textTheme.titleMedium!.copyWith(
              color: isIncome ? context.kuberMoney.income : cs.onSurface,
            ),
          ),
          if (hasActiveBudget && !isIncome) ...[
            const SizedBox(height: 4),
            KuberPill(label: context.l10n.budgetLabel),
          ],
        ],
      ),
    );
  }
}
