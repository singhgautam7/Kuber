import '../../transactions/helpers/transaction_filters.dart';
import '../models/handler_result.dart';
import '../models/query_context.dart';
import '../models/thinking_info.dart';
import 'query_handler.dart';

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
        thinking: const ThinkingInfo(dateFilter: 'All time', scanned: ['Transactions']),
      );
    }

    final top = expenses.first;
    return HandlerResult(
      text:
          'Your biggest expense is "${top.name}" (${ctx.money(top.amount)}) on ${ctx.fmtDate(top.createdAt)}.',
      thinking: const ThinkingInfo(dateFilter: 'All time', scanned: ['Transactions']),
    );
  }
}
