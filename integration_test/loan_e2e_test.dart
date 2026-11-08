// The loan flow end to end on a device, Part 5 of the Nov design brief. Numbers
// come from specs/nov-release-design/loan_e2e_check.py (no shared code). Each
// check prints a KUBER_LOAN line; the test report is built from them.
//   flutter test integration_test/loan_e2e_test.dart -d emulator-5554
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/background/occurrence_processor.dart';
import 'package:kuber/core/schedule/schedule.dart';
import 'package:kuber/core/schedule/schedule_engine.dart';
import 'package:kuber/core/services/json_backup_service.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/features/accounts/providers/account_provider.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/loans/domain/loan_engine.dart';
import 'package:kuber/features/loans/domain/loan_service.dart';
import 'package:kuber/features/loans/providers/loan_provider.dart';
import 'package:kuber/features/loans/widgets/loan_sheet.dart';
import 'package:kuber/features/settings/providers/data_provider.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/features/transactions/helpers/transaction_filters.dart';
import 'package:kuber/features/transactions/providers/transaction_provider.dart';
import 'package:kuber/l10n/app_localizations_en.dart';
import 'package:kuber/main.dart' as app;
import 'package:kuber/shared/widgets/app_scaffold.dart';
import 'package:kuber/shared/widgets/money_widgets.dart';

import 'loan_e2e_expected.dart';
import 'smoke_helpers.dart';

final now = DateTime(2026, 11, 8, 12);
var failures = 0;

void check(String name, num actual, num want, {double within = 1}) {
  final ok = (actual - want).abs() <= within;
  if (!ok) failures++;
  debugPrint('KUBER_LOAN ${ok ? 'PASS' : 'FAIL'} | $name | app ${actual.toStringAsFixed(2)} | expected ${want.toStringAsFixed(2)}');
}

Future<void> shot(WidgetTester t, String name) async {
  debugPrint('KUBER_SHOT loans-e2e/$name');
  await settle(t, const Duration(milliseconds: 1500));
}

Future<Loan> reload(Loan l) async => (await db.loans.filter().uidEqualTo(l.uid).findFirst())!;
Future<List<Transaction>> linked(Loan l) => db.transactions.filter().linkedRuleIdEqualTo(l.uid).findAll();

LoanRelease part(DateTime d, double amount, [String? account]) => LoanRelease()
  ..date = d
  ..amount = amount
  ..accountId = account
  ..adjust = LoanAdjust.tenure;

Future<Loan> make(String name, {
  required double principal,
  required double rate,
  required double emi,
  required int months,
  required DateTime start,
  required DateTime firstEmi,
  required String account,
  List<LoanRelease> parts = const [],
  LoanPreEmi preEmi = LoanPreEmi.none,
  int? cycleDay,
  bool autoRecord = false,
}) {
  final s = scheduleFrom(start: firstEmi, endType: ScheduleEnd.afterCount, endCount: months)..autoRecord = autoRecord;
  return LoanService(db).save(
      Loan()
        ..name = name
        ..loanType = 'home'
        ..lenderName = 'Bank'
        ..accountId = account
        ..principalAmount = principal
        ..emiAmount = emi
        ..mode = LoanMode.advanced
        ..annualRate = rate
        ..tenureMonths = months
        ..loanStartDate = start
        ..releasedInParts = parts.isNotEmpty
        ..releases = [...parts]
        ..preEmiMode = preEmi
        ..preEmiCycleDay = cycleDay
        ..alreadyRunning = true,
      s,
      isNew: true);
}

Future<void> openSheet(WidgetTester t, Loan l) async {
  showMoneySheet<void>(rootContext(t), LoanSheet(loan: l));
  await settle(t, const Duration(seconds: 1));
}

Future<void> closeSheet(WidgetTester t) async {
  if (find.byType(LoanSheet).evaluate().isNotEmpty) Navigator.of(rootContext(t)).pop();
  await settle(t);
}

Future<double> opening(Loan l) async {
  final a = loanAmortization(await reload(l))!;
  final r = a.rows.first;
  return r.balance + r.principal;
}

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  smokeTest('Fresh install', (t) async {
    app.main();
    await pumpUntil(t, find.text(en.obStartFresh), timeout: const Duration(seconds: 40));
    await tapText(t, en.obStartFresh);
    await pumpUntil(t, find.text(en.getStarted));
    await tapText(t, en.getStarted);
    await tapText(t, en.skip);
    await pumpUntil(t, find.byType(TextFormField));
    await t.enterText(find.byType(TextFormField).first, 'Gaurav');
    await settle(t);
    await tapText(t, en.homeV33TourNext);
    await pumpUntil(t, find.text(en.obNotifTitle));
    await tapText(t, en.obNotifLater);
    await pumpUntil(t, find.text(en.obTermsTitle));
    await tapText(t, en.obTermsCheck1);
    await tapText(t, en.obTermsCheck2);
    await tapText(t, en.obTermsAgree);
    await pumpUntil(t, find.byType(AppScaffold), timeout: const Duration(seconds: 30));
  });

  smokeTest('Loan flow end to end', (t) async {
    await boot(t);
    final c = container(t);
    final service = LoanService(db);
    final bankRow = (await db.accounts.where().findFirst())!;
    final bank = '${bankRow.id}';
    Future<double> balance() async {
      c.invalidate(transactionListProvider);
      c.invalidate(accountBalancesProvider);
      await settle(t, const Duration(milliseconds: 300));
      return (await c.read(accountBalancesProvider.future))[bankRow.id] ?? 0;
    }

    Future<({double income, double spend})> totals() async {
      final all = (await db.transactions.where().findAll()).validForCalculations;
      return (
        income: all.where((x) => x.type == 'income').fold(0.0, (s, x) => s + x.amount),
        spend: all.where((x) => x.type == 'expense').fold(0.0, (s, x) => s + x.amount),
      );
    }

    // 1. A simple loan through the form.
    await push(t, '/loans/add');
    await settle(t);
    await enterField(t, en.msLoansName, 'E2E simple');
    await enterField(t, en.msLoansEmiAmount, '11200');
    await hideKeyboard(t);
    await tapText(t, 'Select Account');
    await tapText(t, 'Bank', last: true);
    await tapText(t, en.msLoansSave, last: true);
    await settle(t, const Duration(seconds: 2));
    final simple = (await db.loans.filter().nameEqualTo('E2E simple').findFirst())!;
    check('1 simple loan saved with its EMI', simple.emiAmount, 11200, within: 0);
    await go(t, '/more/loans');
    await dismissInfo(t);
    await shot(t, '01-simple');

    // 2. Released in parts: one into the bank, one not recorded.
    final b0 = await balance();
    final t0 = await totals();
    final l2 = await make('E2E parts', principal: 2000000, rate: 9, emi: 17000, months: 120,
        start: DateTime(2026, 1, 10), firstEmi: DateTime(2026, 7, 15), account: bank,
        parts: [part(DateTime(2026, 1, 10), 500000, bank), part(DateTime(2026, 3, 15), 300000)],
        preEmi: LoanPreEmi.addToLoan, cycleDay: 10);
    check('2 bank balance rises by the part received', await balance() - b0, 500000, within: 0);
    final t1 = await totals();
    check('2 income unchanged', t1.income, t0.income, within: 0);
    check('2 spending unchanged', t1.spend, t0.spend, within: 0);

    // 3. Bank adds it to the loan: figure, edit, change a release, Use, Keep mine.
    var l = await reload(l2);
    final cycles = loanAmortization(l)!.preEmi!.cycles;
    for (final (i, want) in (expected['s3Cycles'] as List).indexed) {
      check('3 cycle ${i + 1} interest', cycles[i].interest, want as num, within: 0);
    }
    check('3 calculated figure', LoanService.preEmiCalculatedNow(l)!, expected['s3Figure'], within: 0);
    check('3 outstanding before first EMI', await opening(l), expected['s3Opening']);
    l
      ..preEmiOverride = (expected['s3Figure'] as num) + 1000
      ..preEmiCalculated = LoanService.preEmiCalculatedNow(l);
    await db.writeTxn(() => db.loans.put(l));
    check('3 edited figure moves the outstanding', await opening(l), (expected['s3Opening'] as num) + 1000);
    l = await reload(l);
    final second = l.releases.firstWhere((r) => r.amount == 300000);
    await service.saveRelease(l, part(second.date!, 350000), replace: second);
    l = await reload(l);
    check('3 notice shows the new figure', LoanService.preEmiNotice(l)!, expected['s3Figure2'], within: 0);
    c.invalidate(loanListProvider);
    await settle(t, const Duration(seconds: 1));
    await openSheet(t, l);
    await t.scrollUntilVisible(find.text(en.msLoansUse), 200, scrollable: find.byType(Scrollable).last, maxScrolls: 30);
    await settle(t);
    await shot(t, '03-notice');
    await tapText(t, en.msLoansUse);
    await settle(t, const Duration(seconds: 1));
    l = await reload(l);
    check('3 Use takes Kuber\'s figure', l.preEmiOverride ?? -1, -1, within: 0);
    check('3 outstanding after Use', await opening(l), expected['s3Opening2']);
    await closeSheet(t);
    final mine = (expected['s3Figure2'] as num) + 500;
    l
      ..preEmiOverride = mine.toDouble()
      ..preEmiCalculated = LoanService.preEmiCalculatedNow(l);
    await db.writeTxn(() => db.loans.put(l));
    l = await reload(l);
    final third = l.releases.firstWhere((r) => r.amount == 350000);
    await service.saveRelease(l, part(third.date!, 400000), replace: third);
    c.invalidate(loanListProvider);
    await settle(t, const Duration(seconds: 1));
    await openSheet(t, await reload(l));
    await t.scrollUntilVisible(find.text(en.msLoansKeepMine), 200, scrollable: find.byType(Scrollable).last, maxScrolls: 30);
    await settle(t);
    await tapText(t, en.msLoansKeepMine);
    await settle(t, const Duration(seconds: 1));
    l = await reload(l);
    check('3 Keep mine keeps the edit', l.preEmiOverride!, mine, within: 0);
    check('3 Keep mine stops asking', LoanService.preEmiNotice(l) == null ? 1 : 0, 1, within: 0);
    await closeSheet(t);

    // 4. I pay it every month.
    final b4 = await balance();
    var l4 = await make('E2E pays', principal: 1000000, rate: 9.2, emi: 12000, months: 120,
        start: DateTime(2026, 6, 1), firstEmi: DateTime(2026, 12, 5), account: bank,
        parts: [part(DateTime(2026, 6, 1), 1000000)], preEmi: LoanPreEmi.payMonthly, autoRecord: true);
    l4.createdAt = DateTime(2026, 5, 1);
    await db.writeTxn(() => db.loans.put(l4));
    await OccurrenceProcessor(db, decimals: 2, l10n: AppLocalizationsEn()).run();
    final paid = (await linked(l4)).toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final due = (expected['s4Due'] as List).cast<num>();
    check('4 interest payments created', paid.length, due.length, within: 0);
    for (final (i, want) in due.indexed) {
      check('4 payment ${i + 1}', paid[i].amount, want, within: 0);
      check('4 payment ${i + 1} is all interest', paid[i].principalPart ?? -1, 0, within: 0);
    }
    check('4 bank pays them', await balance() - b4, -due.fold<num>(0, (s, x) => s + x), within: 0);

    // 5 and 6, before EMIs start.
    final b5 = await balance();
    var l5 = await make('E2E before', principal: 2000000, rate: 9, emi: 17000, months: 120,
        start: DateTime(2026, 1, 10), firstEmi: DateTime(2026, 7, 15), account: bank,
        parts: [part(DateTime(2026, 1, 10), 500000)], preEmi: LoanPreEmi.addToLoan, cycleDay: 10);
    await service.saveAddition(l5, interest: false, date: DateTime(2026, 2, 5), amount: 1500, adjust: LoanAdjust.tenure);
    await service.saveAddition(l5, interest: true, date: DateTime(2026, 3, 5), amount: 2000, adjust: LoanAdjust.tenure);
    await service.saveRelease(l5, part(DateTime(2026, 3, 20), 100000));
    await service.recordExtraPayment(l5, amount: 10000, towardPrincipal: true, reduce: LoanAdjust.tenure,
        charge: 0, accountId: bank, date: DateTime(2026, 4, 25));
    l5 = await reload(l5);
    check('5 before EMIs: outstanding at the first EMI', await opening(l5), expected['s5Opening']);
    check('6 before EMIs: bank pays the extra', await balance() - b5, -10000, within: 0);

    // 10. Past EMIs, then 5 to 11 after EMIs start.
    final b6 = await balance();
    var l6 = await make('E2E after', principal: 600000, rate: 12, emi: 13000, months: 60,
        start: DateTime(2026, 4, 5), firstEmi: DateTime(2026, 5, 5), account: bank);
    Future<void> status(String name, String key, {bool next = true}) async {
      l6 = await reload(l6);
      final rec = await LoanService.records(db, l6.uid);
      final st = loanStatus(l6, rec.linked, now: now, deletedDays: rec.deleted);
      check(name, st.outstanding!, expected[key]);
      if (next) check('$name, next EMI', st.nextAmount!, expected['${key}Next']);
    }

    final added = await service.addPastEmis(l6, now: now);
    check('10 past EMIs added', added.length, expected['pastCount'], within: 0);
    check('10 bank pays them', await balance() - b6, -13000.0 * (expected['pastCount'] as num), within: 0);
    Future<double> recordedInterest() async => (await linked(l6))
        .where((x) => x.occurrenceDate != null)
        .fold<double>(0, (s, x) => s + x.interestPart!);
    check('10 interest split across them', await recordedInterest(), expected['afterPastInterest']);
    await status('10 outstanding after past EMIs', 'afterPast', next: false);

    await service.saveAddition(l6, interest: false, date: DateTime(2026, 11, 6), amount: 20000, adjust: LoanAdjust.tenure, note: 'Insurance');
    await status('5 charges after EMIs, keep EMI', 'charge');
    l6 = await reload(l6);
    await service.saveAddition(l6, interest: true, date: DateTime(2026, 11, 6), amount: 5000, adjust: LoanAdjust.emi);
    await status('5 unpaid interest after EMIs, keep end date', 'unpaid');
    l6 = await reload(l6);
    await service.saveRelease(l6, part(DateTime(2026, 11, 6), 50000), growSanctioned: true);
    await status('5 money released after EMIs, keep EMI', 'released');
    l6 = await reload(l6);
    await service.saveAddition(l6, interest: false, date: DateTime(2026, 6, 10), amount: 10000, adjust: LoanAdjust.tenure);
    await status('5 dated in the past, Keep as is', 'pastKeep');
    check('5 Keep as is leaves recorded interest', await recordedInterest(), expected['afterPastInterest']);
    l6 = await reload(l6);
    await service.recalculateSplits(l6, dayKey(DateTime(2026, 6, 10)));
    await status('5 dated in the past, Recalculate', 'pastRecalc');
    check('5 Recalculate splits again', await recordedInterest(), expected['pastRecalcInterest']);

    final b7 = await balance();
    l6 = await reload(l6);
    await service.recordExtraPayment(l6, amount: 25000, towardPrincipal: true, reduce: LoanAdjust.tenure,
        charge: 0, accountId: bank, date: DateTime(2026, 11, 7));
    await status('6 extra payment after EMIs', 'extra');
    check('6 bank pays it', await balance() - b7, -25000, within: 0);

    l6 = await reload(l6);
    await service.changeRate(l6, newRate: 10.5, from: DateTime(2026, 11, 7), adjust: LoanAdjust.tenure);
    await status('7 rate change', 'rate');

    final novEmi = (await linked(l6)).firstWhere((x) => x.occurrenceDate == dayKey(DateTime(2026, 11, 5)));
    LoanService.applyEditedSplit(novEmi, amount: novEmi.amount, principal: novEmi.principalPart! - 1000, interest: novEmi.interestPart! + 1000);
    await db.writeTxn(() => db.transactions.put(novEmi));
    await status('8 edit an EMI split', 'split');

    l6 = await reload(l6);
    await service.saveAdjustment(l6, date: DateTime(2026, 11, 8), amount: 3000, reason: LoanAdjustReason.matchBank, adjust: LoanAdjust.tenure);
    await status('9 Update outstanding', 'update');

    l6 = await reload(l6);
    await service.deleteRelease(l6, l6.releases.firstWhere((r) => r.amount == 50000), deleteTransaction: false);
    await status('11 delete a part', 'noPart');
    l6 = await reload(l6);
    await service.deleteEvent(l6, l6.events.firstWhere((e) => e.note == 'Insurance'));
    await status('11 delete an event', 'noEvent');
    final b8 = await balance();
    await db.writeTxn(() => db.transactions.delete(novEmi.id));
    c.invalidate(loanDeletedDaysProvider);
    await settle(t);
    await status('11 delete an EMI', 'noEmi');
    check('11 the EMI comes back to the bank', await balance() - b8, 13000, within: 0);

    // On screen: sheet, schedule, Accounts, Analytics.
    c.invalidate(loanListProvider);
    await go(t, '/more/loans');
    await settle(t, const Duration(seconds: 1));
    await shot(t, '02-loans-list');
    await openSheet(t, l6);
    await shot(t, '04-sheet');
    final rec = await LoanService.records(db, l6.uid);
    final shown = loanStatus(l6, rec.linked, deletedDays: rec.deleted).outstanding!;
    final fmt = container(t).read(formatterProvider);
    expect(find.textContaining(fmt.formatCurrency(shown.round()), findRichText: true), findsWidgets,
        reason: 'the sheet shows the outstanding');
    debugPrint('KUBER_LOAN PASS | sheet shows the outstanding | app ${fmt.formatCurrency(shown.round())} | on screen');
    await closeSheet(t);
    await go(t, '/more/accounts');
    await dismissInfo(t);
    await shot(t, '05-accounts');
    await go(t, '/analytics');
    await settle(t, const Duration(seconds: 2));
    await shot(t, '06-analytics');

    // 12. Back up, clear, restore: every figure the same.
    final before = <String, (double?, int)>{};
    for (final x in await db.loans.where().findAll()) {
      final r = await LoanService.records(db, x.uid);
      final st = loanStatus(x, r.linked, deletedDays: r.deleted);
      before[x.uid] = (st.outstanding, st.emisPaid);
    }
    final bankBefore = await balance();
    final txnsBefore = await db.transactions.count();
    final json = await JsonBackupService().exportJson(db);
    final data = c.read(dataControllerProvider.notifier);
    await data.clearAllData();
    data.reset();
    await settle(t, const Duration(seconds: 2));
    check('12 cleared: no loans left', await db.loans.count(), 0, within: 0);
    await data.runImport(json, isJson: true);
    data.reset();
    await settle(t, const Duration(seconds: 2));
    check('12 transactions back', await db.transactions.count(), txnsBefore, within: 0);
    check('12 bank balance back', await balance(), bankBefore, within: 0);
    for (final x in await db.loans.where().findAll()) {
      final r = await LoanService.records(db, x.uid);
      final st = loanStatus(x, r.linked, deletedDays: r.deleted);
      check('12 ${x.name} outstanding', st.outstanding ?? 0, before[x.uid]!.$1 ?? 0, within: 0.001);
      check('12 ${x.name} EMIs paid', st.emisPaid, before[x.uid]!.$2, within: 0);
    }

    debugPrint('KUBER_LOAN DONE failures=$failures');
    expect(failures, 0);
    expectNoErrors(t);
  });
}
