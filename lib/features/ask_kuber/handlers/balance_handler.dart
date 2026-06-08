import '../../accounts/providers/account_provider.dart';
import '../models/handler_result.dart';
import '../models/query_context.dart';
import '../models/thinking_info.dart';
import 'query_handler.dart';

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
          thinking:
              const ThinkingInfo(dateFilter: 'Current balance', scanned: ['Accounts']),
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
      return HandlerResult(
        text:
            'Your total net worth across ${ctx.accounts.length} account${ctx.accounts.length == 1 ? '' : 's'} is ${ctx.money(total)}.',
        thinking:
            const ThinkingInfo(dateFilter: 'Current balances', scanned: ['Accounts']),
      );
    }

    return null;
  }
}
