import '../../engine/analytics_engine_adapter.dart';
import '../analytics_common.dart';
import 'subscore_explanation_sheet_base.dart';

SubscoreExplanationContent buildDebtRatioContent(SubscoreDetail detail) {
  final emi = detailDouble(detail, 'emi');
  final ccOutstanding = detailDouble(detail, 'ccOutstanding');
  final ccMinPayment = detailDouble(detail, 'ccMinPayment');
  final monthlyDebt = detailDouble(detail, 'monthlyDebt');
  final income = detailDouble(detail, 'income');
  final count = detailInt(detail, 'loanCount');
  final ratio = detail.metric;
  final hasDebt = monthlyDebt > 0;
  final hasCard = ccOutstanding > 0;

  final obligations = <String>[
    if (count > 0)
      '$count loan EMI${count > 1 ? 's' : ''} of ${aaMoney(emi)}/mo',
    if (hasCard)
      'an estimated ${aaMoney(ccMinPayment)}/mo credit-card minimum payment '
          '(5% of ${aaMoney(ccOutstanding)} outstanding)',
  ];

  return SubscoreExplanationContent(
    title: 'Debt Ratio',
    calculationExplanation: !hasDebt
        ? 'Debt ratio = monthly debt obligations / monthly income. Kuber found '
              'no tracked loans and no credit-card outstanding, so this factor '
              'earns full points.'
        : 'Debt ratio = monthly debt obligations / monthly income. Your '
              'obligations are ${obligations.join(' plus ')}, totalling '
              '${aaMoney(monthlyDebt)}/mo. Against ${aaMoney(income)} monthly '
              'income that is ${aaPercent(ratio)}. Below 20% is a strong range.',
    whyExplanation: !hasDebt
        ? 'No tracked debt is the healthiest outcome for this factor.'
        : ratio <= 20
        ? 'Your debt obligations are comfortably below the 20% benchmark.'
        : 'Your debt obligations take a meaningful share of monthly income.',
    improvementSuggestion: !hasDebt
        ? "You're in great shape here."
        : hasCard
        ? 'Paying down the ${aaMoney(ccOutstanding)} credit-card outstanding '
              'lowers the estimated minimum payment and improves this ratio the '
              'fastest.'
        : 'Paying down or closing the smallest loan first would reduce this '
              'ratio and improve cashflow flexibility.',
    actionLabel: count > 0 ? 'Manage loans' : null,
    actionRoute: count > 0 ? '/more/loans' : null,
    footerNote: 'This calculation uses data from the last 3 months.',
  );
}
