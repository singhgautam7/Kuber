import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../tool_catalog.dart';
import 'data/saved_calculation.dart';
import 'providers/saved_calculations_provider.dart';

class SavedCalculationsScreen extends ConsumerStatefulWidget {
  final String? initialTool;
  const SavedCalculationsScreen({super.key, this.initialTool});

  @override
  ConsumerState<SavedCalculationsScreen> createState() =>
      _SavedCalculationsScreenState();
}

class _SavedCalculationsScreenState
    extends ConsumerState<SavedCalculationsScreen> {
  late String _filter = widget.initialTool ?? 'all';
  final Set<int> _selected = {};

  bool get _selecting => _selected.isNotEmpty;

  void _clearSelection() => setState(_selected.clear);

  void _toggle(int id) {
    setState(() {
      if (!_selected.remove(id)) _selected.add(id);
    });
  }

  Future<void> _confirmDelete() async {
    final count = _selected.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: Text(
            'Delete $count calculation${count == 1 ? '' : 's'}?',
            style: localeFont(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'This cannot be undone.',
            style: localeFont(color: cs.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: cs.error),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    await ref
        .read(savedCalculationsProvider.notifier)
        .deleteMany(_selected.toList());
    if (!mounted) return;
    showKuberSnackBar(
      context,
      'Deleted $count calculation${count == 1 ? '' : 's'}.',
    );
    _clearSelection();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final async = ref.watch(savedCalculationsProvider);
    final tools = ref.watch(savedToolsProvider);

    // Fall back to "all" when the selected tool no longer has saves (e.g. its
    // last calc was deleted). Derived locally — never mutate state in build().
    final effectiveFilter = (_filter != 'all' && !tools.contains(_filter))
        ? 'all'
        : _filter;

    return PopScope(
      // While selecting, the system/back gesture cancels the selection instead
      // of leaving the screen.
      canPop: !_selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _clearSelection();
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        body: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
          child: CustomScrollView(
            slivers: [
              // Selecting swaps in the one-line contextual header.
              SliverToBoxAdapter(
                child: _selecting
                    ? KuberAppBar(
                        title: '${_selected.length} selected',
                        showBack: true,
                        closeIcon: true,
                        background: cs.surfaceContainer,
                        onBack: _clearSelection,
                        actions: [
                          AppIconButton(
                            icon: Icons.delete_outline_rounded,
                            kind: AppIconButtonKind.danger,
                            semanticLabel: 'Delete',
                            onPressed: _confirmDelete,
                          ),
                        ],
                      )
                    : const KuberAppBar(
                        title: 'Saved Calculations',
                        showBack: true,
                      ),
              ),
              ...async.when(
                loading: () => [
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
                error: (e, _) => [
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Could not load saved calculations',
                        style: localeFont(color: cs.onSurfaceVariant),
                      ),
                    ),
                  ),
                ],
                data: (list) {
                  if (list.isEmpty) {
                    return [
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: EdgeInsets.all(KuberSpace.xl),
                          child: KuberEmptyState(
                            icon: Icons.bookmark_border_rounded,
                            title: 'No saved calculations yet',
                            description:
                                'Save calculations from any tool to revisit them later.',
                          ),
                        ),
                      ),
                    ];
                  }
                  final filtered = effectiveFilter == 'all'
                      ? list
                      : list.where((c) => c.tool == effectiveFilter).toList();
                  return [
                    SliverToBoxAdapter(
                      child: _FilterChips(
                        tools: tools,
                        selected: effectiveFilter,
                        onSelect: (f) => setState(() => _filter = f),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        KuberSpace.screenMargin,
                        0,
                        KuberSpace.screenMargin,
                        KuberSpace.xl,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            KuberSectionHeader(
                              title: '${filtered.length} saved',
                            ),
                            KuberGroup(
                              children: [
                                for (final c in filtered)
                                  _SavedCard(
                                    calc: c,
                                    selected: _selected.contains(c.id),
                                    selecting: _selecting,
                                    onTap: () {
                                      if (_selecting) {
                                        _toggle(c.id);
                                      } else {
                                        context.push(
                                          '/more/tools/${c.tool}?savedId=${c.id}',
                                        );
                                      }
                                    },
                                    onLongPress: () => _toggle(c.id),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final List<String> tools;
  final String selected;
  final ValueChanged<String> onSelect;

  const _FilterChips({
    required this.tools,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final entries = <(String, String)>[
      ('all', 'All'),
      for (final t in tools) (t, ToolCatalog.byKey(t)?.name ?? t),
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpace.lg),
      child: SizedBox(
        height: 32,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: KuberSpace.screenMargin,
          ),
          children: [
            for (final (i, e) in entries.indexed) ...[
              if (i > 0) const SizedBox(width: KuberSpace.sm),
              KuberChip(
                label: e.$2,
                selected: selected == e.$1,
                onTap: () => onSelect(e.$1),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SavedCard extends StatelessWidget {
  final SavedCalculation calc;
  final bool selected;
  final bool selecting;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _SavedCard({
    required this.calc,
    required this.selected,
    required this.selecting,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final meta = ToolCatalog.byKey(calc.tool);
    final tones = categoryTones(context, meta?.accent ?? cs.primary);
    final now = DateTime.now();
    final dateStr = DateFormat(
      calc.updatedAt.year == now.year ? 'MMM d' : 'MMM d, y',
    ).format(calc.updatedAt);

    return KuberListRow(
      selected: selected,
      onTap: onTap,
      onLongPress: onLongPress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: selected ? cs.primary : tones.container,
          borderRadius: KuberShape.mediumR,
        ),
        child: Icon(
          selected
              ? Icons.check_rounded
              : (meta?.icon ?? Icons.calculate_rounded),
          color: selected ? cs.onPrimary : tones.fg,
          size: 20,
        ),
      ),
      title: calc.name,
      subtitle: calc.summary,
      trailing: Text(
        dateStr,
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
          color: selected ? cs.onSecondaryContainer : cs.onSurfaceVariant,
        ),
      ),
    );
  }
}
