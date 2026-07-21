import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../../shared/widgets/kuber_segmented_control.dart';
import '../../pro/home/shortcut_catalog.dart';
import '../../settings/providers/settings_provider.dart';
import '../data/add_action_catalog.dart';

/// One customizable entry, unified across the shortcut catalog (MANAGE /
/// TOOLS / KUBER SIGNATURE sections) and the add-action catalog (a single
/// group). Drives both the Arrange rows and the Add-tab grouped picker.
class ConfigurableItem {
  final String id;
  final String label;
  final IconData icon;

  /// Group header + per-row caption, e.g. "MANAGE", "TOOLS", "ADD MENU".
  final String section;

  const ConfigurableItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.section,
  });
}

/// Which list this screen configures — decides the title, catalog, the
/// persisted provider and its setter.
enum ConfigureKind { quickActionShortcuts, addMenu }

/// Full-screen editor for the Quick Actions grid / Add menu. Edits are held in
/// a local draft and only committed on Save — leaving (Cancel or back) discards
/// them. Nothing is pinned at the top (title is a scrolling KuberPageHeader);
/// only the Cancel / Save bar is sticky at the bottom, like Add Transaction.
class ConfigureShortcutsScreen extends ConsumerStatefulWidget {
  final ConfigureKind kind;

  const ConfigureShortcutsScreen({super.key, required this.kind});

  @override
  ConsumerState<ConfigureShortcutsScreen> createState() =>
      _ConfigureShortcutsScreenState();
}

enum _Tab { arrange, add }

class _ConfigureShortcutsScreenState
    extends ConsumerState<ConfigureShortcutsScreen> {
  late List<String> _draft;
  _Tab _tab = _Tab.arrange;

  bool get _isShortcuts =>
      widget.kind == ConfigureKind.quickActionShortcuts;

  @override
  void initState() {
    super.initState();
    // Snapshot the current list once; all edits mutate this draft and are only
    // persisted on Save.
    final current = _isShortcuts
        ? ref.read(quickActionShortcutsProvider)
        : ref.read(addMenuActionsProvider);
    _draft = [...current];
  }

  String get _title =>
      _isShortcuts ? 'Customize Shortcuts' : 'Customize Add Menu';

  String get _description => _isShortcuts
      ? 'Pick and arrange the shortcuts shown when you long-press a bottom-nav tab.'
      : 'Pick and arrange the add-entry actions shown when you long-press the + button.';

  /// Full catalog for this kind, mapped to the unified model.
  List<ConfigurableItem> get _catalog {
    if (_isShortcuts) {
      return [
        for (final s in kShortcutCatalog)
          ConfigurableItem(
            id: s.id,
            label: s.label,
            icon: s.icon,
            section: _sectionLabel(s.section),
          ),
      ];
    }
    // Add menu: the full add-action catalog (all entries are configurable).
    return [
      for (final a in kAddActionCatalog)
        ConfigurableItem(
          id: a.id,
          label: a.label,
          icon: a.icon,
          section: 'ADD MENU',
        ),
    ];
  }

  static String _sectionLabel(ShortcutSection s) => switch (s) {
        ShortcutSection.manage => 'MANAGE',
        ShortcutSection.tools => 'TOOLS',
        ShortcutSection.kuberSpecific => 'KUBER SIGNATURE',
      };

  ConfigurableItem? _itemById(String id) =>
      _catalog.where((c) => c.id == id).firstOrNull;

  void _remove(String id) => setState(() => _draft = [..._draft]..remove(id));

  void _add(String id) {
    if (_draft.contains(id)) return;
    setState(() => _draft = [..._draft, id]);
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      final ids = [..._draft];
      if (newIndex > oldIndex) newIndex -= 1;
      ids.insert(newIndex, ids.removeAt(oldIndex));
      _draft = ids;
    });
  }

  void _save() {
    final notifier = ref.read(settingsProvider.notifier);
    if (_isShortcuts) {
      notifier.setQuickActionShortcuts(_draft);
    } else {
      notifier.setAddMenuActions(_draft);
    }
    Navigator.of(context).pop();
  }

  void _cancel() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      // Standard thin app bar (back + home only, no title/brand) — the title
      // lives in the scrolling KuberPageHeader below, like every other page.
      appBar: const KuberAppBar(
        showBack: true,
        showHome: true,
        showBrand: false,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: KuberSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KuberPageHeader(title: _title, description: _description),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          KuberSpacing.lg, 0, KuberSpacing.lg, KuberSpacing.md),
                      child: KuberSegmentedControl<_Tab>(
                        values: const [_Tab.arrange, _Tab.add],
                        labels: [
                          'Arrange',
                          _isShortcuts ? 'Add shortcuts' : 'Add actions',
                        ],
                        selected: _tab,
                        onSelected: (t) => setState(() => _tab = t),
                      ),
                    ),
                    if (_tab == _Tab.arrange)
                      _buildArrange(cs)
                    else
                      _buildAdd(cs),
                  ],
                ),
              ),
            ),
            _BottomBar(onCancel: _cancel, onSave: _save),
          ],
        ),
      ),
    );
  }

  // ── Arrange tab ────────────────────────────────────────────────────────
  Widget _buildArrange(ColorScheme cs) {
    final items =
        _draft.map(_itemById).whereType<ConfigurableItem>().toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              KuberSpacing.lg, 4, KuberSpacing.lg, 8),
          child: Text(
            'IN YOUR LIST · ${items.length}',
            style: localeFont(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
          itemCount: items.length,
          onReorder: _reorder,
          itemBuilder: (context, i) {
            final item = items[i];
            return _ArrangeRow(
              key: ValueKey(item.id),
              index: i,
              item: item,
              onRemove: () => _remove(item.id),
            );
          },
        ),
      ],
    );
  }

  // ── Add tab ────────────────────────────────────────────────────────────
  Widget _buildAdd(ColorScheme cs) {
    final sections = <String, List<ConfigurableItem>>{};
    for (final item in _catalog) {
      sections.putIfAbsent(item.section, () => []).add(item);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in sections.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(
                entry.key,
                style: localeFont(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            for (final item in entry.value) ...[
              _AddRow(
                item: item,
                added: _draft.contains(item.id),
                onToggle: () =>
                    _draft.contains(item.id) ? _remove(item.id) : _add(item.id),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;
  const _BottomBar({required this.onCancel, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(
          KuberSpacing.lg, KuberSpacing.md, KuberSpacing.lg, KuberSpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Cancel',
              type: AppButtonType.outline,
              fullWidth: true,
              onPressed: onCancel,
            ),
          ),
          const SizedBox(width: KuberSpacing.md),
          Expanded(
            child: AppButton(
              label: 'Save',
              type: AppButtonType.primary,
              fullWidth: true,
              onPressed: onSave,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccentSquircle extends StatelessWidget {
  final IconData icon;
  final double size;
  const _AccentSquircle({required this.icon, this.size = 38});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(KuberRadius.sm),
        border: Border.all(color: cs.primary.withValues(alpha: 0.32)),
      ),
      child: Icon(icon, size: size * 0.5, color: cs.primary),
    );
  }
}

class _ArrangeRow extends StatelessWidget {
  final int index;
  final ConfigurableItem item;
  final VoidCallback onRemove;

  const _ArrangeRow({
    super.key,
    required this.index,
    required this.item,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: Icon(Icons.drag_indicator_rounded,
                  size: 20, color: cs.onSurfaceVariant),
            ),
            const SizedBox(width: 12),
            _AccentSquircle(icon: item.icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: localeFont(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    item.section,
                    style: localeFont(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRemove,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.remove_rounded,
                    size: 18, color: cs.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddRow extends StatelessWidget {
  final ConfigurableItem item;
  final bool added;
  final VoidCallback onToggle;

  const _AddRow({
    required this.item,
    required this.added,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(
            color: added ? cs.primary.withValues(alpha: 0.32) : cs.outline,
          ),
        ),
        child: Row(
          children: [
            _AccentSquircle(icon: item.icon, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: localeFont(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: added ? cs.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: added ? null : Border.all(color: cs.outline),
              ),
              child: Icon(
                added ? Icons.check_rounded : Icons.add_rounded,
                size: 17,
                color: added ? cs.onPrimary : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
