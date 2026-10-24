// The loan solver combination table: each starting point x which fields are
// known x interest type. One test per row (loan_math_test.dart). The same
// rows are documented in specs/vnext/loan-solver.md.

import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/money_math/loan_math.dart';
import 'package:kuber/core/schedule/schedule.dart';
import 'package:kuber/core/schedule/schedule_engine.dart';

class SolverRow {
  final String id;
  final void Function() check;
  const SolverRow(this.id, this.check);
}

class _Base {
  final RateKind kind;
  final double p, r;
  final int n, io;
  const _Base(this.kind, this.p, this.r, this.n, [this.io = 0]);
  double get emi => regularEmi(kind, p, r, n, ioMonths: io);
  double get total => switch (kind) {
        RateKind.reducing => emi * n,
        RateKind.flat => p + flatInterest(p, r, n),
        RateKind.interestOnlyFirst => io * monthlyInterest(p, r) + emi * (n - io),
      };
  LoanSolution solve(
          {bool p_ = true,
          bool r_ = true,
          bool n_ = true,
          bool e_ = true,
          double? emiOverride,
          bool total = false}) =>
      solveLoan(
        principal: p_ ? p : null,
        rate: r_ ? r : null,
        months: n_ ? n : null,
        emi: e_ ? (emiOverride ?? emi) : null,
        totalPayable: total ? this.total : null,
        kind: kind,
        ioMonths: io,
      );
}

const _bases = [
  _Base(RateKind.reducing, 2500000, 8.5, 240),
  _Base(RateKind.flat, 500000, 9, 60),
  _Base(RateKind.interestOnlyFirst, 400000, 9.5, 72, 12),
];

void _close(double a, double b, {double rel = 1e-9}) =>
    expect((a - b).abs() <= rel * (b.abs() + 1), isTrue, reason: '$a vs $b');

List<int> _days(int n) => upcomingOccurrences(
        scheduleFrom(start: DateTime(2020, 1, 5), unit: ScheduleUnit.month),
        limit: n)
    .map((o) => o.day)
    .toList();

final List<SolverRow> loanSolverTable = [
  for (final b in _bases) ...[
    // ── Starting point 1: I know the original loan details ──────────────
    SolverRow('original · ${b.kind.name} · P r n -> EMI', () {
      final s = b.solve(e_: false);
      expect(s.calculated, LoanField.emi);
      _close(s.emi, b.emi);
    }),
    SolverRow('original · ${b.kind.name} · P r EMI -> tenure', () {
      final s = b.solve(n_: false);
      expect(s.calculated, LoanField.tenure);
      expect(s.months, b.n);
    }),
    SolverRow('original · ${b.kind.name} · P n EMI -> rate', () {
      final s = b.solve(r_: false);
      expect(s.calculated, LoanField.rate);
      _close(s.rate, b.r, rel: 1e-8);
    }),
    SolverRow('original · ${b.kind.name} · r n EMI -> principal', () {
      final s = b.solve(p_: false);
      expect(s.calculated, LoanField.principal);
      _close(s.principal, b.p, rel: 1e-9);
    }),
    SolverRow('original · ${b.kind.name} · P n total payable -> rate + EMI', () {
      final s = b.solve(r_: false, e_: false, total: true);
      expect(s.calculated, LoanField.rate);
      _close(s.rate, b.r, rel: 1e-8);
      _close(s.emi, b.emi, rel: 1e-8);
    }),
    SolverRow('original · ${b.kind.name} · all four consistent -> no mismatch',
        () {
      final s = b.solve();
      expect(s.calculated, isNull);
      expect(s.mismatch.abs(), lessThan(1e-6));
    }),
    SolverRow('original · ${b.kind.name} · all four, EMI +120 -> mismatch', () {
      final s = b.solve(emiOverride: b.emi + 120);
      expect(s.mismatch, closeTo(120, 1e-6));
      expect(s.emi, b.emi + 120); // the user's EMI pays
      expect(s.rate, b.r); // the rate splits
    }),
    SolverRow('original · ${b.kind.name} · opening values after 30 EMIs', () {
      final a = amortize(
          principal: b.p,
          rate: b.r,
          months: b.n,
          kind: b.kind,
          ioMonths: b.io,
          emiDays: _days(b.n));
      final tracking = addDays(a.rows[29].day, 1);
      final o = openingFromOriginal(a, tracking);
      expect(o.emisPaid, 30);
      _close(o.principalPaid + o.outstanding, b.p, rel: 1e-9);
      _close(o.interestPaid,
          a.rows.take(30).fold(0.0, (s, r) => s + r.interest), rel: 1e-12);
      // Override: Kuber keeps the user's figure, the difference is stored.
      expect(outstandingAdjustment(o.outstanding, o.outstanding - 5378),
          closeTo(-5378, 1e-9));
    }),
    // ── Starting point 2: I know what's outstanding today ───────────────
    SolverRow('outstanding today · ${b.kind.name} · outstanding r EMI -> EMIs left',
        () {
      const o = 300000.0;
      final emi = b.kind == RateKind.flat
          ? flatEmi(o, b.r, 36)
          : calculateEmi(o, b.r, 36);
      final left = emisLeftFor(o, b.r, emi,
          kind: b.kind == RateKind.flat ? RateKind.flat : RateKind.reducing);
      expect(left, 36);
    }),
    SolverRow(
        'outstanding today · ${b.kind.name} · outstanding r EMIs left -> EMI',
        () {
      final s = solveLoan(
          principal: 300000,
          rate: b.r,
          months: 36,
          kind: b.kind == RateKind.flat ? RateKind.flat : RateKind.reducing);
      expect(s.calculated, LoanField.emi);
      expect(s.ok, isTrue);
    }),
    SolverRow('outstanding today · ${b.kind.name} · EMI below interest -> error',
        () {
      expect(emisLeftFor(300000, b.r, monthlyInterest(300000, b.r)), isNull);
    }),
  ],
  // ── Starting point 3: Just track the EMI ─────────────────────────────
  SolverRow('track EMI only · EMI alone -> no split, no outstanding', () {
    expect(solveLoan(emi: 21696).error, LoanError.missingInputs);
  }),
];
