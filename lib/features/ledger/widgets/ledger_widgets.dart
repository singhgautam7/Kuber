// Ledger (Lend / Borrow) overhaul.
//
// Drop-ins for `lib/features/ledger/screens/ledger_screen.dart`:
//   - `LedgerHero` — net-position headline + 2-up "You will receive" /
//     "You owe" sub-cards. Replaces the two equal-weight summary cards that
//     never composed into a single answer.
//   - `LedgerFilterRow` — preserves the existing Lent / Borrowed toggle and
//     clear button. Same behaviour, refined visual: rounded chips, a 34px
//     square clear button. The `_filterType` state variable in the host
//     screen does not change.
//   - `LedgerEntryCard` — single-row layout with inline LENT / BORROWED /
//     SETTLED type pill beside the name. Overdue dates tint inline.
//
// State: reuses existing `ledgerListProvider`, `transactionListProvider`,
// `formatterProvider`, `privacyModeProvider`, and the `calc.*` helpers.
//
// New optional provider (see HANDOFF):
//   - `ledgerSummaryProvider` returning `({double toReceive, double owed,
//     int receiveCount, int oweCount})`. Without it, recompute inline.

import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../shared/widgets/kuber_progress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, privacyModeProvider;

// ---------------------------------------------------------------------------
// Hero
// ---------------------------------------------------------------------------

class LedgerHero extends ConsumerWidget {
  final double toReceive;
  final double owed;
  final int receiveCount;
  final int oweCount;

  /// Unsettled entries and the distinct people behind them (board 3.20
  /// footer: "3 active entries · across 3 people").
  final int activeEntries;
  final int peopleCount;

  const LedgerHero({
    super.key,
    required this.toReceive,
    required this.owed,
    required this.receiveCount,
    required this.oweCount,
    required this.activeEntries,
    required this.peopleCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final masked = ref.watch(privacyModeProvider);
    final net = toReceive - owed;
    final isFavour = net > 0;
    final isFlat = net == 0;
    final netColor = isFlat
        ? cs.onSurface
        : isFavour
        ? context.kuberMoney.income
        : context.kuberMoney.expense;

    final tt = Theme.of(context).textTheme;
    final m = context.kuberMoney;
    final total = toReceive + owed;
    Widget dot(Color c) => Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );
    Widget bar(Color c) => Container(
      height: 8,
      decoration: BoxDecoration(color: c, borderRadius: KuberShape.fullR),
    );

    // Board 3.20: the hero card pattern. Net (+ "in your favour"), a
    // lent / borrowed split bar, the legend and the entry count.
    return KuberCard(
      hero: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.netBalanceUpper,
            style: tt.labelMedium!.copyWith(
              letterSpacing: 0.8,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                isFlat
                    ? '₹0'
                    : '${isFavour ? '+' : '−'}'
                          '${maskAmount(fmt.formatCurrency(net.abs()), masked)}',
                style: tt.headlineMedium!.copyWith(color: netColor),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  isFlat
                      ? context.l10n.ledgerEvensOut
                      : isFavour
                      ? context.l10n.ledgerInYourFavour
                      : context.l10n.ledgerOwedToOthers,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpace.lg),
          if (total == 0)
            bar(cs.surfaceContainerHighest)
          else
            Row(
              children: [
                if (toReceive > 0)
                  Expanded(
                    flex: (toReceive / total * 1000).round().clamp(1, 1000),
                    child: bar(m.income),
                  ),
                if (toReceive > 0 && owed > 0) const SizedBox(width: 4),
                if (owed > 0)
                  Expanded(
                    flex: (owed / total * 1000).round().clamp(1, 1000),
                    child: bar(m.expense),
                  ),
              ],
            ),
          const SizedBox(height: KuberSpace.md),
          Row(
            children: [
              dot(m.income),
              const SizedBox(width: 6),
              Text(
                context.l10n.lentLabel,
                style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(width: 6),
              Text(
                maskAmount(fmt.formatCurrency(toReceive), masked),
                style: tt.titleSmall!.copyWith(color: cs.onSurface),
              ),
              const Spacer(),
              dot(m.expense),
              const SizedBox(width: 6),
              Text(
                context.l10n.borrowedLabel,
                style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(width: 6),
              Text(
                maskAmount(fmt.formatCurrency(owed), masked),
                style: tt.titleSmall!.copyWith(color: cs.onSurface),
              ),
            ],
          ),
          const SizedBox(height: KuberSpace.md),
          Text(
            '${context.l10n.ledgerActiveEntries(activeEntries)}'
            '${peopleCount > 0 ? ' · ${context.l10n.ledgerAcrossPeople(peopleCount)}' : ''}',
            style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

enum LedgerEntryType { lent, borrowed }

class LedgerEntryCard extends ConsumerWidget {
  final String personName;
  final LedgerEntryType type;
  final bool isSettled;
  final double originalAmount;
  final double paid;
  final double remaining;
  final double progress; // 0..1
  final DateTime? expectedDate;
  final DateTime? settledAt;
  final VoidCallback onTap;

  const LedgerEntryCard({
    super.key,
    required this.personName,
    required this.type,
    required this.isSettled,
    required this.originalAmount,
    required this.paid,
    required this.remaining,
    required this.progress,
    required this.onTap,
    this.expectedDate,
    this.settledAt,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final masked = ref.watch(privacyModeProvider);

    final isLent = type == LedgerEntryType.lent;
    final accent = isLent
        ? context.kuberMoney.income
        : context.kuberMoney.expense;

    final dueLabel = isSettled
        ? settledAt == null
              ? context.l10n.settledUpper
              // Sentence-case the template, keep the month capitalised
              // ("Due Oct 27", not "Due oct 27").
              : sentenceCase(context.l10n.settledOnUpper('§')).replaceFirst(
                  '§',
                  DateFormat('MMM d').format(settledAt!),
                )
        : expectedDate == null
        ? context.l10n.noDueDate
        : sentenceCase(context.l10n.dueOnUpper('§')).replaceFirst(
            '§',
            DateFormat('MMM d').format(expectedDate!),
          );

    final overdue =
        !isSettled &&
        expectedDate != null &&
        expectedDate!.isBefore(DateTime.now());

    final theme = Theme.of(context);
    // Board 3.20 row: initial avatar, name, due / settled line, signed amount
    // with the type under it; the wavy bar shows partial repayment.
    final amountText = isSettled
        ? maskAmount(fmt.formatCurrency(originalAmount), masked)
        : maskAmount(
            '${isLent ? '+' : '−'}${fmt.formatCurrency(remaining)}',
            masked,
          );
    final row = InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _Avatar(name: personName),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        personName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        dueLabel +
                            (overdue ? ' · ${context.l10n.overdueLower}' : ''),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: overdue ? cs.error : cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      amountText,
                      style: theme.textTheme.titleMedium!.copyWith(
                        color: isSettled ? cs.onSurfaceVariant : accent,
                      ),
                    ),
                    Text(
                      (isSettled
                              ? context.l10n.settledUpper
                              : isLent
                              ? context.l10n.lentLabel
                              : context.l10n.borrowedLabel)
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
            if (!isSettled && progress > 0) ...[
              const SizedBox(height: KuberSpace.md),
              KuberLinearProgress(value: progress.clamp(0.0, 1.0)),
            ],
          ],
        ),
      ),
    );
    return isSettled ? Opacity(opacity: 0.55, child: row) : row;
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  String _initials() {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    // Tinted from the categorical palette by name, re-toned (board 3.20).
    final palette = context.kuberChart.categorical;
    final tones = categoryTones(
      context,
      palette[name.hashCode.abs() % palette.length],
    );
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: tones.container, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        _initials(),
        style: Theme.of(
          context,
        ).textTheme.titleMedium!.copyWith(color: tones.fg),
      ),
    );
  }
}
