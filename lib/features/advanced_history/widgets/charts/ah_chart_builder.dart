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
import '../../services/ah_results.dart';
import '../common/ah_common.dart';
import '../dashboard/ah_sheets.dart';

/// Opens the chart builder. [editIndex] edits that chart (Update / Remove).
/// [onRemove] runs the card's exit animation before removing.
Future<void> showAhChartBuilder(BuildContext context,
        {int? editIndex, void Function()? onRemove}) =>
    ahShowSheet<void>(
        context, (_) => AhChartBuilder(editIndex: editIndex, onRemove: onRemove));

class AhChartBuilder extends ConsumerStatefulWidget {
  const AhChartBuilder({super.key, this.editIndex, this.onRemove});
  final int? editIndex;
  final VoidCallback? onRemove;

  @override
  ConsumerState<AhChartBuilder> createState() => _AhChartBuilderState();
}

class _AhChartBuilderState extends ConsumerState<AhChartBuilder> {
  late AhChartType _type;
  late AhChartSplit _split;
  late AhChartMeasure _measure;

  @override
  void initState() {
    super.initState();
    final v = ref.read(ahViewProvider);
    final i = widget.editIndex;
    if (i != null && i < v.charts.length) {
      final c = v.charts[i];
      _type = c.type;
      _split = c.split;
      _measure = c.measure;
    } else {
      _type = AhChartType.donut;
      _split = ahDefaultSplit(_type, v.groupBy);
      _measure = AhChartMeasure.total;
    }
  }

  void _setType(AhChartType t) {
    if (t == _type) return;
    final group = ref.read(ahViewProvider).groupBy;
    setState(() {
      _type = t;
      if (!ahSplitAllowed(t, _split)) _split = ahDefaultSplit(t, group);
    });
  }

  String? _reason(AppLocalizations l, AhSplitBlock? b) => switch (b) {
        null => null,
        AhSplitBlock.noTags => l.ahdBlkNoTags,
        AhSplitBlock.oneAccount => l.ahdBlkOneAccount,
        AhSplitBlock.oneType => l.ahdBlkOneType,
        AhSplitBlock.oneSource => l.ahdBlkOneSource,
        AhSplitBlock.oneCategory => l.ahdBlkOneCategory,
        AhSplitBlock.oneMonth => l.ahdBlkOneMonth,
        AhSplitBlock.oneYear => l.ahdBlkOneYear,
      };

  void _submit() {
    final n = ref.read(ahViewProvider.notifier);
    final spec = AhChartSpec(_type, _split, _measure);
    final i = widget.editIndex;
    if (i == null) {
      n.addChart(spec);
    } else if (ref.read(ahViewProvider).charts[i] != spec) {
      n.updateChart(i, spec);
    }
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final group = ref.watch(ahViewProvider.select((v) => v.groupBy));
    final blocks = ref.watch(ahSplitBlocksProvider).valueOrNull ??
        const <AhChartSplit, AhSplitBlock>{};
    final editing = widget.editIndex != null;
    final current = ahSplitOfGroup(group);
    final splits = AhChartSplit.values.where((s) => ahSplitAllowed(_type, s));

    return KuberBottomSheet(
      headerAction: AhInfoButton(ahInfoConfig(
                l.ahdBuilderAdd, [l.ahdInfoChart1, l.ahdInfoChart2])),
      title: editing ? l.ahdBuilderEdit : l.ahdBuilderAdd,
      actions: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(
            label: editing ? l.ahdUpdateChart : l.ahdBuilderAdd,
            type: AppButtonType.primary,
            fullWidth: true,
            onPressed: _submit,
          ),
          if (editing) ...[
            const SizedBox(height: KuberSpace.sm),
            AppButton(
              label: l.ahdRemoveChart,
              type: AppButtonType.danger,
              fullWidth: true,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                widget.onRemove?.call();
              },
            ),
          ],
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Caps(l.ahdChartType),
          Row(
            children: [
              for (final t in AhChartType.values) ...[
                Expanded(
                  child: _TypeCard(
                    type: t,
                    selected: t == _type,
                    onTap: () => _setType(t),
                  ),
                ),
                if (t != AhChartType.line) const SizedBox(width: KuberSpace.sm),
              ],
            ],
          ),
          const SizedBox(height: KuberSpace.xl),
          _Caps(l.ahdSplitBy),
          for (final s in splits)
            _SplitRow(
              label: ahSplitLabel(l, s),
              tag: s == current ? l.ahdCurrentGroup : null,
              reason: _reason(l, blocks[s]),
              selected: s == _split,
              onTap: () => setState(() => _split = s),
            ),
          const SizedBox(height: KuberSpace.xl),
          _Caps(l.ahdShow),
          KuberSegmentedControl<AhChartMeasure>(
            values: AhChartMeasure.values,
            labels: [for (final m in AhChartMeasure.values) ahMeasureLabel(l, m)],
            selected: _measure,
            showCheck: false,
            onSelected: (m) => setState(() => _measure = m),
          ),
        ],
      ),
    );
  }
}

class _Caps extends StatelessWidget {
  const _Caps(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpace.sm),
      child: Text(text.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium!
              .copyWith(letterSpacing: 0.8, color: cs.onSurfaceVariant)),
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard(
      {required this.type, required this.selected, required this.onTap});
  final AhChartType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = selected ? cs.onSecondaryContainer : cs.onSurface;
    return Material(
      color: selected ? cs.secondaryContainer : cs.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: KuberShape.largeR,
        side: BorderSide(color: selected ? cs.secondary : cs.outlineVariant),
      ),
      child: InkWell(
        borderRadius: KuberShape.largeR,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: KuberSpace.lg),
          child: Column(
            children: [
              Icon(ahChartIcon(type), color: fg, size: 28),
              const SizedBox(height: 6),
              Text(ahChartTypeLabel(context.l10n, type),
                  style: localeFont(
                      fontSize: 14, fontWeight: FontWeight.w600, color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplitRow extends StatelessWidget {
  const _SplitRow({
    required this.label,
    required this.selected,
    required this.onTap,
    this.tag,
    this.reason,
  });
  final String label;
  final String? tag;
  final String? reason;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final blocked = reason != null;
    return Opacity(
      opacity: blocked ? 0.38 : 1,
      child: IgnorePointer(
        ignoring: blocked,
        child: Semantics(
          enabled: !blocked,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: KuberShape.mediumR,
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 52),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: selected ? cs.primary : cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(label,
                                    style: localeFont(
                                        fontSize: 16, color: cs.onSurface)),
                                if (tag != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: cs.secondaryContainer,
                                        borderRadius: KuberShape.fullR),
                                    child: Text(tag!,
                                        style: localeFont(
                                            fontSize: 11,
                                            color: cs.onSecondaryContainer)),
                                  ),
                                ],
                              ],
                            ),
                            if (reason != null)
                              Text(reason!,
                                  style: localeFont(
                                      fontSize: 13,
                                      color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
