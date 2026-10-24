// The Recurring hub (design R.1): monthly summary, Active (user rules +
// linked loan EMIs and SIPs, read-only), Paused, Recently processed, Ended.
// Each item is counted once.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/schedule/schedule.dart';
import '../../../core/schedule/schedule_engine.dart';
import '../../investments/data/investment.dart';
import '../../investments/domain/investment_engine.dart';
import '../../investments/providers/investment_provider.dart';
import '../../loans/data/loan.dart';
import '../../loans/domain/loan_engine.dart';
import '../../loans/providers/loan_provider.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/recurring_rule.dart';
import 'recurring_provider.dart';

enum HubKind { rule, loan, sip }

class HubRow {
  final HubKind kind;
  final RecurringRule? rule;
  final Loan? loan;
  final Investment? investment;
  final String name;
  final double amount;
  final bool income;
  final Schedule schedule;
  final int? nextDay;

  const HubRow({
    required this.kind,
    this.rule,
    this.loan,
    this.investment,
    required this.name,
    required this.amount,
    required this.income,
    required this.schedule,
    required this.nextDay,
  });

  double get monthly => amount * monthlyFactor(schedule.intervalCount, schedule.intervalUnit);
}

class RecurringHub {
  final double bills, emis, sips, income;
  final List<HubRow> active, paused, ended;
  final List<Transaction> processed;
  const RecurringHub({
    required this.bills,
    required this.emis,
    required this.sips,
    required this.income,
    required this.active,
    required this.paused,
    required this.ended,
    required this.processed,
  });
  double get out => bills + emis + sips;
  bool get isEmpty => active.isEmpty && paused.isEmpty && ended.isEmpty;
}

final recurringHubProvider = FutureProvider<RecurringHub>((ref) async {
  final rules = await ref.watch(recurringListProvider.future);
  final loans = await ref.watch(loanListProvider.future);
  final invs = await ref.watch(investmentListProvider.future);
  final txns = await ref.watch(transactionListProvider.future);
  final today = todayKey();

  final active = <HubRow>[], paused = <HubRow>[], ended = <HubRow>[];
  var bills = 0.0, emis = 0.0, sips = 0.0, income = 0.0;
  for (final r in rules) {
    final s = r.schedule;
    if (s == null) continue;
    final row = HubRow(
      kind: HubKind.rule,
      rule: r,
      name: r.name,
      amount: r.amount,
      income: r.type == 'income',
      schedule: s,
      nextDay: nextDate(s, fromKey: today),
    );
    if (isEnded(s)) {
      ended.add(row);
    } else if (s.paused) {
      paused.add(row);
    } else {
      active.add(row);
      if (row.income) {
        income += row.monthly;
      } else {
        bills += row.monthly;
      }
    }
  }
  for (final l in loans) {
    final s = l.schedule;
    if (s == null || l.isCompleted || l.closedAt != null || isEnded(s)) continue;
    final next = nextDate(s, fromKey: today);
    final amount = next == null ? l.emiAmount : emiFor(l, next, 2).amount;
    final row = HubRow(
        kind: HubKind.loan,
        loan: l,
        name: l.name,
        amount: amount,
        income: false,
        schedule: s,
        nextDay: next);
    active.add(row);
    emis += row.monthly;
  }
  for (final i in invs) {
    final s = i.sip;
    if (s == null || i.status == InvestmentStatus.closed || isEnded(s) || s.paused) continue;
    final next = nextSip(i);
    final row = HubRow(
        kind: HubKind.sip,
        investment: i,
        name: i.name,
        amount: next?.amount ?? (i.sipAmount ?? i.installment ?? 0),
        income: false,
        schedule: s,
        nextDay: next?.day);
    active.add(row);
    sips += row.monthly;
  }
  int byNext(HubRow a, HubRow b) => (a.nextDay ?? 99999999).compareTo(b.nextDay ?? 99999999);
  active.sort(byNext);
  paused.sort(byNext);
  final processed = txns.where((t) => t.isScheduled).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return RecurringHub(
    bills: bills,
    emis: emis,
    sips: sips,
    income: income,
    active: active,
    paused: paused,
    ended: ended,
    processed: processed.take(5).toList(),
  );
});

/// Per-month totals of a rule's transactions for the last [months] months
/// (oldest first) and the rule's transactions, newest first.
class RuleHistory {
  final List<(DateTime month, double total)> monthly;
  final List<Transaction> transactions;
  const RuleHistory(this.monthly, this.transactions);
  double get last12 => monthly.fold(0.0, (s, m) => s + m.$2);
  double get avg => monthly.isEmpty ? 0 : last12 / monthly.length;
}

final ruleHistoryProvider = FutureProvider.family<RuleHistory, int>((ref, ruleId) async {
  final txns = await ref.watch(recurringRuleTransactionsProvider(ruleId).future);
  final now = DateTime.now();
  final months = [
    for (var i = 11; i >= 0; i--) DateTime(now.year, now.month - i, 1),
  ];
  final totals = [
    for (final m in months)
      (
        m,
        txns
            .where((t) => t.createdAt.year == m.year && t.createdAt.month == m.month)
            .fold(0.0, (s, t) => s + t.amount)
      )
  ];
  return RuleHistory(totals, txns);
});
