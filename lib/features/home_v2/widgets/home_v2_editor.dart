import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../widget_editor/data/widget_catalog.dart';
import '../../widget_editor/models/home_widget_config.dart';
import '../../widget_editor/providers/widget_editor_provider.dart';
import '../data/home_v2_state.dart';
import '../providers/home_v2_provider.dart';

/// Edit Home Widgets for v2 installs (board HV2.7): a pinned Suggestions
/// row (after Get started graduates), then On your Home / Turns on with your
/// data / More widgets. Reorder works within a group; switching moves a row
/// to its new group. Everything applies on Save changes, like v1.
class HomeV2EditorScreen extends ConsumerStatefulWidget {
  const HomeV2EditorScreen({super.key});

  @override
  ConsumerState<HomeV2EditorScreen> createState() => _HomeV2EditorState();
}

class _Row {
  final String id;
  WidgetVis vis;
  _Row(this.id, this.vis);
}

class _HomeV2EditorState extends ConsumerState<HomeV2EditorScreen> {
  List<_Row>? _rows;
  String _initialKey = '';
  late bool _sg = ref.read(homeV2Provider).sgSetting;
  late final bool _sgInitial = _sg;

  String _key(List<_Row> r) => r.map((x) => '${x.id}:${x.vis.name}').join(',');

  @override
  void initState() {
    super.initState();
    ref
        .read(widgetPreferenceRepositoryProvider)
        .readForScope(WidgetEditorScope.home)
        .then((configs) {
          if (!mounted) return;
          final states = ref.read(homeV2Provider).widgets;
          final rows = [
            for (final c in configs)
              _Row(
                c.id,
                c.enabled
                    ? WidgetVis.on
                    : (states[c.id]?.vis == WidgetVis.auto
                          ? WidgetVis.auto
                          : WidgetVis.off),
              ),
          ];
          setState(() {
            _rows = _grouped(rows);
            _initialKey = _key(_rows!);
          });
        });
  }

  /// Stable regroup: on, then waiting, then off; order kept within a group.
  List<_Row> _grouped(List<_Row> rows) => [
    for (final v in const [WidgetVis.on, WidgetVis.auto, WidgetVis.off])
      ...rows.where((r) => r.vis == v),
  ];

  bool get _dirty =>
      _rows != null && (_key(_rows!) != _initialKey || _sg != _sgInitial);

  void _toggle(_Row r, bool on) {
    if (!on && _rows!.where((x) => x.vis == WidgetVis.on).length <= 1) {
      showKuberSnackBar(context, context.l10n.atLeastOneWidget, isError: true);
      return;
    }
    setState(() {
      r.vis = on ? WidgetVis.on : WidgetVis.off;
      _rows = _grouped(_rows!);
    });
  }

  void _reorder(WidgetVis group, int oldI, int newI) {
    final rows = _rows!;
    final members = rows.where((r) => r.vis == group).toList();
    final moved = members.removeAt(oldI);
    members.insert(newI, moved);
    setState(() {
      _rows = [
        for (final v in const [WidgetVis.on, WidgetVis.auto, WidgetVis.off])
          ...(v == group ? members : rows.where((r) => r.vis == v)),
      ];
    });
  }

  Future<void> _save() async {
    final rows = _rows!;
    final byId = {for (final c in kHomeWidgetCatalog) c.id: c};
    await saveWidgetPreferences(ref, WidgetEditorScope.home, [
      for (final r in rows)
        byId[r.id]!.copyWith(enabled: r.vis == WidgetVis.on),
    ]);
    final now = DateTime.now();
    await ref.read(homeV2Provider.notifier).update((s) {
      final widgets = Map.of(s.widgets);
      for (final r in rows) {
        final cur = widgets[r.id] ?? HomeV2WidgetState(vis: r.vis);
        if (cur.vis == r.vis) continue;
        widgets[r.id] = cur.copyWith(
          vis: r.vis,
          unlockedAt: r.vis == WidgetVis.on ? now : cur.unlockedAt,
        );
      }
      return s.copyWith(widgets: widgets, sgSetting: _sg);
    });
    if (mounted) Navigator.pop(context);
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    final cs = Theme.of(context).colorScheme;
    final keep = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          context.l10n.discardChangesConfirm,
          style: localeFont(fontWeight: FontWeight.w700),
        ),
        content: Text(
          context.l10n.discardChangesBody,
          style: localeFont(color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.keepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              context.l10n.discardLabel,
              style: TextStyle(color: cs.error),
            ),
          ),
        ],
      ),
    );
    return keep == false;
  }

  String? _autoReason(String id) {
    final l = context.l10n;
    return switch (id) {
      'insight_stories' => l.homeV2EdAutoStories,
      'spending_stats' => l.homeV2EdAutoStats,
      'home_accounts' => l.homeV2EdAutoAccounts,
      'seven_day_chart' => l.homeV2EdAutoChart,
      'sms_import_widget' => l.homeV2EdAutoSms,
      'upcoming_events_widget' => l.homeV2EdAutoEvents,
      'budget_snapshot' => l.homeV2EdAutoBudget,
      'kuber_notes_widget' => l.homeV2EdAutoNotes,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final rows = _rows;
    final graduated = ref.watch(homeV2Provider.select((s) => s.gsGraduated));

    Widget header(String text, {String? note}) => Padding(
      padding: const EdgeInsets.fromLTRB(4, KuberSpace.lg, 4, KuberSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text.toUpperCase(), style: sectionHeaderStyle(context)),
          if (note != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                note,
                style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );

    Widget group(WidgetVis vis) {
      final members = rows!.where((r) => r.vis == vis).toList();
      if (members.isEmpty) return const SizedBox.shrink();
      return ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        buildDefaultDragHandles: false,
        itemCount: members.length,
        onReorderItem: (o, n) => _reorder(vis, o, n),
        itemBuilder: (_, i) {
          final r = members[i];
          return _EditorRow(
            key: ValueKey(r.id),
            index: i,
            isFirst: i == 0,
            isLast: i == members.length - 1,
            title: localizedWidgetName(context, r.id),
            subtitle: vis == WidgetVis.auto
                ? _autoReason(r.id)
                : localizedWidgetDesc(context, r.id),
            value: r.vis == WidgetVis.on,
            onChanged: (v) => _toggle(r, v),
          );
        },
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        body: KuberScrollAwayHeader(
          header: KuberAppBar(
            showBack: true,
            closeIcon: true,
            title: WidgetEditorScope.home.title,
            onBack: () async {
              if (await _confirmDiscard() && context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
          body: rows == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  // Clears the pinned Save bar (12 + button + 24 + nav inset)
                  // with room to spare under the last card.
                  padding: EdgeInsets.fromLTRB(
                    KuberSpace.screenMargin,
                    0,
                    KuberSpace.screenMargin,
                    140 + systemNavBarInset(context),
                  ),
                  children: [
                    Text(
                      'Drag the handle to reorder. Toggle to show/hide.',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    header(l.homeV2EdSecOn),
                    if (graduated)
                      Padding(
                        padding: const EdgeInsets.only(bottom: KuberSpace.sm),
                        child: _EditorRow(
                          index: 0,
                          isFirst: true,
                          isLast: true,
                          pinned: true,
                          title: l.homeV2EdSgTitle,
                          subtitle: l.homeV2EdSgSub,
                          value: _sg,
                          onChanged: (v) => setState(() => _sg = v),
                        ),
                      ),
                    group(WidgetVis.on),
                    if (rows.any((r) => r.vis == WidgetVis.auto)) ...[
                      header(l.homeV2EdSecAuto, note: l.homeV2EdAutoNote),
                      group(WidgetVis.auto),
                    ],
                    if (rows.any((r) => r.vis == WidgetVis.off)) ...[
                      header(l.homeV2EdSecMore),
                      group(WidgetVis.off),
                    ],
                  ],
                ),
        ),
        bottomSheet: rows == null
            ? null
            : Container(
                padding: EdgeInsets.fromLTRB(
                  KuberSpace.screenMargin,
                  12,
                  KuberSpace.screenMargin,
                  24 + systemNavBarInset(context),
                ),
                decoration: BoxDecoration(
                  color: cs.surface,
                  border: Border(top: BorderSide(color: cs.outlineVariant)),
                ),
                child: AppButton(
                  label: l.saveChanges,
                  type: AppButtonType.primary,
                  fullWidth: true,
                  onPressed: _dirty ? _save : null,
                ),
              ),
      ),
    );
  }
}

/// One editor row (same look as the v1 editor): drag handle (or a pin for
/// the pinned Suggestions row), title, subtitle, switch.
class _EditorRow extends StatelessWidget {
  final int index;
  final bool isFirst;
  final bool isLast;
  final bool pinned;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _EditorRow({
    super.key,
    required this.index,
    required this.isFirst,
    required this.isLast,
    this.pinned = false,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    const r = Radius.circular(KuberShape.largeIncreased);
    final handle = SizedBox(
      width: 48,
      height: 48,
      child: Icon(
        pinned ? Icons.push_pin_outlined : Icons.drag_indicator_rounded,
        color: cs.onSurfaceVariant,
        size: 24,
      ),
    );
    return Transform.translate(
      offset: Offset(0, -index.toDouble()),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.vertical(
            top: isFirst ? r : Radius.zero,
            bottom: isLast ? r : Radius.zero,
          ),
          border: Border.all(color: cs.outlineVariant),
        ),
        constraints: const BoxConstraints(minHeight: KuberSpace.listItem2),
        padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
        child: Row(
          children: [
            if (pinned)
              handle
            else
              ReorderableDragStartListener(index: index, child: handle),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: tt.titleMedium?.copyWith(color: cs.onSurface),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: KuberSpace.md),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
