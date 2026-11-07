// November release Phase 0: golden values written by the engine BEFORE any
// part of the release touched loans. Loans with no releases, pre-EMI choice or
// new events must keep these numbers exactly: outstanding today, the next 12
// EMI splits, the end date and total interest. It widens
// loan_golden_test.dart to every starting point, edited splits, deleted EMIs,
// "Update outstanding" adjustments (both reasons) and Recalculate.
//
// Regenerate (only before an intended change of numbers):
//   UPDATE_LOAN_GOLDEN=1 flutter test test/features/loans/loan_golden_nov_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/money_math/loan_math.dart';
import 'package:kuber/core/schedule/schedule.dart';
import 'package:kuber/core/schedule/schedule_engine.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/loans/domain/loan_engine.dart';
import 'package:kuber/features/loans/domain/loan_service.dart';
import 'package:kuber/features/transactions/data/transaction.dart';

import 'loan_golden_test.dart' show goldenLoans, postedEmis;

const _path = 'test/fixtures/loans/golden_nov_release.json';
final _now = DateTime(2026, 10, 26, 12);

Loan _base(String key, LoanInterestType type, LoanStartingPoint start,
    {bool running = true, int months = 180, double principal = 1800000, double rate = 9.2,
    int io = 0, bool bank = true, bool pastEmis = false}) {
  final first = running ? DateTime(2020, 2, 12) : DateTime(2026, 12, 12);
  final created = running ? DateTime(2023, 5, 9) : DateTime(2026, 10, 20);
  final kind = switch (type) {
    LoanInterestType.reducingBalance => RateKind.reducing,
    LoanInterestType.flatRate => RateKind.flat,
    LoanInterestType.interestOnlyFirst => RateKind.interestOnlyFirst,
  };
  final plan = regularEmi(kind, principal, rate, months, ioMonths: io);
  final s = scheduleFrom(start: first, endType: ScheduleEnd.afterCount, endCount: months)
    ..autoRecord = true
    ..processedThrough = addDays(dayKey(_now), -1);
  final l = Loan()
    ..uid = key
    ..name = key
    ..loanType = 'home'
    ..lenderName = 'Bank'
    ..accountId = '1'
    ..categoryId = '1'
    ..principalAmount = principal
    ..emiAmount = bank ? plan.roundToDouble() : plan
    ..billDate = 12
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
    ..addPastEmis = pastEmis
    ..schedule = s
    ..dataVersion = 1;
  if (start == LoanStartingPoint.outstandingToday) {
    final full = l.copy()..startingPoint = LoanStartingPoint.originalDetails;
    final o = openingFromOriginal(loanAmortization(full)!, dayKey(created));
    l
      ..outstandingAtStart = o.outstanding
      ..principalPaidBefore = o.principalPaid
      ..interestPaidBefore = o.interestPaid
      ..emisPaidBefore = o.emisPaid
      ..tenureMonths = months - o.emisPaid
      ..interestOnlyMonths = 0
      ..interestType = type == LoanInterestType.flatRate
          ? LoanInterestType.flatRate
          : LoanInterestType.reducingBalance
      ..schedule = (scheduleFrom(
          start: DateTime(2023, 6, 12),
          endType: ScheduleEnd.afterCount,
          endCount: months - o.emisPaid)
        ..autoRecord = true
        ..processedThrough = addDays(dayKey(_now), -1));
  }
  if (start == LoanStartingPoint.trackEmiOnly) {
    l
      ..annualRate = null
      ..emisPaidBefore = 39;
  }
  return l;
}

LoanEvent _ev(LoanEventKind k, DateTime d,
        {double amount = 0, double? rate, LoanAdjust a = LoanAdjust.tenure,
        LoanAdjustReason r = LoanAdjustReason.matchBank, double charge = 0}) =>
    LoanEvent()
      ..kind = k
      ..date = d
      ..amount = amount
      ..newRate = rate
      ..adjust = a
      ..reason = r
      ..charge = charge;

/// One entry of the matrix: the loan and how its recorded EMIs were changed.
class _Case {
  final Loan loan;
  final Map<int, (double principal, double interest)> edited;
  final Set<int> deleted;
  final int? recalculateFrom;
  _Case(this.loan,
      {this.edited = const {}, this.deleted = const {}, this.recalculateFrom});
}

List<_Case> _cases() {
  final out = <_Case>[for (final l in goldenLoans()) _Case(l)];
  var n = 0;
  String k(String s) => 'nov${n++}_$s';
  for (final type in LoanInterestType.values) {
    final io = type == LoanInterestType.interestOnlyFirst ? 24 : 0;
    for (final start in LoanStartingPoint.values) {
      for (final running in [true, false]) {
        if (!running && start == LoanStartingPoint.outstandingToday) continue;
        final tag = '${type.name}_${start.name}_${running ? 'running' : 'new'}';
        Loan b(String t, {bool bank = true, bool past = false}) => _base(k('${tag}_$t'), type,
            start, running: running, io: io, bank: bank, pastEmis: past);
        out.add(_Case(b('plain')));
        out.add(_Case(b('exact', bank: false)));
        if (start == LoanStartingPoint.trackEmiOnly) continue;
        out.add(_Case(b('pastemis', past: running)));
        // Update outstanding: both reasons, both adjust modes, one on an EMI
        // day (applies after that EMI).
        for (final a in LoanAdjust.values) {
          out.add(_Case(b('match_up_${a.name}')
            ..events = [_ev(LoanEventKind.adjustment, DateTime(2025, 8, 20), amount: 25000, a: a)]));
          out.add(_Case(b('match_down_${a.name}')
            ..events = [_ev(LoanEventKind.adjustment, DateTime(2025, 8, 12), amount: -40000.5, a: a)]));
          out.add(_Case(b('interest_added_${a.name}')
            ..events = [
              _ev(LoanEventKind.adjustment, DateTime(2024, 11, 2),
                  amount: 18250, a: a, r: LoanAdjustReason.interestAdded),
            ]));
        }
        out.add(_Case(b('mixed')
          ..events = [
            _ev(LoanEventKind.prepayment, DateTime(2024, 3, 15), amount: 100000, charge: 2000),
            _ev(LoanEventKind.rateChange, DateTime(2024, 9, 1), rate: 8.65, a: LoanAdjust.emi),
            _ev(LoanEventKind.adjustment, DateTime(2025, 4, 1), amount: 9100,
                r: LoanAdjustReason.interestAdded),
            _ev(LoanEventKind.charge, DateTime(2025, 6, 1), amount: 1180),
          ]));
        if (!running) continue;
        // Edited splits and a deleted EMI.
        out.add(_Case(b('edited'), edited: {
          20240412: (5000.0, 13000.0),
          20250212: (9000.0, 9500.0),
        }));
        out.add(_Case(b('deleted'), deleted: {20250512}));
        out.add(_Case(
            b('recalc')
              ..events = [
                _ev(LoanEventKind.adjustment, DateTime(2024, 1, 20), amount: -60000),
              ],
            recalculateFrom: 20240121,
            edited: {20240712: (7000.0, 11000.0)}));
      }
    }
  }
  // Closed loan, zero-rate reducing, a loan past its end.
  out.add(_Case(_base(k('closed'), LoanInterestType.reducingBalance,
      LoanStartingPoint.originalDetails)
    ..isCompleted = true
    ..closedAt = DateTime(2025, 1, 1)));
  out.add(_Case(_base(k('zero'), LoanInterestType.reducingBalance,
      LoanStartingPoint.originalDetails, rate: 0, principal: 360000, months: 36)));
  out.add(_Case(_base(k('ended'), LoanInterestType.flatRate,
      LoanStartingPoint.originalDetails, principal: 240000, months: 24)));
  return out;
}

/// Recorded EMIs of the case: rounded splits, the edited ones, none deleted.
List<Transaction> _linked(_Case c) {
  final out = <Transaction>[];
  for (final t in postedEmis(c.loan)) {
    if (c.deleted.contains(t.occurrenceDate)) continue;
    final e = c.edited[t.occurrenceDate];
    if (e != null) {
      t
        ..principalPart = e.$1
        ..interestPart = e.$2
        ..amount = e.$1 + e.$2
        ..splitEdited = true;
    }
    out.add(t);
  }
  return out;
}

Map<String, dynamic> _snapshot(_Case c) {
  final linked = _linked(c);
  final l = c.loan;
  final st = loanStatus(l, linked, now: _now, deletedDays: c.deleted);
  final a = loanAmortization(l,
      linked: linked, deletedDays: c.deleted, recalculateFrom: c.recalculateFrom);
  final today = dayKey(_now);
  final preview = c.recalculateFrom == null
      ? null
      : LoanService.recalculatePreview(
          l, (linked: linked, deleted: c.deleted), c.recalculateFrom!);
  return {
    'outstanding': st.outstanding,
    'emisPaid': st.emisPaid,
    'totalEmis': st.totalEmis,
    'nextDay': st.nextDay,
    'nextAmount': st.nextAmount,
    'interestPaid': st.interestPaid,
    'principalPaid': st.principalPaid,
    'totalInterest': st.totalInterest,
    'addedInterest': st.addedInterest,
    'endDay': st.endDay,
    'closed': st.closed,
    'next12': [
      for (final r in (a?.rows ?? const <AmortRow>[]).where((r) => r.day > today).take(12))
        [r.day, r.payment, r.principal, r.interest, r.balance, r.rate, r.recorded, r.edited],
    ],
    'recalc': preview == null
        ? null
        : [preview.count, preview.oldInterest, preview.newInterest],
  };
}

void main() {
  test('loans without new data match the Phase 0 golden values exactly', () {
    final cases = _cases();
    if (Platform.environment['UPDATE_LOAN_GOLDEN'] == '1') {
      File(_path)
        ..createSync(recursive: true)
        ..writeAsStringSync(jsonEncode({for (final c in cases) c.loan.uid: _snapshot(c)}));
      return;
    }
    final golden = jsonDecode(File(_path).readAsStringSync()) as Map<String, dynamic>;
    expect(golden.length, cases.length);
    for (final c in cases) {
      expect(jsonDecode(jsonEncode(_snapshot(c))), golden[c.loan.uid], reason: c.loan.uid);
    }
  });
}
