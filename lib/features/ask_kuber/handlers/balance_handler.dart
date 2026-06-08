import '../../accounts/providers/account_provider.dart';
import '../models/handler_result.dart';
import '../models/query_context.dart';
import '../models/thinking_info.dart';
import 'query_handler.dart';
import 'thinking_steps.dart';

/// Account-specific balance and overall net worth. Ported verbatim, including
/// the per-account balance loop. Balances come from [accountBalanceProvider].
class BalanceHandler extends QueryHandler {
  const BalanceHandler();

  @override
  Future<HandlerResult?> tryHandle(QueryContext ctx) async {
    final lower = ctx.lower;
    final mentionsBalance = lower.contains('balance') ||
        lower.contains('how much') ||
        lower.contains('net worth') ||
        lower.contains('networth') ||
        lower.contains('total');
    if (!mentionsBalance) return null;

    // Account-specific balance.
    for (final a in ctx.accounts) {
      if (lower.contains(a.name.toLowerCase()) &&
          (lower.contains('balance') || lower.contains('how much'))) {
        final balance = await ctx.read(accountBalanceProvider(a.id).future);
        return HandlerResult(
          text: '${a.name} balance: ${ctx.money(balance)}.',
          thinking: ThinkingInfo(
            dateFilter: 'Current balance',
            scanned: const ['Accounts'],
            steps: [
              intentStep('account balance', 'current'),
              scannedStep(ctx.accounts.length, 'accounts'),
              resultStep('**${a.name}** balance is **${ctx.money(balance)}**.'),
            ],
          ),
        );
      }
    }

    // Net worth / total balance.
    if (lower.contains('balance') ||
        lower.contains('net worth') ||
        lower.contains('networth') ||
        lower.contains('total')) {
      double total = 0;
      for (final a in ctx.accounts) {
        total += await ctx.read(accountBalanceProvider(a.id).future);
      }
      final n = ctx.accounts.length;
      return HandlerResult(
        text:
            'Your total net worth across $n account${n == 1 ? '' : 's'} is ${ctx.money(total)}.',
        thinking: ThinkingInfo(
          dateFilter: 'Current balances',
          scanned: const ['Accounts'],
          steps: [
            intentStep('net worth', 'current'),
            scannedStep(n, 'accounts'),
            resultStep(
                'Sum of balances across **$n account${n == 1 ? '' : 's'}** is **${ctx.money(total)}**.'),
          ],
        ),
      );
    }

    return null;
  }
}
