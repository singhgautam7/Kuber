// The money "i" sheets (copy.md "i" sheets, components/info-sheet.md). Every
// number in an example is computed with the shared money math and formatted
// in the user's currency at display time.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/info_config.dart';
import '../../core/money_math/investment_math.dart';
import '../../core/money_math/loan_math.dart';
import '../../core/schedule/schedule.dart';
import '../../core/schedule/schedule_engine.dart';
import '../../core/schedule/schedule_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/l10n_ext.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../../features/tools/engine/fd_rd_engine.dart';
import 'kuber_info_bottom_sheet.dart';

enum MoneyInfo {
  reducing,
  flat,
  io,
  calculated,
  mismatch,
  run1,
  run2,
  run3,
  adjustment,
  interestOnly,
  tenureEmi,
  prepayCharge,
  floating,
  xirr,
  realized,
  proportional,
  stepup,
  compounding,
  payout,
  accrued,
  updated,
  monthly,
}

void showMoneyInfo(BuildContext context, WidgetRef ref, MoneyInfo kind) {
  KuberInfoBottomSheet.show(
      context, moneyInfoConfig(context.l10n, ref.read(formatterProvider), kind));
}

/// The persona home loan the examples use: 25,00,000 at 8.5% for 20 years,
/// first EMI 5 Apr 2017, looked at on 20 Oct 2026.
Amortization _homeLoan() => amortize(
      principal: 2500000,
      rate: 8.5,
      months: 240,
      emiDays: upcomingOccurrences(
              scheduleFrom(start: DateTime(2017, 4, 5), unit: ScheduleUnit.month),
              limit: 240)
          .map((o) => o.day)
          .toList(),
    );

const _today = 20261021;

KuberInfoConfig moneyInfoConfig(AppLocalizations l, AppFormatter f, MoneyInfo kind) {
  String m(num v) => f.formatCurrency(v.round());
  String pct(num v) => f.formatPercentage(v);
  KuberInfoConfig cfg(String title, String line, {KuberInfoExampleBlock? ex}) =>
      KuberInfoConfig(
          title: title, description: line, exampleBlock: ex, actionLabel: l.gotIt);
  KuberInfoExampleBlock ex(List<KuberInfoExampleRow> rows,
          {String? sentence, String? after}) =>
      KuberInfoExampleBlock(
          label: l.msExample, sentence: sentence, rows: rows, after: after);
  KuberInfoExampleRow row(String a, String b, {bool hi = false}) =>
      KuberInfoExampleRow(a, b, highlight: hi);

  switch (kind) {
    case MoneyInfo.reducing:
      final a = _homeLoan();
      final s = roundedSplit(a.rows.first.payment, a.rows.first.interest, 0);
      return cfg(l.msInfoReducingTitle, l.msInfoReducingLine,
          ex: ex([
            row(l.msInfoReducingRow1, m(s.interest)),
            row(l.msInfoReducingRow2, m(s.principal)),
          ],
              sentence: l.msInfoReducingEx(m(2500000), pct(8.5), '20', m(s.payment)),
              after: l.msInfoReducingAfter));
    case MoneyInfo.flat:
      return cfg(l.msInfoFlatTitle, l.msInfoFlatLine,
          ex: ex([
            row(l.msInfoFlatRow1, m(500000 * 0.09)),
            row(l.msInfoFlatRow2, m(flatInterest(500000, 9, 60))),
            row(l.msInfoFlatRow3, m(flatEmi(500000, 9, 60)), hi: true),
          ],
              sentence: l.msInfoFlatEx(m(500000), pct(9), '5'),
              after: l.msInfoFlatAfter(
                  pct(9), m(calculateEmi(500000, 9, 60) * 60 - 500000))));
    case MoneyInfo.io:
      final io = monthlyInterest(400000, 9.5);
      final emi = calculateEmi(400000, 9.5, 60);
      return cfg(l.msInfoIoTitle, l.msInfoIoLine,
          ex: ex([
            row(l.msInfoIoRow1('12'), l.msInfoIoRowValue(m(io))),
            row(l.msInfoIoRow2('60'), l.msInfoIoRowValue(m(emi)), hi: true),
          ], sentence: l.msInfoIoEx(m(400000), pct(9.5), '12'), after: l.msInfoIoAfter));
    case MoneyInfo.calculated:
      return cfg(l.msInfoCalculatedTitle, l.msInfoCalculatedLine,
          ex: ex([
            row(l.msLoansPrincipal, m(2500000)),
            row(l.msLoansRate, pct(8.5)),
            row(l.msLoansTenure, '20 ${l.msLoansYears.toLowerCase()}'),
            row('${l.msLoansEmi} (${l.msCalculated})', m(calculateEmi(2500000, 8.5, 240)),
                hi: true),
          ], after: l.msInfoCalculatedAfter));
    case MoneyInfo.mismatch:
      final calc = calculateEmi(2500000, 8.5, 240).roundToDouble();
      return cfg(l.msInfoMismatchTitle, l.msInfoMismatchLine,
          ex: ex([
            row(l.msInfoMismatchRow1, m(calc)),
            row(l.msInfoMismatchRow2, m(calc + 120)),
            row(l.msInfoMismatchRow3, m(120), hi: true),
          ]));
    case MoneyInfo.run1:
      final o = openingFromOriginal(_homeLoan(), _today);
      return cfg(l.msInfoRun1Title, l.msInfoRun1Line,
          ex: ex([
            row(l.msLoansEmisPaid, '${o.emisPaid}'),
            row(l.msLoansPrincipalPaid, m(o.principalPaid)),
            row(l.msLoansInterestPaid, m(o.interestPaid)),
            row(l.msLoansOutstandingToday, m(o.outstanding), hi: true),
          ]));
    case MoneyInfo.run2:
      final left = emisLeftFor(1563554, 8.25, 21696) ?? 0;
      final last = DateTime(2026, 11 + left - 1, 5);
      return cfg(l.msInfoRun2Title, l.msInfoRun2Line,
          ex: ex([
            row(l.msLoansOutstanding, m(1563554)),
            row(l.msLoansEmi, m(21696)),
            row(l.msLoansRate, pct(8.25)),
            row(l.msLoansEmisLeft, l.msLoansEmisLeftValue('$left', fmtMonthYear(last)), hi: true),
          ], after: l.msInfoRun2After));
    case MoneyInfo.run3:
      return cfg(l.msInfoRun3Title, l.msInfoRun3Line);
    case MoneyInfo.adjustment:
      final calc = openingFromOriginal(_homeLoan(), _today).outstanding.roundToDouble();
      final entered = (calc / 10000).floor() * 10000.0;
      return cfg(l.msInfoAdjustmentTitle, l.msInfoAdjustmentLine,
          ex: ex([
            row(l.msInfoAdjustmentRow1, m(calc)),
            row(l.msInfoAdjustmentRow2, m(entered)),
            row(l.msInfoAdjustmentTitle, m(entered - calc), hi: true),
          ], after: l.msInfoAdjustmentAfter));
    case MoneyInfo.interestOnly:
      final r = _homeLoan().rows.firstWhere((r) => r.day > _today);
      final s = roundedSplit(r.payment, r.interest, 0);
      return cfg(l.msInfoInterestOnlyTitle, l.msInfoInterestOnlyLine,
          ex: ex([
            row(l.msInfoInterestOnlyRow1, m(s.interest), hi: true),
            row(l.msInfoInterestOnlyRow2, m(s.principal)),
          ], after: l.msInfoInterestOnlyAfter));
    case MoneyInfo.tenureEmi:
      final days = upcomingOccurrences(
              scheduleFrom(start: DateTime(2026, 11, 5)), limit: 400)
          .map((o) => o.day)
          .toList();
      final base = amortize(principal: 1563554, rate: 8.25, months: 100, emiDays: days, emi: 21696);
      final ten = amortize(
          principal: 1563554, rate: 8.25, months: 100, emiDays: days, emi: 21696,
          events: [AmortEvent(20261101, AmortEventKind.prepayment, amount: 200000)]);
      final emiCut = amortize(
          principal: 1563554, rate: 8.25, months: 100, emiDays: days, emi: 21696,
          events: [AmortEvent(20261101, AmortEventKind.prepayment, amount: 200000, adjustEmi: true)]);
      return cfg(l.msInfoTenureEmiTitle, l.msInfoTenureEmiLine,
          ex: ex([
            row(l.msLoansReduceTenure,
                l.msLoansExtraPreviewTenure(m(base.totalInterest - ten.totalInterest),
                    '${base.rows.length - ten.rows.length}'),
                hi: true),
            row(l.msLoansReduceEmi,
                l.msLoansExtraPreviewEmi(m(base.totalInterest - emiCut.totalInterest),
                    m(emiCut.rows.first.payment))),
          ]));
    case MoneyInfo.prepayCharge:
      return cfg(l.msInfoPrepayChargeTitle, l.msInfoPrepayChargeLine,
          ex: ex([
            row(l.msInfoPrepayRow1, m(200000)),
            row(l.msInfoPrepayRow2, m(4000)),
            row(l.msInfoPrepayRow3, m(204000), hi: true),
          ]));
    case MoneyInfo.floating:
      final newEmi = calculateEmi(1563554, 8.0, 100);
      final left = emisLeftFor(1563554, 8.0, 21696) ?? 0;
      return cfg(l.msInfoFloatingTitle, l.msInfoFloatingLine,
          ex: ex([
            row(l.msLoansAdjustEmi, m(newEmi)),
            row(l.msLoansAdjustTenure,
                l.msLoansEndsOn(fmtMonthYear(DateTime(2026, 11 + left - 1, 5)))),
          ]));
    case MoneyInfo.xirr:
      final start = DateTime(2023, 10, 20);
      final r = xirr([
            for (var i = 0; i < 36; i++)
              CashFlow(DateTime(start.year, start.month + i, start.day), -5000),
            CashFlow(DateTime(2026, 10, 20), 220000),
          ]) ??
          0;
      return cfg(l.msInfoXirrTitle, l.msInfoXirrLine,
          ex: ex([
            row(l.msInfoXirrRow1, pct(percentGain(220000, 180000))),
            row(l.msInfoXirrRow2, l.msInfoXirrValue(pct(r * 100)), hi: true),
          ], sentence: l.msInfoXirrEx(m(5000), m(180000), m(220000))));
    case MoneyInfo.realized:
      final w = proportionalWithdrawal(
          invested: 151600, value: 184000, redeemed: 20000, charges: 200);
      return cfg(l.msInfoRealizedTitle, l.msInfoRealizedLine,
          ex: ex([
            row(l.msInvUnrealized, m(184000 - 151600)),
            row(l.msInvRealized, m(w.realizedGain), hi: true),
          ]));
    case MoneyInfo.proportional:
      final w = proportionalWithdrawal(invested: 80000, value: 100000, redeemed: 20000);
      return cfg(l.msInfoProportionalTitle, l.msInfoProportionalLine,
          ex: ex([
            row(l.msInfoProportionalRow1, m(w.investedReduction)),
            row(l.msInfoProportionalRow2, m(w.realizedGain)),
            row(l.msInfoProportionalRow3, m(80000 - w.investedReduction), hi: true),
          ], sentence: l.msInfoProportionalEx(m(100000), m(80000), m(20000))));
    case MoneyInfo.stepup:
      final s = stepUpSeries(5000, true, 10, 4);
      return cfg(l.msInfoStepupTitle, l.msInfoStepupLine,
          ex: ex([
            for (var i = 0; i < s.length; i++) row(l.msInfoStepupRow('${i + 1}'), m(s[i])),
          ], sentence: l.msInfoStepupEx(m(5000))));
    case MoneyInfo.compounding:
      return cfg(l.msInfoCompoundingTitle, l.msInfoCompoundingLine,
          ex: ex([
            row(l.msInvCompYearly, m(fdMaturity(100000, 7, 60, CompoundingFrequency.yearly))),
            row(l.msInvCompQuarterly, m(fdMaturity(100000, 7, 60, CompoundingFrequency.quarterly))),
            row(l.msInvCompMonthly, m(fdMaturity(100000, 7, 60, CompoundingFrequency.monthly)), hi: true),
          ], sentence: l.msInfoCompoundingEx(m(100000))));
    case MoneyInfo.payout:
      return cfg(l.msInfoPayoutTitle, l.msInfoPayoutLine,
          ex: ex([
            row(l.msInfoPayoutRow1, m(fdMaturity(200000, 7.25, 24, CompoundingFrequency.quarterly)), hi: true),
            row(l.msInfoPayoutRow2, l.msInfoPayoutRow2Value(m(fdPayoutAmount(200000, 7.25, 4)))),
            row(l.msInfoPayoutRow3, m(200000)),
          ]));
    case MoneyInfo.accrued:
      final start = DateTime(2026, 3, 15);
      final today = DateTime(2026, 10, 20);
      return cfg(l.msInfoAccruedTitle, l.msInfoAccruedLine,
          ex: ex([
            row(fmtDayLong(today),
                m(fdValueOn(
                    principal: 200000,
                    rate: 7.25,
                    freq: CompoundingFrequency.quarterly,
                    start: start,
                    tenureMonths: 24,
                    at: today)),
                hi: true),
            row(fmtDayLong(DateTime(2028, 3, 15)),
                m(fdMaturity(200000, 7.25, 24, CompoundingFrequency.quarterly))),
          ]));
    case MoneyInfo.updated:
      return cfg(l.msInfoUpdatedTitle, l.msInfoUpdatedLine);
    case MoneyInfo.monthly:
      return cfg(l.msInfoMonthlyTitle, l.msInfoMonthlyLine,
          ex: ex([
            row(l.msInfoMonthlyRow1(m(14400)), l.msInfoIoRowValue(m(14400 * monthlyFactor(1, ScheduleUnit.year)))),
            row(l.msInfoMonthlyRow2(m(6000)), l.msInfoIoRowValue(m(6000 * monthlyFactor(3, ScheduleUnit.month)))),
            row(l.msInfoMonthlyRow3(m(750)), l.msInfoIoRowValue(m(750 * monthlyFactor(1, ScheduleUnit.week)))),
          ], after: l.msInfoMonthlyAfter));
  }
}
