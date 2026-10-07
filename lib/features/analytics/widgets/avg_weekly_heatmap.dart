import 'package:flutter/material.dart';
import '../../../shared/widgets/kuber_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../transactions/data/transaction.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../settings/providers/settings_provider.dart';

class AvgWeeklyHeatmap extends ConsumerStatefulWidget {
  final List<Transaction> transactions;
  final Map<String, double>? precomputedDailyAverages;
  final bool isLoading;

  const AvgWeeklyHeatmap({
    super.key,
    required this.transactions,
    this.precomputedDailyAverages,
    this.isLoading = false,
  });

  @override
  ConsumerState<AvgWeeklyHeatmap> createState() => _AvgWeeklyHeatmapState();
}

class _AvgWeeklyHeatmapState extends ConsumerState<AvgWeeklyHeatmap> {
  bool _isExpanded = false;
  int? _selectedDayIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildSkeleton();
    }

    final dailyAverages =
        widget.precomputedDailyAverages ?? _calculateDailyAverages();
    final maxAvg = dailyAverages.values.fold<double>(
      0,
      (max, val) => val > max ? val : max,
    );
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final ramp = context.kuberChart.ramp;
    // Intensity -> one of the 5 ramp steps (tokens.md §6).
    Color cellColor(double avg) => maxAvg <= 0
        ? ramp.first
        : ramp[((avg / maxAvg) * (ramp.length - 1)).round().clamp(
            0,
            ramp.length - 1,
          )];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(KuberSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.avgWeeklyHeatmap,
                        style: tt.titleMedium?.copyWith(color: cs.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        context.l10n.basedOnSelectedFilter,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: KuberSpace.md),
                // Icon(
                //   Icons.grid_view_rounded,
                //   color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                //   size: 20,
                // ),
              ],
            ),
            const SizedBox(height: KuberSpace.lg),

            // Heatmap Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final dayName = _getDayName(index);
                final avg = dailyAverages[dayName] ?? 0;
                final selected = _selectedDayIndex == index;

                return Expanded(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_selectedDayIndex == index && _isExpanded) {
                              _isExpanded = false;
                              _selectedDayIndex = null;
                            } else {
                              _isExpanded = true;
                              _selectedDayIndex = index;
                            }
                          });
                        },
                        child: Container(
                          height: 40,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: cellColor(avg),
                            borderRadius: KuberShape.smallR,
                          ),
                          foregroundDecoration: selected
                              ? BoxDecoration(
                                  borderRadius: KuberShape.smallR,
                                  border: Border.all(
                                    color: cs.onSurface,
                                    width: 2,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _getDayShortName(index),
                        style: tt.labelSmall?.copyWith(
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected ? cs.onSurface : cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

            const SizedBox(height: KuberSpace.lg),

            // Intensity Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.intensity.toUpperCase(),
                  style: tt.labelMedium?.copyWith(
                    letterSpacing: 0.8,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                Row(
                  children: ramp.map((c) {
                    return Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(KuberShape.extraSmall),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            if (_isExpanded) ...[
              const SizedBox(height: KuberSpace.sm),
              // Daily averages as a grouped list, selected day in
              // secondaryContainer (board 3.6b).
              KuberGroup(
                children: List.generate(7, (index) {
                  final dayName = _getDayName(index);
                  final avg = dailyAverages[dayName] ?? 0;
                  final isSelected = _selectedDayIndex == index;
                  return Container(
                    height: 44,
                    color: isSelected ? cs.secondaryContainer : null,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          dayName,
                          style: tt.bodyMedium?.copyWith(
                            color: isSelected
                                ? cs.onSecondaryContainer
                                : cs.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          maskAmount(
                            ref.watch(formatterProvider).formatCurrency(avg),
                            ref.watch(privacyModeProvider),
                          ),
                          style: tt.titleSmall?.copyWith(
                            color: isSelected
                                ? cs.onSecondaryContainer
                                : cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Map<String, double> _calculateDailyAverages() {
    final expenses = widget.transactions
        .where((t) => t.type == 'expense')
        .toList();
    if (expenses.isEmpty) return {};

    final Map<String, List<double>> dayAmounts = {
      'Monday': [],
      'Tuesday': [],
      'Wednesday': [],
      'Thursday': [],
      'Friday': [],
      'Saturday': [],
      'Sunday': [],
    };

    for (final tx in expenses) {
      final day = DateFormat('EEEE').format(tx.createdAt.toLocal());
      dayAmounts[day]?.add(tx.amount);
    }

    return dayAmounts.map((day, amounts) {
      if (amounts.isEmpty) return MapEntry(day, 0.0);
      return MapEntry(day, amounts.reduce((a, b) => a + b) / amounts.length);
    });
  }

  String _getDayName(int index) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[index];
  }

  String _getDayShortName(int index) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[index];
  }

  Widget _buildSkeleton() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(KuberSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150,
              height: 20,
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
            ),
            const SizedBox(height: 8),
            Container(
              width: 120,
              height: 14,
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
            ),
            const SizedBox(height: KuberSpace.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                7,
                (index) => Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 30,
                      height: 10,
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
