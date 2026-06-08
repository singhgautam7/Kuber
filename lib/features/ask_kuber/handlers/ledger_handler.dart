import '../../ledger/providers/ledger_provider.dart';
import '../models/handler_result.dart';
import '../models/query_context.dart';
import '../models/thinking_info.dart';
import 'query_handler.dart';
import 'thinking_steps.dart';

/// Lend / borrow (ledger) summary. Ported verbatim, including the owe-vs-lent
/// branch selection.
class LedgerHandler extends QueryHandler {
  const LedgerHandler();

  @override
  Future<HandlerResult?> tryHandle(QueryContext ctx) async {
    final lower = ctx.lower;
    if (!(lower.contains('borrow') ||
        lower.contains('lent') ||
        lower.contains('lend') ||
        lower.contains('owe') ||
        lower.contains('receivable') ||
        lower.contains('payable'))) {
      return null;
    }

    final summary = await ctx.read(ledgerSummaryProvider.future);
    const scanLedger = ThinkingStep('Scanned your **lend / borrow ledger**.');
    if (lower.contains('borrow') || lower.contains('owe')) {
      return HandlerResult(
        text:
            'You currently owe ${ctx.money(summary.owed)} in total (money you borrowed).',
        thinking: ThinkingInfo(
          dateFilter: 'Current',
          scanned: const ['Ledger'],
          steps: [
            intentStep('money borrowed', 'current'),
            scanLedger,
            resultStep('You owe **${ctx.money(summary.owed)}** in total.'),
          ],
        ),
      );
    }
    if (lower.contains('lent') ||
        lower.contains('lend') ||
        lower.contains('receivable')) {
      return HandlerResult(
        text:
            'People owe you ${ctx.money(summary.toReceive)} in total (money you lent).',
        thinking: ThinkingInfo(
          dateFilter: 'Current',
          scanned: const ['Ledger'],
          steps: [
            intentStep('money lent', 'current'),
            scanLedger,
            resultStep('You are owed **${ctx.money(summary.toReceive)}** in total.'),
          ],
        ),
      );
    }
    return HandlerResult(
      text:
          'Lend/Borrow summary:\n• You are owed: ${ctx.money(summary.toReceive)}\n• You owe: ${ctx.money(summary.owed)}',
      thinking: ThinkingInfo(
        dateFilter: 'Current',
        scanned: const ['Ledger'],
        steps: [
          intentStep('lend / borrow summary', 'current'),
          scanLedger,
          resultStep(
              'You are owed **${ctx.money(summary.toReceive)}** and you owe **${ctx.money(summary.owed)}**.'),
        ],
      ),
    );
  }
}
