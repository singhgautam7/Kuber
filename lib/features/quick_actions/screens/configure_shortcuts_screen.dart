import 'package:flutter/material.dart';
import '../../../shared/widgets/kuber_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
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

  bool get _isShortcuts => widget.kind == ConfigureKind.quickActionShortcuts;

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
      // Board 3.2d: pushed header with the title, description as subtitle.
      body: KuberScrollAwayHeader(
        header: KuberAppBar(
          showBack: true,
          title: _title,
          subtitle: _description,
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: KuberSpace.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          KuberSpace.screenMargin,
                          KuberSpace.xs,
                          KuberSpace.screenMargin,
                          KuberSpace.xl,
                        ),
                        child: KuberSegmentedControl<_Tab>(
                          showCheck: false,
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
      ),
    );
  }

  // ── Arrange tab ────────────────────────────────────────────────────────
  Widget _buildArrange(ColorScheme cs) {
    final items = _draft.map(_itemById).whereType<ConfigurableItem>().toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KuberSpace.screenMargin,
          ),
          child: KuberSectionHeader(title: 'IN YOUR LIST · ${items.length}'),
        ),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: KuberSpace.screenMargin,
          ),
          itemCount: items.length,
          onReorder: _reorder,
          proxyDecorator: (child, _, __) => Material(
            color: cs.surfaceContainerHigh,
            borderRadius: KuberShape.cardR,
            child: child,
          ),
          itemBuilder: (context, i) {
            final item = items[i];
            return _ArrangeRow(
              key: ValueKey(item.id),
              index: i,
              isLast: i == items.length - 1,
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
      padding: const EdgeInsets.symmetric(horizontal: KuberSpace.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final entry in sections.entries) ...[
            KuberSectionHeader(title: entry.key),
            KuberGroup(
              children: [
                for (final item in entry.value)
                  _AddRow(
                    item: item,
                    added: _draft.contains(item.id),
                    onToggle: () => _draft.contains(item.id)
                        ? _remove(item.id)
                        : _add(item.id),
                  ),
              ],
            ),
            const SizedBox(height: KuberSpace.xl),
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
        KuberSpace.screenMargin,
        KuberSpace.md,
        KuberSpace.screenMargin,
        KuberSpace.xl,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
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
          const SizedBox(width: KuberSpace.md),
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

class _ArrangeRow extends StatelessWidget {
  final int index;
  final bool isLast;
  final ConfigurableItem item;
  final VoidCallback onRemove;

  const _ArrangeRow({
    super.key,
    required this.index,
    required this.isLast,
    required this.item,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    const r = Radius.circular(KuberShape.largeIncreased);
    // One grouped list: rounded ends, shared 1dp edges.
    return Transform.translate(
      offset: Offset(0, -index.toDouble()),
      child: Container(
        height: KuberSpace.listItem1,
        padding: const EdgeInsets.only(left: 12, right: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.vertical(
            top: index == 0 ? r : Radius.zero,
            bottom: isLast ? r : Radius.zero,
          ),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: Icon(
                Icons.drag_indicator_rounded,
                size: 20,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: KuberSpace.md),
            Icon(item.icon, size: 24, color: cs.onSurfaceVariant),
            const SizedBox(width: KuberSpace.lg),
            Expanded(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium!.copyWith(
                  color: cs.onSurface,
                ),
              ),
            ),
            const SizedBox(width: KuberSpace.sm),
            GestureDetector(
              onTap: onRemove,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: cs.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.remove_rounded,
                  size: 18,
                  color: cs.onErrorContainer,
                ),
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
    return KuberListRow(
      onTap: onToggle,
      leading: Icon(item.icon, size: 24, color: cs.onSurfaceVariant),
      title: item.label,
      trailing: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: added ? cs.primary : Colors.transparent,
          shape: BoxShape.circle,
          border: added ? null : Border.all(color: cs.outline),
        ),
        child: Icon(
          added ? Icons.check_rounded : Icons.add_rounded,
          size: 18,
          color: added ? cs.onPrimary : cs.onSurfaceVariant,
        ),
      ),
    );
  }
}
