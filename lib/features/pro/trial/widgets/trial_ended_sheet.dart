import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/l10n_ext.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/info_table.dart';
import '../../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../../shared/widgets/kuber_list.dart';
import '../../../../shared/widgets/kuber_comparison_table.dart';
import '../../paywall/billing_ui_state.dart';
import '../../paywall/pro_page_extras.dart';
import '../trial_checklist.dart';
import 'trial_common.dart';

// Same id as purchase_service.dart kProYearlyId (not imported: it pulls the router).
const _kYearlyId = 'kuber_pro_yearly';

/// Shown once after the trial ends (the caller then calls
/// `markEndedNoticeShown()`). Counts come from the trial window.
Future<void> showTrialEndedSheet(BuildContext context) {
  final router = GoRouter.maybeOf(context);
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => TrialEndedSheet(onGetPro: () => router?.push('/pro')),
  );
}

/// Pro Comparison table label for a feature, to read its free limit from the
/// one table (no second copy of the limits).
String? _tableLabel(ProTrialFeature f) => switch (f) {
      ProTrialFeature.sms => 'SMS Import',
      ProTrialFeature.dashboards => 'Custom Dashboard',
      ProTrialFeature.notes => 'Kuber Notes',
      ProTrialFeature.ask => 'Ask Kuber',
      ProTrialFeature.reminders => 'Reminders',
      ProTrialFeature.backups => 'Automatic Backups',
      ProTrialFeature.themes => 'Custom themes',
      ProTrialFeature.advancedAnalytics => 'Advanced Analytics',
      ProTrialFeature.cards => 'Kuber Cards',
      ProTrialFeature.multiCurrency => null,
    };

class TrialEndedSheet extends ConsumerWidget {
  const TrialEndedSheet({super.key, required this.onGetPro});
  final VoidCallback onGetPro;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final usage = ref.watch(trialUsageProvider).valueOrNull ?? const TrialUsage();
    final tried = ref.watch(triedFeaturesProvider);
    final prices = ref.watch(cachedProductPricesProvider);

    final stats = <(int, String)>[
      (usage.sms, l.trialEndStatSms),
      (usage.dashboards, l.trialEndStatDash),
      (usage.asks, l.trialEndStatAsk),
      (usage.notes, l.trialEndStatNotes),
      (usage.reminders, l.trialEndStatRem),
      (usage.backups, l.trialEndStatBackup),
    ].where((s) => s.$1 > 0).take(4).toList();

    final limits = <(ProTrialFeature, String)>[];
    for (final f in ProTrialFeature.values) {
      final label = _tableLabel(f);
      final row = kProComparisonRows
          .whereType<ComparisonRow>()
          .where((r) => r.feature == label)
          .firstOrNull;
      if (tried.contains(f) && row != null) limits.add((f, row.free));
    }

    return KuberBottomSheet(
      title: l.trialEndTitle,
      description: l.trialEndBody,
      showClose: false,
      actions: AppButton(
        label: l.trialEndCta(l.proCardYearly, prices[_kYearlyId] ?? '₹1,099'),
        type: AppButtonType.primary,
        fullWidth: true,
        onPressed: () {
          Navigator.of(context).pop();
          onGetPro();
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (stats.isNotEmpty)
            LayoutBuilder(
              builder: (context, c) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in stats)
                    SizedBox(
                      width: (c.maxWidth - 8) / 2,
                      child: KuberCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${s.$1}', style: tt.titleLarge!.copyWith(color: cs.onSurface)),
                            Text(s.$2, style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          if (limits.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(l.trialEndLimits.toUpperCase(),
                style: tt.labelMedium!.copyWith(letterSpacing: .8, color: cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            InfoTable(rows: [
              for (final e in limits)
                InfoTableDataRow(label: e.$1.featureName(l), value: e.$2),
            ]),
          ],
          const SizedBox(height: 16),
          Text(l.trialEndKept, style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}
