import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../transactions/data/transaction.dart';
import '../../settings/providers/settings_provider.dart' show currencyProvider;

class AvgWeeklyHeatmap extends ConsumerStatefulWidget {
  final List<Transaction> transactions;
  final bool isLoading;

  const AvgWeeklyHeatmap({
    super.key,
    required this.transactions,
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

    final dailyAverages = _calculateDailyAverages();
    final maxAvg = dailyAverages.values.fold<double>(0, (max, val) => val > max ? val : max);
    final cs = Theme.of(context).colorScheme;
    final currency = ref.watch(currencyProvider);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(KuberSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Avg Weekly Heatmap',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Based on your selected filter',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.grid_view_rounded,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: KuberSpacing.xl),
            
            // Heatmap Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final dayName = _getDayName(index);
                final avg = dailyAverages[dayName] ?? 0;
                final opacity = maxAvg > 0 ? (0.1 + (avg / maxAvg) * 0.6) : 0.05;

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
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: opacity),
                            borderRadius: BorderRadius.circular(KuberRadius.sm),
                            border: Border.all(
                              color: _selectedDayIndex == index 
                                ? cs.primary 
                                : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: KuberSpacing.sm),
                      Text(
                        _getDayShortName(index),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            
            const SizedBox(height: KuberSpacing.lg),
            const Divider(),
            const SizedBox(height: KuberSpacing.md),
            
            // Intensity Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'INTENSITY',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                Row(
                  children: List.generate(4, (index) {
                    final opacity = 0.1 + (index * 0.2);
                    return Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: opacity),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ],
            ),

            if (_isExpanded) ...[
              const SizedBox(height: KuberSpacing.lg),
              ...List.generate(7, (index) {
                final dayName = _getDayName(index);
                final avg = dailyAverages[dayName] ?? 0;
                final isSelected = _selectedDayIndex == index;

                return Container(
                  margin: const EdgeInsets.only(bottom: KuberSpacing.sm),
                  padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg, vertical: KuberSpacing.md),
                  decoration: BoxDecoration(
                    color: isSelected ? cs.primary.withValues(alpha: 0.1) : Colors.black, // Dark background as per screenshot
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    border: Border.all(
                      color: isSelected ? cs.primary.withValues(alpha: 0.3) : Colors.white10,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        dayName.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? cs.primary : cs.onSurfaceVariant,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        '${currency.symbol}${NumberFormat('#,##0').format(avg)}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Map<String, double> _calculateDailyAverages() {
    final expenses = widget.transactions.where((t) => t.type == 'expense').toList();
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
      final day = DateFormat('EEEE').format(tx.createdAt);
      dayAmounts[day]?.add(tx.amount);
    }

    return dayAmounts.map((day, amounts) {
      if (amounts.isEmpty) return MapEntry(day, 0.0);
      return MapEntry(day, amounts.reduce((a, b) => a + b) / amounts.length);
    });
  }

  String _getDayName(int index) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
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
        padding: const EdgeInsets.all(KuberSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 150, height: 20, color: Colors.white10),
            const SizedBox(height: 8),
            Container(width: 120, height: 14, color: Colors.white10),
            const SizedBox(height: KuberSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) => Column(
                children: [
                  Container(width: 40, height: 40, color: Colors.white10),
                  const SizedBox(height: 8),
                  Container(width: 30, height: 10, color: Colors.white10),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
}
