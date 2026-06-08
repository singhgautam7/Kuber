import '../../loans/providers/loan_provider.dart';
import '../models/handler_result.dart';
import '../models/query_context.dart';
import '../models/thinking_info.dart';
import 'query_handler.dart';

/// Loan outstanding + total paid. Ported verbatim.
class LoansHandler extends QueryHandler {
  const LoansHandler();

  @override
  Future<HandlerResult?> tryHandle(QueryContext ctx) async {
    final lower = ctx.lower;
    if (!(lower.contains('loan') ||
        lower.contains('emi') ||
        (lower.contains('debt') && !lower.contains('borrow')) ||
        lower.contains('repay') ||
        lower.contains('lender'))) {
      return null;
    }

    final summary = await ctx.read(loanSummaryProvider.future);
    if (summary.outstanding == 0 && summary.totalPaid == 0) {
      return HandlerResult(
        text: 'You have no active loans tracked.',
        thinking: const ThinkingInfo(dateFilter: 'Current', scanned: ['Loans']),
      );
    }
    return HandlerResult(
      text:
          'Loan summary:\n• Outstanding: ${ctx.money(summary.outstanding)}\n• Total paid so far: ${ctx.money(summary.totalPaid)}',
      thinking: const ThinkingInfo(dateFilter: 'Active loans', scanned: ['Loans']),
    );
  }
}
