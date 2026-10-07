import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../../shared/widgets/sheet_button_section.dart';
import '../../engine/analytics_engine_adapter.dart';
import 'budget_adherence_sheet.dart';
import 'debt_ratio_sheet.dart';
import 'emergency_fund_sheet.dart';
import 'expense_ratio_sheet.dart';
import 'savings_rate_sheet.dart';

class SubscoreExplanationContent {
  final String title;
  final String calculationExplanation;
  final String whyExplanation;
  final String improvementSuggestion;
  final String? actionLabel;
  final String? actionRoute;
  final String footerNote;

  const SubscoreExplanationContent({
    required this.title,
    required this.calculationExplanation,
    required this.whyExplanation,
    required this.improvementSuggestion,
    this.actionLabel,
    this.actionRoute,
    required this.footerNote,
  });
}

/// Resolves the copy for a subscore. Shared by the explanation sheet and the
/// health-score screen's inline "how to improve" banner.
SubscoreExplanationContent buildSubscoreContent(SubscoreDetail detail) {
  return switch (detail.type) {
    SubscoreType.savingsRate => buildSavingsRateContent(detail),
    SubscoreType.expenseRatio => buildExpenseRatioContent(detail),
    SubscoreType.budgetAdherence => buildBudgetAdherenceContent(detail),
    SubscoreType.emergencyFund => buildEmergencyFundContent(detail),
    SubscoreType.debtRatio => buildDebtRatioContent(detail),
  };
}

void showSubscoreExplanationSheet(BuildContext context, SubscoreDetail detail) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, __) => SubscoreExplanationSheet(detail: detail),
    ),
  );
}

class SubscoreExplanationSheet extends StatelessWidget {
  final SubscoreDetail detail;

  const SubscoreExplanationSheet({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final content = buildSubscoreContent(detail);

    return KuberBottomSheet(
      title: content.title,
      subtitle: 'Subscore',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ScoreCard(detail: detail),
          const SizedBox(height: KuberSpace.xl),
          _SectionBlock(
            title: "How it's calculated",
            body: content.calculationExplanation,
          ),
          _SectionBlock(
            title: 'Why your score is ${detail.score}/20',
            body: content.whyExplanation,
          ),
          _SectionBlock(
            title: 'How to improve',
            body: content.improvementSuggestion,
          ),
          if (content.actionLabel != null && content.actionRoute != null) ...[
            const SizedBox(height: KuberSpace.sm),
            SheetButtonSection(
              padding: EdgeInsets.zero,
              primary: SheetAction(
                label: content.actionLabel!,
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  Navigator.pop(context);
                  context.push(content.actionRoute!);
                },
              ),
            ),
          ],
          const SizedBox(height: KuberSpace.lg),
          Text(
            content.footerNote,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Board "Subscore sheet": a 56 ring with the score beside the status.
class _ScoreCard extends StatelessWidget {
  final SubscoreDetail detail;

  const _ScoreCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = detail.score >= 16
        ? context.kuberMoney.income
        : detail.score >= 10
        ? context.kuberMoney.warning
        : context.kuberMoney.expense;
    return Row(
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: (detail.score / 20).clamp(0.0, 1.0),
                  strokeWidth: 5,
                  strokeCap: StrokeCap.round,
                  color: color,
                  backgroundColor: cs.surfaceContainerHighest,
                ),
              ),
              Text(
                '${detail.score}',
                style: tt.titleMedium!.copyWith(color: cs.onSurface),
              ),
            ],
          ),
        ),
        const SizedBox(width: KuberSpace.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${detail.score} of 20',
                style: tt.titleMedium!.copyWith(color: color),
              ),
              Text(
                detail.status,
                style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionBlock extends StatelessWidget {
  final String title;
  final String body;

  const _SectionBlock({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: sectionHeaderStyle(context)),
          const SizedBox(height: KuberSpace.sectionHeaderGap),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

double detailDouble(SubscoreDetail detail, String key) =>
    (detail.context[key] as num?)?.toDouble() ?? 0;

int detailInt(SubscoreDetail detail, String key) =>
    (detail.context[key] as num?)?.toInt() ?? 0;
