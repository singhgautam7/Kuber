import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FixedWindowNote(
          message:
              'Health score always reflects the last 3-6 months, regardless of section date filters.',
        ),
        const SizedBox(height: KuberSpacing.md),
        async.when(
          loading: () => const AnalyticsSkeletonBlock(),
          error: (error, _) => KuberEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Could not load health score',
            description: '$error',
          ),
          data: (score) {
            if (score.monthsTracked < 2) {
              return KuberEmptyState(
                icon: Icons.health_and_safety_outlined,
                title: 'Score needs 2 months of history',
                description:
                    'You currently have ${score.monthsTracked} months.',
              );
            }
            final band = _bandFor(context, score.total);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: KuberSpacing.md),
                Center(child: _ScoreHero(score: score.total, band: band)),
                const SizedBox(height: KuberSpacing.lg),
                _HealthSummary(band: band, focusAreas: score.improvementAreas),
                const SizedBox(height: KuberSpacing.xl),
                for (final detail in score.subscores)
                  _SubscoreRow(detail: detail),
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
  final cs = Theme.of(context).colorScheme;
  final warning = context.kuberColors.warning;
  if (total >= 80) return _HealthBand('Excellent', cs.tertiary);
  if (total >= 65) return _HealthBand('Good', cs.tertiary);
  if (total >= 45) return _HealthBand('Fair', warning);
  return _HealthBand('Needs attention', cs.error);
}

Color _subscoreColor(BuildContext context, int score) {
  final cs = Theme.of(context).colorScheme;
  if (score >= 16) return cs.tertiary;
  if (score >= 10) return context.kuberColors.warning;
  return cs.error;
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: (score / 100).clamp(0.0, 1.0),
                  strokeWidth: 12,
                  strokeCap: StrokeCap.round,
                  color: band.color,
                  backgroundColor: cs.surfaceContainerHigh,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: localeFont(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    '/ 100',
                    style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: KuberSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: band.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: band.color.withValues(alpha: 0.35)),
          ),
          child: Text(
            band.label,
            style: localeFont(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: band.color,
            ),
          ),
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
            style: localeFont(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
        );
      }
      spans.add(const TextSpan(text: ' score.'));
    }
    return Text.rich(
      TextSpan(
        style: localeFont(
          fontSize: 12.5,
          color: cs.onSurfaceVariant,
          height: 1.5,
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
    final applicable = detail.applicable;
    final barColor = applicable
        ? _subscoreColor(context, detail.score)
        : cs.outlineVariant;

    final card = Container(
      padding: const EdgeInsets.all(KuberSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 34,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: KuberSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _subscoreTitle(detail.type),
                  style: localeFont(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: applicable ? cs.onSurface : cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _subscoreSubtitle(detail),
                  style: localeFont(fontSize: 11.5, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: KuberSpacing.sm),
          if (applicable) ...[
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${detail.score}',
                    style: localeFont(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: '/20',
                    style: localeFont(fontSize: 11, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: KuberSpacing.xs),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ] else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(KuberRadius.sm),
              ),
              child: Text(
                'NOT APPLICABLE',
                style: localeFont(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpacing.sm),
      child: applicable
          ? Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => showSubscoreExplanationSheet(context, detail),
                child: card,
              ),
            )
          : Opacity(opacity: 0.6, child: card),
    );
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
      margin: const EdgeInsets.only(top: KuberSpacing.sm),
      padding: const EdgeInsets.all(KuberSpacing.md),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, size: 18, color: cs.primary),
          const SizedBox(width: KuberSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: localeFont(
                fontSize: 12.5,
                color: cs.onSurface,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
