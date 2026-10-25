// The Upcoming events demo month (upcoming-calendar-v1, board 3.26): Gaurav,
// today Thu 12 Nov 2026 10:30. Every source the screen reads, with past,
// skipped, done, overdue, legacy (pre-vNext) and paused rows. Fixed ids are
// assigned in insertion order on a fresh database.
import 'package:isar_community/isar.dart';
import 'package:kuber/core/schedule/processed_occurrence.dart';
import 'package:kuber/core/schedule/schedule.dart';
import 'package:kuber/core/schedule/schedule_engine.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/features/investments/data/investment.dart';
import 'package:kuber/features/ledger/data/ledger.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/recurring/data/recurring_rule.dart';
import 'package:kuber/features/reminders/data/reminder.dart';
import 'package:kuber/features/transactions/data/transaction.dart';

final upcomingNow = DateTime(2026, 11, 12, 10, 30);

/// Watermark: the background run has posted everything through today.
Schedule _s(DateTime start,
    {ScheduleUnit unit = ScheduleUnit.month,
    int count = 1,
    List<int> skipped = const [],
    bool paused = false,
    int through = 20261112}) {
  final s = scheduleFrom(start: start, unit: unit, count: count)
    ..processedThrough = through
    ..skippedDates = skipped
    ..paused = paused;
  return s;
}

RecurringRule _rule(String name, double amount, Schedule? s,
        {String type = 'expense', DateTime? legacyNext, bool paused = false}) =>
    RecurringRule()
      ..name = name
      ..amount = amount
      ..type = type
      ..categoryId = '1'
      ..accountId = '1'
      ..frequency = 'monthly'
      ..startDate = s?.startDate ?? DateTime(2026, 1, 1)
      ..nextDueAt = legacyNext ?? DateTime(2026, 12, 1)
      ..endType = 'never'
      ..isPaused = paused
      ..createdAt = DateTime(2026, 1, 1)
      ..updatedAt = DateTime(2026, 1, 1)
      ..schedule = s
      ..dataVersion = s == null ? 0 : 1;

Reminder _rem(String title, DateTime due, {double? amount, String status = 'pending', String? repeat}) =>
    Reminder()
      ..title = title
      ..dueAt = due
      ..amount = amount
      ..transactionType = amount == null ? null : 'expense'
      ..repeat = repeat
      ..status = status
      ..completedAt = status == ReminderStatus.completed ? due : null
      ..createdAt = DateTime(2026, 10, 1)
      ..updatedAt = DateTime(2026, 10, 1);

Future<void> seedUpcomingFixture(Isar isar) async {
  await isar.writeTxn(() async {
    await isar.accounts.putAll([
      Account()
        ..name = 'HDFC Bank'
        ..type = 'bank',
      Account()
        ..name = 'HDFC Regalia'
        ..type = 'credit'
        ..isCreditCard = true
        ..billGenerationDay = 16
        ..paymentDueDay = 5,
    ]);
    await isar.recurringRules.putAll([
      _rule('Rent', 18000, _s(DateTime(2026, 1, 1))),
      _rule('Spotify', 119, _s(DateTime(2026, 1, 5))),
      _rule('Broadband', 799, _s(DateTime(2026, 1, 5))),
      _rule('Maid', 750, _s(DateTime(2026, 10, 3), unit: ScheduleUnit.week, skipped: [20261107])),
      _rule('Netflix', 649, _s(DateTime(2026, 1, 15))),
      _rule('Salary', 120000, _s(DateTime(2026, 1, 30)), type: 'income'),
      _rule('Gym', 1500, _s(DateTime(2026, 1, 20), paused: true)),
      // Pre-vNext row (no schedule yet): the old nextDueAt is used.
      _rule('Society maintenance', 3500, null, legacyNext: DateTime(2026, 11, 26)),
    ]);
    await isar.loans.putAll([
      Loan()
        ..uid = 'loan-home'
        ..name = 'Home loan EMI'
        ..loanType = 'home'
        ..lenderName = 'HDFC'
        ..principalAmount = 0
        ..emiAmount = 21696
        ..billDate = 5
        ..startDate = DateTime(2023, 1, 5)
        ..autoAddTransaction = true
        ..accountId = '1'
        ..categoryId = '1'
        ..createdAt = DateTime(2023, 1, 1)
        ..updatedAt = DateTime(2023, 1, 1)
        ..dataVersion = 1
        ..schedule = (_s(DateTime(2023, 1, 5))..autoRecord = true),
      // Pre-vNext loan: billDate only.
      Loan()
        ..uid = 'loan-car'
        ..name = 'Maruti Brezza EMI'
        ..loanType = 'vehicle'
        ..lenderName = 'SBI'
        ..principalAmount = 0
        ..emiAmount = 11200
        ..billDate = 5
        ..startDate = DateTime(2025, 1, 5)
        ..autoAddTransaction = true
        ..accountId = '1'
        ..categoryId = '1'
        ..createdAt = DateTime(2025, 1, 1)
        ..updatedAt = DateTime(2025, 1, 1),
    ]);
    await isar.investments.putAll([
      Investment()
        ..uid = 'inv-nifty'
        ..name = 'Nifty 50 Index Fund'
        ..investmentType = 'mutual_fund'
        ..sipAmount = 5500
        ..accountId = '1'
        ..categoryId = '1'
        ..createdAt = DateTime(2026, 1, 1)
        ..updatedAt = DateTime(2026, 1, 1)
        ..dataVersion = 1
        ..sip = _s(DateTime(2026, 1, 10)),
      // Pre-vNext SIP: autoDebit + sipDate.
      Investment()
        ..uid = 'inv-ppfas'
        ..name = 'Parag Parikh Flexi Cap'
        ..investmentType = 'mutual_fund'
        ..autoDebit = true
        ..sipDate = 28
        ..sipAmount = 3000
        ..accountId = '1'
        ..categoryId = '1'
        ..createdAt = DateTime(2026, 1, 1)
        ..updatedAt = DateTime(2026, 1, 1),
      Investment()
        ..uid = 'inv-fd'
        ..name = 'SBI FD'
        ..investmentType = 'fd'
        ..behaviour = InvestmentBehaviour.fixedReturn
        ..fixedPrincipal = 48500
        ..investedAmount = 48500
        ..fixedRate = 7
        ..fixedStart = DateTime(2026, 5, 25)
        ..fixedTenureMonths = 6
        ..maturityDate = DateTime(2026, 11, 25)
        ..accountId = '1'
        ..categoryId = '1'
        ..createdAt = DateTime(2026, 5, 25)
        ..updatedAt = DateTime(2026, 5, 25)
        ..dataVersion = 1,
    ]);
    await isar.reminders.putAll([
      _rem('Electricity bill', DateTime(2026, 11, 8, 9), amount: 1240),
      _rem('Mobile recharge', DateTime(2026, 11, 12, 10), amount: 349),
      _rem('Water purifier service', DateTime(2026, 11, 12, 18)),
      _rem('Renew car insurance', DateTime(2026, 11, 28, 11)),
      _rem('Pay school fees', DateTime(2026, 11, 3, 9), amount: 8000, status: ReminderStatus.completed),
      _rem('Check credit score', DateTime(2026, 11, 14, 9), repeat: ReminderRepeat.weekly),
    ]);
    await isar.ledgers.putAll([
      Ledger()
        ..uid = 'led-rahul'
        ..personName = 'Rahul'
        ..personNameLower = 'rahul'
        ..type = 'lent'
        ..originalAmount = 1500
        ..accountId = '1'
        ..categoryId = '1'
        ..expectedDate = DateTime(2026, 11, 20)
        ..createdAt = DateTime(2026, 10, 2)
        ..updatedAt = DateTime(2026, 10, 2),
      Ledger()
        ..uid = 'led-amit'
        ..personName = 'Amit'
        ..personNameLower = 'amit'
        ..type = 'borrowed'
        ..originalAmount = 2000
        ..accountId = '1'
        ..categoryId = '1'
        ..expectedDate = DateTime(2026, 11, 2)
        ..isSettled = true
        ..createdAt = DateTime(2026, 9, 1)
        ..updatedAt = DateTime(2026, 11, 2),
      Ledger()
        ..uid = 'led-neha'
        ..personName = 'Neha'
        ..personNameLower = 'neha'
        ..type = 'borrowed'
        ..originalAmount = 900
        ..accountId = '1'
        ..categoryId = '1'
        ..expectedDate = DateTime(2026, 11, 9)
        ..createdAt = DateTime(2026, 10, 9)
        ..updatedAt = DateTime(2026, 10, 9),
    ]);
  });
  await _postNovember(isar);
}

/// What the background run recorded in November so far (posted rows with
/// their actual amounts, and the skipped maid date).
Future<void> _postNovember(Isar isar) async {
  final rules = {for (final r in await isar.recurringRules.where().findAll()) r.name: r.id};
  final rows = <(String, String, int, double?)>[
    ('recurring', '${rules['Rent']}', 20261101, 18000),
    ('loan', 'loan-home', 20261105, 21696),
    ('recurring', '${rules['Spotify']}', 20261105, 119),
    ('recurring', '${rules['Broadband']}', 20261105, 812), // actual differed
    ('recurring', '${rules['Maid']}', 20261107, null), // skipped
    ('investment', 'inv-nifty', 20261110, 5500),
  ];
  await isar.writeTxn(() async {
    for (final (type, id, day, amount) in rows) {
      int? tid;
      if (amount != null) {
        tid = await isar.transactions.put(Transaction()
          ..name = '$type $id'
          ..nameLower = '$type $id'
          ..amount = amount
          ..type = 'expense'
          ..categoryId = '1'
          ..accountId = '1'
          ..createdAt = dayOf(day).add(const Duration(hours: 9))
          ..updatedAt = dayOf(day)
          ..occurrenceDate = day
          ..sourceType = type
          ..sourceId = id
          ..linkedRuleType = type
          ..linkedRuleId = id);
      }
      await isar.processedOccurrences.put(ProcessedOccurrence()
        ..key = ProcessedOccurrence.keyOf(type, id, day)
        ..sourceType = type
        ..sourceId = id
        ..occurrenceDate = day
        ..status = amount == null ? 'skipped' : 'posted'
        ..transactionId = tid
        ..createdAt = dayOf(day));
    }
    // Card spending in the 17 Oct to 16 Nov cycle, and a partial payment.
    for (final (day, amount) in [(20, 4400.0), (28, 8000.0)]) {
      await isar.transactions.put(Transaction()
        ..name = 'Card spend'
        ..nameLower = 'card spend'
        ..amount = amount
        ..type = 'expense'
        ..categoryId = '1'
        ..accountId = '2'
        ..createdAt = DateTime(2026, 10, day, 12)
        ..updatedAt = DateTime(2026, 10, day, 12));
    }
  });
}
