import 'investment_engine.dart';

class LumpsumVsSipResult {
  final InvestmentResult lumpsum;
  final InvestmentResult sip;
  final double monthlySip;

  /// lumpsum.futureValue − sip.futureValue (positive ⇒ lumpsum wins).
  final double difference;

  const LumpsumVsSipResult({
    required this.lumpsum,
    required this.sip,
    required this.monthlySip,
    required this.difference,
  });

  bool get lumpsumWins => difference >= 0;

  /// Magnitude of the gap as a % of the losing side's final value.
  double get differencePercent {
    final loser = lumpsumWins ? sip.futureValue : lumpsum.futureValue;
    if (loser == 0) return 0;
    return difference.abs() / loser * 100;
  }
}

/// Compare investing the same [total] as an upfront lumpsum vs spreading it as
/// a monthly SIP over [years]. SIP monthly = total / (years·12).
LumpsumVsSipResult computeLumpsumVsSip(
  double total,
  double annualRatePercent,
  int years,
) {
  final monthly = years <= 0 ? 0.0 : (total / (years * 12)).roundToDouble();
  final lump = computeLumpsum(total, annualRatePercent, years);
  final sip = computeSip(monthly, annualRatePercent, years);
  return LumpsumVsSipResult(
    lumpsum: lump,
    sip: sip,
    monthlySip: monthly,
    difference: lump.futureValue - sip.futureValue,
  );
}
