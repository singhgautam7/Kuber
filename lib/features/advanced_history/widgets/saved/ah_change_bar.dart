import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/timed_snackbar.dart';
import '../../providers/ah_providers.dart';
import 'package:kuber/core/motion/motion.dart';
import 'ah_save_sheet.dart';
import 'ah_saved_state.dart';

String ahChangeLabel(AppLocalizations l, AhChange c) => switch (c) {
      AhChange.filter => l.ahdChFilter,
      AhChange.group => l.ahdChGroup,
      AhChange.sort => l.ahdChSort,
      AhChange.kpis => l.ahdChKpis,
      AhChange.chartAdded => l.ahdChAdded,
      AhChange.chartRemoved => l.ahdChRemoved,
      AhChange.chartMoved => l.ahdChMoved,
      AhChange.chartEdited => l.ahdChEdited,
    };

/// "You changed {name}" + what changed + Save as new / Save changes. Height
/// 0 to full with the expressive spring; hides the same way.
class AhChangeBar extends ConsumerWidget {
  const AhChangeBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(ahOpenSavedProvider);
    final changes = saved == null ? const <AhChange>[] : ref.watch(ahChangesProvider);
    final show = saved != null && changes.isNotEmpty;
    final reduced = KuberMotion.reduced(context);

    return AnimatedAlign(
      alignment: Alignment.topCenter,
      heightFactor: show ? 1 : 0,
      duration: reduced ? KuberMotion.fxInstant : KuberMotion.defaultCurve.settle,
      curve: reduced ? Curves.linear : KuberMotion.defaultCurve.clamped,
      child: AnimatedOpacity(
        opacity: show ? 1 : 0,
        duration: KuberMotion.of(context, KuberMotion.fxFast),
        child: show
            ? _Bar(name: saved.name, id: saved.id, changes: changes)
            : const SizedBox(width: double.infinity),
      ),
    );
  }
}

class _Bar extends ConsumerWidget {
  const _Bar({required this.name, required this.id, required this.changes});
  final String name;
  final int id;
  final List<AhChange> changes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpace.md),
      child: Container(
        padding: const EdgeInsets.all(KuberSpace.lg),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: KuberShape.largeR,
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.ahdChanged(name),
                style: localeFont(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface)),
            const SizedBox(height: 2),
            Text(changes.map((c) => ahChangeLabel(l, c)).toSet().join(' · '),
                style: localeFont(fontSize: 13, color: cs.onSurfaceVariant)),
            const SizedBox(height: KuberSpace.md),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: l.ahdSaveAsNew,
                    type: AppButtonType.outline,
                    height: 40,
                    fullWidth: true,
                    onPressed: () => showAhNameSheet(context,
                        mode: AhNameMode.saveAsNew, initialName: '$name 2'),
                  ),
                ),
                const SizedBox(width: KuberSpace.sm),
                Expanded(
                  child: AppButton(
                    label: l.ahdSaveChanges,
                    type: AppButtonType.primary,
                    height: 40,
                    fullWidth: true,
                    onPressed: () => _saveChanges(context, ref),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveChanges(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(savedFilterRepositoryProvider);
    final l = context.l10n;
    // The bar hides itself as soon as the save lands, so the snackbar goes
    // to the root overlay taken now, not to this (soon unmounted) context.
    final overlay = Overlay.of(context, rootOverlay: true);
    // Undo puts back exactly what the write replaced (read inside it).
    final previous = await repo.saveChanges(id, ref.read(ahViewProvider));
    KuberHaptics.confirm();
    if (!overlay.mounted) return;
    showKuberSnackBar(
      overlay.context,
      l.ahdUpdated(name),
      overlay: overlay,
      actionLabel: previous == null ? null : l.ahdUndo,
      duration: const Duration(seconds: 7),
      onAction: previous == null ? null : () => repo.saveChanges(id, previous),
    );
  }
}
