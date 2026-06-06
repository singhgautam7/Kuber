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

  const LedgerHero({
    super.key,
    required this.toReceive,
    required this.owed,
    required this.receiveCount,
    required this.oweCount,
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
        ? cs.tertiary
        : cs.error;
    final activeCount = receiveCount + oweCount;

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
              netColor.withValues(alpha: 0.16),
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
                Text(
                  context.l10n.netPosition,
                  style: localeFont(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isFlat
                      ? '₹0'
                      : '${isFavour ? '+' : '−'}'
                            '${maskAmount(fmt.formatCurrency(net.abs()), masked)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: localeFont(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: netColor,
                    letterSpacing: -0.8,
                    height: 1.1,
                  ),
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
                        text: isFlat
                            ? context.l10n.ledgerEvensOut
                            : isFavour
                            ? context.l10n.ledgerInYourFavour
                            : context.l10n.ledgerOwedToOthers,
                      ),
                      const TextSpan(text: ' · '),
                      TextSpan(
                        text: context.l10n.ledgerActiveEntries(activeCount),
                        style: localeFont(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            child: Row(
              children: [
                Expanded(
                  child: _SideCard(
                    side: _Side.receive,
                    amount: toReceive,
                    peopleCount: receiveCount,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SideCard(
                    side: _Side.owe,
                    amount: owed,
                    peopleCount: oweCount,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _Side { receive, owe }

class _SideCard extends ConsumerWidget {
  final _Side side;
  final double amount;
  final int peopleCount;
  const _SideCard({
    required this.side,
    required this.amount,
    required this.peopleCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final masked = ref.watch(privacyModeProvider);

    final isReceive = side == _Side.receive;
    final accent = isReceive ? cs.tertiary : cs.error;
    final iconData = isReceive
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;
    final label = isReceive ? context.l10n.youWillReceive : context.l10n.youOwe;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(KuberRadius.md + 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(KuberRadius.sm + 2),
                ),
                alignment: Alignment.center,
                child: Icon(iconData, size: 14, color: accent),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: localeFont(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            maskAmount(fmt.formatCurrency(amount), masked),
            style: localeFont(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: accent,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            peopleCount == 0
                ? context.l10n.ledgerNoOne
                : context.l10n.ledgerAcrossPeople(peopleCount),
            style: localeFont(
              fontSize: 10.5,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Entry card
// ---------------------------------------------------------------------------

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
    final accent = isLent ? cs.tertiary : cs.error;

    final dueLabel = isSettled
        ? settledAt == null
              ? context.l10n.settledUpper
              : context.l10n.settledOnUpper(
                  DateFormat('MMM d').format(settledAt!).toUpperCase())
        : expectedDate == null
        ? context.l10n.noDueDate
        : context.l10n.dueOnUpper(
            DateFormat('MMM d').format(expectedDate!).toUpperCase());

    final overdue =
        !isSettled &&
        expectedDate != null &&
        expectedDate!.isBefore(DateTime.now());

    return Opacity(
      opacity: isSettled ? 0.55 : 1.0,
      child: Material(
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
                    _Avatar(name: personName),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  personName,
                                  overflow: TextOverflow.ellipsis,
                                  style: localeFont(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _TypePill(type: type, isSettled: isSettled),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text.rich(
                            TextSpan(
                              style: localeFont(
                                fontSize: 10.5,
                                color: cs.onSurfaceVariant,
                                letterSpacing: 0.4,
                              ),
                              children: [
                                TextSpan(
                                  text: dueLabel,
                                  style: localeFont(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: overdue
                                        ? cs.error
                                        : cs.onSurfaceVariant,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                if (overdue)
                                  TextSpan(
                                    text: ' · ${context.l10n.overdueLower}',
                                    style: localeFont(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: cs.error,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      maskAmount(fmt.formatCurrency(originalAmount), masked),
                      style: localeFont(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                        letterSpacing: -0.3,
                        decoration: isSettled
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ],
                ),
                if (!isSettled) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: SizedBox(
                      height: 4,
                      child: Stack(
                        children: [
                          Container(color: cs.surfaceContainerHigh),
                          FractionallySizedBox(
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: Container(color: accent),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isLent
                              ? context.l10n.pctReceived(
                                  (progress * 100).toStringAsFixed(0))
                              : context.l10n.pctPaidBack(
                                  (progress * 100).toStringAsFixed(0)),
                          style: localeFont(
                            fontSize: 10.5,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Text(
                        context.l10n.amountRemaining(
                            maskAmount(fmt.formatCurrency(remaining), masked)),
                        style: localeFont(
                          fontSize: 10.5,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
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
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        border: Border.all(color: cs.outline),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(),
        style: localeFont(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  final LedgerEntryType type;
  final bool isSettled;
  const _TypePill({required this.type, required this.isSettled});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color fg;
    final Color bg;
    final Color border;
    final String label;
    if (isSettled) {
      label = context.l10n.settledUpper;
      fg = cs.onSurfaceVariant;
      bg = cs.surfaceContainerHigh;
      border = cs.outline;
    } else if (type == LedgerEntryType.lent) {
      label = context.l10n.lentUpper;
      fg = cs.tertiary;
      bg = cs.tertiary.withValues(alpha: 0.12);
      border = cs.tertiary.withValues(alpha: 0.30);
    } else {
      label = context.l10n.borrowedUpper;
      fg = cs.error;
      bg = cs.error.withValues(alpha: 0.12);
      border = cs.error.withValues(alpha: 0.30);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(KuberRadius.sm),
      ),
      child: Text(
        label,
        style: localeFont(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}