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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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

    final monthLabel = DateFormat(
      'MMM yyyy',
    ).format(DateTime.now()).toUpperCase();

    // Loans hero accent flips to error when there's outstanding debt.
    final heroAccent = totalOutstanding > 0 ? cs.error : cs.primary;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(KuberRadius.xl),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color.alphaBlend(
              heroAccent.withValues(alpha: 0.16),
              cs.surfaceContainer,
            ),
            cs.surfaceContainer,
          ],
          stops: const [0.0, 0.75],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.totalOutstandingDebt,
                        style: localeFont(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurfaceVariant,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        border: Border.all(color: cs.outline),
                        borderRadius: BorderRadius.circular(KuberRadius.sm),
                      ),
                      child: Text(
                        monthLabel,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: cs.onSurfaceVariant,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        maskAmount(
                          fmt.formatCurrency(totalOutstanding),
                          masked,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: localeFont(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                          letterSpacing: -0.8,
                          height: 1.1,
                        ),
                      ),
                    ),
                    if (totalPrincipal > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4, left: 8),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(6, 3, 8, 3),
                          decoration: BoxDecoration(
                            color: cs.tertiary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                              KuberRadius.full,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.trending_down_rounded,
                                size: 14,
                                color: cs.tertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${(paidPct * 100).toStringAsFixed(0)}% paid',
                                style: localeFont(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: cs.tertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    style: localeFont(
                      fontSize: 11.5,
                      color: cs.onSurfaceVariant,
                    ),
                    children: [
                      TextSpan(
                        text: activeCount == 0
                            ? 'no active loans'
                            : '$activeCount active loan${activeCount == 1 ? '' : 's'}',
                        style: localeFont(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      if (activeCount > 0 && nextDueLabel != null)
                        TextSpan(text: ' · next EMI $nextDueLabel'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border.all(color: cs.outline),
                borderRadius: BorderRadius.circular(KuberRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 8,
                      child: Row(
                        children: [
                          if (paidPct > 0)
                            Expanded(
                              flex: (paidPct * 1000).round().clamp(1, 1000),
                              child: ColoredBox(color: cs.tertiary),
                            ),
                          Expanded(
                            flex: ((1 - paidPct) * 1000).round().clamp(1, 1000),
                            child: ColoredBox(color: cs.outlineVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _LegendBlock(
                          color: cs.tertiary,
                          label: context.l10n.paidLabel,
                          value: maskAmount(
                            fmt.formatCurrency(totalPaid),
                            masked,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _LegendBlock(
                          color: cs.outlineVariant,
                          label: context.l10n.outstandingTitle,
                          value: maskAmount(
                            fmt.formatCurrency(totalOutstanding),
                            masked,
                          ),
                          alignEnd: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendBlock extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final bool alignEnd;
  const _LegendBlock({
    required this.color,
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: alignEnd
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!alignEnd) ...[_Dot(color: color), const SizedBox(width: 6)],
            Text(
              label.toUpperCase(),
              style: localeFont(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
                letterSpacing: 0.6,
              ),
            ),
            if (alignEnd) ...[const SizedBox(width: 6), _Dot(color: color)],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: localeFont(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: 7,
    height: 7,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

// ---------------------------------------------------------------------------
// Loan card
// ---------------------------------------------------------------------------

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

    final dueColor = overdue
        ? cs.error
        : dueSoon
        ? context.kuberColors.warning
        : cs.onSurface;

    final progressColor = isCompleted ? cs.tertiary : iconColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KuberRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            border: Border.all(color: cs.outline),
            borderRadius: BorderRadius.circular(KuberRadius.lg),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      border: Border.all(
                        color: iconColor.withValues(alpha: 0.30),
                      ),
                      borderRadius: BorderRadius.circular(KuberRadius.md + 2),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 22, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                overflow: TextOverflow.ellipsis,
                                style: localeFont(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            if (isCompleted) ...[
                              const SizedBox(width: 8),
                              const _CompletePill(),
                            ],
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          lenderLabel,
                          overflow: TextOverflow.ellipsis,
                          style: localeFont(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isCompleted ? context.l10n.paidUpper : context.l10n.outstandingLabel,
                        style: localeFont(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurfaceVariant,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        maskAmount(
                          fmt.formatCurrency(
                            isCompleted ? principal : outstanding,
                          ),
                          masked,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: localeFont(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  height: 6,
                  child: Stack(
                    children: [
                      Container(color: cs.surfaceContainerHigh),
                      FractionallySizedBox(
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: Container(color: progressColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: localeFont(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                        children: [
                          TextSpan(
                            text: '${(progress * 100).toStringAsFixed(0)}%',
                            style: localeFont(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                          const TextSpan(text: ' paid · '),
                          TextSpan(
                            text: maskAmount(fmt.formatCurrency(paid), masked),
                          ),
                          const TextSpan(text: ' of '),
                          TextSpan(
                            text: maskAmount(
                              fmt.formatCurrency(principal),
                              masked,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (!isCompleted) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: cs.outline.withValues(alpha: 0.5)),
                    ),
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
                            value: '${interestRate!.toStringAsFixed(2)}%',
                          ),
                        ),
                      Expanded(
                        child: _StripItem(
                          label: context.l10n.nextDue,
                          value: nextDue == null
                              ? '—'
                              : DateFormat('MMM d').format(nextDue!),
                          valueColor: dueColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
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
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: localeFont(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: cs.onSurfaceVariant,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: localeFont(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: valueColor ?? cs.onSurface,
          ),
        ),
      ],
    );
  }
}

class _CompletePill extends StatelessWidget {
  const _CompletePill();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: cs.tertiary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(KuberRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 11, color: cs.tertiary),
          const SizedBox(width: 3),
          Text(
            context.l10n.completedUpper,
            style: localeFont(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: cs.tertiary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(KuberRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Text(
              context.l10n.completedUpper,
              style: localeFont(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: cs.tertiary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(KuberRadius.sm),
              ),
              child: Text(
                '$count',
                style: localeFont(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: cs.tertiary,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            const Spacer(),
            Icon(
              expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}