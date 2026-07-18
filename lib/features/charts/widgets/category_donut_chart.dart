import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/locale_font.dart';
import 'income_expense_chart_controls.dart' show KuberSegmentedTabs;
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
  ConsumerState<CategoryDonutChart> createState() =>
      _CategoryDonutChartState();
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
                cs.primary, cs.tertiary, i / stats.length.clamp(1, 100))!,
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
          color: harmonizeCategory(context, Color(s.category.colorValue)),
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
      child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.lg),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending by category',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: localeFont(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: KuberSegmentedTabs(
              labels: const ['Category', 'Group'],
              selectedIndex: _groupMode ? 1 : 0,
              onChanged: (i) => setState(() {
                _groupMode = i == 1;
                _selectedIndex = null;
              }),
            ),
          ),
          if (slices.isEmpty)
            DonutEmptyState(cs: cs)
          else ...[
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        startDegreeOffset: -90,
                        sectionsSpace: 2,
                        centerSpaceRadius: 60,
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            final isAction = event is FlTapUpEvent ||
                                event is FlPanEndEvent;
                            if (!isAction) return;
                            final index = response
                                ?.touchedSection?.touchedSectionIndex;
                            setState(() {
                              _selectedIndex =
                                  (index == null || index < 0 ||
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
                                  : slices[i]
                                      .color
                                      .withValues(alpha: 0.4),
                              radius: selected == i ? 28 : 24,
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
                              total: slices.fold(
                                  0.0, (s, x) => s + x.amount),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Show ALL categories/groups, not just the top few.
            for (var i = 0; i < slices.length; i++)
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
      ),
      ),
    );
  }
}
