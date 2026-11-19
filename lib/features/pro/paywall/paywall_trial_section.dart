import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/info_table.dart';
import '../../../../shared/widgets/kuber_list.dart';
import '../trial/trial_checklist.dart';
import '../trial/trial_state.dart';
import '../trial/widgets/trial_checklist_sheet.dart';
import '../trial/widgets/trial_common.dart';

/// Pro page entry for a free user who can claim the trial (never for Pro).
class ProClaimEntry extends ConsumerWidget {
  const ProClaimEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return KuberCard(
      color: cs.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const KuberIconTile(
                  icon: Icons.workspace_premium_rounded, tone: KuberTone.primary, size: 48, glyph: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.proClaimTitle, style: tt.titleMedium!.copyWith(color: cs.onSurface)),
                    Text(l.proClaimBody, style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppButton(
            label: l.proClaimCta,
            type: AppButtonType.primary,
            fullWidth: true,
            onPressed: () => claimTrial(context, ref),
          ),
        ],
      ),
    );
  }
}

/// Free user, trial running or ended: status, features tried, the keep-Pro
/// text and the trial facts. The plans stay below, as for any free user.
class PaywallTrialSection extends ConsumerWidget {
  const PaywallTrialSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final t = ref.watch(proTrialProvider);
    final tried = ref.watch(triedFeaturesProvider).length;
    final loc = l.localeName;
    final end = t.endAt?.toLocal();
    final start = t.startAt?.toLocal();
    final endDate = end == null ? '' : DateFormat('d MMM y', loc).format(end);
    final shortEnd = end == null ? '' : DateFormat('d MMM', loc).format(end);
    final active = t.isActive;

    final rows = <InfoTableRow>[
      InfoTableDataRow(label: l.proManagePlan, value: active ? l.proManageTrial : l.proManagePlanFree),
      if (start != null)
        InfoTableDataRow(label: l.proManageStarted, value: DateFormat('d MMM y', loc).format(start)),
      if (end != null)
        InfoTableDataRow(
          label: active ? l.proManageEnds : l.proManageEnded,
          value: active ? '$endDate, ${trialTime(context, end)}' : endDate,
        ),
      InfoTableDataRow(label: l.proManageTried, value: l.proManageTriedValue('$tried')),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KuberCard(
          color: cs.surfaceContainerLow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  KuberIconTile(
                    icon: active ? Icons.workspace_premium_rounded : Icons.history_rounded,
                    tone: active ? KuberTone.primary : KuberTone.neutral,
                    size: 48,
                    glyph: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(active ? l.proTrialStatus('${t.daysLeft}') : l.proManageEndedTitle,
                            style: tt.titleMedium!.copyWith(color: cs.onSurface)),
                        Text(
                          active
                              ? l.proTrialEnds(shortEnd, trialTime(context, end!))
                              : l.proManageEndedBody(shortEnd),
                          style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (active) ...[
                Divider(height: 28, color: cs.outlineVariant),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.proTrialTried('$tried'),
                              style: tt.titleSmall!.copyWith(color: cs.onSurface)),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: KuberShape.fullR,
                            child: LinearProgressIndicator(value: tried / 10, minHeight: 8),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => showTrialChecklistSheet(context),
                      child: Text(l.trialSuggSeeAll,
                          style: tt.labelLarge!.copyWith(color: cs.primary)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: KuberSpace.lg),
        InfoTable(rows: rows),
        if (active) ...[
          const SizedBox(height: KuberSpace.xl),
          Text(l.proKeepTitle, style: tt.titleMedium!.copyWith(color: cs.onSurface)),
          const SizedBox(height: 4),
          Text(l.proKeepBody(shortEnd), style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
        ],
      ],
    );
  }
}
