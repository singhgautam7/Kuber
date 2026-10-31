// Loan writes on the shared engine: save from the form, extra payment
// (principal part + optional charge), rate change, close, delete. Opening
// values never create transactions, so they never change a balance.

import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../core/money_math/loan_math.dart';
import '../../../core/schedule/processed_occurrence.dart';
import '../../../core/schedule/schedule.dart';
import '../../../core/schedule/schedule_engine.dart';
import '../../categories/data/category.dart';
import '../../categories/data/category_group.dart';
import '../../transactions/data/transaction.dart';
import '../data/loan.dart';
import 'loan_engine.dart';

class LoanService {
  final Isar isar;
  LoanService(this.isar);

  /// The loan's transactions and the days of recorded EMIs that were deleted
  /// (their ledger row says posted, the transaction is gone).
  static Future<LoanRecords> records(
      Isar isar, String uid) async {
    final linked = await isar.transactions.filter().linkedRuleIdEqualTo(uid).findAll();
    final ledger = await isar.processedOccurrences
        .filter()
        .sourceTypeEqualTo('loan')
        .sourceIdEqualTo(uid)
        .statusEqualTo('posted')
        .findAll();
    return (linked: linked, deleted: deletedEmiDays(ledger, linked.map((t) => t.id).toSet()));
  }

  /// Finds (or creates, in the OTHER group) a system category by name.
  static Future<String> systemCategory(Isar isar, String name,
      {String icon = 'account_balance', int color = 0xFF5C6BC0, String type = 'expense'}) async {
    final existing = await isar.categorys.filter().nameEqualTo(name).findFirst();
    if (existing != null) return '${existing.id}';
    final group = await isar.categoryGroups.filter().nameEqualTo('OTHER').findFirst();
    final c = Category()
      ..name = name
      ..icon = icon
      ..colorValue = color
      ..type = type
      ..isDefault = true
      ..groupId = group?.id;
    final id = await isar.writeTxn(() => isar.categorys.put(c));
    return '$id';
  }

  /// Saves a new or edited loan. For a new loan the watermark is yesterday:
  /// EMIs before today are "Before Kuber" (opening values), never posted;
  /// "Add past EMIs as transactions" adds them afterwards ([addPastEmis]).
  /// An edit keeps the stored watermark, posted count and skips, so nothing
  /// in the past is ever posted by the background run.
  /// [schedule] is the EMI schedule from the form.
  Future<Loan> save(Loan l, Schedule schedule, {bool isNew = false}) async {
    final now = DateTime.now();
    l.updatedAt = now;
    if (isNew) {
      l
        ..uid = const Uuid().v4()
        ..createdAt = now
        ..categoryId = await systemCategory(isar, 'Loan EMI');
      final yesterday = addDays(dayKey(now), -1);
      schedule.processedThrough = yesterday;
      // EMIs that fell before today use up the count (afterCount ends).
      final before = upcomingOccurrences(schedule.copy()..processedThrough = 0,
              toKey: yesterday, limit: 100000)
          .length;
      schedule.postedCount = before;
      if (l.startingPoint == LoanStartingPoint.trackEmiOnly ||
          l.startingPoint == LoanStartingPoint.originalDetails) {
        l.emisPaidBefore = l.alreadyRunning ? before : 0;
      }
    } else {
      // The stored row, not [l.schedule]: the form hands over a draft whose
      // schedule is [schedule] itself (watermark 0), which made the next run
      // post every EMI since the first EMI date (audit.md §4).
      final stored = l.id == Isar.autoIncrement ? null : await isar.loans.get(l.id);
      final old = stored?.schedule ?? (identical(l.schedule, schedule) ? null : l.schedule);
      final yesterday = addDays(dayKey(now), -1);
      schedule
        ..processedThrough = old?.processedThrough ?? yesterday
        ..postedCount = old?.postedCount ??
            upcomingOccurrences(schedule.copy()..processedThrough = 0,
                    toKey: yesterday, limit: 100000)
                .length
        ..skippedDates = old?.skippedDates ?? const []
        ..paused = old?.paused ?? false;
    }
    l
      ..schedule = schedule
      ..dataVersion = 1
      // Legacy mirrors for pre-vNext readers.
      ..billDate = (schedule.anchorDay ?? schedule.startDate!.day).clamp(1, 31)
      ..startDate = schedule.startDate!
      ..interestRate = l.annualRate
      ..autoAddTransaction = schedule.autoRecord
      ..endDate = lastDate(schedule.copy()..processedThrough = 0) == null
          ? null
          : dayOf(lastDate(schedule.copy()..processedThrough = 0)!);
    await isar.writeTxn(() => isar.loans.put(l));
    return l;
  }

  /// Extra payment: principal part as a loan repayment (outstanding goes down
  /// from its date) and an optional charge as an expense in Loan charges.
  /// [towardPrincipal] false: only a fee (expense), outstanding unchanged.
  Future<void> recordExtraPayment(
    Loan l, {
    required double amount,
    required bool towardPrincipal,
    required LoanAdjust reduce,
    required double charge,
    required String accountId,
    required DateTime date,
    String? chargesCategoryId,
  }) async {
    final now = DateTime.now();
    Transaction txn(String name, double value, String categoryId, TxnSubType? sub,
            {double? principal}) =>
        Transaction()
          ..name = name
          ..nameLower = name.toLowerCase()
          ..amount = value
          ..type = 'expense'
          ..accountId = accountId
          ..categoryId = categoryId
          ..linkedRuleId = l.uid
          ..linkedRuleType = 'loan'
          ..sourceType = 'loan'
          ..sourceId = l.uid
          ..subType = sub
          ..principalPart = principal
          ..interestPart = principal == null ? null : 0
          // Count-only-interest: an extra principal payment isn't spending.
          ..spendInterestOnly = principal != null && l.countOnlyInterest
          ..createdAt = DateTime(date.year, date.month, date.day, now.hour, now.minute)
          ..updatedAt = now;
    final chargesCat = chargesCategoryId ??
        await systemCategory(isar, 'Loan charges', icon: 'receipt_long', color: 0xFF8D6E63);
    await isar.writeTxn(() async {
      int? mainId, chargeId;
      if (towardPrincipal && amount > 0) {
        mainId = await isar.transactions.put(
            txn('Extra Payment - ${l.name}', amount, l.categoryId, TxnSubType.loanRepayment,
                principal: amount));
      }
      final fee = towardPrincipal ? charge : amount;
      if (fee > 0) {
        chargeId = await isar.transactions
            // A fee or charge is a plain expense, not a repayment.
            .put(txn('Loan charge - ${l.name}', fee, chargesCat, null));
      }
      l.events = [
        ...l.events,
        LoanEvent()
          ..kind = towardPrincipal ? LoanEventKind.prepayment : LoanEventKind.charge
          ..date = DateTime(date.year, date.month, date.day)
          ..amount = towardPrincipal ? amount : fee
          ..adjust = reduce
          ..charge = towardPrincipal ? charge : 0
          ..transactionId = mainId
          ..chargeTransactionId = chargeId,
      ];
      l.mode = LoanMode.advanced;
      l.updatedAt = now;
      await isar.loans.put(l);
    });
  }

  Future<void> changeRate(Loan l,
      {required double newRate, required DateTime from, required LoanAdjust adjust}) async {
    l.events = [
      ...l.events,
      LoanEvent()
        ..kind = LoanEventKind.rateChange
        ..date = DateTime(from.year, from.month, from.day)
        ..newRate = newRate
        ..adjust = adjust,
    ];
    l
      ..mode = LoanMode.advanced
      ..updatedAt = DateTime.now();
    await isar.writeTxn(() => isar.loans.put(l));
  }

  // ── Update outstanding (A3) and dated changes in the past (A4) ─────────

  /// Adds (or, with [replace], edits) an outstanding adjustment: [amount] is
  /// the signed difference to Kuber's outstanding on [date].
  Future<void> saveAdjustment(Loan l,
      {required DateTime date,
      required double amount,
      required LoanAdjustReason reason,
      required LoanAdjust adjust,
      LoanEvent? replace}) async {
    final e = LoanEvent()
      ..kind = LoanEventKind.adjustment
      ..date = DateTime(date.year, date.month, date.day)
      ..amount = amount
      ..reason = reason
      ..adjust = adjust;
    l
      ..events = [
        for (final x in l.events)
          if (!identical(x, replace)) x,
        e,
      ]
      ..mode = LoanMode.advanced
      ..updatedAt = DateTime.now();
    await isar.writeTxn(() => isar.loans.put(l));
  }

  // ── Past EMIs as transactions (Part B) ───────────────────────────────

  /// The EMI days from the first EMI to today (inclusive) that have no
  /// transaction or ledger row yet.
  static List<int> missingPastEmiDays(Loan l, Set<int> handled, {DateTime? now}) {
    final s = l.schedule;
    if (s == null || s.startDate == null) return const [];
    final all = upcomingOccurrences(
        s.copy()
          ..processedThrough = 0
          ..postedCount = 0
          ..skippedDates = []
          ..paused = false,
        toKey: todayKey(now),
        limit: 100000);
    return [for (final o in all) if (!handled.contains(o.day)) o.day];
  }

  /// Days already handled for the loan: ledger rows and linked EMIs.
  Future<Set<int>> handledDays(Loan l) async {
    final ledger = await isar.processedOccurrences
        .filter()
        .sourceTypeEqualTo('loan')
        .sourceIdEqualTo(l.uid)
        .findAll();
    final linked = await isar.transactions.filter().linkedRuleIdEqualTo(l.uid).findAll();
    return {
      for (final p in ledger) p.occurrenceDate,
      for (final t in linked)
        if (t.occurrenceDate != null) t.occurrenceDate!,
    };
  }

  /// Preview for the switch: how many EMIs, from / to, and the total.
  static ({int count, int? from, int? to, double total}) pastEmisPreview(
      Loan l, Set<int> handled, {int decimals = 2, DateTime? now}) {
    final days = missingPastEmiDays(l, handled, now: now);
    var total = 0.0;
    for (final d in days) {
      total += emiFor(l, d, decimals).amount;
    }
    return (
      count: days.length,
      from: days.isEmpty ? null : days.first,
      to: days.isEmpty ? null : days.last,
      total: total,
    );
  }

  /// Creates one EMI transaction per missing past occurrence (calculated
  /// split, sub type, source link, ledger row), in chunked writes, and sets
  /// the opening values to zero. Returns the new transaction ids.
  Future<List<int>> addPastEmis(Loan l,
      {int decimals = 2,
      int chunk = 100,
      DateTime? now,
      void Function(int done, int total)? onProgress}) async {
    final at = now ?? DateTime.now();
    final stamp = DateTime(at.year, at.month, at.day, at.hour, at.minute, at.second);
    final days = missingPastEmiDays(l, await handledDays(l), now: at);
    final rec = await records(isar, l.uid);
    // One amortization for all of them (missing days have no record, so
    // their split is the calculation from the outstanding at that point).
    final a = loanAmortizationWith(l, rec);
    final from = l.countOnlyInterestFrom;
    final ids = <int>[];
    onProgress?.call(0, days.length);
    for (var i = 0; i < days.length; i += chunk) {
      final part = days.sublist(i, (i + chunk).clamp(0, days.length));
      await isar.writeTxn(() async {
        final txns = <Transaction>[];
        for (final d in part) {
          final row = a?.rowOn(d);
          final sp = row == null ? null : roundedSplit(row.payment, row.interest, decimals);
          final name = 'EMI - ${l.name}';
          txns.add(Transaction()
            ..name = name
            ..nameLower = name.toLowerCase()
            ..amount = sp?.payment ?? l.emiAmount
            ..type = 'expense'
            ..categoryId = l.categoryId
            ..accountId = l.accountId
            ..createdAt = DateTime(d ~/ 10000, d ~/ 100 % 100, d % 100, at.hour, at.minute)
            ..updatedAt = stamp
            ..occurrenceDate = d
            ..sourceType = 'loan'
            ..sourceId = l.uid
            ..linkedRuleType = 'loan'
            ..linkedRuleId = l.uid
            ..subType = TxnSubType.loanRepayment
            ..principalPart = sp?.principal
            ..interestPart = sp?.interest
            ..spendInterestOnly = l.countOnlyInterest &&
                sp != null &&
                (from == null || d >= dayKey(from))
            ..addedAsPastEmi = true);
        }
        final newIds = await isar.transactions.putAll(txns);
        await isar.processedOccurrences.putAll([
          for (var k = 0; k < part.length; k++)
            ProcessedOccurrence()
              ..key = ProcessedOccurrence.keyOf('loan', l.uid, part[k])
              ..sourceType = 'loan'
              ..sourceId = l.uid
              ..occurrenceDate = part[k]
              ..status = 'posted'
              ..transactionId = newIds[k]
              ..createdAt = stamp,
        ]);
        ids.addAll(newIds);
      });
      onProgress?.call(ids.length, days.length);
    }
    final s = l.schedule!;
    final newer = days.where((d) => d > s.processedThrough).length;
    if (days.isNotEmpty && days.last > s.processedThrough) s.processedThrough = days.last;
    s.postedCount += newer;
    l
      ..addPastEmis = true
      ..pastEmisAddedAt = stamp
      // The transactions now cover that history: nothing counted twice.
      ..emisPaidBefore = 0
      ..principalPaidBefore = 0
      ..interestPaidBefore = 0
      ..updatedAt = DateTime.now();
    await isar.writeTxn(() => isar.loans.put(l));
    return ids;
  }

  /// Past EMIs this switch added that the user hasn't edited (the only ones
  /// that can be removed), and the edited ones that stay.
  Future<({List<Transaction> removable, int keptEdited})> pastEmisToRemove(Loan l) async {
    final added = (await isar.transactions.filter().linkedRuleIdEqualTo(l.uid).findAll())
        .where((t) => t.addedAsPastEmi)
        .toList();
    final at = l.pastEmisAddedAt;
    bool edited(Transaction t) =>
        t.splitEdited ||
        (at != null && t.updatedAt.isAfter(at.add(const Duration(seconds: 2))));
    final removable = added.where((t) => !edited(t)).toList();
    return (removable: removable, keptEdited: added.length - removable.length);
  }

  /// Turns "Add past EMIs" off: removes the unedited ones (and their ledger
  /// rows, so turning it on again adds them back) and restores the opening
  /// values. Returns (removed, kept because edited).
  Future<(int, int)> removePastEmis(Loan l, {bool remove = true, DateTime? now}) async {
    final r = await pastEmisToRemove(l);
    await isar.writeTxn(() async {
      if (remove && r.removable.isNotEmpty) {
        await isar.transactions.deleteAll([for (final t in r.removable) t.id]);
        await isar.processedOccurrences.deleteAllByKey([
          for (final t in r.removable)
            ProcessedOccurrence.keyOf('loan', l.uid, t.occurrenceDate!),
        ]);
      }
      final before = upcomingOccurrences(l.schedule!.copy()..processedThrough = 0,
              toKey: addDays(dayKey(l.createdAt), -1), limit: 100000)
          .length;
      l
        ..addPastEmis = false
        ..emisPaidBefore = l.alreadyRunning ? before : 0
        ..updatedAt = DateTime.now();
      await isar.loans.put(l);
    });
    return (remove ? r.removable.length : 0, r.keptEdited);
  }

  /// Deletes an adjustment or an extra payment (with its transactions).
  Future<void> deleteEvent(Loan l, LoanEvent e) async {
    await isar.writeTxn(() async {
      final ids = [e.transactionId, e.chargeTransactionId].whereType<int>().toList();
      if (ids.isNotEmpty) await isar.transactions.deleteAll(ids);
      l
        ..events = [for (final x in l.events) if (!identical(x, e)) x]
        ..updatedAt = DateTime.now();
      await isar.loans.put(l);
    });
  }

  /// Recorded EMIs on or after [fromDay] the user hasn't edited, with their
  /// interest now and after recalculating from the outstanding (A4 preview).
  static ({int count, double oldInterest, double newInterest}) recalculatePreview(
      Loan l, LoanRecords records, int fromDay) {
    final a = loanAmortizationWith(l, records, recalculateFrom: fromDay);
    final byDay = {for (final r in a?.rows ?? const <AmortRow>[]) r.day: r};
    var count = 0;
    var oldI = 0.0, newI = 0.0;
    for (final t in records.linked) {
      final d = t.occurrenceDate;
      if (d == null || d < fromDay || t.splitEdited || t.interestPart == null) continue;
      final row = byDay[d];
      if (row == null) continue;
      count++;
      oldI += t.interestPart!;
      newI += row.interest;
    }
    return (count: count, oldInterest: oldI, newInterest: newI);
  }

  /// Splits the unedited recorded EMIs on or after [fromDay] again, in date
  /// order from the adjusted outstanding. Edited EMIs are never touched (their
  /// principal still counts). One write transaction.
  Future<int> recalculateSplits(Loan l, int fromDay, {int decimals = 2}) async {
    final rec = await records(isar, l.uid);
    final a = loanAmortizationWith(l, rec, recalculateFrom: fromDay);
    if (a == null) return 0;
    final byDay = {for (final r in a.rows) r.day: r};
    final changed = <Transaction>[];
    for (final t in rec.linked) {
      final d = t.occurrenceDate;
      if (d == null || d < fromDay || t.splitEdited || t.principalPart == null) continue;
      final row = byDay[d];
      if (row == null) continue;
      final sp = roundedSplit(t.amount, row.interest, decimals);
      t
        ..principalPart = sp.principal
        ..interestPart = sp.interest
        ..updatedAt = DateTime.now();
      changed.add(t);
    }
    if (changed.isNotEmpty) await isar.writeTxn(() => isar.transactions.putAll(changed));
    return changed.length;
  }

  /// Saves a user-edited EMI split (A2): the parts always add up to [amount].
  static void applyEditedSplit(Transaction t,
      {required double amount, required double principal, required double interest}) {
    final changed = (t.principalPart ?? -1) != principal || (t.interestPart ?? -1) != interest;
    t
      ..amount = amount
      ..principalPart = principal
      ..interestPart = interest;
    if (changed) t.splitEdited = true;
  }

  Future<void> close(Loan l) async {
    l
      ..isCompleted = true
      ..closedAt = DateTime.now()
      ..updatedAt = DateTime.now();
    await isar.writeTxn(() => isar.loans.put(l));
  }

  /// Re-open a closed loan. EMIs that fell while it was closed are passed,
  /// not posted (like resuming a paused schedule): its next EMI is the next
  /// date from today and its end date does not move.
  Future<void> reopen(Loan l, {DateTime? now}) async {
    final s = l.schedule;
    if (s != null) {
      final yesterday = addDays(todayKey(now), -1);
      if (s.processedThrough < yesterday) {
        final missed = upcomingOccurrences(s, toKey: yesterday, limit: 100000);
        s
          ..postedCount += missed.length
          ..processedThrough = yesterday;
      }
    }
    l
      ..isCompleted = false
      ..closedAt = null
      ..updatedAt = DateTime.now();
    await isar.writeTxn(() => isar.loans.put(l));
  }

  /// What an extra payment saves (preview), or null without loan numbers.
  static ({double saved, int monthsSooner, double newEmi, int endDay})? extraPaymentPreview(
      Loan l, double amount, LoanAdjust reduce, DateTime date,
      {LoanRecords records = noLoanRecords}) {
    if (!hasLoanNumbers(l) || amount <= 0) return null;
    final base = loanAmortizationWith(l, records);
    final copy = l.copy()
      ..events = [
        ...l.events,
        LoanEvent()
          ..kind = LoanEventKind.prepayment
          ..date = date
          ..amount = amount
          ..adjust = reduce,
      ];
    final after = loanAmortizationWith(copy, records);
    if (base == null || after == null) return null;
    final next = after.rows.where((r) => r.day > dayKey(date)).firstOrNull;
    return (
      saved: base.totalInterest - after.totalInterest,
      monthsSooner: base.rows.length - after.rows.length,
      newEmi: next?.payment ?? l.emiAmount,
      // Paying it all off before the next EMI: it ends on the payment day.
      endDay: after.rows.isEmpty ? dayKey(date) : after.rows.last.day,
    );
  }

  /// What a rate change does (preview), or null without loan numbers.
  static ({double newEmi, int monthsDelta, double interestDelta, int? endDay})? ratePreview(
      Loan l, double newRate, DateTime from, LoanAdjust adjust,
      {LoanRecords records = noLoanRecords}) {
    if (!hasLoanNumbers(l)) return null;
    final base = loanAmortizationWith(l, records);
    final copy = l.copy()
      ..events = [
        ...l.events,
        LoanEvent()
          ..kind = LoanEventKind.rateChange
          ..date = from
          ..newRate = newRate
          ..adjust = adjust,
      ];
    final after = loanAmortizationWith(copy, records);
    if (base == null || after == null) return null;
    final next = after.rows.where((r) => r.day >= dayKey(from)).firstOrNull;
    return (
      newEmi: next?.payment ?? l.emiAmount,
      monthsDelta: base.rows.length - after.rows.length,
      interestDelta: base.totalInterest - after.totalInterest,
      endDay: after.rows.isEmpty ? null : after.rows.last.day,
    );
  }

  /// Opening values for "I know the original loan details" at today.
  static OpeningValues? openingValues(Loan l) {
    final saved = l.adjustment;
    l.adjustment = 0;
    try {
      final a = loanAmortization(l);
      return a == null ? null : openingFromOriginal(a, todayKey());
    } finally {
      l.adjustment = saved;
    }
  }
}
