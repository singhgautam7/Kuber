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

import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../shared/widgets/kuber_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Recurring hero (board 3.19): "MONTHLY ESTIMATE", an Expense tile and an
/// Income tile (monthly equivalents of the active rules), and the active /
/// paused rule count.
class RecurringHero extends ConsumerWidget {
  final double monthlyIncome;
  final double monthlyExpense;
  final int activeCount;
  final int pausedCount;

  const RecurringHero({
    super.key,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.activeCount,
    required this.pausedCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = ref.watch(formatterProvider);
    final masked = ref.watch(privacyModeProvider);
    final m = context.kuberMoney;

    Widget tile(IconData icon, Color iconColor, String label, double v) =>
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(KuberSpace.md),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: KuberShape.mediumR,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: iconColor),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    maskAmount(fmt.formatCurrency(v), masked),
                    style: tt.headlineSmall!.copyWith(color: cs.onSurface),
                  ),
                ),
              ],
            ),
          ),
        );

    return KuberCard(
      hero: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MONTHLY ESTIMATE',
            style: tt.labelMedium!.copyWith(
              letterSpacing: 0.8,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: KuberSpace.sm),
          Row(
            children: [
              tile(
                Icons.arrow_upward_rounded,
                m.expense,
                context.l10n.expenseLabel,
                monthlyExpense,
              ),
              const SizedBox(width: KuberSpace.sm),
              tile(
                Icons.arrow_downward_rounded,
                m.income,
                context.l10n.incomeLabel,
                monthlyIncome,
              ),
            ],
          ),
          const SizedBox(height: KuberSpace.md),
          Text(
            '$activeCount active rule${activeCount == 1 ? '' : 's'}'
            '${pausedCount > 0 ? ' · $pausedCount paused' : ''}',
            style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

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
    final fmt = ref.watch(formatterProvider);
    final masked = ref.watch(privacyModeProvider);
    final warning = context.kuberMoney.warning;

    final daysAway = nextChargeOn?.difference(DateTime.now()).inDays;
    final soon = daysAway != null && daysAway >= 0 && daysAway <= 3;

    final whenText = nextChargeOn == null
        ? ''
        : daysAway! <= 0
        ? context.l10n.todayLower
        : daysAway == 1
        ? context.l10n.tomorrowLower
        : daysAway < 7
        ? context.l10n.inDays(daysAway)
        : DateFormat('MMM d').format(nextChargeOn!);

    final theme = Theme.of(context);
    final tones = categoryTones(context, iconColor);
    final isExpense = amount < 0;
    final sub = [
      sentenceCase(frequencyLabel),
      if (whenText.isNotEmpty) '${context.l10n.nextChargeLabel} $whenText',
      ?accountName,
    ].join(' · ');
    // Board 3.19 rule row: tile, name, "Monthly · Next Oct 15 · Account",
    // signed amount; a charge within 3 days tints the line warning.
    return KuberListRow(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: tones.container,
          borderRadius: KuberShape.mediumR,
        ),
        child: Icon(icon, size: 20, color: tones.fg),
      ),
      title: ruleName,
      subtitle: sub,
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            maskAmount(
              '${isExpense ? '−' : '+'}${fmt.formatCurrency(amount.abs())}',
              masked,
            ),
            style: theme.textTheme.titleMedium!.copyWith(
              color: isExpense
                  ? context.kuberMoney.expense
                  : context.kuberMoney.income,
            ),
          ),
          if (soon)
            Text(
              whenText,
              style: theme.textTheme.labelSmall!.copyWith(color: warning),
            ),
        ],
      ),
    );
  }
}

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
    final theme = Theme.of(context);
    final tones = categoryTones(context, iconColor);
    return KuberListRow(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: tones.container,
          borderRadius: KuberShape.mediumR,
        ),
        child: Icon(icon, size: 20, color: tones.fg),
      ),
      title: ruleName,
      subtitle: [context.l10n.recurringModule, ?accountName].join(' · '),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            maskAmount(
              '${isExpense ? '−' : '+'}${fmt.formatCurrency(amount.abs())}',
              masked,
            ),
            style: theme.textTheme.titleMedium!.copyWith(
              color: isExpense
                  ? context.kuberMoney.expense
                  : context.kuberMoney.income,
            ),
          ),
          Text(
            DateFormat('MMM d').format(processedAt),
            style: theme.textTheme.bodySmall!.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
