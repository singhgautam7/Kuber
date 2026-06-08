import '../models/handler_result.dart';
import '../models/query_context.dart';
import '../models/thinking_info.dart';
import 'query_handler.dart';

/// This-month net savings (income minus expense). Ported verbatim.
class SavingsHandler extends QueryHandler {
  const SavingsHandler();

  @override
  Future<HandlerResult?> tryHandle(QueryContext ctx) async {
    final lower = ctx.lower;
    if (!(lower.contains('saving') ||
        lower.contains('saved') ||
        lower.contains('save'))) {
      return null;
    }

    final income = ctx.sumIncome(ctx.monthStart, ctx.monthEnd);
    final expense = ctx.sumExpenses(ctx.monthStart, ctx.monthEnd);
    final savings = income - expense;
    return HandlerResult(
      text:
          'This month you earned ${ctx.money(income)} and spent ${ctx.money(expense)}.\n'
          'Net savings: ${ctx.money(savings.abs())}${savings < 0 ? ' (deficit)' : ''}.',
      thinking: ThinkingInfo(
        dateFilter: '${ctx.fmtDate(ctx.monthStart)} – ${ctx.fmtDate(ctx.today)}',
        scanned: const ['Transactions'],
      ),
    );
  }
}
