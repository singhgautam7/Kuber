// InvestmentService writes: opening values never touch a balance, top-ups and
// withdrawals carry the source link and sub type, proportional cost basis,
// FD maturity (move / renew), close pauses the SIP.
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/background/background_tasks.dart';
import 'package:kuber/core/background/occurrence_processor.dart';
import 'package:kuber/core/schedule/schedule_engine.dart';
import 'package:kuber/features/investments/data/investment.dart';
import 'package:kuber/features/investments/domain/investment_engine.dart';
import 'package:kuber/features/investments/domain/investment_service.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/l10n/app_localizations_en.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  setUpAll(initialiseIsarForTests);
  late Isar isar;
  late InvestmentService service;
  setUp(() async {
    isar = await openTestIsar();
    service = InvestmentService(isar);
  });
  tearDown(() => closeAndCleanIsar(isar));

  Investment fund({bool running = false}) => Investment()
    ..name = 'Index'
    ..investmentType = 'mutual_fund'
    ..investedAmount = 100000
    ..currentValue = 120000
    ..accountId = '1'
    ..alreadyRunning = running;

  Future<List<Transaction>> linked(Investment i) =>
      isar.transactions.filter().sourceIdEqualTo(i.uid).findAll();

  test('a running holding keeps opening values and writes no transaction', () async {
    final i = await service.create(fund(running: true), firstAmount: 100000);
    expect(await linked(i), isEmpty);
    expect(i.openingInvested, 100000);
    expect(i.openingValue, 120000);
    expect(i.snapshots.single.value, 120000);
    expect(i.dataVersion, 1);
  });

  test('a new holding records the first amount as an investment expense', () async {
    final i = await service.create(fund(), firstAmount: 100000, firstDate: DateTime(2026, 10, 1));
    final t = (await linked(i)).single;
    expect((t.type, t.amount, t.subType), ('expense', 100000.0, TxnSubType.investment));
    expect((t.sourceType, t.linkedRuleType, t.linkedRuleId), ('investment', 'investment', i.uid));
    expect(t.createdAt.day, 1);
  });

  test('top-up adds to invested; value updates keep history', () async {
    final i = await service.create(fund(running: true));
    await service.addMoney(i, amount: 5000, accountId: '1', date: DateTime(2026, 10, 3));
    expect(i.investedAmount, 105000);
    expect((await linked(i)).single.subType, TxnSubType.investment);
    final now = DateTime.now();
    await service.updateValue(i, 130000, date: now.add(const Duration(minutes: 1)));
    await service.updateValue(i, 125000, date: now.subtract(const Duration(days: 40)));
    expect(i.snapshots.length, 3);
    expect(i.currentValue, 130000, reason: 'the newest dated value is current');
  });

  test('withdraw: income with sub type, proportional cost basis, gain', () async {
    final i = await service.create(fund(running: true));
    await service.withdraw(i,
        redeemed: 60000, charges: 100, received: 59900, accountId: '2', date: DateTime(2026, 10, 5));
    final t = (await linked(i)).single;
    expect((t.type, t.amount, t.subType, t.accountId),
        ('income', 59900.0, TxnSubType.investmentReturn, '2'));
    final w = i.withdrawals.single;
    expect(w.investedReduction, closeTo(50000, 0.01)); // 100000 × 60000 / 120000
    expect(w.realizedGain, closeTo(9900, 0.01));
    expect(w.transactionId, t.id);
    expect(i.investedAmount, closeTo(50000, 0.01));
    expect(i.currentValue, 60000);
  });

  test('withdraw everything and close pauses the SIP', () async {
    final i = await service.create(fund(running: true),
        sip: scheduleFrom(start: DateTime(2026, 1, 10)));
    await service.withdraw(i,
        redeemed: 120000,
        charges: 0,
        received: 120000,
        accountId: '1',
        date: DateTime(2026, 10, 5),
        closeAfter: true);
    expect(i.status, InvestmentStatus.closed);
    expect(i.sip!.paused, isTrue);
    expect(i.investedAmount, 0);
    final r = await OccurrenceProcessor(isar, decimals: 2, l10n: AppLocalizationsEn())
        .run(now: DateTime(2027, 3, 1, 9));
    expect(r.sips, 0, reason: 'a closed holding posts no SIP');
  });

  Investment fd(DateTime start) => Investment()
    ..name = 'SBI FD'
    ..investmentType = 'fd'
    ..behaviour = InvestmentBehaviour.fixedReturn
    ..fixedPrincipal = 100000
    ..investedAmount = 100000
    ..fixedRate = 7
    ..fixedStart = start
    ..fixedTenureMonths = 12
    ..accountId = '1'
    ..alreadyRunning = true;

  test('FD maturity: due when matured, move brings the maturity amount in once', () async {
    final i = await service.create(fd(DateTime(2025, 10, 1)));
    expect(i.maturityDate, DateTime(2026, 10, 1));
    expect(await BackgroundTasks.anythingDue(isar), isTrue, reason: 'matured FD is work');
    final value = maturityValue(i)!;
    expect(value, greaterThan(100000));
    await service.moveMatured(i, '2');
    final t = (await linked(i)).single;
    expect((t.amount, t.subType, t.accountId), (value, TxnSubType.investmentReturn, '2'));
    expect(t.createdAt.year, 2026);
    expect(i.status, InvestmentStatus.closed);
    expect(i.maturityHandled, isTrue);
    expect(await BackgroundTasks.anythingDue(isar), isFalse);
  });

  test('FD renew: new term from maturity with the maturity amount', () async {
    final i = await service.create(fd(DateTime(2025, 10, 1)));
    final value = maturityValue(i)!;
    await service.renew(i);
    expect(i.fixedPrincipal, value);
    expect(i.fixedStart, DateTime(2026, 10, 1));
    expect(i.maturityDate, DateTime(2027, 10, 1));
    expect(await linked(i), isEmpty, reason: 'renewing moves no money');
    expect(dayKey(i.maturityDate!) > todayKey(), isTrue);
  });
}
