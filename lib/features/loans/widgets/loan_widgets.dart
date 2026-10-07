// Loans overhaul widgets.
//
// Drop-ins for `lib/features/loans/screens/loans_screen.dart`:
//   - `LoansHero` — debt outstanding + paid-pill + paid/outstanding split.
//     Replaces the two-card summary that put outstanding-red and paid-green
//     in equal weight.
//   - `LoanCard` — single utilization-style progress bar + 3-column inline
//     strip (EMI · Interest · Next Due) instead of 4 cramped columns.
//   - `LoansCompletedToggle` — collapsed by default, expand to see done loans.
//
// State: reuses existing `loanListProvider`, `transactionListProvider`,
// `formatterProvider`, `privacyModeProvider`, and the `calc.*` helpers.
//
// New optional provider (see HANDOFF):
//   - `loansSummaryProvider` returning `({double totalPrincipal,
//     double totalPaid, double totalOutstanding, int activeCount,
//     DateTime? nextDue})`. Without it, recompute inline from
//     `calc.totalOutstanding` / `calc.totalPaidAllLoans` (already there).

import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../shared/widgets/kuber_progress.dart';
import '../../../shared/widgets/kuber_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, privacyModeProvider;

// ---------------------------------------------------------------------------
// Hero
// ---------------------------------------------------------------------------

class LoansHero extends ConsumerWidget {
  final double totalPrincipal;
  final double totalPaid;
  final double totalOutstanding;
  final int activeCount;
  final DateTime? nextDue; // earliest EMI date across active loans

  const LoansHero({
    super.key,
    required this.totalPrincipal,
    required this.totalPaid,
    required this.totalOutstanding,
    required this.activeCount,
    this.nextDue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final masked = ref.watch(privacyModeProvider);

    final paidPct = totalPrincipal <= 0
        ? 0.0
        : (totalPaid / totalPrincipal).clamp(0.0, 1.0);

    final daysToNext = nextDue?.difference(DateTime.now()).inDays;
    final nextDueLabel = nextDue == null
        ? null
        : daysToNext! <= 0
        ? 'overdue'
        : daysToNext == 1
        ? 'tomorrow'
        : daysToNext < 7
        ? 'in $daysToNext days'
        : DateFormat('MMM d').format(nextDue!);

    final tt = Theme.of(context).textTheme;
    Widget legend(Color dot, String label, String value) => Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: 8),
          Text(value, style: tt.titleSmall!.copyWith(color: cs.onSurface)),
        ],
      ),
    );

    // Board 3.21: total outstanding, a flat paid bar, Paid / Outstanding
    // legend and the next EMI line.
    return KuberCard(
      hero: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.totalOutstandingDebt,
            style: tt.labelMedium!.copyWith(
              letterSpacing: 0.8,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            maskAmount(fmt.formatCurrency(totalOutstanding), masked),
            style: tt.headlineMedium!.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: KuberSpace.lg),
          KuberLinearProgress(value: paidPct, flat: true, height: 8),
          const SizedBox(height: KuberSpace.sm),
          legend(
            cs.primary,
            context.l10n.paidLabel,
            maskAmount(fmt.formatCurrency(totalPaid), masked),
          ),
          legend(
            cs.surfaceContainerHighest,
            context.l10n.outstandingTitle,
            maskAmount(fmt.formatCurrency(totalOutstanding), masked),
          ),
          if (nextDueLabel != null) ...[
            const SizedBox(height: KuberSpace.md),
            Row(
              children: [
                Icon(
                  Icons.event_rounded,
                  size: 16,
                  color: daysToNext! <= 1
                      ? context.kuberMoney.warning
                      : cs.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  '${sentenceCase(context.l10n.nextDue)} $nextDueLabel',
                  style: tt.bodySmall!.copyWith(
                    color: daysToNext <= 1
                        ? context.kuberMoney.warning
                        : cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class LoanCard extends ConsumerWidget {
  final String name;
  final String lenderLabel;
  final IconData icon;
  final Color iconColor;
  final double principal;
  final double paid;
  final double outstanding;
  final double progress; // 0..1
  final double emi;
  final double? interestRate;
  final DateTime? nextDue;
  final bool isCompleted;
  final VoidCallback onTap;

  const LoanCard({
    super.key,
    required this.name,
    required this.lenderLabel,
    required this.icon,
    required this.iconColor,
    required this.principal,
    required this.paid,
    required this.outstanding,
    required this.progress,
    required this.emi,
    required this.isCompleted,
    required this.onTap,
    this.interestRate,
    this.nextDue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final masked = ref.watch(privacyModeProvider);

    final daysToDue = nextDue?.difference(DateTime.now()).inDays;
    final overdue = nextDue != null && daysToDue! < 0;
    final dueSoon = nextDue != null && daysToDue! >= 0 && daysToDue <= 3;

    // "tomorrow" / "overdue" use the warning colour (board 3.21).
    final dueColor = context.kuberMoney.warning;

    final theme = Theme.of(context);
    final tones = categoryTones(context, iconColor);
    // Board 3.21 row: tile, name + lender, outstanding on the right, wavy
    // progress with "29% paid", the three facts in a tonal strip.
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: tones.container,
                    borderRadius: KuberShape.mediumR,
                  ),
                  child: Icon(icon, size: 20, color: tones.fg),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium!.copyWith(
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                          if (isCompleted) ...[
                            const SizedBox(width: 8),
                            KuberPill(
                              label: sentenceCase(context.l10n.completedUpper),
                              tone: KuberTone.income,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        lenderLabel,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      maskAmount(
                        fmt.formatCurrency(
                          isCompleted ? principal : outstanding,
                        ),
                        masked,
                      ),
                      style: theme.textTheme.titleMedium!.copyWith(
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      (isCompleted
                              ? context.l10n.paidUpper
                              : context.l10n.outstandingLabel)
                          .toUpperCase(),
                      style: theme.textTheme.labelSmall!.copyWith(
                        letterSpacing: 0.6,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: KuberSpace.md),
            KuberLinearProgress(
              value: progress.clamp(0.0, 1.0),
              color: isCompleted ? context.kuberMoney.income : null,
            ),
            const SizedBox(height: 4),
            Text(
              '${(progress * 100).toStringAsFixed(0)}% paid',
              style: theme.textTheme.labelSmall!.copyWith(
                letterSpacing: 0.4,
                color: cs.onSurfaceVariant,
              ),
            ),
            if (!isCompleted) ...[
              const SizedBox(height: KuberSpace.md),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: KuberShape.mediumR,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _StripItem(
                        label: context.l10n.monthlyEmi,
                        value: maskAmount(fmt.formatCurrency(emi), masked),
                      ),
                    ),
                    if (interestRate != null)
                      Expanded(
                        child: _StripItem(
                          label: context.l10n.interestLabel,
                          value: '${interestRate!.toStringAsFixed(1)}%',
                        ),
                      ),
                    Expanded(
                      child: _StripItem(
                        label: context.l10n.nextDue,
                        value: nextDue == null
                            ? '-'
                            : dueSoon && daysToDue <= 1
                            ? (daysToDue == 0
                                  ? context.l10n.todayLower
                                  : context.l10n.tomorrowLower)
                            : DateFormat('MMM d').format(nextDue!),
                        valueColor: overdue || dueSoon ? dueColor : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StripItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _StripItem({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sentenceCase(label),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.titleSmall!.copyWith(color: valueColor ?? cs.onSurface),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Completed toggle
// ---------------------------------------------------------------------------

class LoansCompletedToggle extends StatelessWidget {
  final int count;
  final bool expanded;
  final VoidCallback onToggle;
  const LoansCompletedToggle({
    super.key,
    required this.count,
    required this.expanded,
    required this.onToggle,
  });

  /// Board 3.21: a filter chip "Completed · n" that shows / hides the
  /// completed loans.
  @override
  Widget build(BuildContext context) {
    return KuberChip(
      label: '${sentenceCase(context.l10n.completedUpper)} · $count',
      icon: Icons.check_circle_outline_rounded,
      selected: expanded,
      showCheck: false,
      onTap: onToggle,
    );
  }
}
