import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../../shared/widgets/kuber_segmented_control.dart';
import '../../models/ah_view.dart';
import '../../providers/ah_providers.dart';
import '../common/ah_common.dart';

Future<T?> ahShowSheet<T>(BuildContext context, WidgetBuilder builder) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: builder,
    );

/// One selectable row (radio style) used by the Group and Sort sheets.
class AhOptionRow extends StatelessWidget {
  const AhOptionRow({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected ? cs.secondaryContainer : Colors.transparent,
        borderRadius: KuberShape.mediumR,
        child: InkWell(
          borderRadius: KuberShape.mediumR,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon,
                        size: 20,
                        color: selected
                            ? cs.onSecondaryContainer
                            : cs.onSurfaceVariant),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(label,
                        style: localeFont(
                            fontSize: 16,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w500,
                            color: selected
                                ? cs.onSecondaryContainer
                                : cs.onSurface)),
                  ),
                  if (selected)
                    Icon(Icons.check_rounded,
                        size: 20, color: cs.onSecondaryContainer),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Keeps the sort valid after the grouping changes.
void ahFixSort(WidgetRef ref) {
  final v = ref.read(ahViewProvider);
  if (!ahSortValidFor(v.sort.field, v.groupBy)) {
    ref.read(ahViewProvider.notifier).setSort(
        v.groupBy == AhGroupBy.none
            ? AhSort.ungroupedDefault
            : AhSort.groupedDefault);
  }
}

class AhGroupSheet extends ConsumerWidget {
  const AhGroupSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cur = ref.watch(ahViewProvider.select((v) => v.groupBy));
    return KuberBottomSheet(
      title: l.ahdGroupBy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AhSheetIntro(
            text: l.ahdGroupHelp,
            info: ahInfoConfig(
                l.ahdGroupBy, [l.ahdInfoGroup1, l.ahdInfoGroup2]),
          ),
          for (final g in AhGroupBy.values)
            AhOptionRow(
              label: ahGroupName(l, g),
              icon: ahGroupIcon(g),
              selected: g == cur,
              onTap: () {
                ref.read(ahViewProvider.notifier).setGroup(g);
                ahFixSort(ref);
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
        ],
      ),
    );
  }
}

class AhSortSheet extends ConsumerWidget {
  const AhSortSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final v = ref.watch(ahViewProvider);
    final grouped = v.groupBy != AhGroupBy.none;
    final fields = grouped
        ? const [AhSortField.total, AhSortField.count, AhSortField.name]
        : const [
            AhSortField.date,
            AhSortField.amount,
            AhSortField.category,
            AhSortField.account,
          ];
    final text = v.sort.field == AhSortField.name ||
        v.sort.field == AhSortField.category ||
        v.sort.field == AhSortField.account;
    // Text sorts read A to Z first; the others read highest / newest first.
    final orders = text ? const [false, true] : const [true, false];
    return KuberBottomSheet(
      title: l.ahdSort,
      subtitle: grouped ? l.ahdSortGroups : l.ahdSortTxns,
      actions: AppButton(
        label: l.doneLabel,
        type: AppButtonType.primary,
        fullWidth: true,
        onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AhSheetIntro(
            info: ahInfoConfig(l.ahdSort, [l.ahdInfoSort1, l.ahdInfoSort2]),
          ),
          for (final f in fields)
            AhOptionRow(
              label: ahSortFieldLabel(l, f),
              selected: f == v.sort.field,
              onTap: () => ref.read(ahViewProvider.notifier).setSort(AhSort(
                  f,
                  descending: v.sort.field == f
                      ? v.sort.descending
                      : (f == AhSortField.date ||
                          f == AhSortField.amount ||
                          f == AhSortField.total ||
                          f == AhSortField.count))),
            ),
          const SizedBox(height: KuberSpace.lg),
          KuberSegmentedControl<bool>(
            values: orders,
            labels: [
              for (final d in orders)
                ahOrderLabel(l, AhSort(v.sort.field, descending: d)),
            ],
            selected: v.sort.descending,
            showCheck: false,
            onSelected: (d) => ref
                .read(ahViewProvider.notifier)
                .setSort(AhSort(v.sort.field, descending: d)),
          ),
        ],
      ),
    );
  }
}

/// KPI cards: all 7 with a checkbox and a drag handle; at least 1 on.
class AhKpiSheet extends ConsumerStatefulWidget {
  const AhKpiSheet({super.key});

  @override
  ConsumerState<AhKpiSheet> createState() => _AhKpiSheetState();
}

class _AhKpiSheetState extends ConsumerState<AhKpiSheet> {
  late List<AhKpi> _order;
  late Set<AhKpi> _on;

  @override
  void initState() {
    super.initState();
    final cur = ref.read(ahViewProvider).kpis;
    _on = cur.toSet();
    _order = [...cur, ...AhKpi.values.where((k) => !_on.contains(k))];
  }

  void _push() => ref
      .read(ahViewProvider.notifier)
      .setKpis([for (final k in _order) if (_on.contains(k)) k]);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    return KuberBottomSheet(
      title: l.ahdKpiSheetTitle,
      actions: Row(
        children: [
          Expanded(
            child: AppButton(
              label: l.ahdReset,
              type: AppButtonType.outline,
              fullWidth: true,
              onPressed: () {
                setState(() {
                  _order = [...kAhDefaultKpis];
                  _on = kAhDefaultKpis.toSet();
                });
                _push();
              },
            ),
          ),
          const SizedBox(width: KuberSpace.md),
          Expanded(
            child: AppButton(
              label: l.doneLabel,
              type: AppButtonType.primary,
              fullWidth: true,
              onPressed: () =>
                  Navigator.of(context, rootNavigator: true).pop(),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AhSheetIntro(
              text: l.ahdKpiSheetDesc,
              info: ahInfoConfig(l.ahdKpiSheetTitle, [l.ahdInfoKpi])),
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            onReorderItem: (a, b) {
              setState(() {
                _order.insert(b, _order.removeAt(a));
              });
              _push();
            },
            children: [
              for (var i = 0; i < _order.length; i++)
                Container(
                  key: ValueKey(_order[i]),
                  constraints: const BoxConstraints(minHeight: 52),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _on.contains(_order[i]),
                        onChanged: (v) {
                          final k = _order[i];
                          if (v == true) {
                            setState(() => _on.add(k));
                          } else if (_on.length > 1) {
                            setState(() => _on.remove(k));
                          } else {
                            return;
                          }
                          _push();
                        },
                      ),
                      Expanded(
                        child: Text(ahKpiLabel(l, _order[i]),
                            style: localeFont(
                                fontSize: 16, color: cs.onSurface)),
                      ),
                      ReorderableDragStartListener(
                        index: i,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(Icons.drag_indicator_rounded,
                              color: cs.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: KuberSpace.sm),
          Text(l.ahdKpiSheetNote,
              style: localeFont(fontSize: 13, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}
