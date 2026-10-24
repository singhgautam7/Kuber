// Loan writes on the shared engine: save from the form, extra payment
// (principal part + optional charge), rate change, close, delete. Opening
// values never create transactions, so they never change a balance.

import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../core/money_math/loan_math.dart';
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
  /// EMIs before today are "Before Kuber" (opening values), never posted.
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
      final old = l.schedule!;
      schedule
        ..processedThrough = old.processedThrough
        ..postedCount = old.postedCount
        ..skippedDates = old.skippedDates
        ..paused = old.paused;
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

  Future<void> close(Loan l) async {
    l
      ..isCompleted = true
      ..closedAt = DateTime.now()
      ..updatedAt = DateTime.now();
    await isar.writeTxn(() => isar.loans.put(l));
  }

  /// What an extra payment saves (preview), or null without loan numbers.
  static ({double saved, int monthsSooner, double newEmi, int endDay})? extraPaymentPreview(
      Loan l, double amount, LoanAdjust reduce, DateTime date) {
    if (!hasLoanNumbers(l) || amount <= 0) return null;
    final base = loanAmortization(l);
    final copy = l.copy()
      ..events = [
        ...l.events,
        LoanEvent()
          ..kind = LoanEventKind.prepayment
          ..date = date
          ..amount = amount
          ..adjust = reduce,
      ];
    final after = loanAmortization(copy);
    if (base == null || after == null) return null;
    final next = after.rows.where((r) => r.day > dayKey(date)).firstOrNull;
    return (
      saved: base.totalInterest - after.totalInterest,
      monthsSooner: base.rows.length - after.rows.length,
      newEmi: next?.payment ?? l.emiAmount,
      endDay: after.rows.last.day,
    );
  }

  /// What a rate change does (preview), or null without loan numbers.
  static ({double newEmi, int monthsDelta, double interestDelta, int? endDay})? ratePreview(
      Loan l, double newRate, DateTime from, LoanAdjust adjust) {
    if (!hasLoanNumbers(l)) return null;
    final base = loanAmortization(l);
    final copy = l.copy()
      ..events = [
        ...l.events,
        LoanEvent()
          ..kind = LoanEventKind.rateChange
          ..date = from
          ..newRate = newRate
          ..adjust = adjust,
      ];
    final after = loanAmortization(copy);
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
