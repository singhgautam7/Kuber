import '../../engine/analytics_engine_adapter.dart';
import '../analytics_common.dart';
import 'subscore_explanation_sheet_base.dart';

SubscoreExplanationContent buildEmergencyFundContent(SubscoreDetail detail) {
  final savings = detailDouble(detail, 'savings');
  final avgExpense = detailDouble(detail, 'avgExpense');
  final months = detail.metric;
  final target = (avgExpense * 6 - savings).clamp(0, double.infinity);
  return SubscoreExplanationContent(
    title: 'Emergency Fund',
    calculationExplanation: avgExpense <= 0
        ? 'Emergency fund coverage needs recent expenses. Kuber could not estimate monthly coverage from the last 6 months.'
        : 'Coverage = savings balances / average monthly expense. For you: ${aaMoney(savings)} / ${aaMoney(avgExpense)} = ${months.toStringAsFixed(1)} months. Six months earns full points.',
    whyExplanation: savings <= 0
        ? 'No positive savings balance was found in tracked non-credit accounts.'
        : months >= 6
        ? 'Your tracked savings cover at least 6 months of expenses.'
        : 'Your emergency fund covers ${months.toStringAsFixed(1)} months of expenses.',
    improvementSuggestion: target <= 0
        ? "You're already in the full-score band."
        : 'Adding about ${aaMoney(target / 6)} per month for 6 months would move this score meaningfully higher.',
    footerNote: 'Emergency Fund uses data from the last 6 months.',
  );
}
