import 'package:collection/collection.dart';

import '../../transactions/helpers/transaction_filters.dart';
import '../models/handler_result.dart';
import '../models/query_context.dart';
import '../models/thinking_info.dart';
import 'query_handler.dart';

/// Spending queries: category-specific spend, relative ranges, and the
/// today/week/last-month/this-month/this-year period totals. Ported verbatim
/// from `_processQuery` (preserving order and fall-through), currency rounded
/// to whole numbers via [QueryContext.money].
class SpendingHandler extends QueryHandler {
  const SpendingHandler();

  bool _mentionsSpend(String lower) =>
      lower.contains('spent') ||
      lower.contains('spend') ||
      lower.contains('expense');

  @override
  Future<HandlerResult?> tryHandle(QueryContext ctx) async {
    final lower = ctx.lower;
    // Budget-intent queries ("am I overspending on food", "over budget on X")
    // defer to BudgetsHandler, which renders a budget-status visualization.
    // Without this, "overspending" (contains "spend") would be swallowed here
    // as plain category spend.
    if (lower.contains('overspend') ||
        lower.contains('budget') ||
        lower.contains('spending limit')) {
      return null;
    }
    if (!_mentionsSpend(lower)) return null;

    // Category-specific spending.
    if (!(lower.contains('top') || lower.contains('most'))) {
      final matchedCat = ctx.categories
          .where((c) =>
              c.name.trim().isNotEmpty && lower.contains(c.name.toLowerCase()))
          .firstOrNull;

      if (matchedCat != null) {
        final catCustomRange = ctx.extractor.customRange(lower);
        final DateTime from;
        final DateTime to;
        final String dateLabel;
        final String thinkingDate;

        if (catCustomRange != null) {
          from = catCustomRange.from;
          to = catCustomRange.to;
          dateLabel = 'in the past ${catCustomRange.label}';
          thinkingDate =
              '${ctx.fmtDate(catCustomRange.from)} – ${ctx.fmtDate(catCustomRange.to.subtract(const Duration(days: 1)))}';
        } else if (lower.contains('this year')) {
          from = ctx.yearStart;
          to = ctx.yearEnd;
          dateLabel = 'this year';
          thinkingDate = '${ctx.fmtDate(ctx.yearStart)} – ${ctx.fmtDate(ctx.today)}';
        } else if (lower.contains('last month')) {
          from = ctx.lastMonthStart;
          to = ctx.lastMonthEnd;
          dateLabel = 'last month';
          thinkingDate =
              '${ctx.fmtDate(ctx.lastMonthStart)} – ${ctx.fmtDate(ctx.lastMonthEnd.subtract(const Duration(days: 1)))}';
        } else if (lower.contains('last week')) {
          final lastWeekStart = ctx.weekStart.subtract(const Duration(days: 7));
          from = lastWeekStart;
          to = ctx.weekStart;
          dateLabel = 'last week';
          thinkingDate =
              '${ctx.fmtDate(lastWeekStart)} – ${ctx.fmtDate(ctx.weekStart.subtract(const Duration(days: 1)))}';
        } else if (lower.contains('today')) {
          from = ctx.today;
          to = ctx.today.add(const Duration(days: 1));
          dateLabel = 'today';
          thinkingDate = ctx.fmtDate(ctx.today);
        } else if (lower.contains('week')) {
          from = ctx.weekStart;
          to = ctx.today.add(const Duration(days: 1));
          dateLabel = 'this week';
          thinkingDate = '${ctx.fmtDate(ctx.weekStart)} – ${ctx.fmtDate(ctx.today)}';
        } else if (lower.contains('month')) {
          from = ctx.monthStart;
          to = ctx.monthEnd;
          dateLabel = 'this month';
          thinkingDate = '${ctx.fmtDate(ctx.monthStart)} – ${ctx.fmtDate(ctx.today)}';
        } else {
          from = DateTime(2000);
          to = ctx.today.add(const Duration(days: 1));
          dateLabel = 'overall';
          thinkingDate = 'All time';
        }

        final total = ctx.txns.validForCalculations
            .where((t) =>
                t.type == 'expense' &&
                t.categoryId == matchedCat.id.toString() &&
                !t.createdAt.isBefore(from) &&
                t.createdAt.isBefore(to))
            .fold(0.0, (sum, t) => sum + t.amount);

        final verb = (dateLabel == 'today' ||
                dateLabel == 'this week' ||
                dateLabel == 'this month' ||
                dateLabel == 'this year')
            ? "You've spent"
            : 'You spent';
        final suffix = dateLabel == 'overall' ? 'in total' : dateLabel;

        return HandlerResult(
          text: '$verb ${ctx.money(total)} on ${matchedCat.name} $suffix.',
          thinking: ThinkingInfo(
            dateFilter: thinkingDate,
            scanned: ['Transactions', 'Categories (${matchedCat.name})'],
          ),
        );
      }
    }

    // Custom date range ("past two weeks", "last 3 months").
    final customRange = ctx.extractor.customRange(lower);
    if (customRange != null) {
      final total = ctx.sumExpenses(customRange.from, customRange.to);
      return HandlerResult(
        text: 'You spent ${ctx.money(total)} in the past ${customRange.label}.',
        thinking: ThinkingInfo(
          dateFilter:
              '${ctx.fmtDate(customRange.from)} – ${ctx.fmtDate(customRange.to)}',
          scanned: const ['Transactions'],
        ),
      );
    }

    // Expenses today.
    if (lower.contains('today') || lower.contains('day')) {
      final total = ctx.sumExpenses(ctx.today, ctx.today.add(const Duration(days: 1)));
      return HandlerResult(
        text: "You've spent ${ctx.money(total)} today.",
        thinking: ThinkingInfo(
          dateFilter: ctx.fmtDate(ctx.today),
          scanned: const ['Transactions'],
        ),
      );
    }

    // Expenses this week. (Original requires spent|spend here, not "expense".)
    if (lower.contains('week') &&
        !lower.contains('last') &&
        (lower.contains('spent') || lower.contains('spend'))) {
      final total =
          ctx.sumExpenses(ctx.weekStart, ctx.today.add(const Duration(days: 1)));
      return HandlerResult(
        text: "You've spent ${ctx.money(total)} this week.",
        thinking: ThinkingInfo(
          dateFilter: '${ctx.fmtDate(ctx.weekStart)} – ${ctx.fmtDate(ctx.today)}',
          scanned: const ['Transactions'],
        ),
      );
    }

    // Expenses last month. (Original requires spent|spend here, not "expense".)
    if (lower.contains('last month') &&
        (lower.contains('spent') || lower.contains('spend'))) {
      final total = ctx.sumExpenses(ctx.lastMonthStart, ctx.lastMonthEnd);
      return HandlerResult(
        text: 'You spent ${ctx.money(total)} last month.',
        thinking: ThinkingInfo(
          dateFilter:
              '${ctx.fmtDate(ctx.lastMonthStart)} – ${ctx.fmtDate(ctx.lastMonthEnd.subtract(const Duration(days: 1)))}',
          scanned: const ['Transactions'],
        ),
      );
    }

    // Expenses this month.
    if ((lower.contains('month') || lower.contains('this month')) &&
        !lower.contains('last')) {
      final total = ctx.sumExpenses(ctx.monthStart, ctx.monthEnd);
      final count = ctx.txns.validForCalculations
          .where((t) =>
              t.type == 'expense' &&
              !t.createdAt.isBefore(ctx.monthStart) &&
              t.createdAt.isBefore(ctx.monthEnd))
          .length;
      return HandlerResult(
        text:
            "You've spent ${ctx.money(total)} this month across $count transactions.",
        thinking: ThinkingInfo(
          dateFilter: '${ctx.fmtDate(ctx.monthStart)} – ${ctx.fmtDate(ctx.today)}',
          scanned: const ['Transactions'],
        ),
      );
    }

    // Expenses this year.
    if (lower.contains('this year')) {
      final total = ctx.sumExpenses(ctx.yearStart, ctx.yearEnd);
      final count = ctx.txns.validForCalculations
          .where((t) =>
              t.type == 'expense' &&
              !t.createdAt.isBefore(ctx.yearStart) &&
              t.createdAt.isBefore(ctx.yearEnd))
          .length;
      return HandlerResult(
        text:
            "You've spent ${ctx.money(total)} this year across $count transactions.",
        thinking: ThinkingInfo(
          dateFilter: '${ctx.fmtDate(ctx.yearStart)} – ${ctx.fmtDate(ctx.today)}',
          scanned: const ['Transactions'],
        ),
      );
    }

    return null;
  }
}
