part of 'analytics_engine_adapter.dart';

enum SubscoreType {
  savingsRate,
  expenseRatio,
  budgetAdherence,
  emergencyFund,
  debtRatio,
}

class FinancialHealthScore {
  final int monthsTracked;
  final int total;
  final List<SubscoreDetail> subscores;
  final List<String> strengths;
  final List<String> improvementAreas;

  const FinancialHealthScore({
    required this.monthsTracked,
    required this.total,
    required this.subscores,
    required this.strengths,
    required this.improvementAreas,
  });
}

class SubscoreDetail {
  final SubscoreType type;
  final int score;
  final double metric;
  final Map<String, Object?> context;
  final String status;

  /// False when this factor can't be computed for the user (e.g. no budgets
  /// created, or no income tracked). Non-applicable subscores are shown muted
  /// as "Not applicable" and excluded from the weighted total.
  final bool applicable;

  const SubscoreDetail({
    required this.type,
    required this.score,
    required this.metric,
    required this.context,
    required this.status,
    this.applicable = true,
  });
}

FinancialHealthScore computeFinancialHealth(AnalyticsInput input) {
  final monthsTracked = _trackedMonths(input.transactions);
  final now = input.now;
  final last3Start = DateTime(now.year, now.month - 2, 1);
  final last6Start = DateTime(now.year, now.month - 5, 1);
  final end = _endInclusive(now);
  final s3 = _summary(input.transactions, last3Start, end);
  final s6 = _summary(input.transactions, last6Start, end);
  final income3 = s3.income;
  final expense3 = s3.expense;
  final hasIncome = income3 > 0;

  // All five factors are always emitted (in the design's order) so every row
  // renders; ones that can't be computed carry `applicable: false` and are
  // shown muted + excluded from the total.
  final subs = <SubscoreDetail>[];

  // 1. Savings rate (last 3 months).
  final savingsRate = hasIncome ? ((income3 - expense3) / income3) * 100 : 0.0;
  final savingsScore = hasIncome
      ? ((savingsRate / 25) * 20).clamp(0, 20).round()
      : 0;
  subs.add(
    SubscoreDetail(
      type: SubscoreType.savingsRate,
      score: savingsScore,
      metric: savingsRate,
      status: hasIncome ? _status(savingsScore) : 'Not applicable',
      applicable: hasIncome,
      context: {'income': income3, 'expense': expense3},
    ),
  );

  // 2. Expense ratio (last 3 months).
  final expenseRatio = hasIncome ? (expense3 / income3) * 100 : 0.0;
  final expenseScore = hasIncome
      ? (expenseRatio <= 60
            ? 20
            : (20 - ((expenseRatio - 60) / 40) * 20).clamp(0, 20).round())
      : 0;
  subs.add(
    SubscoreDetail(
      type: SubscoreType.expenseRatio,
      score: expenseScore,
      metric: expenseRatio,
      status: hasIncome ? _status(expenseScore) : 'Not applicable',
      applicable: hasIncome,
      context: {'income': income3, 'expense': expense3},
    ),
  );

  // 3. Budget adherence (last 3 months). Not applicable when no active budget
  // exists — the row invites the user to create one instead of scoring a zero.
  final activeBudgets = input.budgets
      .where((b) => b['isActive'] as bool? ?? false)
      .toList();
  if (activeBudgets.isEmpty) {
    subs.add(
      const SubscoreDetail(
        type: SubscoreType.budgetAdherence,
        score: 0,
        metric: 0,
        status: 'Not applicable',
        applicable: false,
        context: {'total': 0},
      ),
    );
  } else {
    var kept = 0;
    final over = <String>[];
    for (final b in activeBudgets) {
      final spent = s3.categorySpend[b['categoryId']] ?? 0;
      final limit = (b['amount'] as num).toDouble() * 3;
      if (spent <= limit) {
        kept++;
      } else {
        over.add(b['categoryId'] as String);
      }
    }
    final adherence = kept / activeBudgets.length;
    final score = (adherence * 20).round();
    subs.add(
      SubscoreDetail(
        type: SubscoreType.budgetAdherence,
        score: score,
        metric: adherence * 100,
        status: _status(score),
        context: {
          'kept': kept,
          'total': activeBudgets.length,
          'over': over.take(3).toList(),
        },
      ),
    );
  }

  // 4. Emergency fund (last 6 months) — savings balances vs average expense.
  final savingsBalance = input.accounts
      .where((a) => !(a['isCreditCard'] as bool? ?? false))
      .fold<double>(
        0,
        (sum, a) =>
            sum +
            (input.balances[a['id'] as int] ?? 0)
                .clamp(0, double.infinity)
                .toDouble(),
      );
  final avgExpense6 = s6.expense / 6;
  final hasExpenses = avgExpense6 > 0;
  final emergencyMonths = hasExpenses ? savingsBalance / avgExpense6 : 0.0;
  final emergencyScore = hasExpenses
      ? ((emergencyMonths / 6) * 20).clamp(0, 20).round()
      : 0;
  subs.add(
    SubscoreDetail(
      type: SubscoreType.emergencyFund,
      score: emergencyScore,
      metric: emergencyMonths,
      status: hasExpenses ? _status(emergencyScore) : 'Not applicable',
      applicable: hasExpenses,
      context: {'savings': savingsBalance, 'avgExpense': avgExpense6},
    ),
  );

  // 5. Debt ratio (last 3 months) — monthly loan EMIs PLUS an estimated
  // credit-card minimum payment (5% of outstanding, the common revolving
  // minimum), divided by monthly income. Credit-card debt is a real monthly
  // obligation, so ignoring it understated the ratio before.
  final activeLoans = input.loans
      .where((l) => !(l['isCompleted'] as bool? ?? false))
      .toList();
  final emi = activeLoans.fold<double>(
    0,
    (sum, l) => sum + (l['emiAmount'] as num).toDouble(),
  );
  final ccOutstanding = input.accounts
      .where((a) => a['isCreditCard'] as bool? ?? false)
      .fold<double>(0, (sum, a) {
        final bal = (input.balances[a['id'] as int] ?? 0).toDouble();
        // A credit card owes money when its computed balance is negative.
        return sum + (bal < 0 ? -bal : 0);
      });
  final ccMinPayment = ccOutstanding * 0.05;
  final monthlyDebt = emi + ccMinPayment;
  final monthlyIncome = income3 / 3;
  // No debt at all is a full-score, always-applicable outcome. If debt exists
  // but there's no income to rate it against, mark it not applicable.
  final debtApplicable = monthlyDebt <= 0 || monthlyIncome > 0;
  final debtRatio = monthlyIncome <= 0 ? 0.0 : (monthlyDebt / monthlyIncome) * 100;
  final debtScore = monthlyDebt <= 0
      ? 20
      : monthlyIncome <= 0
      ? 0
      : debtRatio <= 20
      ? 20
      : (20 - ((debtRatio - 20) / 40) * 20).clamp(0, 20).round();
  subs.add(
    SubscoreDetail(
      type: SubscoreType.debtRatio,
      score: debtScore,
      metric: debtRatio,
      status: debtApplicable ? _status(debtScore) : 'Not applicable',
      applicable: debtApplicable,
      context: {
        'emi': emi,
        'loanCount': activeLoans.length,
        'ccOutstanding': ccOutstanding,
        'ccMinPayment': ccMinPayment,
        'monthlyDebt': monthlyDebt,
        'income': monthlyIncome,
      },
    ),
  );

  // Weighted total per the health-score spec (savings 30%, expense 20%,
  // budget 20%, emergency 15%, debt 15%). Each subscore is 0-20, so it is
  // normalised to 0-1 before weighting. Non-applicable subscores drop out and
  // the remaining weights are renormalised, rather than penalising the user
  // with a zero. Result is scaled to 0-100.
  final applicable = subs.where((s) => s.applicable).toList();
  final weightSum = applicable.fold<double>(
    0,
    (sum, s) => sum + _subscoreWeight(s.type),
  );
  final total = applicable.isEmpty || weightSum <= 0
      ? 0
      : (applicable.fold<double>(
                  0,
                  (sum, s) => sum + _subscoreWeight(s.type) * (s.score / 20),
                ) /
                weightSum *
                100)
            .round()
            .clamp(0, 100);
  final strengths = applicable
      .where((s) => s.score >= 16)
      .map((s) => _subscoreTitle(s.type))
      .take(2)
      .toList();
  final weak = applicable
      .where((s) => s.score < 12)
      .map((s) => _subscoreTitle(s.type))
      .take(2)
      .toList();

  return FinancialHealthScore(
    monthsTracked: monthsTracked,
    total: total,
    subscores: subs,
    strengths: strengths,
    improvementAreas: weak,
  );
}

double _subscoreWeight(SubscoreType type) => switch (type) {
  SubscoreType.savingsRate => 0.30,
  SubscoreType.expenseRatio => 0.20,
  SubscoreType.budgetAdherence => 0.20,
  SubscoreType.emergencyFund => 0.15,
  SubscoreType.debtRatio => 0.15,
};

String _status(int score) {
  if (score >= 16) return 'Strong';
  if (score >= 10) return 'Fair';
  return 'Needs attention';
}

String _subscoreTitle(SubscoreType type) {
  return switch (type) {
    SubscoreType.savingsRate => 'Savings Rate',
    SubscoreType.expenseRatio => 'Expense Ratio',
    SubscoreType.budgetAdherence => 'Budget Adherence',
    SubscoreType.emergencyFund => 'Emergency Fund',
    SubscoreType.debtRatio => 'Debt Ratio',
  };
}
