import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../../shared/widgets/kuber_home_widget_title.dart';
import '../data/pinned_shortcuts_repository.dart';
import '../feature_gates/gate_sheet_sms_import.dart';
import '../feature_gates/pro_gate.dart';
import 'shortcut_catalog.dart';

/// Compact, single-row set of user-configurable jump links (Accounts, Ask
/// Kuber, any Tool, Kuber Notes, etc). No cap on how many can be pinned — the
/// row scrolls horizontally, so it stays a single line regardless of count.
/// Each tile tints its icon chip with the user's chosen color, the same way
/// a category swatch differentiates categories at a glance. Registered in
/// the home widget editor as `shortcuts_widget`.
class ShortcutsWidget extends ConsumerWidget {
  const ShortcutsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final pinned = ref.watch(pinnedShortcutsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KuberHomeWidgetTitle(
          title: 'Shortcuts',
          trailing: GestureDetector(
            onTap: () => _showConfigSheet(context, ref),
            child: Text(
              'EDIT',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: cs.primary,
                  ),
            ),
          ),
        ),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: pinned.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final p = pinned[i];
              final meta = shortcutById(p.id);
              if (meta == null) return const SizedBox.shrink();
              return _ShortcutTile(
                meta: meta,
                color: p.color,
                onTap: () => _openShortcut(context, ref, meta),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Opens a pinned shortcut, applying the same Pro gate its normal entry
  /// point would. SMS Import is fully gated, so it must not be a back door
  /// around the sheet. Notes, Reminders and Ask Kuber all open a landing
  /// screen (free to view) and gate downstream on the actual create/send, so
  /// opening those needs no check here.
  void _openShortcut(BuildContext context, WidgetRef ref, ShortcutMeta meta) {
    if (meta.id == 'sms_import' &&
        !proGate(context, ref, showSmsImportGateSheet)) {
      return;
    }
    context.push(meta.route);
  }

  void _showConfigSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ShortcutsConfigSheet(ref: ref),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  final ShortcutMeta meta;
  final Color color;
  final VoidCallback onTap;
  const _ShortcutTile({required this.meta, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(color: color.withValues(alpha: 0.4)),
              ),
              child: Icon(meta.icon, size: 18, color: color),
            ),
            const SizedBox(height: 5),
            // Fixed slot (one line's worth, top-aligned) so every tile is the
            // same height and the labels share a baseline. Compact labels
            // (`shortLabel`) keep this to a single line; anything longer
            // ellipsizes rather than wrapping and throwing the row off.
            SizedBox(
              height: 13,
              width: double.infinity,
              child: Text(
                meta.shortLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: localeFont(
                  fontSize: 9.5,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pick any number of shortcuts from the full catalog, reorder them by drag,
/// and set each pinned item's accent color. Two-part layout: an explicit,
/// reorderable "Your shortcuts" list up top (drag handle + color swatch +
/// remove, so both reordering and recoloring are visible affordances, not
/// hidden behind a tap-to-discover chip) and the full Manage/Tools/
/// Kuber-specific catalog below it to add more. New pins default to the
/// theme's accent color (`cs.primary`).
class _ShortcutsConfigSheet extends StatefulWidget {
  final WidgetRef ref;
  const _ShortcutsConfigSheet({required this.ref});

  @override
  State<_ShortcutsConfigSheet> createState() => _ShortcutsConfigSheetState();
}

class _ShortcutsConfigSheetState extends State<_ShortcutsConfigSheet> {
  late List<PinnedShortcut> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.of(widget.ref.read(pinnedShortcutsProvider));
  }

  bool _isSelected(String id) => _selected.any((p) => p.id == id);

  void _add(String id) {
    final cs = Theme.of(context).colorScheme;
    setState(() => _selected.add(PinnedShortcut(id: id, color: cs.primary)));
  }

  void _remove(String id) {
    setState(() => _selected.removeWhere((p) => p.id == id));
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _selected.removeAt(oldIndex);
      _selected.insert(newIndex, item);
    });
  }

  void _setColor(String id, Color color) {
    setState(() {
      final i = _selected.indexWhere((p) => p.id == id);
      if (i != -1) _selected[i] = _selected[i].copyWith(color: color);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bySection = <ShortcutSection, List<ShortcutMeta>>{
      for (final section in ShortcutSection.values)
        section: kShortcutCatalog.where((s) => s.section == section).toList(),
    };

    return KuberBottomSheet(
      title: 'Configure shortcuts',
      subtitle: '${_selected.length} pinned',
      actions: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          onPressed: () {
            widget.ref
                .read(pinnedShortcutsProvider.notifier)
                .save(_selected);
            Navigator.pop(context);
          },
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KuberRadius.md),
            ),
          ),
          child: Text('Save', style: localeFont(fontSize: 14, fontWeight: FontWeight.w700)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'YOUR SHORTCUTS · DRAG TO REORDER',
            style: localeFont(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: KuberSpacing.sm),
          if (_selected.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(KuberSpacing.lg),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(color: cs.outline),
              ),
              child: Text(
                'Nothing pinned yet. Add some from the catalog below.',
                style: localeFont(fontSize: 12.5, color: cs.onSurfaceVariant),
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              onReorder: _reorder,
              itemCount: _selected.length,
              itemBuilder: (context, i) {
                final p = _selected[i];
                final meta = shortcutById(p.id);
                if (meta == null) return SizedBox.shrink(key: ValueKey(p.id));
                return Container(
                  key: ValueKey(p.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: KuberSpacing.md,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    border: Border.all(color: cs.outline),
                  ),
                  child: Row(
                    children: [
                      ReorderableDragStartListener(
                        index: i,
                        child: Icon(Icons.drag_indicator_rounded,
                            size: 18, color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(width: KuberSpacing.sm),
                      Icon(meta.icon, size: 17, color: p.color),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          meta.label,
                          style: localeFont(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showColorPicker(context, p.id),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: p.color,
                            shape: BoxShape.circle,
                            border: Border.all(color: cs.outline, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(width: KuberSpacing.sm),
                      GestureDetector(
                        onTap: () => _remove(p.id),
                        child: Icon(Icons.close_rounded,
                            size: 17, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: KuberSpacing.lg),
          Divider(color: cs.outline),
          const SizedBox(height: KuberSpacing.md),
          for (final section in ShortcutSection.values) ...[
            Text(
              section.label,
              style: localeFont(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: KuberSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in bySection[section]!)
                  if (!_isSelected(s.id))
                    _AddChip(meta: s, onTap: () => _add(s.id)),
              ],
            ),
            const SizedBox(height: KuberSpacing.lg),
          ],
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context, String id) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return KuberBottomSheet(
          title: 'Shortcut color',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final c in [cs.primary, ...kShortcutColorSwatches])
                GestureDetector(
                  onTap: () {
                    _setColor(id, c);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.outline, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AddChip extends StatelessWidget {
  final ShortcutMeta meta;
  final VoidCallback onTap;
  const _AddChip({required this.meta, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainer,
      shape: StadiumBorder(side: BorderSide(color: cs.outline)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(meta.icon, size: 15, color: cs.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                meta.label,
                style: localeFont(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.add_rounded, size: 15, color: cs.primary),
            ],
          ),
        ),
      ),
    );
  }
}
