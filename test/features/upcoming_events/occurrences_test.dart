// occurrencesBetween on the demo month (test/helpers/upcoming_fixture.dart):
// statuses, actual vs scheduled amounts, totals, card bills, FD maturity.
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/features/investments/data/investment.dart';
import 'package:kuber/features/investments/domain/investment_engine.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/features/upcoming_events/engine/event_aggregator.dart';
import 'package:kuber/features/upcoming_events/engine/occurrences.dart';

import '../../helpers/isar_test_helper.dart';
import '../../helpers/upcoming_fixture.dart';

void main() {
  setUpAll(initialiseIsarForTests);
  late Isar isar;
  setUp(() async {
    isar = await openTestIsar();
    await seedUpcomingFixture(isar);
  });
  tearDown(() => closeAndCleanIsar(isar));

  Future<List<CalendarOccurrence>> month({DateTime? at, Set<String>? sources}) async =>
      (await OccurrenceEngine(isar).between(DateTime(2026, 11, 1), DateTime(2026, 11, 30),
          at: at ?? upcomingNow, sources: sources))
        ..sort(compareOccurrences);

  Map<String, OccurrenceStatus> statusOn(List<CalendarOccurrence> all, int day) => {
        for (final o in all.where((o) => o.day == 20261100 + day)) o.event.title: o.status,
      };

  test('statuses on past, today and future days', () async {
    final all = await month();
    expect(statusOn(all, 1), {'Rent': OccurrenceStatus.done});
    expect(statusOn(all, 2)['Repay Amit'], OccurrenceStatus.done, reason: 'settled ledger');
    expect(statusOn(all, 3)['Pay school fees'], OccurrenceStatus.done, reason: 'reminder marked done');
    expect(statusOn(all, 7)['Maid'], OccurrenceStatus.skipped);
    expect(statusOn(all, 8)['Electricity bill'], OccurrenceStatus.overdue);
    expect(statusOn(all, 9)['Repay Neha'], OccurrenceStatus.overdue, reason: 'unsettled ledger past due');
    expect(statusOn(all, 12), {
      'Mobile recharge': OccurrenceStatus.needsConfirmation, // amount, 10:00 passed
      'Water purifier service': OccurrenceStatus.upcoming, // no amount
    });
    expect(statusOn(all, 14)['Maid'], OccurrenceStatus.upcoming);
    expect(statusOn(all, 20).containsKey('Gym'), isFalse, reason: 'paused rule');
    expect(statusOn(all, 26)['Society maintenance'], OccurrenceStatus.upcoming, reason: 'pre-vNext rule');
    expect(statusOn(all, 28).keys.toSet(), {'Maid', 'Renew car insurance', 'Parag Parikh Flexi Cap', 'Check credit score'});
    // Recurring, EMIs and SIPs are never overdue.
    expect(all.where((o) => o.status == OccurrenceStatus.overdue).map((o) => o.event.sourceType).toSet(),
        {'reminder', 'ledger'});
  });

  test('a weekly reminder repeats inside the month', () async {
    final all = await month();
    final days = all.where((o) => o.event.title == 'Check credit score').map((o) => o.day).toList();
    expect(days, [20261114, 20261121, 20261128]);
  });

  test('past days use the posted amount, future days the scheduled one', () async {
    final all = await month();
    final broadband = all.where((o) => o.event.title == 'Broadband').toList();
    expect(broadband.single.amount, -812, reason: 'actual on 5 Nov');
    expect(all.firstWhere((o) => o.event.title == 'Netflix').amount, -649);
    final salary = all.firstWhere((o) => o.event.title == 'Salary');
    expect(salary.amount, 120000);
  });

  test('day order: time of day, then type order', () async {
    final day5 = (await month()).where((o) => o.day == 20261105).map((o) => o.event.title).toList();
    expect(day5, ['Home loan EMI', 'Spotify', 'Broadband', 'Payment due · HDFC Regalia']);
    final day12 = (await month()).where((o) => o.day == 20261112).map((o) => o.event.title).toList();
    expect(day12, ['Mobile recharge', 'Water purifier service']);
  });

  test('month totals: out and in counted once, skipped and no-amount left out', () async {
    final all = await month();
    final fd = (await isar.investments.filter().uidEqualTo('inv-fd').findFirst())!;
    final t = OccurrenceTotals.of(all);
    expect(t.out, 18000 + 2000 + 8000 + 21696 + 119 + 812 + 1240 + 900 + 5500 + 349 + 750 * 3 + 649 + 3500 + 3000);
    expect(t.inn, closeTo(1500 + maturityValue(fd)! + 120000, 0.01));
    expect(t.cardBills, 0, reason: '5 Nov bill: nothing was spent in its cycle');
    final day5 = OccurrenceTotals.of(all.where((o) => o.day == 20261105));
    expect(day5.out, 21696 + 119 + 812);
  });

  test('card bill: known after the statement, Done once paid, never in out', () async {
    // 20 Nov: the 16 Nov statement covers 17 Oct to 16 Nov (4,400 + 8,000).
    final dec = await OccurrenceEngine(isar).between(DateTime(2026, 12, 1), DateTime(2026, 12, 31),
        at: DateTime(2026, 11, 20, 9));
    final due = dec.firstWhere((o) => o.isCardDue);
    expect(due.cardBill, 12400);
    expect(due.status, OccurrenceStatus.upcoming);
    expect(OccurrenceTotals.of(dec).cardBills, 12400);
    expect(OccurrenceTotals.of([due]).out, 0);
    // Before the statement the amount is not known: left out.
    final early = await OccurrenceEngine(isar).between(DateTime(2026, 12, 1), DateTime(2026, 12, 31),
        at: upcomingNow);
    expect(early.firstWhere((o) => o.isCardDue).cardBill, isNull);
    // A payment into the card after the statement marks it Done.
    await isar.writeTxn(() => isar.transactions.put(Transaction()
      ..name = 'Card payment'
      ..nameLower = 'card payment'
      ..amount = 12400
      ..type = 'income'
      ..isTransfer = true
      ..transferId = 'p1'
      ..categoryId = '1'
      ..accountId = '2'
      ..createdAt = DateTime(2026, 11, 22)
      ..updatedAt = DateTime(2026, 11, 22)));
    final paid = await OccurrenceEngine(isar).between(DateTime(2026, 12, 1), DateTime(2026, 12, 31),
        at: DateTime(2026, 12, 8));
    expect(paid.firstWhere((o) => o.isCardDue).status, OccurrenceStatus.done);
  });

  test('an unpaid known bill is Overdue after its due day', () async {
    final dec = await OccurrenceEngine(isar).between(DateTime(2026, 12, 1), DateTime(2026, 12, 31),
        at: DateTime(2026, 12, 8));
    expect(dec.firstWhere((o) => o.isCardDue).status, OccurrenceStatus.overdue);
  });

  test('FD maturity is money in, Done once handled', () async {
    final all = await month();
    final m = all.firstWhere((o) => o.event is InvestmentMaturityEvent);
    expect(m.day, 20261125);
    expect(m.amount, greaterThan(0));
    final fd = (await isar.investments.filter().uidEqualTo('inv-fd').findFirst())!;
    await isar.writeTxn(() => isar.investments.put(fd..maturityHandled = true));
    final after = await OccurrenceEngine(isar).between(DateTime(2026, 11, 1), DateTime(2026, 11, 30),
        at: DateTime(2026, 11, 26));
    expect(after.firstWhere((o) => o.event is InvestmentMaturityEvent).status, OccurrenceStatus.done);
  });

  test('source filter limits every source, SIPs include FD maturity', () async {
    final sips = await month(sources: {'sip'});
    expect(sips.map((o) => o.event.title).toSet(),
        {'Nifty 50 Index Fund', 'Parag Parikh Flexi Cap', 'SBI FD'});
  });
}
