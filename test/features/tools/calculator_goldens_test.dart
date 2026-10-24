// Golden outputs for every calculator engine Kuber's money features reuse,
// recorded from the pre-vNext engines (base 6ce4f0e) with
//   KUBER_RECORD_FIXTURES=1 flutter test test/features/tools/calculator_goldens_test.dart
// Every value is compared bit for bit (double.toString round-trips), so a
// refactor onto the shared money math cannot change a single output.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/tools/engine/emi_engine.dart';
import 'package:kuber/features/tools/engine/fd_rd_engine.dart';
import 'package:kuber/features/tools/engine/goal_planner_engine.dart';
import 'package:kuber/features/tools/engine/inflation_engine.dart';
import 'package:kuber/features/tools/engine/investment_engine.dart';
import 'package:kuber/features/tools/engine/loan_prepayment_engine.dart';
import 'package:kuber/features/tools/engine/lumpsum_vs_sip_engine.dart';
import 'package:kuber/features/tools/engine/monthly_schedules.dart';
import 'package:kuber/features/tools/engine/ppf_engine.dart';
import 'package:kuber/features/tools/engine/retirement_engine.dart';
import 'package:kuber/features/tools/engine/sip_required_engine.dart';

const _file = 'test/fixtures/calculators/goldens.json';
final _record = Platform.environment['KUBER_RECORD_FIXTURES'] == '1';

String _d(num v) => v.toDouble().toString();
List<String> _l(Iterable<num> v) => v.map(_d).toList();
List<List<String>> _rows(List<List<double>> r) => r.map(_l).toList();

const principals = [1000.0, 50000.0, 250000.0, 2500000.0, 50000000.0];
const rates = [0.0, 0.5, 7.1, 8.5, 12.0, 36.0];
const tenures = [1, 7, 12, 60, 240, 360];
const sipAmounts = [100.0, 5000.0, 100000.0];
const years = [1, 5, 15, 40];

Map<String, Object> computeGoldens() {
  final g = <String, Object>{};
  for (final p in principals) {
    for (final r in rates) {
      for (final n in tenures) {
        final k = '$p|$r|$n';
        final e = computeEmiSchedule(p, r, n);
        g['emi:$k'] = {
          'emi': _d(calculateEmi(p, r, n)),
          'totalPayable': _d(e.totalPayable),
          'totalInterest': _d(e.totalInterest),
          'balance': _l(e.balanceSeries),
          'interest': _l(e.interestSeries),
          'yearly': [
            for (final y in e.yearly)
              _l([y.year, y.opening, y.totalPaid, y.principal, y.interest, y.closing])
          ],
        };
        if ((p == 50000 || p == 2500000) && n <= 60) {
          g['emiMonthly:$k'] = _rows(emiMonthlyRows(p, r, n));
          g['emiMonthlyExtra:$k'] =
              _rows(emiMonthlyRows(p, r, n, extraMonthly: p / 50));
        }
        g['emiExtra:$k'] = _l(
            computeEmiSchedule(p, r, n, extraMonthlyPrepayment: p / 50)
                .balanceSeries);
      }
      for (final y in [1, 5, 20, 30]) {
        for (final type in PrepaymentType.values) {
          for (final start in [1, 3]) {
            if (start > y) continue;
            final res = computePrepayment(p, r, y,
                type: type, prepayAmount: p / 10, startYear: start);
            g['prepay:$p|$r|$y|${type.name}|$start'] = {
              'monthsSaved': res.monthsSaved,
              'interestSaved': _d(res.interestSaved),
              for (final (name, s) in [
                ('base', res.baseline),
                ('with', res.withPrepay)
              ])
                name: {
                  'emi': _d(s.emi),
                  'months': s.months,
                  'totalInterest': _d(s.totalInterest),
                  'balance': _l(s.balanceSeries),
                  'yearly': [
                    for (final row in s.yearly)
                      _l([row.year, row.emiPaid, row.prepayment, row.principal, row.interest, row.closing])
                  ],
                },
            };
          }
        }
        for (final f in CompoundingFrequency.values) {
          final fd = computeFd(p, r, y, f);
          g['fd:$p|$r|$y|${f.name}'] = {
            'maturity': _d(fd.maturity),
            'interest': _d(fd.interestEarned),
            'yield': _d(fd.effectiveYieldPercent),
            'balance': _l(fd.balanceSeries),
          };
          if (y <= 5 && p == 250000) {
            g['fdMonthlyInline:$p|$r|$y|${f.name}'] =
                _rows(inlineFdMonthlyRows(p, r, y, f));
          }
        }
      }
    }
  }
  for (final a in sipAmounts) {
    for (final r in rates) {
      for (final y in years) {
        final k = '$a|$r|$y';
        final rd = computeRd(a, r, y);
        g['rd:$k'] = {
          'maturity': _d(rd.maturity),
          'invested': _d(rd.totalInvested),
          'interest': _d(rd.interestEarned),
          'yield': _d(rd.effectiveYieldPercent),
          'balance': _l(rd.balanceSeries),
        };
        if (y <= 15) g['rdMonthlyInline:$k'] = _rows(inlineRdMonthlyRows(a, r, y));
        final sip = computeSip(a, r, y);
        g['sip:$k'] = {
          'fv': _d(sip.futureValue),
          'invested': _d(sip.totalInvested),
          'value': _l(sip.valueSeries),
        };
        if (y <= 15) g['sipMonthly:$k'] = _rows(sipMonthlyRows(a, r, y));
        final lump = computeLumpsum(a * 12, r, y);
        g['lump:$k'] = {'fv': _d(lump.futureValue), 'value': _l(lump.valueSeries)};
        final lvs = computeLumpsumVsSip(a * 12 * y, r, y);
        g['lumpVsSip:$k'] = {
          'monthly': _d(lvs.monthlySip),
          'diff': _d(lvs.difference),
          'lumpMonthlyInline': _l([
            for (var m = 1; m <= y * 12; m++) inlineLumpsumMonthValue(a * 12 * y, r, m)
          ]),
        };
        if (r > 0) {
          g['sipReq:$k'] = _d(computeSipRequired(a * 1000, r, y).monthlyAmount);
          final goal = computeGoal(
              target: a * 1000, years: y, ratePercent: r, currentSavings: a);
          g['goal:$k'] = {
            'monthly': _d(goal.monthlyInvestment),
            'corpus': _d(goal.finalCorpus),
            'returns': _d(goal.returns),
          };
        }
        g['infl:$k'] = _l(computeInflation(a, r, y).futureSeries);
        final ppf = computePpf(a * 12, y.clamp(15, 50), ratePercent: r);
        g['ppf:$k'] = {
          'maturity': _d(ppf.maturity),
          'deposited': _d(ppf.totalDeposited),
          'balance': _l(ppf.balanceSeries),
        };
      }
    }
  }
  for (final pre in [6.0, 10.0, 12.0]) {
    final ret = computeRetirement(
      currentAge: 30,
      retirementAge: 60,
      lifeExpectancy: 85,
      currentMonthlyExpense: 50000,
      inflationPercent: 6,
      preRetirementReturnPercent: pre,
      postRetirementReturnPercent: 7,
      currentSavings: 500000,
    );
    g['retire:$pre'] = {
      'corpus': _d(ret.requiredCorpus),
      'monthly': _d(ret.monthlyInvestment),
      'pre': _l(ret.preRetirementSeries),
      'post': _l(ret.postRetirementSeries),
    };
  }
  return g;
}

// The monthly tables the FD/RD and Lump sum vs SIP screens computed inline
// before vNext, copied verbatim (fd_rd_calculator_screen.dart,
// lumpsum_vs_sip_screen.dart). After the refactor these call the engine.
// Formerly inline in the FD/RD and Lump sum vs SIP screens (goldens were
// recorded from those inline copies); now engine functions.
List<List<double>> inlineFdMonthlyRows(
        double amount, double rate, int years, CompoundingFrequency freq) =>
    fdMonthlyRows(amount, rate, years, freq);

List<List<double>> inlineRdMonthlyRows(double amount, double rate, int years) =>
    rdMonthlyRows(amount, rate, years);

double inlineLumpsumMonthValue(double total, double rate, int month) =>
    lumpsumValueAtMonth(total, rate, month);

void main() {
  test('calculator outputs match the recorded goldens bit for bit', () {
    final actual = computeGoldens();
    final file = File(_file);
    if (_record) {
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(jsonEncode(actual));
      return;
    }
    final expected = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    expect(actual.keys.toSet(), expected.keys.toSet());
    for (final k in expected.keys) {
      expect(jsonEncode(actual[k]), jsonEncode(expected[k]), reason: k);
    }
  });
}
