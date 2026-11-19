import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/motion/motion.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../../shared/widgets/kuber_list.dart';
import '../trial_checklist.dart';
import '../trial_state.dart';
import 'trial_common.dart';

/// "Try Kuber Pro": tried features first, then the rest in priority order.
Future<void> showTrialChecklistSheet(BuildContext context) {
  final router = GoRouter.maybeOf(context);
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => TrialChecklistSheet(onTry: (f) => router?.push(f.route)),
  );
}

/// Tried first, then the rest, each in priority order.
List<ProTrialFeature> checklistOrder(Set<ProTrialFeature> tried) => [
      for (final f in ProTrialFeature.values)
        if (tried.contains(f)) f,
      for (final f in ProTrialFeature.values)
        if (!tried.contains(f)) f,
    ];

class TrialChecklistSheet extends ConsumerWidget {
  const TrialChecklistSheet({super.key, required this.onTry});
  final void Function(ProTrialFeature) onTry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tried = ref.watch(triedFeaturesProvider);
    final days = ref.watch(proTrialProvider.select((t) => t.daysLeft));
    ref.listen(triedFeaturesProvider, (a, b) {
      if (b.length > (a?.length ?? 0)) KuberHaptics.tick();
    });
    return KuberBottomSheet(
      title: l.checklistTitle,
      description: l.checklistSub('${tried.length}', '$days'),
      bodyPadding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: KuberShape.fullR,
              child: LinearProgressIndicator(value: tried.length / 10, minHeight: 8),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(l.checklistHint,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: cs.onSurfaceVariant)),
          ),
          const SizedBox(height: 12),
          KuberGroup(
            children: [
              for (final f in checklistOrder(tried))
                ChecklistRow(
                  key: ValueKey(f),
                  feature: f,
                  done: tried.contains(f),
                  onTry: () {
                    Navigator.of(context).pop();
                    onTry(f);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One feature: tile (becomes a check circle when tried), name, status, Try.
class ChecklistRow extends StatelessWidget {
  const ChecklistRow({super.key, required this.feature, required this.done, required this.onTry});
  final ProTrialFeature feature;
  final bool done;
  final VoidCallback onTry;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final curve = KuberMotion.fastCurve.clamped;
    final level = KuberMotion.levelOf(context);
    final dur = level == MotionLevel.off ? Duration.zero : KuberMotion.fastCurve.settle;
    // Shared row (CLAUDE.md rule 11); the tile morphs to a check when tried.
    return KuberListRow(
      minHeight: 60,
      onTap: onTry,
      leading: AnimatedContainer(
        duration: dur,
        curve: curve,
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: done ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(done ? 20 : KuberShape.medium),
        ),
        child: Icon(done ? Icons.check_rounded : feature.icon,
            size: done ? 22 : 20, color: done ? cs.onPrimary : cs.onSurfaceVariant),
      ),
      title: feature.featureName(l),
      subtitle: done
          ? l.checklistTried(feature.usedLabel(l))
          : l.checklistWhere(feature.placeName(l)),
      trailing: done
          ? null
          : Row(mainAxisSize: MainAxisSize.min, children: [
              Text(l.checklistTry, style: tt.labelLarge!.copyWith(color: cs.primary)),
              Icon(Icons.chevron_right_rounded, size: 18, color: cs.primary),
            ]),
    );
  }
}
