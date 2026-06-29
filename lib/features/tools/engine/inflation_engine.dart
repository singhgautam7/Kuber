import 'dart:math';

class InflationResult {
  /// Amount needed in [years] to retain today's purchasing power.
  final double futureValueRequired;

  /// What today's amount will actually be worth in [years].
  final double realValueOfToday;

  /// Future value required at the end of each year, index 0 = today's amount.
  final List<double> futureSeries;

  /// Real value of today's money at the end of each year, index 0 = amount.
  final List<double> realSeries;

  const InflationResult({
    required this.futureValueRequired,
    required this.realValueOfToday,
    required this.futureSeries,
    required this.realSeries,
  });
}

/// Future value required `= amount·(1+i)^years`;
/// real value of today's money `= amount/(1+i)^years`.
InflationResult computeInflation(
  double amount,
  double inflationPercent,
  int years,
) {
  final i = inflationPercent / 100;
  final future = <double>[];
  final real = <double>[];
  for (var y = 0; y <= years; y++) {
    future.add(amount * pow(1 + i, y));
    real.add(amount / pow(1 + i, y));
  }
  return InflationResult(
    futureValueRequired: future[years],
    realValueOfToday: real[years],
    futureSeries: future,
    realSeries: real,
  );
}
