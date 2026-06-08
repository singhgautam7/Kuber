import '../../transactions/helpers/transaction_filters.dart';
import '../models/handler_result.dart';
import '../models/query_context.dart';
import '../models/thinking_info.dart';
import 'query_handler.dart';
import 'thinking_steps.dart';

/// The single largest expense on record. Ported verbatim.
class BiggestExpenseHandler extends QueryHandler {
  const BiggestExpenseHandler();

  @override
  Future<HandlerResult?> tryHandle(QueryContext ctx) async {
    final lower = ctx.lower;
    if (!((lower.contains('biggest') || lower.contains('largest')) &&
        (lower.contains('expense') || lower.contains('transaction')))) {
      return null;
    }

    final expenses = ctx.txns.validForCalculations
        .where((t) => t.type == 'expense')
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    if (expenses.isEmpty) {
      return HandlerResult(
        text: 'No expenses found.',
        thinking: ThinkingInfo(
          dateFilter: 'All time',
          scanned: const ['Transactions'],
          steps: [
            intentStep('largest expense', 'all time'),
            scannedStep(ctx.txns.length, 'transactions'),
            resultStep('No expenses on record.'),
          ],
        ),
      );
    }

    final top = expenses.first;
    return HandlerResult(
      text:
          'Your biggest expense is "${top.name}" (${ctx.money(top.amount)}) on ${ctx.fmtDate(top.createdAt)}.',
      thinking: ThinkingInfo(
        dateFilter: 'All time',
        scanned: const ['Transactions'],
        steps: [
          intentStep('largest expense', 'all time'),
          scannedStep(ctx.txns.length, 'transactions'),
          resultStep(
              '**${top.name}** is the largest at **${ctx.money(top.amount)}**.'),
        ],
      ),
    );
  }
}
