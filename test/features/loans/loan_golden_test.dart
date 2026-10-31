// Loan accuracy A0 / S22: golden values written by the engine BEFORE the
// "outstanding from what was actually paid" change. Every loan here has no
// edits, adjustments or new settings, so outstanding, the next 12 projected
// EMI splits, the end date and total interest must stay exactly the same.
//
// Each loan is checked twice: with no linked transactions, and with the EMIs
// the background processor would have recorded (their rounded splits are in
// the fixture, written by the old engine).
//
// Regenerate (only before an intended change of numbers):
//   UPDATE_LOAN_GOLDEN=1 flutter test test/features/loans/loan_golden_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/money_math/loan_math.dart';
import 'package:kuber/core/schedule/schedule.dart';
import 'package:kuber/core/schedule/schedule_engine.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/loans/domain/loan_engine.dart';
import 'package:kuber/features/transactions/data/transaction.dart';

const _path = 'test/fixtures/loans/golden_pre_accuracy.json';
final _now = DateTime(2026, 10, 26, 12);

/// One loan of the matrix, built the way the form and service save it.
Loan _loan(String key, {
  required LoanInterestType type,
  required LoanStartingPoint start,
  required bool running,
  double principal = 2500000,
  double rate = 8.5,
  int months = 240,
  int io = 0,
  bool bankEmi = false,
  bool onlyInterest = false,
  double adjustment = 0,
  List<LoanEvent> events = const [],
  bool todayPosted = false,
}) {
  final first = running ? DateTime(2019, 7, 5) : DateTime(2026, 11, 5);
  final created = running ? DateTime(2024, 3, 18) : DateTime(2026, 10, 20);
  final kind = switch (type) {
    LoanInterestType.reducingBalance => RateKind.reducing,
    LoanInterestType.flatRate => RateKind.flat,
    LoanInterestType.interestOnlyFirst => RateKind.interestOnlyFirst,
  };
  final plan = regularEmi(kind, principal, rate, months, ioMonths: io);
  final l = Loan()
    ..uid = key
    ..name = key
    ..loanType = 'home'
    ..lenderName = 'Bank'
    ..accountId = '1'
    ..categoryId = '1'
    ..principalAmount = principal
    ..emiAmount = bankEmi ? plan.roundToDouble() : plan
    ..billDate = 5
    ..startDate = first
    ..createdAt = created
    ..updatedAt = created
    ..mode = LoanMode.advanced
    ..interestType = type
    ..interestOnlyMonths = io
    ..annualRate = rate
    ..tenureMonths = months
    ..alreadyRunning = running
    ..startingPoint = start
    ..countOnlyInterest = onlyInterest
    ..countOnlyInterestFrom = onlyInterest ? created : null
    ..adjustment = adjustment
    ..events = [...events]
    ..dataVersion = 1;
  Schedule s;
  if (start == LoanStartingPoint.outstandingToday) {
    // Outstanding today: the opening balance is what the plan says is owed
    // at tracking start; the schedule runs from the next EMI.
    final full = (l.copy()..startingPoint = LoanStartingPoint.originalDetails)
      ..schedule = scheduleFrom(start: first, endType: ScheduleEnd.afterCount, endCount: months);
    final o = openingFromOriginal(loanAmortization(full)!, dayKey(created));
    final left = months - o.emisPaid;
    l
      ..outstandingAtStart = o.outstanding
      ..principalPaidBefore = o.principalPaid
      ..interestPaidBefore = o.interestPaid
      ..emisPaidBefore = o.emisPaid
      ..tenureMonths = left
      ..interestOnlyMonths = 0
      ..interestType = type == LoanInterestType.flatRate
          ? LoanInterestType.flatRate
          : LoanInterestType.reducingBalance;
    s = scheduleFrom(
        start: DateTime(2024, 4, 5), endType: ScheduleEnd.afterCount, endCount: left);
  } else {
    s = scheduleFrom(start: first, endType: ScheduleEnd.afterCount, endCount: months);
  }
  final today = dayKey(_now);
  s
    ..autoRecord = true
    ..processedThrough = todayPosted ? today : addDays(today, -1);
  l.schedule = s;
  return l;
}

LoanEvent _prepay(DateTime d, double amount, LoanAdjust a) => LoanEvent()
  ..kind = LoanEventKind.prepayment
  ..date = d
  ..amount = amount
  ..adjust = a;

LoanEvent _rate(DateTime d, double r, LoanAdjust a) => LoanEvent()
  ..kind = LoanEventKind.rateChange
  ..date = d
  ..newRate = r
  ..adjust = a;

LoanEvent _charge(DateTime d, double amount) => LoanEvent()
  ..kind = LoanEventKind.charge
  ..date = d
  ..amount = amount;

List<Loan> goldenLoans() {
  final out = <Loan>[];
  var n = 0;
  String k(String s) => '${n++}_$s';
  for (final type in LoanInterestType.values) {
    final io = type == LoanInterestType.interestOnlyFirst ? 12 : 0;
    for (final start in [
      LoanStartingPoint.originalDetails,
      LoanStartingPoint.outstandingToday,
    ]) {
      for (final running in [false, true]) {
        if (start == LoanStartingPoint.outstandingToday && !running) continue;
        for (final bank in [false, true]) {
          final tag = '${type.name}_${start.name}_${running ? 'running' : 'new'}_${bank ? 'bankemi' : 'exact'}';
          out.add(_loan(k(tag), type: type, start: start, running: running, io: io, bankEmi: bank));
          out.add(_loan(k('${tag}_today'), type: type, start: start, running: running, io: io,
              bankEmi: bank, todayPosted: true));
          out.add(_loan(k('${tag}_prepay_tenure'), type: type, start: start, running: running,
              io: io, bankEmi: bank,
              events: [_prepay(DateTime(2025, 3, 10), 200000, LoanAdjust.tenure)]));
          out.add(_loan(k('${tag}_prepay_emi'), type: type, start: start, running: running,
              io: io, bankEmi: bank,
              events: [_prepay(DateTime(2025, 3, 10), 200000, LoanAdjust.emi)]));
          out.add(_loan(k('${tag}_rate_tenure'), type: type, start: start, running: running,
              io: io, bankEmi: bank,
              events: [_rate(DateTime(2025, 6, 1), 9.25, LoanAdjust.tenure)]));
          out.add(_loan(k('${tag}_rate_emi'), type: type, start: start, running: running,
              io: io, bankEmi: bank,
              events: [
                _rate(DateTime(2025, 6, 1), 7.9, LoanAdjust.emi),
                _prepay(DateTime(2026, 1, 20), 50000, LoanAdjust.tenure),
                _charge(DateTime(2026, 1, 20), 1180),
              ]));
          out.add(_loan(k('${tag}_future_events'), type: type, start: start, running: running,
              io: io, bankEmi: bank, onlyInterest: true,
              events: [
                _prepay(DateTime(2027, 2, 1), 100000, LoanAdjust.emi),
                _rate(DateTime(2027, 8, 1), 8.0, LoanAdjust.tenure),
              ]));
        }
      }
    }
  }
  // Opening adjustment (the user overrode the calculated outstanding).
  out.add(_loan(k('reducing_adjusted_up'), type: LoanInterestType.reducingBalance,
      start: LoanStartingPoint.originalDetails, running: true, adjustment: 35000));
  out.add(_loan(k('reducing_adjusted_down'), type: LoanInterestType.reducingBalance,
      start: LoanStartingPoint.originalDetails, running: true, adjustment: -42000.5,
      bankEmi: true));
  // Small, short and zero-rate loans.
  out.add(_loan(k('personal_14pc_36'), type: LoanInterestType.reducingBalance,
      start: LoanStartingPoint.originalDetails, running: true, principal: 300000,
      rate: 14, months: 36, bankEmi: true));
  out.add(_loan(k('zero_rate'), type: LoanInterestType.reducingBalance,
      start: LoanStartingPoint.originalDetails, running: true, principal: 120000,
      rate: 0, months: 24));
  out.add(_loan(k('ended_loan'), type: LoanInterestType.reducingBalance,
      start: LoanStartingPoint.originalDetails, running: true, principal: 200000,
      rate: 10, months: 24));
  out.add(_loan(k('car_9_2_60_bank'), type: LoanInterestType.reducingBalance,
      start: LoanStartingPoint.originalDetails, running: true, principal: 900000,
      rate: 9.2, months: 60, bankEmi: true, onlyInterest: true));
  return out;
}

/// The EMIs the processor would have recorded from tracking start to the
/// watermark (rounded split, like `emiFor` with 2 decimals).
List<Transaction> postedEmis(Loan l) {
  final a = loanAmortization(l);
  final s = l.schedule!;
  final from = trackingDay(l);
  return [
    for (final r in a?.rows ?? const <AmortRow>[])
      if (r.day >= from && r.day <= s.processedThrough)
        (() {
          final sp = roundedSplit(r.payment, r.interest, 2);
          return Transaction()
            ..id = r.day
            ..name = 'EMI - ${l.name}'
            ..amount = sp.payment
            ..type = 'expense'
            ..categoryId = '1'
            ..accountId = '1'
            ..createdAt = dayOf(r.day)
            ..updatedAt = dayOf(r.day)
            ..nameLower = 'emi'
            ..linkedRuleType = 'loan'
            ..linkedRuleId = l.uid
            ..sourceType = 'loan'
            ..sourceId = l.uid
            ..subType = TxnSubType.loanRepayment
            ..occurrenceDate = r.day
            ..principalPart = sp.principal
            ..interestPart = sp.interest;
        })(),
  ];
}

Map<String, dynamic> snapshot(Loan l, List<Transaction> linked) {
  final st = loanStatus(l, linked, now: _now);
  final a = loanAmortization(l, linked: linked);
  final today = dayKey(_now);
  return {
    'outstanding': st.outstanding,
    'emisPaid': st.emisPaid,
    'totalEmis': st.totalEmis,
    'nextDay': st.nextDay,
    'nextAmount': st.nextAmount,
    'interestPaid': st.interestPaid,
    'principalPaid': st.principalPaid,
    'totalInterest': st.totalInterest,
    'endDay': st.endDay,
    'next12': [
      for (final r in (a?.rows ?? const <AmortRow>[]).where((r) => r.day > today).take(12))
        [r.day, r.payment, r.principal, r.interest, r.balance, r.rate],
    ],
  };
}

void main() {
  test('loan golden values are unchanged (A0 / S22)', () {
    final loans = goldenLoans();
    if (Platform.environment['UPDATE_LOAN_GOLDEN'] == '1') {
      final out = <String, dynamic>{};
      for (final l in loans) {
        final posted = postedEmis(l);
        out[l.uid] = {
          'posted': [for (final t in posted) [t.occurrenceDate, t.amount, t.principalPart, t.interestPart]],
          'plain': snapshot(l, const []),
          'withPosted': snapshot(l, posted),
        };
      }
      File(_path)
        ..createSync(recursive: true)
        ..writeAsStringSync(const JsonEncoder.withIndent(' ').convert(out));
      return;
    }
    final golden = jsonDecode(File(_path).readAsStringSync()) as Map<String, dynamic>;
    expect(golden.length, loans.length);
    for (final l in loans) {
      final g = golden[l.uid] as Map<String, dynamic>;
      // The recorded EMIs come from the fixture (written by the old engine).
      final posted = [
        for (final p in (g['posted'] as List))
          Transaction()
            ..id = p[0] as int
            ..name = 'EMI - ${l.name}'
            ..amount = (p[1] as num).toDouble()
            ..type = 'expense'
            ..categoryId = '1'
            ..accountId = '1'
            ..createdAt = dayOf(p[0] as int)
            ..updatedAt = dayOf(p[0] as int)
            ..nameLower = 'emi'
            ..linkedRuleType = 'loan'
            ..linkedRuleId = l.uid
            ..sourceType = 'loan'
            ..sourceId = l.uid
            ..subType = TxnSubType.loanRepayment
            ..occurrenceDate = p[0] as int
            ..principalPart = (p[2] as num).toDouble()
            ..interestPart = (p[3] as num).toDouble(),
      ];
      expect(jsonDecode(jsonEncode(snapshot(l, const []))), g['plain'], reason: '${l.uid} plain');
      expect(jsonDecode(jsonEncode(snapshot(l, posted))), g['withPosted'],
          reason: '${l.uid} with recorded EMIs');
    }
  });
}
