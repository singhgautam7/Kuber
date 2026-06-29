import 'package:flutter_test/flutter_test.dart';

import 'package:kuber/features/tools/engine/emi_engine.dart';
import 'package:kuber/features/tools/engine/investment_engine.dart';
import 'package:kuber/features/tools/engine/sip_required_engine.dart';
import 'package:kuber/features/tools/engine/fd_rd_engine.dart';
import 'package:kuber/features/tools/engine/ppf_engine.dart';
import 'package:kuber/features/tools/engine/inflation_engine.dart';
import 'package:kuber/features/tools/engine/loan_prepayment_engine.dart';
import 'package:kuber/features/tools/engine/lumpsum_vs_sip_engine.dart';
import 'package:kuber/features/tools/engine/salary_engine.dart';
import 'package:kuber/features/tools/engine/gst_engine.dart';
import 'package:kuber/features/tools/engine/hra_engine.dart';
import 'package:kuber/features/tools/engine/goal_planner_engine.dart';
import 'package:kuber/features/tools/engine/retirement_engine.dart';

/// All example numbers are taken from the design mockup
/// (`Kuber Tools Overhaul.dc.html`) which is the spec's source of truth.
void main() {
  group('EMI engine', () {
    test('matches mockup: ₹25L @ 8.5% / 20y', () {
      final r = computeEmiSchedule(2500000, 8.5, 240);
      expect(r.emi, closeTo(21696, 2));
      expect(r.totalInterest, closeTo(2706939, 50));
      expect(r.totalPayable, closeTo(5206939, 50));
      expect(r.balanceSeries.first, 2500000);
      expect(r.balanceSeries.last, closeTo(0, 1));
      expect(r.interestSeries.last, closeTo(r.totalInterest, 5000));
    });

    test('zero-rate loan splits principal evenly', () {
      expect(calculateEmi(120000, 0, 12), closeTo(10000, 0.001));
    });

    test('edge: zero tenure returns 0 EMI', () {
      expect(calculateEmi(100000, 10, 0), 0);
    });

    test('high rate / long tenure stays finite and positive', () {
      final emi = calculateEmi(1000000, 36, 360);
      expect(emi.isFinite, isTrue);
      expect(emi, greaterThan(0));
    });
  });

  group('Investment engine', () {
    test('SIP matches mockup: ₹10k @ 12% / 15y', () {
      final r = computeSip(10000, 12, 15);
      expect(r.futureValue, closeTo(5045760, 2000));
      expect(r.totalInvested, 1800000);
      expect(r.totalGains, closeTo(3245760, 2000));
    });

    test('lumpsum compounds yearly', () {
      final r = computeLumpsum(100000, 10, 10);
      expect(r.futureValue, closeTo(259374, 1));
      expect(r.totalInvested, 100000);
    });
  });

  group('SIP required engine', () {
    test('matches mockup: ₹50L / 15y @ 12% → ~₹9,911/mo', () {
      final m = requiredMonthlySip(5000000, 12, 15);
      expect(m, closeTo(9911, 5));
    });

    test('round trip: required SIP grows to target', () {
      final m = requiredMonthlySip(5000000, 12, 15);
      final grown = computeSip(m, 12, 15);
      expect(grown.futureValue, closeTo(5000000, 1000));
    });

    test('edge: zero years returns 0', () {
      expect(requiredMonthlySip(1000000, 12, 0), 0);
    });
  });

  group('FD / RD engine', () {
    test('FD matches mockup: ₹5L @ 7.2% / 5y quarterly', () {
      final r = computeFd(500000, 7.2, 5, CompoundingFrequency.quarterly);
      expect(r.maturity, closeTo(714457, 100));
      expect(r.effectiveYieldPercent, closeTo(7.40, 0.05));
      expect(r.balanceSeries.first, 500000);
    });

    test('RD accumulates monthly deposits with growth', () {
      final r = computeRd(10000, 7, 5);
      expect(r.totalInvested, 600000);
      expect(r.maturity, greaterThan(r.totalInvested));
      expect(r.interestEarned, closeTo(r.maturity - 600000, 0.01));
    });
  });

  group('PPF engine', () {
    test('matches mockup: ₹1.5L/yr × 15y @ 7.1%', () {
      final r = computePpf(150000, 15);
      expect(r.maturity, closeTo(4068209, 50));
      expect(r.totalDeposited, 2250000);
      expect(r.interestEarned, closeTo(1818209, 50));
    });

    test('deposit clamp enforces statutory window', () {
      expect(clampPpfDeposit(100), kPpfMinDeposit);
      expect(clampPpfDeposit(200000), kPpfMaxDeposit);
      expect(clampPpfDeposit(0), 0);
      expect(clampPpfDeposit(50000), 50000);
    });
  });

  group('Inflation engine', () {
    test('matches mockup: ₹10L @ 6% / 15y', () {
      final r = computeInflation(1000000, 6, 15);
      expect(r.futureValueRequired, closeTo(2396558, 50));
      expect(r.realValueOfToday, closeTo(417265, 50));
    });

    test('zero inflation is identity', () {
      final r = computeInflation(1000000, 0, 10);
      expect(r.futureValueRequired, 1000000);
      expect(r.realValueOfToday, 1000000);
    });
  });

  group('Loan prepayment engine', () {
    test('₹25L @ 8.5% / 20y, ₹1L/yr saves tenure and interest', () {
      final r = computePrepayment(
        2500000,
        8.5,
        20,
        type: PrepaymentType.yearly,
        prepayAmount: 100000,
      );
      expect(r.monthsSaved, greaterThan(24)); // > 2 years
      expect(r.interestSaved, greaterThan(400000));
      expect(r.withPrepay.months, lessThan(r.baseline.months));
    });

    test('edge: prepayment ≥ balance closes quickly', () {
      final r = computePrepayment(
        100000,
        10,
        5,
        type: PrepaymentType.oneTime,
        prepayAmount: 200000,
      );
      expect(r.withPrepay.months, lessThanOrEqualTo(1));
    });

    test('zero prepayment leaves tenure unchanged', () {
      final r = computePrepayment(
        2500000,
        8.5,
        20,
        type: PrepaymentType.yearly,
        prepayAmount: 0,
      );
      expect(r.monthsSaved, 0);
      expect(r.interestSaved, closeTo(0, 0.01));
    });
  });

  group('Lumpsum vs SIP engine', () {
    test('matches mockup: ₹12L @ 12% / 15y → lumpsum wins', () {
      final r = computeLumpsumVsSip(1200000, 12, 15);
      expect(r.lumpsum.futureValue, closeTo(6568279, 5000));
      expect(r.sip.futureValue, closeTo(3364008, 5000));
      expect(r.lumpsumWins, isTrue);
      expect(r.monthlySip, closeTo(6667, 1));
    });
  });

  group('Salary engine (FY 2025-26)', () {
    final inputs = SalaryInputs(
      ctc: 2400000,
      basicPercent: 40,
      hraExemptionClaimed: 360000,
      deduction80C: 150000,
      deduction80D: 25000,
      homeLoanInterest: 200000,
      npsContribution: 50000,
    );

    test('component derivation matches mockup', () {
      expect(inputs.basic, 960000);
      expect(inputs.hra, 480000);
      expect(inputs.gross, closeTo(2238720, 1));
      expect(inputs.specialAllowance, closeTo(798720, 1));
    });

    test('old regime matches mockup to the rupee', () {
      final r = computeOldRegime(inputs);
      expect(r.taxableIncome, closeTo(1403720, 1));
      expect(r.tax, closeTo(233616, 1));
      expect(r.cess, closeTo(9345, 1));
      expect(r.totalTax, closeTo(242961, 1));
      expect(r.netAnnual, closeTo(1880559, 2));
    });

    test('new regime matches mockup to the rupee', () {
      final r = computeNewRegime(inputs);
      expect(r.taxableIncome, closeTo(2163720, 1));
      expect(r.tax, closeTo(240930, 1));
      expect(r.cess, closeTo(9637, 1));
      expect(r.totalTax, closeTo(250567, 1));
      expect(r.netAnnual, closeTo(1872953, 2));
    });

    test('recommendation: old regime better by ~₹7,606', () {
      final r = computeSalary(inputs);
      expect(r.newIsBetter, isFalse);
      expect(r.annualDifference, closeTo(7606, 3));
    });

    test('87A rebate zeroes tax for ₹6.5L taxable new regime', () {
      // Gross such that taxable ≤ 7L. CTC chosen so gross - 75k ≈ 6.5L.
      final low = SalaryInputs(ctc: 700000, basicPercent: 40);
      final r = computeNewRegime(low);
      expect(r.taxableIncome, lessThan(700000));
      expect(r.totalTax, 0);
    });

    test('high surcharge tier: ₹2.5Cr taxable hits 25% (new caps)', () {
      final big = SalaryInputs(ctc: 30000000, basicPercent: 40);
      final r = computeNewRegime(big);
      // Surcharge rate applied is 25% (new regime cap) on >₹2Cr taxable.
      expect(r.surcharge, closeTo(r.tax * 0.25, 1));
    });

    test('old regime 37% surcharge tier above ₹5Cr', () {
      final huge = SalaryInputs(ctc: 70000000, basicPercent: 40);
      final r = computeOldRegime(huge);
      expect(r.surcharge, closeTo(r.tax * 0.37, 1));
    });
  });

  group('GST engine', () {
    test('add 18% to ₹50,000', () {
      final r = addGst(50000, 18);
      expect(r.gstAmount, 9000);
      expect(r.grossAmount, 59000);
      expect(r.cgst, 4500);
      expect(r.sgst, 4500);
    });

    test('remove 18% from ₹59,000', () {
      final r = removeGst(59000, 18);
      expect(r.preGst, closeTo(50000, 0.01));
      expect(r.gstAmount, closeTo(9000, 0.01));
    });
  });

  group('HRA engine', () {
    test('matches mockup: method 2 wins', () {
      final r = computeHra(
        basic: 600000,
        hraReceived: 300000,
        rentPaid: 240000,
        isMetro: true,
      );
      expect(r.exemption, 180000);
      expect(r.taxableHra, 120000);
      expect(r.winningMethod, 1);
    });

    test('edge: rent < 10% basic floors method 2 at 0', () {
      final r = computeHra(
        basic: 600000,
        hraReceived: 100000,
        rentPaid: 30000,
        isMetro: false,
      );
      expect(r.methodRentMinus10Basic, 0);
      expect(r.exemption, 0);
    });
  });

  group('Goal planner engine', () {
    test('matches mockup: ₹40L / 12y @ 12%, ₹5L saved → ~₹6,369/mo', () {
      final r = computeGoal(
        target: 4000000,
        years: 12,
        ratePercent: 12,
        currentSavings: 500000,
      );
      expect(r.monthlyInvestment, closeTo(6369, 5));
      expect(r.alreadyOnTrack, isFalse);
      expect(r.finalCorpus, 4000000);
    });

    test('edge: already on track needs ₹0/mo', () {
      final r = computeGoal(
        target: 1000000,
        years: 20,
        ratePercent: 12,
        currentSavings: 500000,
      );
      expect(r.alreadyOnTrack, isTrue);
      expect(r.monthlyInvestment, 0);
    });
  });

  group('Retirement engine', () {
    test('matches mockup: age 32→60→85, ₹60k/mo, i6 pre12 post7, ₹10L', () {
      final r = computeRetirement(
        currentAge: 32,
        retirementAge: 60,
        lifeExpectancy: 85,
        currentMonthlyExpense: 60000,
        inflationPercent: 6,
        preRetirementReturnPercent: 12,
        postRetirementReturnPercent: 7,
        currentSavings: 1000000,
      );
      expect(r.yearsToRetirement, 28);
      expect(r.yearsInRetirement, 25);
      expect(r.monthlyExpenseAtRetirement, closeTo(306700, 1500));
      expect(r.requiredCorpus, closeTo(81600000, 600000)); // ≈ ₹8.16 Cr
      expect(r.monthlyInvestment, closeTo(20930, 600));
      expect(r.fvCurrentSavings, closeTo(23900000, 200000));
    });

    test('edge: zero real rate falls back to linear corpus', () {
      final r = computeRetirement(
        currentAge: 30,
        retirementAge: 60,
        lifeExpectancy: 80,
        currentMonthlyExpense: 50000,
        inflationPercent: 7,
        preRetirementReturnPercent: 10,
        postRetirementReturnPercent: 7,
        currentSavings: 0,
      );
      expect(r.requiredCorpus.isFinite, isTrue);
      expect(r.requiredCorpus, greaterThan(0));
    });
  });

  group('Engine input guards', () {
    test('EMI zero tenure returns zeros, not negative interest', () {
      final r = computeEmiSchedule(100000, 10, 0);
      expect(r.emi, 0);
      expect(r.totalInterest, 0);
      expect(r.totalPayable, 0);
    });

    test('PPF deposit is clamped inside the engine', () {
      final over = computePpf(500000, 15); // above ₹1.5L cap
      final capped = computePpf(kPpfMaxDeposit, 15);
      expect(over.maturity, capped.maturity);
    });

    test('Retirement with life <= retirement age returns safe zeros', () {
      final r = computeRetirement(
        currentAge: 30,
        retirementAge: 60,
        lifeExpectancy: 55,
        currentMonthlyExpense: 60000,
        inflationPercent: 6,
        preRetirementReturnPercent: 12,
        postRetirementReturnPercent: 7,
        currentSavings: 1000000,
      );
      expect(r.requiredCorpus, 0);
      expect(r.monthlyInvestment, 0);
    });
  });
}
