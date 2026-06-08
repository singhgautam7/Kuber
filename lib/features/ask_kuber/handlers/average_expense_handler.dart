import '../../transactions/helpers/transaction_filters.dart';
import '../models/handler_result.dart';
import '../models/query_context.dart';
import '../models/thinking_info.dart';
import 'query_handler.dart';
import 'thinking_steps.dart';

/// Average monthly spending across all months with expense data. Ported verbatim.
class AverageExpenseHandler extends QueryHandler {
  const AverageExpenseHandler();

  @override
  Future<HandlerResult?> tryHandle(QueryContext ctx) async {
    final lower = ctx.lower;
    if (!((lower.contains('average') || lower.contains('avg')) &&
        (lower.contains('expense') || lower.contains('spend')))) {
      return null;
    }

    final monthlyTotals = <String, double>{};
    for (final t in ctx.txns.validForCalculations.where((t) => t.type == 'expense')) {
      final key = '${t.createdAt.year}-${t.createdAt.month}';
      monthlyTotals[key] = (monthlyTotals[key] ?? 0) + t.amount;
    }

    if (monthlyTotals.isEmpty) {
      return HandlerResult(
        text: 'No expense data yet.',
        thinking: ThinkingInfo(
          dateFilter: 'All time',
          scanned: const ['Transactions'],
          steps: [
            intentStep('average monthly spend', 'all time'),
            scannedStep(ctx.txns.length, 'transactions'),
            resultStep('No expense data yet.'),
          ],
        ),
      );
    }

    final avg = monthlyTotals.values.reduce((a, b) => a + b) / monthlyTotals.length;
    final months = monthlyTotals.length;
    return HandlerResult(
      text:
          'Your average monthly spending is ${ctx.money(avg)} (across $months month${months == 1 ? '' : 's'}).',
      thinking: ThinkingInfo(
        dateFilter: 'All time',
        scanned: const ['Transactions'],
        steps: [
          intentStep('average monthly spend', 'all time'),
          scannedStep(ctx.txns.length, 'transactions',
              groups: months, groupType: 'months', dimension: 'month'),
          resultStep(
              'Mean across **$months month${months == 1 ? '' : 's'}** is **${ctx.money(avg)}**.'),
        ],
      ),
    );
  }
}
