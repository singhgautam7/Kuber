import 'dart:math';

/// Month-granularity schedule rows for the Yearly/Monthly table toggle. Each
/// row is a list of doubles whose first element is the 1-based month index; the
/// remaining columns mirror the corresponding engine's yearly columns. Screens
/// format these into strings. Engines stay UI-free and yearly by default; these
/// builders recompute at monthly resolution on demand (only when the user flips
/// the toggle).

/// EMI: [month, opening, paid, principal, interest, closing].
List<List<double>> emiMonthlyRows(
  double principal,
  double annualRatePercent,
  int months, {
  double extraMonthly = 0,
}) {
  final r = annualRatePercent / 100 / 12;
  final emi = r == 0
      ? principal / months
      : principal * r * pow(1 + r, months) / (pow(1 + r, months) - 1);
  double bal = principal;
  final rows = <List<double>>[];
  for (var m = 1; m <= months && bal > 0; m++) {
    final interest = bal * r;
    var prin = emi - interest + extraMonthly;
    if (prin > bal) prin = bal;
    final opening = bal;
    bal -= prin;
    rows.add([m.toDouble(), opening, prin + interest, prin, interest, max(bal, 0)]);
  }
  return rows;
}

/// SIP: [month, invested, value, gains, returnPct].
List<List<double>> sipMonthlyRows(
  double monthly,
  double annualRatePercent,
  int years,
) {
  final r = annualRatePercent / 100 / 12;
  final rows = <List<double>>[];
  double v = 0;
  for (var m = 1; m <= years * 12; m++) {
    v = (v + monthly) * (1 + r);
    final invested = monthly * m;
    rows.add([
      m.toDouble(),
      invested,
      v,
      v - invested,
      invested == 0 ? 0 : (v - invested) / invested * 100,
    ]);
  }
  return rows;
}
