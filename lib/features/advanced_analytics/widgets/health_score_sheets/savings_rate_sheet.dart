import '../../engine/analytics_engine_adapter.dart';
import '../analytics_common.dart';
import 'subscore_explanation_sheet_base.dart';

SubscoreExplanationContent buildSavingsRateContent(SubscoreDetail detail) {
  final income = detailDouble(detail, 'income');
  final expense = detailDouble(detail, 'expense');
  final rate = detail.metric;
  final targetRate = rate < 10
      ? 10
      : rate < 20
      ? 20
      : 25;
  final targetSaving = income * (targetRate / 100);
  final currentSaving = income - expense;
  final delta = (targetSaving - currentSaving)
      .clamp(0, double.infinity)
      .toDouble();
  return SubscoreExplanationContent(
    title: 'Savings Rate',
    calculationExplanation: income <= 0
        ? 'Savings rate needs tracked income. Kuber found expenses but no income in the last 3 months.'
        : 'Savings rate = (Income - Expense) / Income x 100. For you: (${aaMoney(income)} - ${aaMoney(expense)}) / ${aaMoney(income)} = ${aaPercent(rate)}. Full points start at 25% or higher.',
    whyExplanation: rate >= 20
        ? "You're saving ${aaPercent(rate)}, above the recommended 20%."
        : rate >= 10
        ? 'Your savings rate of ${aaPercent(rate)} is decent but has room to grow.'
        : 'Your savings rate of ${aaPercent(rate)} is below the recommended 20%.',
    improvementSuggestion: income <= 0
        ? 'Track income transactions to make this score meaningful.'
        : delta <= 0
        ? "You're already in great shape here."
        : 'To reach the next level, try increasing savings by about ${aaMoney(delta)} over the next 3 months.',
    actionLabel: 'See spending patterns',
    actionRoute: '/advanced-analytics',
    footerNote: 'This calculation uses data from the last 3 months.',
  );
}
