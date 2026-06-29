import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
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
          title: Text('Delete $count calculation${count == 1 ? '' : 's'}?',
              style: localeFont(fontWeight: FontWeight.w700)),
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
    showKuberSnackBar(context, 'Deleted $count calculation${count == 1 ? '' : 's'}.');
    _clearSelection();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final async = ref.watch(savedCalculationsProvider);
    final tools = ref.watch(savedToolsProvider);

    // Reset an invalid filter if its tool no longer has saves.
    if (_filter != 'all' && !tools.contains(_filter)) {
      _filter = 'all';
    }

    return PopScope(
      // While selecting, the system/back gesture cancels the selection instead
      // of leaving the screen.
      canPop: !_selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _clearSelection();
      },
      child: Scaffold(
      backgroundColor: cs.surface,
      // History-style multi-select bar (KuberAppBar stays untouched).
      bottomNavigationBar: _selecting
          ? _SelectionBar(
              count: _selected.length,
              onCancel: _clearSelection,
              onDelete: _confirmDelete,
            )
          : null,
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: CustomScrollView(
          slivers: [
          SliverToBoxAdapter(
            child: KuberAppBar(
              title: 'Saved Calculations',
              showBack: true,
              onBack: _selecting ? _clearSelection : null,
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
                  child: Text('Could not load saved calculations',
                      style: localeFont(color: cs.onSurfaceVariant)),
                ),
              ),
            ],
            data: (list) {
              if (list.isEmpty) {
                return [
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.all(KuberSpacing.xl),
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
              final filtered = _filter == 'all'
                  ? list
                  : list.where((c) => c.tool == _filter).toList();
              return [
                SliverToBoxAdapter(
                  child: _FilterChips(
                    tools: tools,
                    selected: _filter,
                    onSelect: (f) => setState(() => _filter = f),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(KuberSpacing.lg, 0,
                      KuberSpacing.lg, KuberSpacing.xl),
                  sliver: SliverList.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: KuberSpacing.sm),
                    itemBuilder: (context, i) {
                      final c = filtered[i];
                      return _SavedCard(
                        calc: c,
                        selected: _selected.contains(c.id),
                        selecting: _selecting,
                        onTap: () {
                          if (_selecting) {
                            _toggle(c.id);
                          } else {
                            context.push(
                                '/more/tools/${c.tool}?savedId=${c.id}');
                          }
                        },
                        onLongPress: () => _toggle(c.id),
                      );
                    },
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

/// History-style bottom multi-select bar: Cancel · count · Delete.
class _SelectionBar extends StatelessWidget {
  final int count;
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  const _SelectionBar({
    required this.count,
    required this.onCancel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      elevation: 8,
      color: cs.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: KuberSpacing.sm, vertical: KuberSpacing.md),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: cs.outline)),
          ),
          child: Row(
            children: [
              _BarButton(
                icon: Icons.close_rounded,
                color: cs.onSurface,
                borderColor: cs.outline.withValues(alpha: 0.3),
                onTap: onCancel,
              ),
              const SizedBox(width: KuberSpacing.sm),
              Expanded(
                child: Text(
                  '$count selected',
                  style: localeFont(
                      fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
              ),
              _BarButton(
                icon: Icons.delete_outline_rounded,
                color: cs.error,
                borderColor: cs.error.withValues(alpha: 0.5),
                onTap: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color borderColor;
  final VoidCallback onTap;
  const _BarButton({
    required this.icon,
    required this.color,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: borderColor),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final List<String> tools;
  final String selected;
  final ValueChanged<String> onSelect;

  const _FilterChips(
      {required this.tools, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final entries = <(String, String)>[
      ('all', 'All'),
      for (final t in tools) (t, ToolCatalog.byKey(t)?.name ?? t),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          KuberSpacing.lg, KuberSpacing.sm, KuberSpacing.lg, KuberSpacing.md),
      child: Wrap(
        spacing: KuberSpacing.sm,
        runSpacing: KuberSpacing.sm,
        children: [
          for (final e in entries)
            _Pill(
              label: e.$2,
              selected: selected == e.$1,
              onTap: () => onSelect(e.$1),
            ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Pill({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KuberRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? cs.primary.withValues(alpha: 0.12)
              : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.full),
          border: Border.all(color: selected ? cs.primary : cs.outline),
        ),
        child: Text(
          label,
          style: localeFont(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected ? cs.primary : cs.onSurfaceVariant,
          ),
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
    final accent = meta?.accent ?? cs.primary;
    final dateStr =
        'SAVED ${DateFormat('dd MMM yyyy').format(calc.updatedAt).toUpperCase()}';

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(KuberRadius.md),
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? cs.primary.withValues(alpha: 0.06)
              : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: selected ? cs.primary : cs.outline),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(color: accent.withValues(alpha: 0.18)),
              ),
              alignment: Alignment.center,
              child: Icon(meta?.icon ?? Icons.calculate_rounded,
                  color: accent, size: 19),
            ),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    calc.name,
                    style: localeFont(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    calc.summary,
                    style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: localeFont(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: KuberSpacing.sm),
            Icon(
              selecting
                  ? (selected
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined)
                  : Icons.chevron_right_rounded,
              size: selecting ? 20 : 18,
              color: selected ? cs.primary : cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
