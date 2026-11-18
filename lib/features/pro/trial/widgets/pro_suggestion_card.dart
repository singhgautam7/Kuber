import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/l10n_ext.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_icon_button.dart';
import '../../../../shared/widgets/kuber_list.dart';
import '../trial_checklist.dart';
import '../trial_state.dart';
import '../trial_suggestions.dart';
import 'trial_checklist_sheet.dart';
import 'trial_common.dart';

/// Shared shell of the suggestion, reminder and claim cards: leading tile,
/// text, dismiss, then a right-aligned action row.
class _TrialCard extends StatelessWidget {
  const _TrialCard({
    required this.leading,
    required this.title,
    required this.body,
    required this.onDismiss,
    required this.actions,
    this.overline,
  });

  final Widget leading;
  final String? overline;
  final String title, body;
  final VoidCallback onDismiss;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return KuberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leading,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (overline != null)
                      Text(overline!.toUpperCase(),
                          style: tt.labelMedium!.copyWith(letterSpacing: .8, color: cs.primary)),
                    Text(title, style: tt.titleMedium!.copyWith(color: cs.onSurface)),
                    Text(body, style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(8, -8),
                child: AppIconButton(
                  icon: Icons.close_rounded,
                  kind: AppIconButtonKind.plain,
                  semanticLabel: context.l10n.trialDismiss,
                  onPressed: onDismiss,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: actions,
          ),
        ],
      ),
    );
  }
}

Widget _textAction(BuildContext context, String label, VoidCallback onTap) => TextButton(
      onPressed: onTap,
      child: Text(label, style: Theme.of(context).textTheme.labelLarge!.copyWith(
          color: Theme.of(context).colorScheme.primary)),
    );

class _Tile extends StatelessWidget {
  const _Tile(this.icon, {this.tone = KuberTone.primary});
  final IconData icon;
  final KuberTone tone;
  @override
  Widget build(BuildContext context) => KuberIconTile(icon: icon, tone: tone);
}

/// Feature suggestion: overline "Pro trial · N of 10 tried", title, one line,
/// See all + the action. Dismiss hides the feature for the rest of the trial.
class ProSuggestionCard extends ConsumerWidget {
  const ProSuggestionCard({super.key, required this.feature});
  final ProTrialFeature feature;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final tried = ref.watch(triedFeaturesProvider).length;
    return _TrialCard(
      leading: _Tile(feature.icon),
      overline: l.trialSuggOverline('$tried'),
      title: feature.suggTitle(l),
      body: feature.suggBody(l),
      onDismiss: () => ref.read(trialSuggestionsProvider.notifier).dismiss(feature),
      actions: [
        _textAction(context, l.trialSuggSeeAll, () => showTrialChecklistSheet(context)),
        AppButton(
          label: feature.suggCta(l),
          height: 40,
          onPressed: () => context.push(feature.route),
        ),
      ],
    );
  }
}

/// Day 12 to 14 Home card: "3 days left" / "Last day".
class TrialReminderCard extends ConsumerWidget {
  const TrialReminderCard({super.key, required this.last});
  final bool last;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final info = ref.watch(proTrialProvider);
    final left = 10 - ref.watch(triedFeaturesProvider).length;
    final end = info.endAt ?? info.now;
    return _TrialCard(
      leading: const _Tile(Icons.hourglass_top_rounded, tone: KuberTone.warning),
      title: last ? l.trialLastTitle : l.trialRem3Title,
      body: last ? l.trialLastBody : l.trialRem3CardBody(trialDate(context, end), '$left'),
      onDismiss: () => ref.read(trialSuggestionsProvider.notifier).dismissReminder(last),
      actions: [
        _textAction(context, last ? l.trialLastCta : l.trialRem3Cta,
            () => last ? context.push('/pro') : showTrialChecklistSheet(context)),
        AppButton(label: l.trialKeepPro, height: 40, onPressed: () => context.push('/pro')),
      ],
    );
  }
}
