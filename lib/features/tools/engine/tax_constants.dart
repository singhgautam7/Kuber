/// Income-tax constants for FY 2025-26 (AY 2026-27).
///
/// ⚠️ UPDATE ANNUALLY for each new Financial Year. Every slab, cap, rebate and
/// surcharge threshold used by [salary_engine.dart] lives here in one place so
/// the yearly Finance Act change is a single-file edit. Verify against the
/// current Finance Act before shipping.
library;

/// A progressive tax slab: income in (`from`, `upTo`] is taxed at `rate`.
class TaxSlab {
  final double from;
  final double upTo; // double.infinity for the top slab
  final double rate; // fraction, e.g. 0.05 for 5%

  const TaxSlab(this.from, this.upTo, this.rate);
}

class TaxConstants {
  // ── Old regime (FY 2025-26) ────────────────────────────────────────────────
  static const oldSlabs = <TaxSlab>[
    TaxSlab(0, 250000, 0.0),
    TaxSlab(250000, 500000, 0.05),
    TaxSlab(500000, 1000000, 0.20),
    TaxSlab(1000000, double.infinity, 0.30),
  ];
  static const oldStandardDeduction = 50000.0;

  /// Section 87A rebate (old regime): full rebate of tax if taxable income is
  /// within this limit, capped at [oldRebateCap].
  static const oldRebateIncomeLimit = 500000.0;
  static const oldRebateCap = 12500.0;

  // Common old-regime deduction caps (UI enforces; engine just applies values).
  static const cap80C = 150000.0;
  static const cap80DSelf = 25000.0;
  static const cap80DParents = 50000.0;
  static const capHomeLoanInterest = 200000.0;
  static const capNps80ccd1b = 50000.0;

  // ── New regime (FY 2025-26) ────────────────────────────────────────────────
  static const newSlabs = <TaxSlab>[
    TaxSlab(0, 400000, 0.0),
    TaxSlab(400000, 800000, 0.05),
    TaxSlab(800000, 1200000, 0.10),
    TaxSlab(1200000, 1600000, 0.15),
    TaxSlab(1600000, 2000000, 0.20),
    TaxSlab(2000000, 2400000, 0.25),
    TaxSlab(2400000, double.infinity, 0.30),
  ];
  static const newStandardDeduction = 75000.0;

  /// Section 87A rebate (new regime).
  static const newRebateIncomeLimit = 700000.0;
  static const newRebateCap = 25000.0;

  // ── Surcharge (on income tax, by taxable income) ───────────────────────────
  // [threshold, rate]. New regime caps surcharge at 25% (no 37% tier).
  static const surchargeBands = <(double, double)>[
    (5000000, 0.10),
    (10000000, 0.15),
    (20000000, 0.25),
    (50000000, 0.37),
  ];
  static const newRegimeMaxSurcharge = 0.25;

  // ── Health & education cess ────────────────────────────────────────────────
  static const cessRate = 0.04;

  // ── Salary-component derivation defaults ───────────────────────────────────
  // Used to break a CTC into components when explicit values aren't provided.
  static const defaultBasicPercent = 40.0; // of CTC
  static const hraPercentOfBasic = 50.0; // metro assumption
  static const employerPfPercentOfBasic = 12.0;
  static const employeePfPercentOfBasic = 12.0;
  static const gratuityPercentOfBasic = 4.8;
}
