import '../../engine/analytics_engine_adapter.dart';
import '../analytics_common.dart';
import 'subscore_explanation_sheet_base.dart';

SubscoreExplanationContent buildExpenseRatioContent(SubscoreDetail detail) {
  final income = detailDouble(detail, 'income');
  final expense = detailDouble(detail, 'expense');
  final ratio = detail.metric;
  final targetExpense = income * 0.6;
  final reduction = (expense - targetExpense)
      .clamp(0, double.infinity)
      .toDouble();
  return SubscoreExplanationContent(
    title: 'Expense Ratio',
    calculationExplanation: income <= 0
        ? 'Expense ratio needs tracked income. Without income, Kuber skips this factor instead of assigning a false low score.'
        : 'Expense ratio = Expense / Income x 100. For you: ${aaMoney(expense)} / ${aaMoney(income)} = ${aaPercent(ratio)}. Lower is better, and 60% or lower earns full points.',
    whyExplanation: ratio <= 60
        ? 'Your expense ratio is within the strong band.'
        : ratio <= 80
        ? 'Your expense ratio is workable, but spending is taking a large share of income.'
        : 'Most of your tracked income is being spent in this window.',
    improvementSuggestion: reduction <= 0
        ? "You're already under the 60% benchmark."
        : 'Reducing expenses by about ${aaMoney(reduction)} over 3 months would move you toward the next band.',
    actionLabel: 'See spending patterns',
    actionRoute: '/advanced-analytics',
    footerNote: 'This calculation uses data from the last 3 months.',
  );
}
