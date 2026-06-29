import 'dart:math';

class HraResult {
  final double exemption;
  final double taxableHra;

  final double methodHraReceived;
  final double methodRentMinus10Basic;
  final double methodPercentOfBasic;

  /// 0-based index (into the three methods) of the winning (least) value.
  final int winningMethod;

  const HraResult({
    required this.exemption,
    required this.taxableHra,
    required this.methodHraReceived,
    required this.methodRentMinus10Basic,
    required this.methodPercentOfBasic,
    required this.winningMethod,
  });
}

/// HRA exemption = least of the three statutory methods. All inputs annual.
/// [isMetro] selects 50% (metro) vs 40% (non-metro) of basic.
HraResult computeHra({
  required double basic,
  required double hraReceived,
  required double rentPaid,
  required bool isMetro,
}) {
  final m1 = hraReceived;
  final m2 = max(0.0, rentPaid - 0.10 * basic);
  final m3 = (isMetro ? 0.50 : 0.40) * basic;

  final methods = [m1, m2, m3];
  var winning = 0;
  for (var k = 1; k < methods.length; k++) {
    if (methods[k] < methods[winning]) winning = k;
  }
  final exemption = methods[winning];
  return HraResult(
    exemption: exemption,
    taxableHra: max(0.0, hraReceived - exemption),
    methodHraReceived: m1,
    methodRentMinus10Basic: m2,
    methodPercentOfBasic: m3,
    winningMethod: winning,
  );
}
