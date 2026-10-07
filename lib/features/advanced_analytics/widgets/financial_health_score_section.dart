import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../engine/analytics_engine_adapter.dart';
import '../providers/advanced_analytics_provider.dart';
import 'analytics_common.dart';
import 'fixed_window_note.dart';
import 'health_score_sheets/subscore_explanation_sheet_base.dart';

class FinancialHealthScoreSection extends ConsumerWidget {
  const FinancialHealthScoreSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(financialHealthProvider);
    const note = FixedWindowNote(
      message:
          'Health score always reflects the last 3-6 months, regardless of section date filters.',
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        async.when(
          loading: () => const AnalyticsSkeletonBlock(),
          error: (error, _) => KuberEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Could not load health score',
            description: '$error',
          ),
          data: (score) {
            if (score.monthsTracked < 2) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  note,
                  KuberEmptyState(
                    icon: Icons.health_and_safety_outlined,
                    title: 'Score needs 2 months of history',
                    description:
                        'You currently have ${score.monthsTracked} months.',
                  ),
                ],
              );
            }
            final band = _bandFor(context, score.total);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: KuberSpace.sm),
                Center(
                  child: _ScoreHero(score: score.total, band: band),
                ),
                const SizedBox(height: KuberSpace.sm),
                _HealthSummary(band: band, focusAreas: score.improvementAreas),
                const SizedBox(height: KuberSpace.xl),
                note,
                const SizedBox(height: KuberSpace.sectionGap - 4),
                KuberSectionHeader(title: 'Breakdown'),
                KuberGroup(
                  children: [
                    for (final detail in score.subscores)
                      _SubscoreRow(detail: detail),
                  ],
                ),
                _ImprovementBanner(score: score),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ── Score bands ─────────────────────────────────────────────────────────────

class _HealthBand {
  final String label;
  final Color color;
  const _HealthBand(this.label, this.color);
}

_HealthBand _bandFor(BuildContext context, int total) {
  final warning = context.kuberMoney.warning;
  if (total >= 80) return _HealthBand('Excellent', context.kuberMoney.income);
  if (total >= 65) return _HealthBand('Good', context.kuberMoney.income);
  if (total >= 45) return _HealthBand('Fair', warning);
  return _HealthBand('Needs attention', context.kuberMoney.expense);
}

Color _subscoreColor(BuildContext context, int score) {
  if (score >= 16) return context.kuberMoney.income;
  if (score >= 10) return context.kuberMoney.warning;
  return context.kuberMoney.expense;
}

String _subscoreTitle(SubscoreType type) => switch (type) {
  SubscoreType.savingsRate => 'Savings Rate',
  SubscoreType.expenseRatio => 'Expense Ratio',
  SubscoreType.budgetAdherence => 'Budget Adherence',
  SubscoreType.emergencyFund => 'Emergency Fund',
  SubscoreType.debtRatio => 'Debt Ratio',
};

String _subscoreSubtitle(SubscoreDetail d) {
  if (!d.applicable) {
    return switch (d.type) {
      SubscoreType.budgetAdherence =>
        'Create budgets to take this into consideration.',
      SubscoreType.savingsRate ||
      SubscoreType.expenseRatio => 'Add income transactions to calculate this.',
      SubscoreType.emergencyFund => 'Track expenses to calculate this.',
      SubscoreType.debtRatio => 'Add income to rate your debt obligations.',
    };
  }
  final ctx = d.context;
  switch (d.type) {
    case SubscoreType.savingsRate:
      return '${d.metric.round()}% savings rate';
    case SubscoreType.expenseRatio:
      return '${d.metric.round()}% of income spent';
    case SubscoreType.budgetAdherence:
      final total = (ctx['total'] as num?)?.toInt() ?? 0;
      final kept = (ctx['kept'] as num?)?.toInt() ?? 0;
      final over = total - kept;
      return over == 0
          ? 'All $total budgets on track'
          : '$over of $total budget${total == 1 ? '' : 's'} over pace';
    case SubscoreType.emergencyFund:
      return '${d.metric.toStringAsFixed(1)} months of expenses saved';
    case SubscoreType.debtRatio:
      final loanCount = (ctx['loanCount'] as num?)?.toInt() ?? 0;
      final cc = (ctx['ccOutstanding'] as num?)?.toDouble() ?? 0;
      if (loanCount == 0 && cc <= 0) return 'No tracked debt obligations';
      return '${d.metric.round()}% of income goes to debt';
  }
}

// ── Hero ring + band pill ───────────────────────────────────────────────────

class _ScoreHero extends StatelessWidget {
  final int score;
  final _HealthBand band;

  const _ScoreHero({required this.score, required this.band});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: (score / 100).clamp(0.0, 1.0),
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                  color: band.color,
                  backgroundColor: cs.surfaceContainerHighest,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: tt.displaySmall!.copyWith(color: cs.onSurface),
                  ),
                  Text(
                    '/ 100',
                    style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: KuberSpace.md),
        Text(
          band.label,
          style: tt.headlineSmall!.copyWith(color: band.color),
        ),
      ],
    );
  }
}

class _HealthSummary extends StatelessWidget {
  final _HealthBand band;
  final List<String> focusAreas;

  const _HealthSummary({required this.band, required this.focusAreas});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lead = switch (band.label) {
      'Excellent' => 'Your finances are in excellent shape.',
      'Good' => 'Your finances are in good shape.',
      'Fair' => 'Your finances are on the right track.',
      _ => 'Your finances need some attention.',
    };
    final spans = <InlineSpan>[TextSpan(text: lead)];
    if (focusAreas.isNotEmpty) {
      spans.add(const TextSpan(text: ' Focus on improving your '));
      for (var i = 0; i < focusAreas.length; i++) {
        if (i > 0) {
          spans.add(
            TextSpan(text: i == focusAreas.length - 1 ? ' and ' : ', '),
          );
        }
        spans.add(
          TextSpan(
            text: focusAreas[i],
            style: localeFont(fontWeight: FontWeight.w700, color: cs.onSurface),
          ),
        );
      }
      spans.add(const TextSpan(text: ' score.'));
    }
    return Text.rich(
      TextSpan(
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: cs.onSurfaceVariant,
        ),
        children: spans,
      ),
      textAlign: TextAlign.center,
    );
  }
}

// ── Subscore row ────────────────────────────────────────────────────────────

class _SubscoreRow extends StatelessWidget {
  final SubscoreDetail detail;

  const _SubscoreRow({required this.detail});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final applicable = detail.applicable;
    final color = applicable
        ? _subscoreColor(context, detail.score)
        : cs.outline;

    final row = KuberListRow(
      leading: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: applicable ? (detail.score / 20).clamp(0.0, 1.0) : 0,
                strokeWidth: 3.5,
                strokeCap: StrokeCap.round,
                color: color,
                backgroundColor: cs.surfaceContainerHighest,
              ),
            ),
            Text(
              applicable ? '${detail.score}' : '–',
              style: tt.labelMedium!.copyWith(color: cs.onSurface),
            ),
          ],
        ),
      ),
      title: _subscoreTitle(detail.type),
      subtitle: _subscoreSubtitle(detail),
      trailing: applicable
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${detail.score}/20',
                  style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(width: KuberSpace.xs),
                const KuberChevron(),
              ],
            )
          : const KuberPill(label: 'Not applicable'),
      onTap: applicable
          ? () => showSubscoreExplanationSheet(context, detail)
          : null,
    );
    return applicable ? row : Opacity(opacity: 0.6, child: row);
  }
}

// ── Improvement banner ──────────────────────────────────────────────────────

class _ImprovementBanner extends StatelessWidget {
  final FinancialHealthScore score;

  const _ImprovementBanner({required this.score});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final applicable = score.subscores.where((s) => s.applicable).toList();
    if (applicable.isEmpty) return const SizedBox.shrink();

    var weakest = applicable.first;
    for (final s in applicable) {
      if (s.score < weakest.score) weakest = s;
    }
    final message = weakest.score >= 16
        ? 'Your finances are in great shape. Keep up the good habits.'
        : buildSubscoreContent(weakest).improvementSuggestion;

    return Container(
      margin: const EdgeInsets.only(top: KuberSpace.lg),
      padding: const EdgeInsets.all(KuberSpace.lg),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: KuberShape.largeR,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 20,
            color: cs.onSecondaryContainer,
          ),
          const SizedBox(width: KuberSpace.md),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: cs.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
