import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/schedule/schedule.dart';
import 'package:kuber/core/schedule/schedule_engine.dart';
import 'package:kuber/core/utils/formatters.dart';
import 'package:kuber/features/ask_kuber/handlers/schedules_handler.dart';
import 'package:kuber/features/ask_kuber/models/query_context.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/loans/domain/loan_engine.dart';
import 'package:kuber/features/loans/providers/loan_provider.dart';
import 'package:kuber/features/recurring/providers/recurring_hub_provider.dart';
import 'package:kuber/features/transactions/data/transaction.dart';

Loan _loan(String uid, String name, String type, {bool numbers = true}) {
  final l = Loan()
    ..uid = uid
    ..name = name
    ..loanType = type
    ..lenderName = 'B'
    ..principalAmount = 120000
    ..emiAmount = 10661.85
    ..billDate = 5
    ..startDate = DateTime(2026, 1, 5)
    ..accountId = '1'
    ..categoryId = '2'
    ..createdAt = DateTime(2026, 1, 1)
    ..updatedAt = DateTime(2026, 1, 1)
    ..dataVersion = 1
    ..schedule = scheduleFrom(start: DateTime(2026, 1, 5), endType: ScheduleEnd.afterCount, endCount: 12);
  if (numbers) {
    l
      ..annualRate = 12
      ..tenureMonths = 12
      ..startingPoint = LoanStartingPoint.originalDetails;
  }
  return l;
}

List<Transaction> _emis(Loan l, int n) => [
      for (var i = 0; i < n; i++)
        Transaction()
          ..name = 'EMI - ${l.name}'
          ..amount = l.emiAmount
          ..type = 'expense'
          ..accountId = '1'
          ..categoryId = '2'
          ..linkedRuleId = l.uid
          ..linkedRuleType = 'loan'
          ..sourceType = 'loan'
          ..sourceId = l.uid
          ..subType = TxnSubType.loanRepayment
          ..createdAt = DateTime(2026, 1 + i, 5, 9)
          ..updatedAt = DateTime(2026, 1 + i, 5, 9),
    ];

class _Loans extends LoanListNotifier {
  _Loans(this.loans);
  final List<Loan> loans;
  @override
  List<Loan> build() => loans;
}

void main() {
  final home = _loan('H', 'Home loan', 'home');
  final car = _loan('C', 'Car', 'vehicle', numbers: false);
  final txns = [..._emis(home, 3), ..._emis(car, 2)];
  const hub = RecurringHub(
      bills: 1200, emis: 10661.85, sips: 5000, income: 0, active: [], paused: [], ended: [], processed: []);

  Future<String?> ask(String q, {RecurringHub h = hub}) async {
    final c = ProviderContainer(overrides: [
      loanListProvider.overrideWith(() => _Loans([home, car])),
      // No EMI was recorded and then deleted.
      loanDeletedDaysProvider.overrideWith((ref) async => const <String, Set<int>>{}),
      recurringHubProvider.overrideWith((ref) async => h),
    ]);
    addTearDown(c.dispose);
    final ctx = QueryContext.forTest(
        raw: q, read: c.read, txns: txns, now: DateTime(2026, 4, 10), formatter: AppFormatter());
    return (await const SchedulesHandler().tryHandle(ctx))?.text;
  }

  test('interest paid on the named loan', () async {
    final paid = loanStatus(home, _emis(home, 3), now: DateTime(2026, 4, 10)).interestPaid!;
    expect(paid, greaterThan(0));
    final text = await ask('How much interest have I paid on my home loan?');
    expect(text, contains('Home loan'));
    expect(text, contains(AppFormatter().formatCurrency(paid.round())));
  });

  test('"How much interest have I paid?" without the word loan', () async {
    final text = await ask('How much interest have I paid?');
    expect(text, isNotNull);
    expect(text, contains('interest'));
  });

  test('loan without numbers says how to get the split', () async {
    final text = await ask('Interest paid on my car loan?');
    expect(text, contains('Advanced options'));
  });

  test('monthly recurring total', () async {
    final row = HubRow(
        kind: HubKind.rule, name: 'Rent', amount: 1200, income: false, schedule: scheduleFrom(start: DateTime(2026, 1, 1)), nextDay: null);
    final text = await ask("What's my monthly total for recurring payments?",
        h: RecurringHub(bills: 1200, emis: 10661.85, sips: 5000, income: 0, active: [row], paused: const [], ended: const [], processed: const []));
    expect(text, contains(AppFormatter().formatCurrency(16862)));
    expect(await ask('how much did I spend this month'), isNull);
  });
}
