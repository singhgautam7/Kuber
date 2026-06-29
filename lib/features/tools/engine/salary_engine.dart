import 'tax_constants.dart';

/// User inputs for the salary breakdown. Component percentages default to the
/// standard derivation but can be overridden.
class SalaryInputs {
  final double ctc;
  final double basicPercent; // of CTC

  // Old-regime deductions (ignored by the new regime).
  final double hraExemptionClaimed;
  final double deduction80C;
  final double deduction80D;
  final double homeLoanInterest;
  final double npsContribution;

  const SalaryInputs({
    required this.ctc,
    this.basicPercent = TaxConstants.defaultBasicPercent,
    this.hraExemptionClaimed = 0,
    this.deduction80C = 0,
    this.deduction80D = 0,
    this.homeLoanInterest = 0,
    this.npsContribution = 0,
  });

  double get basic => ctc * basicPercent / 100;
  double get hra => basic * TaxConstants.hraPercentOfBasic / 100;
  double get employerPf => basic * TaxConstants.employerPfPercentOfBasic / 100;
  double get employeePf => basic * TaxConstants.employeePfPercentOfBasic / 100;
  double get gratuity => basic * TaxConstants.gratuityPercentOfBasic / 100;

  /// Taxable employment income (in-hand gross): CTC minus the employer's
  /// retirals (employer PF + gratuity accrual).
  double get gross => ctc - employerPf - gratuity;

  double get specialAllowance => gross - basic - hra;
}

/// Result of one regime's tax computation.
class RegimeResult {
  final bool isNew;
  final double taxableIncome;
  final double taxBeforeRebate;
  final double rebate;
  final double tax; // after rebate, before surcharge/cess
  final double surcharge;
  final double cess;
  final double totalTax;
  final double netAnnual;
  final double netMonthly;

  /// Ordered line-items for the comparison table (label → signed value).
  final Map<String, double> breakdown;

  const RegimeResult({
    required this.isNew,
    required this.taxableIncome,
    required this.taxBeforeRebate,
    required this.rebate,
    required this.tax,
    required this.surcharge,
    required this.cess,
    required this.totalTax,
    required this.netAnnual,
    required this.netMonthly,
    required this.breakdown,
  });
}

class SalaryResult {
  final RegimeResult oldRegime;
  final RegimeResult newRegime;

  const SalaryResult({required this.oldRegime, required this.newRegime});

  /// The regime that leaves more take-home pay.
  RegimeResult get recommended =>
      newRegime.netAnnual >= oldRegime.netAnnual ? newRegime : oldRegime;

  bool get newIsBetter => newRegime.netAnnual >= oldRegime.netAnnual;

  /// Absolute annual take-home advantage of the recommended regime.
  double get annualDifference =>
      (newRegime.netAnnual - oldRegime.netAnnual).abs();
}

/// Progressive tax across [slabs].
double taxFromSlabs(double income, List<TaxSlab> slabs) {
  if (income <= 0) return 0;
  double tax = 0;
  for (final s in slabs) {
    if (income > s.from) {
      final upper = income < s.upTo ? income : s.upTo;
      tax += (upper - s.from) * s.rate;
    }
  }
  return tax;
}

double _surcharge(double taxableIncome, double tax, {required bool isNew}) {
  double rate = 0;
  for (final band in TaxConstants.surchargeBands) {
    if (taxableIncome > band.$1) rate = band.$2;
  }
  if (isNew && rate > TaxConstants.newRegimeMaxSurcharge) {
    rate = TaxConstants.newRegimeMaxSurcharge;
  }
  return tax * rate;
}

RegimeResult computeOldRegime(SalaryInputs i) {
  final gross = i.gross;
  final totalDeductions = TaxConstants.oldStandardDeduction +
      i.hraExemptionClaimed +
      i.deduction80C +
      i.deduction80D +
      i.homeLoanInterest +
      i.npsContribution;
  final taxable = (gross - totalDeductions).clamp(0, double.infinity).toDouble();

  final taxBeforeRebate = taxFromSlabs(taxable, TaxConstants.oldSlabs);
  final rebate = taxable <= TaxConstants.oldRebateIncomeLimit
      ? (taxBeforeRebate < TaxConstants.oldRebateCap
          ? taxBeforeRebate
          : TaxConstants.oldRebateCap)
      : 0.0;
  final tax = taxBeforeRebate - rebate;
  final surcharge = _surcharge(taxable, tax, isNew: false);
  final cess = (tax + surcharge) * TaxConstants.cessRate;
  final totalTax = tax + surcharge + cess;
  final netAnnual = gross - totalTax - i.employeePf;

  return RegimeResult(
    isNew: false,
    taxableIncome: taxable,
    taxBeforeRebate: taxBeforeRebate,
    rebate: rebate,
    tax: tax,
    surcharge: surcharge,
    cess: cess,
    totalTax: totalTax,
    netAnnual: netAnnual,
    netMonthly: netAnnual / 12,
    breakdown: {
      'Basic': i.basic,
      'HRA': i.hra,
      'Special Allowance': i.specialAllowance,
      'Gross Salary': gross,
      'Standard Deduction': -TaxConstants.oldStandardDeduction,
      'HRA Exemption': -i.hraExemptionClaimed,
      '80C': -i.deduction80C,
      '80D': -i.deduction80D,
      'Home Loan Interest': -i.homeLoanInterest,
      'NPS (80CCD1B)': -i.npsContribution,
      'Taxable Income': taxable,
      'Tax at slab': tax,
      'Surcharge': surcharge,
      'Cess (4%)': cess,
      'Total Tax': totalTax,
      'Take-home (annual)': netAnnual,
    },
  );
}

RegimeResult computeNewRegime(SalaryInputs i) {
  final gross = i.gross;
  final taxable = (gross - TaxConstants.newStandardDeduction)
      .clamp(0, double.infinity)
      .toDouble();

  final taxBeforeRebate = taxFromSlabs(taxable, TaxConstants.newSlabs);
  final rebate = taxable <= TaxConstants.newRebateIncomeLimit
      ? (taxBeforeRebate < TaxConstants.newRebateCap
          ? taxBeforeRebate
          : TaxConstants.newRebateCap)
      : 0.0;
  final tax = taxBeforeRebate - rebate;
  final surcharge = _surcharge(taxable, tax, isNew: true);
  final cess = (tax + surcharge) * TaxConstants.cessRate;
  final totalTax = tax + surcharge + cess;
  final netAnnual = gross - totalTax - i.employeePf;

  return RegimeResult(
    isNew: true,
    taxableIncome: taxable,
    taxBeforeRebate: taxBeforeRebate,
    rebate: rebate,
    tax: tax,
    surcharge: surcharge,
    cess: cess,
    totalTax: totalTax,
    netAnnual: netAnnual,
    netMonthly: netAnnual / 12,
    breakdown: {
      'Basic': i.basic,
      'HRA': i.hra,
      'Special Allowance': i.specialAllowance,
      'Gross Salary': gross,
      'Standard Deduction': -TaxConstants.newStandardDeduction,
      'HRA Exemption': 0,
      '80C': 0,
      '80D': 0,
      'Home Loan Interest': 0,
      'NPS (80CCD1B)': 0,
      'Taxable Income': taxable,
      'Tax at slab': tax,
      'Surcharge': surcharge,
      'Cess (4%)': cess,
      'Total Tax': totalTax,
      'Take-home (annual)': netAnnual,
    },
  );
}

SalaryResult computeSalary(SalaryInputs i) => SalaryResult(
      oldRegime: computeOldRegime(i),
      newRegime: computeNewRegime(i),
    );
