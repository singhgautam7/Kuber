import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../transactions/providers/stats_provider.dart';
import 'category_donut_parts.dart';

/// One donut slice, bucketed by category or category group.
class CategorySlice {
  final String label;
  final double amount;
  final double percentage;
  final Color color;

  const CategorySlice({
    required this.label,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}

/// Redesigned category donut chart (screens 4e default / 4f segment tapped /
/// 4g empty). Replaces the old pie chart on the Analytics tab. Category
/// colors come from each category's existing assigned color.
class CategoryDonutChart extends ConsumerStatefulWidget {
  const CategoryDonutChart({super.key});

  @override
  ConsumerState<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends ConsumerState<CategoryDonutChart> {
  bool _groupMode = false;
  int? _selectedIndex;

  List<CategorySlice> _slices(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (_groupMode) {
      final stats =
          ref.watch(analyticsGroupStatsProvider).valueOrNull ?? const [];
      return [
        for (var i = 0; i < stats.length; i++)
          CategorySlice(
            label: stats[i].groupName,
            amount: stats[i].total,
            percentage: stats[i].percentage,
            color: Color.lerp(
              cs.primary,
              context.kuberMoney.income,
              i / stats.length.clamp(1, 100),
            )!,
          ),
      ];
    }
    final stats =
        ref.watch(analyticsCategoryStatsProvider).valueOrNull ?? const [];
    return [
      for (final s in stats)
        CategorySlice(
          label: s.category.name,
          amount: s.total,
          percentage: s.percentage,
          color: categoryVizColor(context, Color(s.category.colorValue)),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final slices = _slices(context);
    final selected = _selectedIndex != null && _selectedIndex! < slices.length
        ? _selectedIndex
        : null;

    return TapRegion(
      // Tapping anywhere outside the pie/rows deselects.
      onTapOutside: (_) {
        if (_selectedIndex != null) setState(() => _selectedIndex = null);
      },
      child: KuberCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Spending by category',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: cs.onSurface),
                  ),
                ),
                KuberDropdownChip<bool>(
                  value: _groupMode,
                  options: const [
                    KuberDropdownOption(false, 'Category'),
                    KuberDropdownOption(true, 'Group'),
                  ],
                  onChanged: (g) => setState(() {
                    _groupMode = g;
                    _selectedIndex = null;
                  }),
                ),
              ],
            ),
            if (slices.isEmpty)
              DonutEmptyState(cs: cs)
            else ...[
              const SizedBox(height: KuberSpace.lg),
              Center(
                // 176 ring + room for the +6 selected slice.
                child: SizedBox(
                  width: 188,
                  height: 188,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          startDegreeOffset: -90,
                          sectionsSpace: 3,
                          centerSpaceRadius: 68,
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              final isAction =
                                  event is FlTapUpEvent ||
                                  event is FlPanEndEvent;
                              if (!isAction) return;
                              final index =
                                  response?.touchedSection?.touchedSectionIndex;
                              setState(() {
                                _selectedIndex =
                                    (index == null ||
                                        index < 0 ||
                                        index == _selectedIndex)
                                    ? null
                                    : index;
                              });
                            },
                          ),
                          sections: [
                            for (var i = 0; i < slices.length; i++)
                              PieChartSectionData(
                                value: slices[i].percentage.clamp(0.1, 100),
                                title: '',
                                color: selected == null || selected == i
                                    ? slices[i].color
                                    : slices[i].color.withValues(
                                        alpha: KuberChartTheme.unselectedAlpha,
                                      ),
                                radius: selected == i ? 26 : 20,
                              ),
                          ],
                        ),
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOut,
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        child: selected == null
                            ? DonutCenterTotal(
                                key: const ValueKey('total'),
                                slices: slices,
                                groupMode: _groupMode,
                              )
                            : DonutCenterSelected(
                                key: ValueKey('sel$selected'),
                                slice: slices[selected],
                                total: slices.fold(0.0, (s, x) => s + x.amount),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: KuberSpace.lg),
              // Show ALL categories/groups, not just the top few.
              for (var i = 0; i < slices.length; i++) ...[
                if (i > 0)
                  Divider(height: 1, thickness: 1, color: cs.outlineVariant),
                DonutTopRow(
                  slice: slices[i],
                  dimmed: selected != null && selected != i,
                  // No default highlight — a row is highlighted only when its
                  // segment is actually selected.
                  highlighted: selected == i,
                  onTap: () => setState(() {
                    _selectedIndex = _selectedIndex == i ? null : i;
                  }),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
