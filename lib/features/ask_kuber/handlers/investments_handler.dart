import '../../investments/providers/investment_provider.dart';
import '../models/handler_result.dart';
import '../models/query_context.dart';
import '../models/thinking_info.dart';
import 'query_handler.dart';

/// Investment portfolio rollup (invested / current value / gain-loss). Ported
/// verbatim, preserving the U+2212 minus sign in the gain/loss label.
class InvestmentsHandler extends QueryHandler {
  const InvestmentsHandler();

  @override
  Future<HandlerResult?> tryHandle(QueryContext ctx) async {
    final lower = ctx.lower;
    if (!(lower.contains('invest') ||
        lower.contains('portfolio') ||
        lower.contains('stock') ||
        lower.contains('mutual fund') ||
        lower.contains('asset') ||
        lower.contains('gain') ||
        lower.contains('loss'))) {
      return null;
    }

    final summary = await ctx.read(investmentSummaryProvider.future);
    if (summary.assetCount == 0) {
      return HandlerResult(
        text: 'No investments tracked yet.',
        thinking: const ThinkingInfo(dateFilter: 'Current', scanned: ['Investments']),
      );
    }
    final gainLabel = summary.gainLoss >= 0
        ? '+${ctx.money(summary.gainLoss)}'
        : '−${ctx.money(summary.gainLoss.abs())}';
    return HandlerResult(
      text:
          'Investment portfolio (${summary.assetCount} asset${summary.assetCount == 1 ? '' : 's'}):\n'
          '• Invested: ${ctx.money(summary.totalInvested)}\n'
          '• Current value: ${ctx.money(summary.currentValue)}\n'
          '• Gain/Loss: $gainLabel',
      thinking: const ThinkingInfo(dateFilter: 'Current', scanned: ['Investments']),
    );
  }
}
