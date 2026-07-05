import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/locale_font.dart';
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
    ref.read(historyFilterProvider.notifier).setFilters(
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

    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.primary),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            point.tooltipLabel,
            style: localeFont(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 7),
          _row(cs, 'Income',
              maskAmount(fmt.formatCurrency(point.income), isPrivate),
              cs.tertiary),
          const SizedBox(height: 4),
          _row(cs, 'Expense',
              maskAmount(fmt.formatCurrency(point.expense), isPrivate),
              cs.error),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Divider(height: 1, thickness: 1, color: cs.outline),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Net',
                  style: localeFont(
                      fontSize: 11.5, color: cs.onSurfaceVariant)),
              Text(
                maskAmount(
                  '${net < 0 ? '-' : ''}${fmt.formatCurrency(net.abs())}',
                  isPrivate,
                ),
                style: localeFont(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: net < 0 ? cs.error : cs.primary,
                ),
              ),
            ],
          ),
          if (showViewTransactions && point.date != null) ...[
            const SizedBox(height: 9),
            GestureDetector(
              onTap: () => _viewTransactions(context, ref),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View transactions',
                    style: localeFont(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(Icons.arrow_forward_rounded,
                      size: 11, color: cs.primary),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(ColorScheme cs, String label, String amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: localeFont(fontSize: 11.5, color: cs.onSurfaceVariant)),
        Text(
          amount,
          style: localeFont(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
