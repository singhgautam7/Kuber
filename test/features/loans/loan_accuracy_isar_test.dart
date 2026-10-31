// Loan accuracy E1 through the real service, background processor and
// backup: S5, S8, S9 (stored splits), S18 to S21, and the A0 back-fill bug.
// Expected counts and totals are worked out here from the calendar and the
// closed-form EMI, not from the code under test.
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/background/occurrence_processor.dart';
import 'package:kuber/core/schedule/processed_occurrence.dart';
import 'package:kuber/core/schedule/schedule.dart';
import 'package:kuber/core/schedule/schedule_engine.dart';
import 'package:kuber/core/services/json_backup_service.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/loans/domain/loan_engine.dart';
import 'package:kuber/features/loans/domain/loan_service.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/l10n/app_localizations_en.dart';

import '../../helpers/isar_test_helper.dart';

double refEmi(double p, double annual, int n) {
  final r = annual / 1200;
  final f = math.pow(1 + r, n);
  return p * r * f / (f - 1);
}

void main() {
  late Isar isar;
  setUpAll(() async {
    await initialiseIsarForTests();
    isar = await openTestIsar();
  });
  setUp(() => isar.writeTxn(() => isar.clear()));
  tearDownAll(() => closeAndCleanIsar(isar));

  final today = DateUtils.dateOnly(DateTime.now());
  final todayK = dayKey(today);
  final first = DateTime(2017, 7, 5);

  /// EMI dates from [from] (day 5) to today, counted on the calendar.
  int monthsUntilToday(DateTime from) {
    var n = 0;
    for (var d = from; !d.isAfter(today); d = DateTime(d.year, d.month + 1, 5)) {
      n++;
    }
    return n;
  }

  OccurrenceProcessor processor() =>
      OccurrenceProcessor(isar, decimals: 2, l10n: AppLocalizationsEn());

  Future<List<Transaction>> linked(Loan l) =>
      isar.transactions.filter().linkedRuleIdEqualTo(l.uid).findAll();

  Future<Loan> reload(Loan l) async => (await isar.loans.filter().uidEqualTo(l.uid).findFirst())!;

  /// The reported home loan: 30 lakh at 8.5% for 20 years, first EMI Jul 2017,
  /// created in Kuber today ("I know the original loan details").
  Future<Loan> create({bool autoRecord = true}) {
    final l = Loan()
      ..name = 'Home Loan'
      ..loanType = 'home'
      ..lenderName = 'Federal Bank'
      ..accountId = '7'
      ..principalAmount = 3000000
      ..emiAmount = refEmi(3000000, 8.5, 240).roundToDouble()
      ..mode = LoanMode.advanced
      ..alreadyRunning = true
      ..startingPoint = LoanStartingPoint.originalDetails
      ..annualRate = 8.5
      ..tenureMonths = 240;
    final s = scheduleFrom(start: first, endType: ScheduleEnd.afterCount, endCount: 240)
      ..autoRecord = autoRecord;
    return LoanService(isar).save(l, s, isNew: true);
  }

  test('A0 fix: saving an edit never back-fills past EMIs (the reported bug)', () async {
    final l = await create();
    await processor().run();
    final before = (await linked(l)).length;
    // Edit loan as the form does: a draft whose schedule is a fresh object
    // (watermark 0) handed to save.
    final draft = (await reload(l)).copy()..name = 'Home Loan SBI';
    draft.schedule = scheduleFrom(start: first, endType: ScheduleEnd.afterCount, endCount: 240)
      ..autoRecord = true;
    await LoanService(isar).save(draft, draft.schedule!);
    await processor().run();
    expect((await linked(l)).length, before, reason: 'no EMI before today is posted');
    expect((await reload(l)).schedule!.processedThrough, greaterThanOrEqualTo(addDays(todayK, -1)));
  });

  test('S19 past EMIs off: a past start date creates no past transactions', () async {
    final l = await create();
    await processor().run();
    final txns = await linked(l);
    // At most today's EMI (when today is an EMI day).
    expect(txns.where((t) => t.occurrenceDate! < todayK), isEmpty);
    // EMIs before today are opening values (today's own EMI is not).
    expect((await reload(l)).emisPaidBefore, monthsUntilToday(first) - (today.day == 5 ? 1 : 0));
  });

  test('S18 past EMIs on from Jul 2017: count, total and balance match the preview', () async {
    final l = await create();
    final service = LoanService(isar);
    final preview = LoanService.pastEmisPreview(l, await service.handledDays(l));
    final expected = monthsUntilToday(first);
    expect(preview.count, expected);
    expect(dayOf(preview.from!), first);

    final progress = <int>[];
    final ids = await service.addPastEmis(await reload(l), chunk: 25, onProgress: (d, _) => progress.add(d));
    expect(ids.length, expected);
    expect(progress.last, expected);
    expect(progress.length, greaterThan(2), reason: 'chunked writes report progress');

    final txns = await linked(l);
    final past = txns.where((t) => t.addedAsPastEmi).toList();
    expect(past.length, expected);
    // The account balance falls by the preview's total (expenses on account 7).
    final spent = past.fold(0.0, (s, t) => s + t.amount);
    expect(spent, closeTo(preview.total, 0.01));
    for (final t in past) {
      expect(t.accountId, '7');
      expect(t.subType, TxnSubType.loanRepayment);
      expect(t.principalPart! + t.interestPart!, closeTo(t.amount, 1e-9));
    }
    // Each has its ledger row; the opening values are zero.
    final ledger = await isar.processedOccurrences.filter().sourceIdEqualTo(l.uid).findAll();
    expect(ledger.length, expected);
    final saved = await reload(l);
    expect(saved.addPastEmis, isTrue);
    expect(saved.emisPaidBefore, 0);
    expect(trackingDay(saved), dayKey(first));
    // No duplicates after a relaunch (processor) or adding again.
    await processor().run();
    expect((await linked(l)).where((t) => t.occurrenceDate! <= todayK).length, expected);
    expect(await service.addPastEmis(await reload(l)), isEmpty);
    // The outstanding equals principal minus every recorded principal.
    final rec = await LoanService.records(isar, l.uid);
    final st = loanStatus(saved, rec.linked, deletedDays: rec.deleted);
    final paid = rec.linked.fold(0.0, (s, t) => s + (t.principalPart ?? 0));
    expect(st.outstanding, closeTo(3000000 - paid, 0.5));
    expect(st.emisPaid, expected);
  });

  test('S20 on later from Edit adds only the missing ones; off removes only unedited', () async {
    final l = await create();
    await processor().run(); // today's EMI when due
    final service = LoanService(isar);
    final already = (await linked(l)).length;
    final ids = await service.addPastEmis(await reload(l));
    expect(ids.length + already, monthsUntilToday(first));

    // The user edits one past EMI's split to match the bank.
    final t = (await isar.transactions.get(ids[10]))!;
    LoanService.applyEditedSplit(t,
        amount: t.amount, principal: t.principalPart! + 50, interest: t.interestPart! - 50);
    t.updatedAt = DateTime.now().add(const Duration(minutes: 1));
    await isar.writeTxn(() => isar.transactions.put(t));

    final r = await service.pastEmisToRemove(await reload(l));
    expect(r.keptEdited, 1);
    final (removed, kept) = await service.removePastEmis(await reload(l));
    expect(removed, ids.length - 1);
    expect(kept, 1);
    final left = await linked(l);
    expect(left.where((x) => x.addedAsPastEmi).single.id, t.id);
    expect((await reload(l)).addPastEmis, isFalse);
    // Turning it on again adds the removed ones back, nothing twice.
    final again = await service.addPastEmis(await reload(l));
    expect(again.length, ids.length - 1);
  });

  test('S5 a deleted EMI returns its principal and is not recreated', () async {
    final l = await create();
    final service = LoanService(isar);
    final ids = await service.addPastEmis(await reload(l));
    final before = await LoanService.records(isar, l.uid);
    final out1 = loanStatus(await reload(l), before.linked).outstanding!;
    final victim = (await isar.transactions.get(ids[ids.length - 3]))!;
    await isar.writeTxn(() => isar.transactions.delete(victim.id));
    final after = await LoanService.records(isar, l.uid);
    expect(after.deleted, {victim.occurrenceDate});
    final out2 = loanStatus(await reload(l), after.linked, deletedDays: after.deleted).outstanding!;
    // Later recorded EMIs keep their split, so exactly that principal is back.
    expect(out2, closeTo(out1 + victim.principalPart!, 0.01));
    await processor().run();
    expect((await linked(l)).where((t) => t.occurrenceDate == victim.occurrenceDate), isEmpty);
  });

  test('S8 interest added to the loan is not a transaction (not spending)', () async {
    final l = await create();
    final n = await isar.transactions.count();
    await LoanService(isar).saveAdjustment(await reload(l),
        date: DateTime(2017, 7, 5),
        amount: 185000,
        reason: LoanAdjustReason.interestAdded,
        adjust: LoanAdjust.tenure);
    expect(await isar.transactions.count(), n);
    final st = loanStatus(await reload(l), const []);
    expect(st.addedInterest, 185000);
  });

  test('S9 Recalculate writes the new splits; the edited EMI is untouched', () async {
    final l = await create();
    final service = LoanService(isar);
    final ids = await service.addPastEmis(await reload(l));
    final edited = (await isar.transactions.get(ids[40]))!;
    LoanService.applyEditedSplit(edited,
        amount: edited.amount, principal: edited.principalPart! - 300, interest: edited.interestPart! + 300);
    await isar.writeTxn(() => isar.transactions.put(edited));
    final editedSplit = (edited.principalPart, edited.interestPart);

    final adjDay = dayOf((await isar.transactions.get(ids[29]))!.occurrenceDate!).add(const Duration(days: 3));
    await service.saveAdjustment(await reload(l),
        date: adjDay, amount: 60000, reason: LoanAdjustReason.matchBank, adjust: LoanAdjust.tenure);
    final rec = await LoanService.records(isar, l.uid);
    final p = LoanService.recalculatePreview(await reload(l), rec, dayKey(adjDay));
    expect(p.count, ids.length - 30 - 1);
    final n = await service.recalculateSplits(await reload(l), dayKey(adjDay));
    expect(n, p.count);

    final after = await linked(l);
    final e = after.firstWhere((t) => t.id == edited.id);
    expect((e.principalPart, e.interestPart), editedSplit);
    // Reference: from the adjusted balance, each later month's interest is
    // the balance times r (edited month as entered).
    final r = 8.5 / 1200;
    final sorted = [...after]..sort((a, b) => a.occurrenceDate!.compareTo(b.occurrenceDate!));
    var bal = 3000000.0;
    var adjusted = false;
    for (final t in sorted) {
      if (!adjusted && t.occurrenceDate! >= dayKey(adjDay)) {
        bal += 60000;
        adjusted = true;
      }
      if (adjusted && !t.splitEdited) {
        // Rounded to paise; earlier recorded EMIs carry paise of rounding.
        expect(t.interestPart, closeTo(bal * r, 0.05), reason: '${t.occurrenceDate}');
      }
      bal -= t.principalPart!;
    }
    // All parts still add up to the amount paid.
    for (final t in after) {
      expect(t.principalPart! + t.interestPart!, closeTo(t.amount, 1e-6));
    }
  });

  test('S21 backup round trip keeps edits, adjustments and past EMIs', () async {
    final l = await create();
    final service = LoanService(isar);
    final ids = await service.addPastEmis(await reload(l));
    final t = (await isar.transactions.get(ids[5]))!;
    LoanService.applyEditedSplit(t, amount: t.amount, principal: t.principalPart! + 1, interest: t.interestPart! - 1);
    await isar.writeTxn(() => isar.transactions.put(t));
    await service.saveAdjustment(await reload(l),
        date: DateTime(2020, 1, 1), amount: -12000, reason: LoanAdjustReason.interestAdded, adjust: LoanAdjust.emi);
    final rec1 = await LoanService.records(isar, l.uid);
    final st1 = loanStatus(await reload(l), rec1.linked, deletedDays: rec1.deleted);

    final json = await JsonBackupService().exportJson(isar);
    expect(json, contains('"version":3'));
    final res = await JsonBackupService().importJson(isar, json);
    expect(res.error, isNull);

    final back = await reload(l);
    expect(back.addPastEmis, isTrue);
    final adj = back.events.singleWhere((e) => e.kind == LoanEventKind.adjustment);
    expect(adj.reason, LoanAdjustReason.interestAdded);
    expect(adj.adjust, LoanAdjust.emi);
    expect(adj.amount, -12000);
    final t2 = (await isar.transactions.get(t.id))!;
    expect(t2.splitEdited, isTrue);
    expect(t2.addedAsPastEmi, isTrue);
    final rec2 = await LoanService.records(isar, l.uid);
    final st2 = loanStatus(back, rec2.linked, deletedDays: rec2.deleted);
    expect(st2.outstanding, st1.outstanding);
    expect(st2.totalInterest, st1.totalInterest);
    expect(st2.endDay, st1.endDay);
  });

  test('S21 a backup from before this release (version 2) still restores', () async {
    final l = await create();
    await LoanService(isar).addPastEmis(await reload(l));
    final rec1 = await LoanService.records(isar, l.uid);
    final st1 = loanStatus(await reload(l), rec1.linked, deletedDays: rec1.deleted);

    // A version 2 file has none of this release's fields.
    final m = jsonDecode(await JsonBackupService().exportJson(isar)) as Map<String, dynamic>;
    m['version'] = 2;
    for (final t in (m['transactions'] as List).cast<Map<String, dynamic>>()) {
      t..remove('splitEdited')..remove('addedAsPastEmi');
    }
    for (final loan in (m['loans'] as List).cast<Map<String, dynamic>>()) {
      loan.remove('addPastEmis');
    }
    final v2 = jsonEncode(m);
    expect(v2, isNot(contains('splitEdited')));

    final res = await JsonBackupService().importJson(isar, v2);
    expect(res.error, isNull);
    final back = await reload(l);
    expect(back.addPastEmis, isFalse);
    final rec2 = await LoanService.records(isar, l.uid);
    expect(rec2.linked.length, rec1.linked.length);
    expect(rec2.linked.every((t) => !t.splitEdited && !t.addedAsPastEmi), isTrue);
    final st2 = loanStatus(back, rec2.linked, deletedDays: rec2.deleted);
    expect(st2.outstanding, st1.outstanding);
    expect(st2.totalInterest, st1.totalInterest);
    expect(st2.endDay, st1.endDay);
  });
}
