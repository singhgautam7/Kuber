// Investment writes: create / edit, add money (top-up), update values, past
// values, withdraw (proportional cost basis), close, FD maturity (move /
// renew) and early FD withdrawal. Withdrawals are income transactions with
// subType investment_return and the source link; opening values never touch
// a balance.

import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../core/money_math/investment_math.dart';
import '../../../core/schedule/schedule.dart';
import '../../../core/schedule/schedule_engine.dart';
import '../../loans/domain/loan_service.dart';
import '../../transactions/data/transaction.dart';
import '../data/investment.dart';
import 'investment_engine.dart';

class InvestmentService {
  final Isar isar;
  InvestmentService(this.isar);

  Transaction _txn(Investment i, String name, double amount, String type, String accountId,
      DateTime date, String categoryId, TxnSubType sub) {
    final now = DateTime.now();
    return Transaction()
      ..name = name
      ..nameLower = name.toLowerCase()
      ..amount = amount
      ..type = type
      ..accountId = accountId
      ..categoryId = categoryId
      ..linkedRuleId = i.uid
      ..linkedRuleType = 'investment'
      ..sourceType = 'investment'
      ..sourceId = i.uid
      ..subType = sub
      ..createdAt = DateTime(date.year, date.month, date.day, now.hour, now.minute)
      ..updatedAt = now;
  }

  /// Creates a holding. [firstAmount] (one time / opening deposit) is
  /// recorded from [accountId] unless [alreadyRunning]: opening values never
  /// change a balance. A SIP / RD schedule starts with its watermark before
  /// its first date, so a start in the past catches up.
  Future<Investment> create(Investment i,
      {double firstAmount = 0, Schedule? sip, DateTime? firstDate}) async {
    final now = DateTime.now();
    i
      ..uid = const Uuid().v4()
      ..createdAt = now
      ..updatedAt = now
      ..categoryId = await LoanService.systemCategory(isar, 'Investment',
          icon: 'show_chart', color: 0xFF26A69A)
      ..dataVersion = 1
      ..status = InvestmentStatus.active
      ..sip = sip
      ..autoDebit = sip != null
      ..sipDate = sip?.anchorDay;
    if (i.alreadyRunning) {
      i
        ..openingInvested = i.investedAmount ?? 0
        ..openingValue = i.currentValue
        ..openingDate = now;
    }
    if (i.currentValue != null) {
      i.snapshots = [
        ValueSnapshot()
          ..date = now
          ..value = i.currentValue!,
      ];
    }
    if (hasFixedTerms(i)) i.maturityDate = maturityDateOf(i);
    await isar.writeTxn(() async {
      await isar.investments.put(i);
      if (firstAmount > 0 && !i.alreadyRunning && i.accountId != null) {
        await isar.transactions.put(_txn(i, 'Contribution - ${i.name}', firstAmount, 'expense',
            i.accountId!, firstDate ?? now, i.categoryId, TxnSubType.investment));
      }
    });
    return i;
  }

  Future<void> save(Investment i) async {
    i.updatedAt = DateTime.now();
    if (hasFixedTerms(i)) i.maturityDate = maturityDateOf(i);
    if (i.sip != null) {
      i
        ..autoDebit = true
        ..sipDate = i.sip!.anchorDay;
    }
    await isar.writeTxn(() => isar.investments.put(i));
  }

  /// Add money (top-up): an expense from the account; invested goes up.
  Future<void> addMoney(Investment i,
      {required double amount, required String accountId, required DateTime date}) async {
    i
      ..investedAmount = (i.investedAmount ?? 0) + amount
      ..updatedAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.transactions.put(_txn(i, 'Top-up - ${i.name}', amount, 'expense', accountId, date,
          i.categoryId, TxnSubType.investment));
      await isar.investments.put(i);
    });
  }

  /// A new value today (or [date]); the newest snapshot is the current value.
  Future<void> updateValue(Investment i, double value, {DateTime? date}) async {
    final d = date ?? DateTime.now();
    i.snapshots = [
      ...i.snapshots,
      ValueSnapshot()
        ..date = d
        ..value = value,
    ]..sort((a, b) => a.date!.compareTo(b.date!));
    i
      ..currentValue = i.snapshots.last.value
      ..updatedAt = DateTime.now();
    await isar.writeTxn(() => isar.investments.put(i));
  }

  Future<void> updateValues(Map<Investment, double> values) async {
    final now = DateTime.now();
    await isar.writeTxn(() async {
      for (final e in values.entries) {
        final i = e.key;
        i.snapshots = [
          ...i.snapshots,
          ValueSnapshot()
            ..date = now
            ..value = e.value,
        ];
        i
          ..currentValue = e.value
          ..updatedAt = now;
        await isar.investments.put(i);
      }
    });
  }

  Future<void> editSnapshot(Investment i, int index, {DateTime? date, double? value}) async {
    final list = [...i.snapshots];
    final s = list[index];
    list[index] = ValueSnapshot()
      ..date = date ?? s.date
      ..value = value ?? s.value;
    list.sort((a, b) => a.date!.compareTo(b.date!));
    i
      ..snapshots = list
      ..currentValue = list.isEmpty ? i.currentValue : list.last.value;
    await isar.writeTxn(() => isar.investments.put(i));
  }

  Future<void> deleteSnapshot(Investment i, int index) async {
    final list = [...i.snapshots]..removeAt(index);
    i
      ..snapshots = list
      ..currentValue = list.isEmpty ? i.currentValue : list.last.value;
    await isar.writeTxn(() => isar.investments.put(i));
  }

  /// Withdraw: an income transaction of the amount received into
  /// [accountId]; invested reduces in proportion to the value redeemed and the
  /// realized gain is recorded. [closeAfter] moves it to Closed.
  Future<void> withdraw(
    Investment i, {
    required double redeemed,
    required double charges,
    required double received,
    required String accountId,
    required DateTime date,
    bool closeAfter = false,
  }) async {
    final value = currentValue(i);
    final w = proportionalWithdrawal(
        invested: investedOf(i), value: value, redeemed: redeemed, charges: charges, received: received);
    final incomeCat = await LoanService.systemCategory(isar, 'Investment returns',
        icon: 'trending_up', color: 0xFF26A69A, type: 'income');
    await isar.writeTxn(() async {
      final tid = await isar.transactions.put(_txn(i, 'Withdrawal - ${i.name}', received,
          'income', accountId, date, incomeCat, TxnSubType.investmentReturn));
      i
        ..withdrawals = [
          ...i.withdrawals,
          Withdrawal()
            ..date = date
            ..redeemed = redeemed
            ..charges = charges
            ..received = received
            ..accountId = accountId
            ..investedReduction = w.investedReduction
            ..realizedGain = w.realizedGain
            ..transactionId = tid,
        ]
        ..investedAmount = closeAfter ? 0 : investedOf(i) - w.investedReduction
        ..updatedAt = DateTime.now();
      if (i.behaviour != InvestmentBehaviour.fixedReturn) {
        final left = closeAfter ? 0.0 : (value - redeemed).clamp(0.0, double.infinity);
        i.snapshots = [
          ...i.snapshots,
          ValueSnapshot()
            ..date = date
            ..value = left,
        ];
        i.currentValue = left;
      }
      if (closeAfter) {
        i
          ..status = InvestmentStatus.closed
          ..closedAt = DateTime.now();
        if (i.sip != null) i.sip = i.sip!.copy()..paused = true;
      }
      await isar.investments.put(i);
    });
  }

  /// FD maturity "Move to {account}": the maturity amount comes in and the
  /// FD closes.
  Future<void> moveMatured(Investment i, String accountId) async {
    final amount = maturityValue(i) ?? currentValue(i);
    await withdraw(i,
        redeemed: amount,
        charges: 0,
        received: amount,
        accountId: accountId,
        date: i.maturityDate ?? DateTime.now(),
        closeAfter: true);
    i.maturityHandled = true;
    await isar.writeTxn(() => isar.investments.put(i));
  }

  /// "Renew": a new term from maturity with the maturity amount as principal.
  Future<void> renew(Investment i) async {
    final amount = maturityValue(i) ?? currentValue(i);
    i
      ..fixedPrincipal = amount
      ..fixedStart = i.maturityDate
      ..investedAmount = amount
      ..maturityHandled = false;
    i.maturityDate = maturityDateOf(i);
    await save(i);
  }

  Future<void> markMaturityHandled(Investment i) async {
    i.maturityHandled = true;
    await save(i);
  }

  Future<void> close(Investment i) async {
    i
      ..status = InvestmentStatus.closed
      ..closedAt = DateTime.now();
    if (i.sip != null) i.sip = i.sip!.copy()..paused = true;
    await save(i);
  }

  /// SIP next dates for the step-up notice: amount now and after the next
  /// two anniversaries.
  static List<(DateTime, double)> stepUpPreview(Investment i, int count) {
    final s = i.sip;
    if (s == null || s.startDate == null) return const [];
    final start = s.startDate!;
    return [
      for (var y = 0; y < count; y++)
        (
          DateTime(start.year + y, start.month, start.day),
          stepUpAmount(
              base: i.sipAmount ?? i.installment ?? 0,
              start: start,
              on: DateTime(start.year + y, start.month, start.day),
              percent: i.stepUpKind == StepUpKind.percent,
              value: i.stepUpValue)
        ),
    ];
  }

  /// Unused SIP occurrences before today (used when editing the schedule).
  static int pastOccurrences(Schedule s) => upcomingOccurrences(
          s.copy()..processedThrough = 0,
          toKey: addDays(todayKey(), -1),
          limit: 100000)
      .length;
}
