/// Current statutory PPF rate. Constant in code; the screen lets the user edit
/// it for what-if scenarios but defaults here. Update if the govt revises it.
const double kPpfDefaultRate = 7.1;

/// Statutory yearly deposit limits.
const double kPpfMinDeposit = 500;
const double kPpfMaxDeposit = 150000;

class PpfYearRow {
  final int year;
  final double opening;
  final double deposit;
  final double interest;
  final double closing;

  const PpfYearRow({
    required this.year,
    required this.opening,
    required this.deposit,
    required this.interest,
    required this.closing,
  });
}

class PpfResult {
  final double maturity;
  final double totalDeposited;
  final double interestEarned;
  final List<double> balanceSeries; // index 0 = 0
  final List<PpfYearRow> yearly;

  const PpfResult({
    required this.maturity,
    required this.totalDeposited,
    required this.interestEarned,
    required this.balanceSeries,
    required this.yearly,
  });
}

/// Clamp a yearly PPF deposit to the statutory [kPpfMinDeposit, kPpfMaxDeposit]
/// window. A zero/empty input is left as 0 so the screen can show its empty
/// state instead of forcing ₹500.
double clampPpfDeposit(double deposit) {
  if (deposit <= 0) return 0;
  if (deposit < kPpfMinDeposit) return kPpfMinDeposit;
  if (deposit > kPpfMaxDeposit) return kPpfMaxDeposit;
  return deposit;
}

/// PPF compounds yearly: interest is credited on the year-end balance
/// (opening + deposit).
PpfResult computePpf(
  double rawYearlyDeposit,
  int years, {
  double ratePercent = kPpfDefaultRate,
}) {
  // Enforce the statutory ₹500–₹1,50,000 window inside the engine so maturity
  // can never reflect an out-of-bounds deposit (the screen also clamps + warns).
  final yearlyDeposit = clampPpfDeposit(rawYearlyDeposit);
  double bal = 0;
  final balanceSeries = <double>[0];
  final yearly = <PpfYearRow>[];
  for (var y = 1; y <= years; y++) {
    final opening = bal;
    final interest = (bal + yearlyDeposit) * ratePercent / 100;
    bal = (bal + yearlyDeposit) + interest;
    yearly.add(PpfYearRow(
      year: y,
      opening: opening,
      deposit: yearlyDeposit,
      interest: interest,
      closing: bal,
    ));
    balanceSeries.add(bal);
  }
  final deposited = yearlyDeposit * years;
  return PpfResult(
    maturity: bal,
    totalDeposited: deposited,
    interestEarned: bal - deposited,
    balanceSeries: balanceSeries,
    yearly: yearly,
  );
}
