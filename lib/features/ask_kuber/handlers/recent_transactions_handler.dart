import '../models/handler_result.dart';
import '../models/query_context.dart';
import '../models/thinking_info.dart';
import 'query_handler.dart';
import 'thinking_steps.dart';

/// The three most recent non-transfer transactions. Ported verbatim.
class RecentTransactionsHandler extends QueryHandler {
  const RecentTransactionsHandler();

  @override
  Future<HandlerResult?> tryHandle(QueryContext ctx) async {
    final lower = ctx.lower;
    if (!((lower.contains('recent') || lower.contains('latest')) &&
        lower.contains('transaction'))) {
      return null;
    }

    final valid = ctx.txns
        .where((t) => !t.isBalanceAdjustment && !t.isTransfer)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final top = valid.take(3).toList();

    if (top.isEmpty) {
      return HandlerResult(
        text: 'No transactions found.',
        thinking: ThinkingInfo(
          dateFilter: 'All time',
          scanned: const ['Transactions'],
          steps: [
            intentStep('recent transactions', 'all time'),
            scannedStep(ctx.txns.length, 'transactions'),
            resultStep('No transactions on record.'),
          ],
        ),
      );
    }

    final lines = top
        .map((t) => '• ${t.name} - ${ctx.money(t.amount)} on ${ctx.fmtDate(t.createdAt)}')
        .join('\n');
    return HandlerResult(
      text: 'Your 3 most recent transactions:\n$lines',
      thinking: ThinkingInfo(
        dateFilter: 'All time',
        scanned: const ['Transactions'],
        steps: [
          intentStep('recent transactions', 'all time'),
          scannedStep(ctx.txns.length, 'transactions'),
          resultStep('Sorted by date; showing the **${top.length}** most recent.'),
        ],
      ),
    );
  }
}
