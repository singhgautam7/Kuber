import '../../loans/domain/loan_engine.dart';
import '../../loans/providers/loan_provider.dart';
import '../../recurring/providers/recurring_hub_provider.dart';
import '../models/handler_result.dart';
import '../models/query_context.dart';
import '../models/thinking_info.dart';
import 'query_handler.dart';
import 'thinking_steps.dart';

/// vNext schedule questions: "How much interest have I paid on my home
/// loan?" and "What's my monthly total for recurring payments?". Runs before
/// the spending handlers so "paid" / "total" aren't read as spending.
class SchedulesHandler extends QueryHandler {
  const SchedulesHandler();

  @override
  Future<HandlerResult?> tryHandle(QueryContext ctx) async {
    final lower = ctx.lower;
    // "How much interest have I paid?" is a loan question too: interest is
    // only ever paid on loans (investments earn it).
    if (lower.contains('interest') &&
        (lower.contains('loan') || lower.contains('emi') || lower.contains('paid') || lower.contains(' pay'))) {
      return _interest(ctx);
    }
    if ((lower.contains('recurring') || lower.contains('subscription')) &&
        (lower.contains('monthly') || lower.contains('a month') || lower.contains('per month') ||
            lower.contains('total'))) {
      return _recurring(ctx);
    }
    return null;
  }

  Future<HandlerResult> _interest(QueryContext ctx) async {
    final loans = await ctx.read(loanListProvider.future);
    // Name or type words in the question ("home loan", "car") narrow it down.
    final named = loans.where((l) {
      final words = '${l.name} ${l.loanType}'.toLowerCase().split(RegExp(r'\W+'))
        ..removeWhere((w) => w.length < 3 || w == 'loan');
      return words.any(ctx.lower.contains);
    }).toList();
    final picked = named.isNotEmpty ? named : loans;
    final deleted = await ctx.read(loanDeletedDaysProvider.future);
    final lines = <String>[];
    var total = 0.0, added = 0.0, unknown = 0;
    String? lastName;
    for (final l in picked) {
      final linked = ctx.txns.where((t) => t.linkedRuleType == 'loan' && t.linkedRuleId == l.uid).toList();
      // Recorded EMI splits (edits included); interest the bank added to the
      // loan is reported on its own line, it was not paid.
      final st = loanStatus(l, linked, now: ctx.now, deletedDays: deleted[l.uid] ?? const {});
      final paid = st.interestPaid;
      added += st.addedInterest;
      if (paid == null) {
        unknown++;
        continue;
      }
      total += paid;
      lines.add('• ${l.name}: ${ctx.money(paid)}');
      lastName = l.name;
    }
    final thinking = ThinkingInfo(
      dateFilter: 'All time',
      scanned: const ['Loans', 'EMI transactions'],
      steps: [
        intentStep('loan interest paid', 'all time'),
        ThinkingStep('Matched **${picked.length}** loan${picked.length == 1 ? '' : 's'}.'),
        resultStep('Interest paid so far is **${ctx.money(total)}**.'),
      ],
    );
    if (picked.isEmpty) {
      return HandlerResult(text: 'You have no loans tracked.', thinking: thinking);
    }
    if (lines.isEmpty) {
      return HandlerResult(
        text: 'I can\'t split interest for ${picked.length == 1 ? picked.first.name : 'these loans'} yet. '
            'Add the loan amount, rate and tenure under Advanced options to see it.',
        thinking: thinking,
      );
    }
    final head = lines.length == 1
        ? 'You have paid ${ctx.money(total)} in interest on $lastName so far.'
        : 'You have paid ${ctx.money(total)} in interest so far:\n${lines.join('\n')}';
    final withAdded = added > 0
        ? '$head\nInterest added to the loan by the bank: ${ctx.money(added)}. It is owed, not paid yet.'
        : head;
    return HandlerResult(
      text: unknown > 0 ? '$withAdded\n($unknown loan${unknown == 1 ? '' : 's'} without loan details not counted.)' : head,
      thinking: thinking,
    );
  }

  Future<HandlerResult> _recurring(QueryContext ctx) async {
    final hub = await ctx.read(recurringHubProvider.future);
    final text = hub.active.isEmpty
        ? 'You have no active recurring payments.'
        : 'Your recurring payments come to about ${ctx.money(hub.out)} a month:\n'
            '• Bills and subscriptions: ${ctx.money(hub.bills)}\n'
            '• EMIs: ${ctx.money(hub.emis)}\n'
            '• SIPs: ${ctx.money(hub.sips)}'
            '${hub.income > 0 ? '\nRecurring income: ${ctx.money(hub.income)} a month.' : ''}';
    return HandlerResult(
      text: text,
      thinking: ThinkingInfo(
        dateFilter: 'Monthly',
        scanned: const ['Recurring', 'Loans', 'Investments'],
        steps: [
          intentStep('recurring monthly total', 'monthly'),
          ThinkingStep('Scanned **${hub.active.length}** active schedules, weekly and yearly ones turned into a monthly amount.'),
          resultStep('Monthly outgoing is **${ctx.money(hub.out)}**.'),
        ],
      ),
    );
  }
}
