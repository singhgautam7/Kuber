import '../models/handler_result.dart';
import '../models/query_context.dart';
import '../models/thinking_info.dart';
import 'query_handler.dart';
import 'thinking_steps.dart';

/// "How many ..." counts: transactions (today/week/month/total), expense/income
/// transaction counts, account count, category count. Ported verbatim - note
/// these use the raw list (transfers included, balance adjustments excluded),
/// not `validForCalculations`.
class CountsHandler extends QueryHandler {
  const CountsHandler();

  ThinkingInfo _think(String range, int n, String item) => ThinkingInfo(
        dateFilter: range,
        scanned: const ['Transactions'],
        steps: [
          intentStep('count', range),
          scannedStep(n, item),
          resultStep('Counted **$n ${n == 1 ? _singular(item) : item}**.'),
        ],
      );

  static String _singular(String w) =>
      w.endsWith('ies') ? '${w.substring(0, w.length - 3)}y' : (w.endsWith('s') ? w.substring(0, w.length - 1) : w);

  @override
  Future<HandlerResult?> tryHandle(QueryContext ctx) async {
    final lower = ctx.lower;
    if (!lower.contains('how many')) return null;
    final txns = ctx.txns;

    // Transaction count - today.
    if (lower.contains('transaction') && lower.contains('today')) {
      final count = txns
          .where((t) =>
              !t.isBalanceAdjustment &&
              !t.createdAt.isBefore(ctx.today) &&
              t.createdAt.isBefore(ctx.today.add(const Duration(days: 1))))
          .length;
      return HandlerResult(
        text: 'You made $count transaction${count == 1 ? '' : 's'} today.',
        thinking: _think(ctx.fmtDate(ctx.today), count, 'transactions'),
      );
    }

    // Transaction count - this week.
    if (lower.contains('transaction') && lower.contains('week')) {
      final count = txns
          .where((t) =>
              !t.isBalanceAdjustment &&
              !t.createdAt.isBefore(ctx.weekStart) &&
              t.createdAt.isBefore(ctx.today.add(const Duration(days: 1))))
          .length;
      return HandlerResult(
        text: 'You made $count transaction${count == 1 ? '' : 's'} this week.',
        thinking: _think(
            '${ctx.fmtDate(ctx.weekStart)} – ${ctx.fmtDate(ctx.today)}',
            count,
            'transactions'),
      );
    }

    // Transaction count - this month.
    if (lower.contains('transaction') && lower.contains('month')) {
      final count = txns
          .where((t) =>
              !t.isBalanceAdjustment &&
              !t.createdAt.isBefore(ctx.monthStart) &&
              t.createdAt.isBefore(ctx.monthEnd))
          .length;
      return HandlerResult(
        text: 'You made $count transaction${count == 1 ? '' : 's'} this month.',
        thinking: _think(
            '${ctx.fmtDate(ctx.monthStart)} – ${ctx.fmtDate(ctx.today)}',
            count,
            'transactions'),
      );
    }

    // Transaction count - total.
    if (lower.contains('transaction')) {
      final count = txns.where((t) => !t.isBalanceAdjustment).length;
      return HandlerResult(
        text: 'You have $count transactions in total.',
        thinking: _think('All time', count, 'transactions'),
      );
    }

    // Expense transaction count.
    if (lower.contains('expense') || lower.contains('expenses')) {
      final count =
          txns.where((t) => t.type == 'expense' && !t.isBalanceAdjustment).length;
      return HandlerResult(
        text: 'You have $count expense transaction${count == 1 ? '' : 's'} in total.',
        thinking: _think('All time', count, 'expense transactions'),
      );
    }

    // Income transaction count.
    if (lower.contains('income')) {
      final count =
          txns.where((t) => t.type == 'income' && !t.isBalanceAdjustment).length;
      return HandlerResult(
        text: 'You have $count income transaction${count == 1 ? '' : 's'} in total.',
        thinking: _think('All time', count, 'income transactions'),
      );
    }

    // Account count.
    if (lower.contains('account')) {
      return HandlerResult(
        text: 'You have ${ctx.accounts.length} account${ctx.accounts.length == 1 ? '' : 's'}.',
        thinking: ThinkingInfo(
          dateFilter: 'Current',
          scanned: const ['Accounts'],
          steps: [
            intentStep('account count', 'current'),
            scannedStep(ctx.accounts.length, 'accounts'),
            resultStep(
                'Counted **${ctx.accounts.length} ${ctx.accounts.length == 1 ? 'account' : 'accounts'}**.'),
          ],
        ),
      );
    }

    // Category count.
    if (lower.contains('categor')) {
      return HandlerResult(
        text:
            'You have ${ctx.categories.length} categor${ctx.categories.length == 1 ? 'y' : 'ies'} set up.',
        thinking: ThinkingInfo(
          dateFilter: 'Current',
          scanned: const ['Categories'],
          steps: [
            intentStep('category count', 'current'),
            scannedStep(ctx.categories.length, 'categories'),
            resultStep(
                'Counted **${ctx.categories.length} categor${ctx.categories.length == 1 ? 'y' : 'ies'}**.'),
          ],
        ),
      );
    }

    return null;
  }
}
