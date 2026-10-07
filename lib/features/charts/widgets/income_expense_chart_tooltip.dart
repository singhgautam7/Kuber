import 'package:flutter/material.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../history/providers/history_filter_provider.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, privacyModeProvider;
import 'income_expense_chart_model.dart';

/// Floating tooltip card for the income/expense chart (screen 4c): period,
/// income, expense, divider, net, "View transactions →".
class IncomeExpenseChartTooltip extends ConsumerWidget {
  final IncomeExpensePoint point;
  final bool showViewTransactions;

  const IncomeExpenseChartTooltip({
    super.key,
    required this.point,
    this.showViewTransactions = true,
  });

  static const double width = 186;

  void _viewTransactions(BuildContext context, WidgetRef ref) {
    final d = point.date;
    if (d == null) return;
    final e = point.endDate ?? d;
    ref.read(historyFilterProvider.notifier).clearAll();
    ref
        .read(historyFilterProvider.notifier)
        .setFilters(
          from: DateTime(d.year, d.month, d.day),
          to: DateTime(e.year, e.month, e.day, 23, 59, 59),
        );
    context.go('/history');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final isPrivate = ref.watch(privacyModeProvider);
    final net = point.income - point.expense;

    // Chart tooltip (tokens.md §6): inverseSurface, radius 8, padding 8/12,
    // labelMedium inverseOnSurface; money in the inverse-safe tones.
    final money = context.kuberMoney;
    final on = cs.onInverseSurface;
    final label = Theme.of(context).textTheme.labelMedium!;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.inverseSurface,
        borderRadius: KuberShape.smallR,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(point.tooltipLabel, style: label.copyWith(color: on)),
          const SizedBox(height: 4),
          _row(
            cs,
            'Income',
            maskAmount(fmt.formatCurrency(point.income), isPrivate),
            money.inverseIncome,
            context,
          ),
          const SizedBox(height: 2),
          _row(
            cs,
            'Expense',
            maskAmount(fmt.formatCurrency(point.expense), isPrivate),
            money.inverseExpense,
            context,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Divider(
              height: 1,
              thickness: 1,
              color: on.withValues(alpha: 0.16),
            ),
          ),
          _row(
            cs,
            'Net',
            maskAmount(
              '${net < 0 ? '-' : ''}${fmt.formatCurrency(net.abs())}',
              isPrivate,
            ),
            net < 0 ? money.inverseExpense : on,
            context,
          ),
          if (showViewTransactions && point.date != null) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => _viewTransactions(context, ref),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View transactions',
                    style: label.copyWith(color: cs.inversePrimary),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: cs.inversePrimary,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(
    ColorScheme cs,
    String label,
    String amount,
    Color color,
    BuildContext context,
  ) {
    final style = Theme.of(context).textTheme.labelMedium!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: style.copyWith(
            color: cs.onInverseSurface.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(amount, style: style.copyWith(color: color)),
      ],
    );
  }
}
