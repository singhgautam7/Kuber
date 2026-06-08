import '../models/handler_result.dart';
import '../models/query_context.dart';
import '../models/thinking_info.dart';
import 'query_handler.dart';

/// Income totals for this month / this year. Ported verbatim from `_processQuery`.
class IncomeHandler extends QueryHandler {
  const IncomeHandler();

  @override
  Future<HandlerResult?> tryHandle(QueryContext ctx) async {
    final lower = ctx.lower;
    if (!lower.contains('income')) return null;

    // Income this month.
    if ((lower.contains('month') || lower.contains('this month')) &&
        !lower.contains('last')) {
      final total = ctx.sumIncome(ctx.monthStart, ctx.monthEnd);
      return HandlerResult(
        text: 'Your income this month is ${ctx.money(total)}.',
        thinking: ThinkingInfo(
          dateFilter: '${ctx.fmtDate(ctx.monthStart)} – ${ctx.fmtDate(ctx.today)}',
          scanned: const ['Transactions'],
        ),
      );
    }

    // Income this year.
    if (lower.contains('this year')) {
      final total = ctx.sumIncome(ctx.yearStart, ctx.yearEnd);
      return HandlerResult(
        text: 'Your income this year is ${ctx.money(total)}.',
        thinking: ThinkingInfo(
          dateFilter: '${ctx.fmtDate(ctx.yearStart)} – ${ctx.fmtDate(ctx.today)}',
          scanned: const ['Transactions'],
        ),
      );
    }

    return null;
  }
}
