// Overhauled Recurring Transactions screen widgets.
//
// Drop-ins for `lib/features/recurring/screens/recurring_screen.dart`:
//   - `RecurringHero` — monthly cost + next-3-charges timeline
//   - `RecurringRuleCard` — refined rule card with frequency pill + next charge
//   - `RecurringProcessedRow` — dense row for "Recently processed" history
//
// Provider wiring (mostly reuses existing):
//   - `recurringListProvider` (existing) — rules
//   - `recurringMonthlyCostProvider` (new, see HANDOFF) — `({double total,
//     int activeCount, List<UpcomingCharge> upcoming})` where UpcomingCharge
//     has `{name, amount, on, daysAway}`.
//   - `recentlyProcessedProvider` (existing) — recently-fired rule transactions
//   - `categoryMapProvider`, `accountListProvider` (existing)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, privacyModeProvider;

// ---------------------------------------------------------------------------
// Upcoming charge — small data class
// ---------------------------------------------------------------------------

class UpcomingCharge {
  final String name;
  final double amount;
  final DateTime on;
  const UpcomingCharge({
    required this.name,
    required this.amount,
    required this.on,
  });

  int get daysAway => on.difference(DateTime.now()).inDays;
}

// ---------------------------------------------------------------------------
// Hero
// ---------------------------------------------------------------------------

class RecurringHero extends ConsumerWidget {
  final double monthlyCost;
  final int activeCount;
  final List<UpcomingCharge> upcoming; // first 3 will be shown

  const RecurringHero({
    super.key,
    required this.monthlyCost,
    required this.activeCount,
    required this.upcoming,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final masked = ref.watch(privacyModeProvider);
    final next = upcoming.take(3).toList();
    final nextLabel = next.isEmpty
        ? null
        : next.first.daysAway <= 0
        ? 'today'
        : next.first.daysAway == 1
        ? 'tomorrow'
        : 'in ${next.first.daysAway} days';

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.xl),
        border: Border.all(color: cs.outline),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color.alphaBlend(
              context.kuberColors.warning.withValues(alpha: 0.16),
              cs.surfaceContainer,
            ),
            cs.surfaceContainer,
          ],
          stops: const [0.0, 0.75],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MONTHLY AUTOMATION COST',
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                maskAmount(fmt.formatCurrency(monthlyCost), masked),
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: -0.7,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: cs.onSurfaceVariant,
                ),
                children: [
                  TextSpan(
                    text:
                        '$activeCount active rule${activeCount == 1 ? '' : 's'}',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  if (nextLabel != null)
                    TextSpan(text: ' · next charge $nextLabel'),
                ],
              ),
            ),
            if (next.isNotEmpty) ...[
              const SizedBox(height: 14),
              _UpcomingStrip(items: next),
            ],
          ],
        ),
      ),
    );
  }
}

class _UpcomingStrip extends ConsumerWidget {
  final List<UpcomingCharge> items;
  const _UpcomingStrip({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(KuberRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UPCOMING CHARGES',
            style: GoogleFonts.inter(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                Expanded(
                  child: _UpcomingTile(charge: items[i], soon: i == 0),
                ),
                if (i < items.length - 1) const SizedBox(width: 6),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _UpcomingTile extends ConsumerWidget {
  final UpcomingCharge charge;
  final bool soon;
  const _UpcomingTile({required this.charge, required this.soon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final masked = ref.watch(privacyModeProvider);
    final warning = context.kuberColors.warning;

    final daysAway = charge.daysAway;
    final whenText = daysAway <= 0
        ? 'TODAY'
        : daysAway == 1
        ? 'TOMORROW'
        : daysAway < 7
        ? 'IN $daysAway DAYS'
        : DateFormat('MMM d').format(charge.on).toUpperCase();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: soon ? warning : cs.outline),
        color: soon ? warning.withValues(alpha: 0.10) : null,
        borderRadius: BorderRadius.circular(KuberRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            whenText,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: soon ? warning : cs.onSurfaceVariant,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            charge.name,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            maskAmount(fmt.formatCurrency(charge.amount), masked),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Rule card
// ---------------------------------------------------------------------------

class RecurringRuleCard extends ConsumerWidget {
  final String ruleName;
  final String frequencyLabel; // "MONTHLY", "WEEKLY", "QUARTERLY", "YEARLY"
  final String? accountName;
  final IconData icon;
  final Color iconColor;
  final double amount;
  final DateTime? nextChargeOn;
  final VoidCallback onTap;

  const RecurringRuleCard({
    super.key,
    required this.ruleName,
    required this.frequencyLabel,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.accountName,
    this.nextChargeOn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final masked = ref.watch(privacyModeProvider);
    final warning = context.kuberColors.warning;

    final daysAway = nextChargeOn?.difference(DateTime.now()).inDays;
    final soon = daysAway != null && daysAway >= 0 && daysAway <= 3;

    final whenText = nextChargeOn == null
        ? ''
        : daysAway! <= 0
        ? 'today'
        : daysAway == 1
        ? 'tomorrow'
        : daysAway < 7
        ? 'in $daysAway days'
        : DateFormat('MMM d').format(nextChargeOn!);

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
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
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
                        Text(
                          ruleName,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            _FreqPill(label: frequencyLabel),
                            if (accountName != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: cs.onSurfaceVariant.withValues(
                                    alpha: 0.6,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  accountName!,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    maskAmount(fmt.formatCurrency(amount), masked),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              if (nextChargeOn != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: cs.outline.withValues(alpha: 0.5)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 5),
                      Text.rich(
                        TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                          children: [
                            const TextSpan(text: 'Next charge '),
                            TextSpan(
                              text: whenText,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: soon ? warning : cs.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('MMM d').format(nextChargeOn!),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
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

class _FreqPill extends StatelessWidget {
  final String label;
  const _FreqPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.12),
        border: Border.all(color: cs.primary.withValues(alpha: 0.30)),
        borderRadius: BorderRadius.circular(KuberRadius.sm),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: cs.primary,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recently processed — dense row (no card chrome)
// ---------------------------------------------------------------------------

class RecurringProcessedRow extends ConsumerWidget {
  final String ruleName;
  final String? accountName;
  final DateTime processedAt;
  final IconData icon;
  final Color iconColor;
  final double amount; // signed: negative = expense
  final VoidCallback? onTap;
  const RecurringProcessedRow({
    super.key,
    required this.ruleName,
    required this.processedAt,
    required this.icon,
    required this.iconColor,
    required this.amount,
    this.accountName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final masked = ref.watch(privacyModeProvider);

    final isExpense = amount < 0;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: cs.outline)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                border: Border.all(color: iconColor.withValues(alpha: 0.30)),
                borderRadius: BorderRadius.circular(KuberRadius.md),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ruleName,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    [
                      ?accountName,
                      DateFormat('MMM d').format(processedAt),
                    ].join(' · '),
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isExpense ? '−' : '+'}'
              '${maskAmount(fmt.formatCurrency(amount.abs()), masked)}',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isExpense ? cs.error : cs.tertiary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
