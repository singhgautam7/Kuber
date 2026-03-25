import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../transactions/providers/stats_provider.dart';
import '../../analytics/providers/analytics_provider.dart';
import 'analytics_toggle.dart';

class CategoryGroupStatsWidget extends ConsumerStatefulWidget {
  final AnalyticsPeriod period;
  const CategoryGroupStatsWidget({super.key, required this.period});

  @override
  ConsumerState<CategoryGroupStatsWidget> createState() => _CategoryGroupStatsWidgetState();
}

class _CategoryGroupStatsWidgetState extends ConsumerState<CategoryGroupStatsWidget> {
  bool _isGroupView = false;
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final statsAsync = _isGroupView
        ? ref.watch(analyticsGroupStatsProvider(widget.period))
        : ref.watch(analyticsCategoryStatsProvider(widget.period));

    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(KuberSpacing.lg, KuberSpacing.lg, KuberSpacing.lg, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spending Distribution',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                AnalyticsCardSmallTabs(
                  labels: const ['Category', 'Group'],
                  selectedIndex: _isGroupView ? 1 : 0,
                  onChanged: (i) => setState(() {
                    _isGroupView = i == 1;
                    _touchedIndex = null;
                  }),
                ),
              ],
            ),
          ),
          statsAsync.when(
            loading: () => _buildLoading(context),
            error: (e, _) => const Padding(
              padding: EdgeInsets.all(KuberSpacing.lg),
              child: _EmptyState(message: 'Error loading data'),
            ),
            data: (stats) {
              if (stats.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(KuberSpacing.lg),
                  child: _EmptyState(message: 'No data available'),
                );
              }

              return Column(
                children: [
                  const SizedBox(height: KuberSpacing.md),
                  SizedBox(
                    height: 200,
                    child: _buildPieChart(stats),
                  ),
                  const SizedBox(height: KuberSpacing.md),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(KuberSpacing.lg),
                    child: Column(
                      children: stats.map((s) {
                        if (s is CategoryStat) {
                          return _StatRow(
                            label: s.category.name,
                            amount: s.total,
                            percentage: s.percentage,
                            icon: IconMapper.fromString(s.category.icon),
                            color: harmonizeCategory(context, Color(s.category.colorValue)),
                            onTap: () => context.go('/history?categoryId=${s.category.id}'),
                          );
                        } else if (s is GroupStat) {
                          return _StatRow(
                            label: s.groupName,
                            amount: s.total,
                            percentage: s.percentage,
                            icon: Icons.folder_open_rounded,
                            color: cs.primary,
                            onTap: () => context.go('/history?group=${s.groupName}'),
                          );
                        }
                        return const SizedBox.shrink();
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(List<dynamic> stats) {
    final cs = Theme.of(context).colorScheme;
    
    return PieChart(
      key: ValueKey(_isGroupView),
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            // Only respond to actual user "actions" (tap up, pan end) to toggle
            final bool isAction = event is FlTapUpEvent || event is FlPanEndEvent;
            
            if (isAction) {
              if (pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                return;
              }
              final index = pieTouchResponse.touchedSection!.touchedSectionIndex;
              if (index >= 0 && index < stats.length) {
                setState(() {
                  _touchedIndex = (_touchedIndex == index) ? null : index;
                });
              }
            }
          },
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: List.generate(stats.length, (i) {
          final isTouched = i == _touchedIndex;
          final double radius = isTouched ? 65.0 : 50.0;
          
          final s = stats[i];
          Color color;
          String name;
          double percentage;

          if (s is CategoryStat) {
            color = harmonizeCategory(context, Color(s.category.colorValue));
            name = s.category.name;
            percentage = s.percentage;
          } else {
            color = Color.lerp(cs.primary, cs.tertiary, i / stats.length.clamp(1, 100))!;
            name = s.groupName;
            percentage = s.percentage;
          }

          return PieChartSectionData(
            color: color,
            value: percentage,
            title: isTouched ? '$name\n${percentage.toStringAsFixed(1)}%' : '',
            radius: radius,
            titlePositionPercentageOffset: 0.55,
            titleStyle: TextStyle(
              fontSize: isTouched ? 11 : 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
            ),
          );
        }),
      ),
    );
  }



  Widget _buildLoading(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: cs.surfaceContainerHigh,
      highlightColor: cs.surfaceContainerLowest,
      child: Container(
        height: 250,
        margin: const EdgeInsets.all(KuberSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
      ),
    );
  }
}



class _StatRow extends StatelessWidget {
  final String label;
  final double amount;
  final double percentage;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatRow({
    required this.label,
    required this.amount,
    required this.percentage,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: KuberSpacing.md),
        child: Row(
          children: [
            CategoryIcon.square(icon: icon, rawColor: color, size: 36),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(label, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                      Text(
                        CurrencyFormatter.format(amount),
                        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: (percentage / 100).clamp(0, 1),
                            backgroundColor: color.withValues(alpha: 0.1),
                            color: color,
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KuberSpacing.xl),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
        ),
      ),
    );
  }
}
