import '../../loans/providers/loan_provider.dart';
import '../models/handler_result.dart';
import '../models/query_context.dart';
import '../models/thinking_info.dart';
import 'query_handler.dart';
import 'thinking_steps.dart';

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
        thinking: ThinkingInfo(
          dateFilter: 'Current',
          scanned: const ['Loans'],
          steps: [
            intentStep('loan summary', 'current'),
            const ThinkingStep('Scanned your **loan records**.'),
            resultStep('No active loans on record.'),
          ],
        ),
      );
    }
    return HandlerResult(
      text:
          'Loan summary:\n• Outstanding: ${ctx.money(summary.outstanding)}\n• Total paid so far: ${ctx.money(summary.totalPaid)}',
      thinking: ThinkingInfo(
        dateFilter: 'Active loans',
        scanned: const ['Loans'],
        steps: [
          intentStep('loan summary', 'active loans'),
          const ThinkingStep('Scanned your **active loans**.'),
          resultStep(
              'Outstanding principal is **${ctx.money(summary.outstanding)}**, paid so far **${ctx.money(summary.totalPaid)}**.'),
        ],
      ),
    );
  }
}
