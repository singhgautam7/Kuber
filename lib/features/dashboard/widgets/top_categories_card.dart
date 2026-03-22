import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../categories/providers/category_provider.dart';

class TopCategoriesCard extends ConsumerWidget {
  final Map<String, double> categorySpending;

  const TopCategoriesCard({super.key, required this.categorySpending});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final categoryMapAsync = ref.watch(categoryMapProvider);

    if (categorySpending.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort by amount desc, take top 5
    final sorted = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.lg),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top Categories', style: textTheme.titleLarge),
            const SizedBox(height: KuberSpacing.lg),
            categoryMapAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
              data: (categories) {
                return SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: top.isEmpty ? 100 : top.first.value * 1.2,
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i < 0 || i >= top.length) {
                                return const SizedBox.shrink();
                              }
                              final catId =
                                  int.tryParse(top[i].key);
                              final cat = catId != null
                                  ? categories[catId]
                                  : null;
                              return Padding(
                                padding: const EdgeInsets.only(
                                    top: KuberSpacing.sm),
                                child: Text(
                                  cat?.name ?? '?',
                                  style: textTheme.labelSmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      barGroups: top.asMap().entries.map((entry) {
                        final i = entry.key;
                        final catId = int.tryParse(entry.value.key);
                        final cat =
                            catId != null ? categories[catId] : null;
                        final rawColor = cat != null
                            ? Color(cat.colorValue)
                            : colorScheme.primary;
                        final harmonized =
                            harmonizeCategory(context, rawColor);
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.value,
                              color: harmonized,
                              width: 24,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
