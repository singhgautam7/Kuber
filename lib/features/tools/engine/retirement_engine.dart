import 'dart:math';

import 'sip_required_engine.dart';

class RetirementPhase1Row {
  final int age;
  final double investment; // annual
  final double corpusValue;
  const RetirementPhase1Row({
    required this.age,
    required this.investment,
    required this.corpusValue,
  });
}

class RetirementPhase2Row {
  final int age;
  final double annualExpense;
  final double withdrawal;
  final double remainingCorpus;
  const RetirementPhase2Row({
    required this.age,
    required this.annualExpense,
    required this.withdrawal,
    required this.remainingCorpus,
  });
}

class RetirementResult {
  final double requiredCorpus;
  final double monthlyInvestment;
  final int yearsToRetirement;
  final int yearsInRetirement;
  final double monthlyExpenseAtRetirement;
  final double fvCurrentSavings;
  final double totalInvested;
  final double returns;

  /// Corpus value at the end of each working year (now → retirement).
  final List<double> preRetirementSeries;

  /// Remaining corpus at the end of each retirement year.
  final List<double> postRetirementSeries;

  final List<RetirementPhase1Row> phase1;
  final List<RetirementPhase2Row> phase2;

  const RetirementResult({
    required this.requiredCorpus,
    required this.monthlyInvestment,
    required this.yearsToRetirement,
    required this.yearsInRetirement,
    required this.monthlyExpenseAtRetirement,
    required this.fvCurrentSavings,
    required this.totalInvested,
    required this.returns,
    required this.preRetirementSeries,
    required this.postRetirementSeries,
    required this.phase1,
    required this.phase2,
  });
}

/// Two linked calculations:
///  1. Corpus needed at retirement to fund an inflation-growing expense for the
///     retirement years (PV of a growing annuity via the real rate of return).
///  2. Monthly SIP today to build that corpus by retirement, given current
///     savings that grow at the pre-retirement return.
RetirementResult computeRetirement({
  required int currentAge,
  required int retirementAge,
  required int lifeExpectancy,
  required double currentMonthlyExpense,
  required double inflationPercent,
  required double preRetirementReturnPercent,
  required double postRetirementReturnPercent,
  double currentSavings = 0,
}) {
  final yearsToRet = retirementAge - currentAge;
  final yearsInRet = lifeExpectancy - retirementAge;
  final infl = inflationPercent / 100;
  final pre = preRetirementReturnPercent / 100;
  final post = postRetirementReturnPercent / 100;

  final monthlyExpAtRet = currentMonthlyExpense * pow(1 + infl, yearsToRet);
  final annualExpAtRet = monthlyExpAtRet * 12;

  // Real rate ≈ (1+post)/(1+inflation) − 1. Corpus = PV of the inflation-growing
  // withdrawal stream over the retirement years.
  final realRate = (1 + post) / (1 + infl) - 1;
  final double requiredCorpus = realRate.abs() < 1e-9
      ? annualExpAtRet * yearsInRet
      : annualExpAtRet * (1 - pow(1 + realRate, -yearsInRet)) / realRate;

  final fvCurrent = currentSavings * pow(1 + pre, yearsToRet);
  final remaining = max(0.0, requiredCorpus - fvCurrent);
  final monthlySip =
      requiredMonthlySip(remaining, preRetirementReturnPercent, yearsToRet);
  final totalInvested = monthlySip * 12 * yearsToRet;

  // Phase 1: corpus growth during working years.
  final preSeries = <double>[currentSavings];
  final phase1 = <RetirementPhase1Row>[];
  double c = currentSavings;
  phase1.add(RetirementPhase1Row(
    age: currentAge,
    investment: monthlySip * 12,
    corpusValue: c,
  ));
  for (var y = 1; y <= yearsToRet; y++) {
    c = c * (1 + pre) + monthlySip * 12;
    preSeries.add(c);
    phase1.add(RetirementPhase1Row(
      age: currentAge + y,
      investment: monthlySip * 12,
      corpusValue: c,
    ));
  }

  // Phase 2: drawdown during retirement.
  final postSeries = <double>[requiredCorpus];
  final phase2 = <RetirementPhase2Row>[];
  double corpus = requiredCorpus;
  double expense = annualExpAtRet;
  for (var y = 1; y <= yearsInRet; y++) {
    final withdrawal = expense;
    corpus = (corpus - withdrawal) * (1 + post);
    phase2.add(RetirementPhase2Row(
      age: retirementAge + y,
      annualExpense: expense,
      withdrawal: withdrawal,
      remainingCorpus: max(0.0, corpus),
    ));
    postSeries.add(max(0.0, corpus));
    expense = expense * (1 + infl);
  }

  return RetirementResult(
    requiredCorpus: requiredCorpus,
    monthlyInvestment: monthlySip,
    yearsToRetirement: yearsToRet,
    yearsInRetirement: yearsInRet,
    monthlyExpenseAtRetirement: monthlyExpAtRet.toDouble(),
    fvCurrentSavings: fvCurrent.toDouble(),
    totalInvested: totalInvested,
    returns: requiredCorpus - fvCurrent - totalInvested,
    preRetirementSeries: preSeries,
    postRetirementSeries: postSeries,
    phase1: phase1,
    phase2: phase2,
  );
}
