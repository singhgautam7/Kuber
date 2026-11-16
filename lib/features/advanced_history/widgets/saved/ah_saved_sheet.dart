import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/app_icon_button.dart';
import '../../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../../shared/widgets/kuber_empty_state.dart';
import '../../../../shared/widgets/kuber_menu.dart';
import '../../data/saved_filter.dart';
import '../../providers/ah_providers.dart';
import '../common/ah_common.dart';
import 'ah_save_sheet.dart';
import 'ah_saved_state.dart';

/// Applies a saved view (restores the whole page) and marks it used.
void ahApplySaved(WidgetRef ref, SavedFilter f) {
  ref.read(ahViewProvider.notifier).applySaved(f);
}

Future<void> showAhSavedSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AhSavedSheet(host: context),
  );
}

class AhSavedSheet extends ConsumerWidget {
  const AhSavedSheet({super.key, required this.host});
  final BuildContext host;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final list = ref.watch(savedFiltersProvider).valueOrNull ?? const [];
    final openId = ref.watch(ahViewProvider.select((v) => v.savedId));

    return KuberBottomSheet(
      title: l.ahdSavedTitle,
      subtitle: list.isEmpty ? null : l.ahdSavedN(list.length),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AhSheetIntro(
            info: ahInfoConfig(l.ahdSavedTitle,
                [l.ahdInfoSaved1, l.ahdInfoSaved2]),
          ),
          if (list.isEmpty)
            KuberEmptyState(
              icon: Icons.bookmarks_outlined,
              title: l.ahdSavedEmptyTitle,
              description: l.ahdSavedEmptyBody,
            )
          else
            for (final f in list)
              Padding(
                padding: const EdgeInsets.only(bottom: KuberSpace.sm),
                child: Material(
                  color: f.id == openId
                      ? cs.secondaryContainer
                      : cs.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: KuberShape.mediumR,
                    side: BorderSide(color: cs.outlineVariant),
                  ),
                  child: InkWell(
                    borderRadius: KuberShape.mediumR,
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      ahApplySaved(ref, f);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(f.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: localeFont(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: cs.onSurface)),
                                const SizedBox(height: 2),
                                Text(ahSavedSummary(l, f),
                                    style: localeFont(
                                        fontSize: 13,
                                        color: cs.onSurfaceVariant)),
                              ],
                            ),
                          ),
                          Builder(
                            builder: (anchor) => AppIconButton(
                              icon: Icons.more_vert_rounded,
                              semanticLabel: l.ahdMenuSaved,
                              kind: AppIconButtonKind.plain,
                              onPressed: () => _menu(anchor, context, ref, f),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _menu(BuildContext anchor, BuildContext sheet, WidgetRef ref,
      SavedFilter f) async {
    final l = sheet.l10n;
    final pick = await showKuberMenu<String>(
      context: anchor,
      entries: [
        KuberMenuEntry(
            value: 'rename', label: l.ahdRename, icon: Icons.edit_outlined),
        KuberMenuEntry(
            value: 'delete',
            label: l.deleteLabel,
            icon: Icons.delete_outline_rounded,
            destructive: true),
      ],
    );
    if (!sheet.mounted) return;
    if (pick == 'rename') {
      await showAhNameSheet(sheet,
          mode: AhNameMode.rename, initialName: f.name, renaming: f);
    } else if (pick == 'delete') {
      final ok = await showDialog<bool>(
        context: sheet,
        builder: (ctx) {
          final cs = Theme.of(ctx).colorScheme;
          return AlertDialog(
            title: Text(l.ahdDeleteTitle(f.name),
                style: localeFont(fontSize: 20, fontWeight: FontWeight.w600)),
            content: Text(l.ahdDeleteBody, style: localeFont(fontSize: 14)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l.cancelLabel, style: localeFont())),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l.deleteLabel,
                      style: localeFont(color: cs.error))),
            ],
          );
        },
      );
      if (ok == true) {
        await ref.read(savedFilterRepositoryProvider).delete(f.id);
      }
    }
  }
}
