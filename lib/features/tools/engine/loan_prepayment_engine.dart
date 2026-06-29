import 'dart:math';

import 'emi_engine.dart';

enum PrepaymentType { oneTime, yearly }

class PrepayYearRow {
  final int year;
  final double emiPaid;
  final double prepayment;
  final double principal; // principal from EMI + prepayment
  final double interest;
  final double closing;

  const PrepayYearRow({
    required this.year,
    required this.emiPaid,
    required this.prepayment,
    required this.principal,
    required this.interest,
    required this.closing,
  });
}

/// One amortization scenario (either the baseline or the with-prepayment run).
class PrepayScenario {
  final double emi;
  final int months;
  final double totalInterest;

  /// Outstanding balance at the end of each year, index 0 = principal.
  final List<double> balanceSeries;
  final List<PrepayYearRow> yearly;

  const PrepayScenario({
    required this.emi,
    required this.months,
    required this.totalInterest,
    required this.balanceSeries,
    required this.yearly,
  });
}

class PrepaymentResult {
  final PrepayScenario baseline;
  final PrepayScenario withPrepay;
  final int monthsSaved;
  final double interestSaved;

  const PrepaymentResult({
    required this.baseline,
    required this.withPrepay,
    required this.monthsSaved,
    required this.interestSaved,
  });

  int get yearsSaved => monthsSaved ~/ 12;
  int get remainderMonthsSaved => monthsSaved % 12;
}

PrepayScenario _simulate(
  double principal,
  double annualRatePercent,
  int years, {
  required PrepaymentType type,
  required double prepayAmount,
  required int startYear,
}) {
  final n = years * 12;
  final r = annualRatePercent / 100 / 12;
  final emi = calculateEmi(principal, annualRatePercent, n);
  final startMonthIndex = (startYear - 1) * 12; // 0-based

  double bal = principal;
  double cumInterest = 0;
  var months = 0;
  final balanceSeries = <double>[principal];
  final yearly = <PrepayYearRow>[];

  var yearInterest = 0.0;
  var yearPrincipal = 0.0;
  var yearPrepay = 0.0;
  var yearMonths = 0;
  var currentYear = 1;

  // Cap iterations generously; prepayment can only shorten the term.
  while (bal > 0 && months < n + 12) {
    final interest = bal * r;
    var extra = 0.0;
    if (prepayAmount > 0 && months >= startMonthIndex) {
      if (type == PrepaymentType.yearly) {
        extra = prepayAmount / 12;
      } else if (type == PrepaymentType.oneTime && months == startMonthIndex) {
        extra = prepayAmount;
      }
    }
    var principalPaid = emi - interest + extra;
    if (principalPaid > bal) principalPaid = bal;
    // The portion of principalPaid attributable to prepayment (for the column).
    final emiPrincipal = min(max(emi - interest, 0.0), principalPaid);
    final prepayPart = principalPaid - emiPrincipal;

    bal -= principalPaid;
    cumInterest += interest;
    months++;

    yearInterest += interest;
    yearPrincipal += principalPaid;
    yearPrepay += prepayPart;
    yearMonths++;

    if (months % 12 == 0 || bal <= 0) {
      yearly.add(PrepayYearRow(
        year: currentYear,
        emiPaid: emi * yearMonths,
        prepayment: yearPrepay,
        principal: yearPrincipal,
        interest: yearInterest,
        closing: max(bal, 0),
      ));
      balanceSeries.add(max(bal, 0));
      yearInterest = 0;
      yearPrincipal = 0;
      yearPrepay = 0;
      yearMonths = 0;
      currentYear++;
    }
  }

  return PrepayScenario(
    emi: emi,
    months: months,
    totalInterest: cumInterest,
    balanceSeries: balanceSeries,
    yearly: yearly,
  );
}

PrepaymentResult computePrepayment(
  double principal,
  double annualRatePercent,
  int years, {
  required PrepaymentType type,
  required double prepayAmount,
  int startYear = 1,
}) {
  final baseline = _simulate(
    principal,
    annualRatePercent,
    years,
    type: type,
    prepayAmount: 0,
    startYear: startYear,
  );
  final withPrepay = _simulate(
    principal,
    annualRatePercent,
    years,
    type: type,
    prepayAmount: prepayAmount,
    startYear: startYear,
  );

  // Pad the with-prepayment series to the baseline length so the comparison
  // chart spans the full original tenure.
  while (withPrepay.balanceSeries.length < baseline.balanceSeries.length) {
    withPrepay.balanceSeries.add(0);
  }

  return PrepaymentResult(
    baseline: baseline,
    withPrepay: withPrepay,
    monthsSaved: baseline.months - withPrepay.months,
    interestSaved: baseline.totalInterest - withPrepay.totalInterest,
  );
}
