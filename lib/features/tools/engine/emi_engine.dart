import 'dart:math';

/// One year-row of an amortization schedule.
class EmiYearRow {
  final int year;
  final double opening;
  final double totalPaid;
  final double principal;
  final double interest;
  final double closing;

  const EmiYearRow({
    required this.year,
    required this.opening,
    required this.totalPaid,
    required this.principal,
    required this.interest,
    required this.closing,
  });
}

/// Full EMI result: the monthly instalment, totals, the year-wise schedule and
/// the per-year series used by the charts (outstanding balance, cumulative
/// interest).
class EmiResult {
  final double emi;
  final double totalPayable;
  final double totalInterest;
  final double principal;
  final List<EmiYearRow> yearly;

  /// Outstanding balance at the end of each year, index 0 = start (= principal).
  final List<double> balanceSeries;

  /// Cumulative interest paid up to the end of each year, index 0 = 0.
  final List<double> interestSeries;

  const EmiResult({
    required this.emi,
    required this.totalPayable,
    required this.totalInterest,
    required this.principal,
    required this.yearly,
    required this.balanceSeries,
    required this.interestSeries,
  });
}

/// EMI = P·r·(1+r)^n / ((1+r)^n − 1)
/// where r = monthly interest rate, n = total months.
double calculateEmi(double principal, double annualRatePercent, int tenureMonths) {
  if (tenureMonths <= 0) return 0;
  final r = annualRatePercent / 100 / 12;
  if (r == 0) return principal / tenureMonths;
  final factor = pow(1 + r, tenureMonths);
  return principal * r * factor / (factor - 1);
}

/// Amortize a loan month-by-month and aggregate into a year-wise schedule.
///
/// Mirrors the reference `amortize(P, ar, years, extraMonthly)` used in the
/// design mockup. [extraMonthlyPrepayment] adds an extra principal payment each
/// month (used by the prepayment calculator); pass 0 for a plain EMI loan.
EmiResult computeEmiSchedule(
  double principal,
  double annualRatePercent,
  int tenureMonths, {
  double extraMonthlyPrepayment = 0,
}) {
  // Guard invalid input (the UI also blocks it): without this a zero tenure
  // yields totalInterest = −principal.
  if (principal <= 0 || tenureMonths <= 0) {
    return EmiResult(
      emi: 0,
      totalPayable: 0,
      totalInterest: 0,
      principal: principal <= 0 ? 0 : principal,
      yearly: const [],
      balanceSeries: [principal <= 0 ? 0 : principal],
      interestSeries: const [0],
    );
  }
  final years = (tenureMonths / 12).ceil();
  final r = annualRatePercent / 100 / 12;
  final emi = calculateEmi(principal, annualRatePercent, tenureMonths);

  double bal = principal;
  double cumInterest = 0;
  final yearly = <EmiYearRow>[];
  final balanceSeries = <double>[principal];
  final interestSeries = <double>[0];

  for (var y = 1; y <= years; y++) {
    double yearInterest = 0;
    double yearPrincipal = 0;
    final opening = bal;
    final monthsThisYear = min(12, tenureMonths - (y - 1) * 12);
    for (var m = 0; m < monthsThisYear && bal > 0; m++) {
      final interest = bal * r;
      var principalPaid = emi - interest + extraMonthlyPrepayment;
      if (principalPaid > bal) principalPaid = bal;
      bal -= principalPaid;
      yearInterest += interest;
      yearPrincipal += principalPaid;
      cumInterest += interest;
    }
    yearly.add(EmiYearRow(
      year: y,
      opening: opening,
      totalPaid: yearPrincipal + yearInterest,
      principal: yearPrincipal,
      interest: yearInterest,
      closing: max(bal, 0),
    ));
    balanceSeries.add(max(bal, 0));
    interestSeries.add(cumInterest);
    if (bal <= 0) {
      // Pad the remaining years with a flat zero balance so the chart x-axis
      // still spans the original tenure.
      for (var k = y + 1; k <= years; k++) {
        balanceSeries.add(0);
        interestSeries.add(cumInterest);
      }
      break;
    }
  }

  return EmiResult(
    emi: emi,
    totalPayable: emi * tenureMonths,
    totalInterest: emi * tenureMonths - principal,
    principal: principal,
    yearly: yearly,
    balanceSeries: balanceSeries,
    interestSeries: interestSeries,
  );
}
