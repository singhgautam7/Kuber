import 'package:flutter/material.dart';

import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/monthly_recurrence.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';

/// Collapsible "Billing cycle" card for credit cards: bill-generation day and
/// payment-due day pickers, each with its own reminder toggle, plus a
/// cross-month hint. Shared by the add form (AccountForm) and the edit screen
/// (EditAccountScreen) so the two stay in lockstep.
///
/// Uses the app's collapsible idiom — a bordered container wrapping an
/// [ExpansionTile] with squared-off shapes — the same pattern as the FAQ
/// screen. Starts expanded when either day is already set.
class CreditBillingCycleSection extends StatelessWidget {
  final int? billDay;
  final int? dueDay;
  final bool billReminder;
  final bool dueReminder;
  final ValueChanged<int> onBillDayChanged;
  final ValueChanged<int> onDueDayChanged;
  final ValueChanged<bool> onBillReminderChanged;
  final ValueChanged<bool> onDueReminderChanged;

  const CreditBillingCycleSection({
    super.key,
    required this.billDay,
    required this.dueDay,
    required this.billReminder,
    required this.dueReminder,
    required this.onBillDayChanged,
    required this.onDueDayChanged,
    required this.onBillReminderChanged,
    required this.onDueReminderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    // Collapsed summary: set days, or "Optional" when nothing is set yet.
    final parts = <String>[
      if (billDay != null) '${l10n.billGenerationLabel} ${ordinalDay(billDay!)}',
      if (dueDay != null) '${l10n.paymentDueLabel} ${ordinalDay(dueDay!)}',
    ];
    final summary = parts.isEmpty ? l10n.optionalLabel : parts.join('  ·  ');

    final crossMonth = billDay != null && dueDay != null && dueDay! <= billDay!;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        // ExpansionTile draws its own top/bottom dividers from theme; the
        // bordered container already separates it, so suppress them.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: billDay != null || dueDay != null,
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding:
              const EdgeInsets.symmetric(horizontal: KuberSpacing.md),
          childrenPadding: const EdgeInsets.fromLTRB(
            KuberSpacing.md,
            0,
            KuberSpacing.md,
            KuberSpacing.md,
          ),
          iconColor: cs.onSurfaceVariant,
          collapsedIconColor: cs.onSurfaceVariant,
          title: Text(
            l10n.billingCycle,
            style: localeFont(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              summary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ),
          children: [
            KuberFieldLabel(l10n.billGenerationDaySection),
            const SizedBox(height: 8),
            KuberDayGrid(selected: billDay, onChanged: onBillDayChanged),
            const SizedBox(height: 10),
            KuberSwitchRow(
              icon: Icons.notifications_active_rounded,
              name: l10n.remindMe,
              sub: l10n.billReminderSub,
              value: billReminder,
              enabled: billDay != null,
              onChanged: onBillReminderChanged,
            ),
            const SizedBox(height: 20),
            KuberFieldLabel(l10n.paymentDueDaySection),
            const SizedBox(height: 8),
            KuberDayGrid(selected: dueDay, onChanged: onDueDayChanged),
            const SizedBox(height: 10),
            KuberSwitchRow(
              icon: Icons.notifications_active_rounded,
              name: l10n.remindMe,
              sub: l10n.dueReminderSub,
              value: dueReminder,
              enabled: dueDay != null,
              onChanged: onDueReminderChanged,
            ),
            if (crossMonth) ...[
              const SizedBox(height: 12),
              KuberCallout(
                child: Text(
                  l10n.billDueCrossMonthHint(
                    ordinalDay(billDay!),
                    ordinalDay(dueDay!),
                  ),
                  style: localeFont(
                    fontSize: 12.5,
                    color: cs.onSurface,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
