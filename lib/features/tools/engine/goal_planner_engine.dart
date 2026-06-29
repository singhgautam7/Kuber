import 'dart:math';

import 'sip_required_engine.dart';

class GoalYearRow {
  final int year;
  final double totalInvested;
  final double returns;
  final double totalValue;
  final double progressPercent;

  const GoalYearRow({
    required this.year,
    required this.totalInvested,
    required this.returns,
    required this.totalValue,
    required this.progressPercent,
  });
}

class GoalResult {
  final double monthlyInvestment;
  final double totalInvestment;
  final double returns;
  final double finalCorpus;
  final double target;
  final bool alreadyOnTrack;

  /// Portfolio value at the end of each year, index 0 = current savings.
  final List<double> valueSeries;
  final List<GoalYearRow> yearly;

  const GoalResult({
    required this.monthlyInvestment,
    required this.totalInvestment,
    required this.returns,
    required this.finalCorpus,
    required this.target,
    required this.alreadyOnTrack,
    required this.valueSeries,
    required this.yearly,
  });
}

/// Monthly investment needed to reach [target] in [years] at [ratePercent],
/// given [currentSavings] that also grows at the same rate.
GoalResult computeGoal({
  required double target,
  required int years,
  required double ratePercent,
  double currentSavings = 0,
}) {
  final fvCurrent = currentSavings * pow(1 + ratePercent / 100, years);
  final remaining = max(0.0, target - fvCurrent);
  final alreadyOnTrack = remaining <= 0;

  final monthly = alreadyOnTrack
      ? 0.0
      : requiredMonthlySip(remaining, ratePercent, years);
  final annualInvestment = monthly * 12;
  final totalInvestment = annualInvestment * years;

  final r = ratePercent / 100;
  final valueSeries = <double>[currentSavings];
  final yearly = <GoalYearRow>[];
  double v = currentSavings;
  for (var y = 1; y <= years; y++) {
    v = v * (1 + r) + annualInvestment;
    valueSeries.add(v);
    final invested = currentSavings + annualInvestment * y;
    yearly.add(GoalYearRow(
      year: y,
      totalInvested: annualInvestment * y,
      returns: max(0.0, v - invested),
      totalValue: v,
      progressPercent: target == 0 ? 0 : min(100.0, v / target * 100),
    ));
  }

  final finalCorpus = alreadyOnTrack ? fvCurrent.toDouble() : target;
  return GoalResult(
    monthlyInvestment: monthly,
    totalInvestment: totalInvestment,
    returns: finalCorpus - currentSavings - totalInvestment,
    finalCorpus: finalCorpus,
    target: target,
    alreadyOnTrack: alreadyOnTrack,
    valueSeries: valueSeries,
    yearly: yearly,
  );
}
