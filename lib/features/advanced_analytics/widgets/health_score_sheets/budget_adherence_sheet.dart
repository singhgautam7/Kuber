import '../../engine/analytics_engine_adapter.dart';
import 'subscore_explanation_sheet_base.dart';

SubscoreExplanationContent buildBudgetAdherenceContent(SubscoreDetail detail) {
  final kept = detailInt(detail, 'kept');
  final total = detailInt(detail, 'total');
  final over = (detail.context['over'] as List?)?.cast<String>() ?? const [];
  return SubscoreExplanationContent(
    title: 'Budget Adherence',
    calculationExplanation: total == 0
        ? 'Budget adherence needs active budgets. Kuber skips this factor when no budgets are active.'
        : 'Budget adherence is the percentage of budgets kept within limit over the last 3 months. For you: $kept of $total budgets stayed under.',
    whyExplanation: over.isEmpty
        ? 'Your active budgets stayed within limit in this window.'
        : 'These budget categories went over: ${over.join(', ')}.',
    improvementSuggestion: over.isEmpty
        ? "You're in great shape here. Keep reviewing budgets as your spending changes."
        : 'Review the categories that went over consistently. Either raise unrealistic budgets or focus on reducing those expenses.',
    actionLabel: 'Manage budgets',
    actionRoute: '/more/budgets',
    footerNote: 'This calculation uses data from the last 3 months.',
  );
}
