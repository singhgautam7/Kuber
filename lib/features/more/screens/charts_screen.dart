import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider;
import '../providers/chart_data_provider.dart';

class ChartsScreen extends ConsumerWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KuberAppBar(showBack: true, title: 'Charts'),
          Expanded(
            child: _ChartsBody(),
          ),
        ],
      ),
    );
  }
}

class _ChartsBody extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ChartsBody> createState() => _ChartsBodyState();
}

class _ChartsBodyState extends ConsumerState<_ChartsBody> {
  @override
  void initState() {
    super.initState();
    // Auto-select the last bar after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoSelectLast());
  }

  void _autoSelectLast() {
    final period = ref.read(selectedChartPeriodProvider);
    final dataAsync = ref.read(chartDataProvider(period));
    dataAsync.whenData((buckets) {
      if (buckets.isNotEmpty) {
        ref.read(selectedChartBarIndexProvider.notifier).state =
            buckets.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final period = ref.watch(selectedChartPeriodProvider);
    final dataAsync = ref.watch(chartDataProvider(period));

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(
              KuberSpacing.lg, KuberSpacing.md, KuberSpacing.lg, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Charts',
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                            height: 1.15,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Visualise your spending patterns over time.',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  // WIP badge — disabled, greyed out
                  Opacity(
                    opacity: 0.35,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        borderRadius:
                            BorderRadius.circular(KuberRadius.md),
                        border:
                            Border.all(color: cs.outline.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.construction_rounded,
                              size: 14, color: cs.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Text('WIP',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: KuberSpacing.lg),
              // Period chips
              _PeriodChipRow(),
            ],
          ),
        ),
        const SizedBox(height: KuberSpacing.md),
        // Top panel — bar chart
        Expanded(
          flex: 5,
          child: dataAsync.when(
            loading: () => _ChartSkeleton(),
            error: (e, _) => Center(
              child: Text('Failed to load data',
                  style: GoogleFonts.inter(color: cs.error)),
            ),
            data: (buckets) => _ScrollableBarChart(buckets: buckets),
          ),
        ),
        Divider(height: 1, color: cs.outline.withValues(alpha: 0.4)),
        // Bottom panel — period detail
        Expanded(
          flex: 5,
          child: _DetailsPanel(),
        ),
      ],
    );
  }
}

// ────────────────────────── Period chips ────────────────────────────────────

class _PeriodChipRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final selected = ref.watch(selectedChartPeriodProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ChartPeriod.values.map((p) {
          final isSelected = p == selected;
          return GestureDetector(
            onTap: () {
              ref.read(selectedChartPeriodProvider.notifier).state = p;
              ref.read(selectedChartBarIndexProvider.notifier).state = null;
              // auto-select last after data loads
              Future.delayed(const Duration(milliseconds: 100), () {
                final dataAsync = ref.read(chartDataProvider(p));
                dataAsync.whenData((buckets) {
                  if (buckets.isNotEmpty) {
                    ref.read(selectedChartBarIndexProvider.notifier).state =
                        buckets.length - 1;
                  }
                });
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? cs.primary : cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(KuberRadius.full),
                border: Border.all(
                  color: isSelected
                      ? cs.primary
                      : cs.outline.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                p.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ────────────────────────── Skeleton loader ──────────────────────────────────

class _ChartSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.lg, vertical: KuberSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          9,
          (i) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 400 + i * 60),
                height: 40.0 + (i % 4) * 24,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(KuberRadius.sm),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────── Scrollable bar chart ─────────────────────────────

class _ScrollableBarChart extends ConsumerStatefulWidget {
  final List<ChartBarBucket> buckets;
  const _ScrollableBarChart({required this.buckets});

  @override
  ConsumerState<_ScrollableBarChart> createState() =>
      _ScrollableBarChartState();
}

class _ScrollableBarChartState extends ConsumerState<_ScrollableBarChart> {
  static const double _barWidth = 16;
  static const double _barGroupWidth = 44;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selectedIdx = ref.watch(selectedChartBarIndexProvider);
    final buckets = widget.buckets;

    if (buckets.isEmpty) {
      return Center(
        child: Text('No data for this period',
            style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
      );
    }

    final maxVal = buckets.fold<double>(
      0,
      (m, b) => math.max(m, math.max(b.income, b.expense)),
    );
    final yMax = maxVal <= 0 ? 100.0 : maxVal * 1.25;
    final intervals = _niceInterval(yMax);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fixed Y-axis labels
        Padding(
          padding: const EdgeInsets.only(
              left: KuberSpacing.lg, bottom: 28, top: KuberSpacing.sm),
          child: _YAxisLabels(yMax: yMax, interval: intervals),
        ),
        // Scrollable chart area
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(
                right: KuberSpacing.lg, bottom: 0),
            child: SizedBox(
              width: buckets.length * _barGroupWidth.toDouble(),
              child: BarChart(
                BarChartData(
                  maxY: yMax,
                  minY: 0,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: intervals,
                    getDrawingHorizontalLine: (v) => FlLine(
                      color: cs.outline.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= buckets.length) {
                            return const SizedBox.shrink();
                          }
                          // Show every Nth label to avoid crowding
                          final step =
                              (buckets.length / 6).ceil().clamp(1, 99);
                          if (idx % step != 0 && idx != buckets.length - 1) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              buckets[idx].label,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: idx == selectedIdx
                                    ? cs.primary
                                    : cs.onSurfaceVariant,
                                fontWeight: idx == selectedIdx
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(buckets.length, (i) {
                    final b = buckets[i];
                    final isSelected = i == selectedIdx;
                    final dimOpacity = selectedIdx != null && !isSelected
                        ? 0.35
                        : 1.0;
                    return BarChartGroupData(
                      x: i,
                      groupVertically: false,
                      barRods: [
                        BarChartRodData(
                          toY: b.expense,
                          width: _barWidth,
                          color: cs.error.withValues(alpha: dimOpacity),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(3)),
                        ),
                        BarChartRodData(
                          toY: b.income,
                          width: _barWidth,
                          color: cs.tertiary.withValues(alpha: dimOpacity),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(3)),
                        ),
                      ],
                      barsSpace: 4,
                    );
                  }),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.transparent,
                      tooltipPadding: EdgeInsets.zero,
                    ),
                    touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
                      if (event is FlTapUpEvent || event is FlPanUpdateEvent) {
                        final idx = response?.spot?.touchedBarGroupIndex;
                        if (idx != null) {
                          ref
                              .read(selectedChartBarIndexProvider.notifier)
                              .state = idx;
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _niceInterval(double maxY) {
    if (maxY <= 0) return 25;
    final rawInterval = maxY / 4;
    final magnitude = math.pow(10, (math.log(rawInterval) / math.ln10).floor());
    return (rawInterval / magnitude).ceil() * magnitude.toDouble();
  }
}

String _compactValue(double val) {
  if (val >= 10000000) return '${(val / 10000000).toStringAsFixed(1)}Cr';
  if (val >= 100000) return '${(val / 100000).toStringAsFixed(1)}L';
  if (val >= 1000) return '${(val / 1000).toStringAsFixed(1)}K';
  return val.toStringAsFixed(0);
}

class _YAxisLabels extends StatelessWidget {
  final double yMax;
  final double interval;

  const _YAxisLabels({required this.yMax, required this.interval});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final count = (yMax / interval).ceil();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(count + 1, (i) {
        final val = yMax - i * interval;
        if (val < 0) return const SizedBox.shrink();
        return Text(
          _compactValue(val),
          style: GoogleFonts.inter(
              fontSize: 10,
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500),
        );
      }),
    );
  }
}

// ────────────────────────── Details panel ───────────────────────────────────

class _DetailsPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final period = ref.watch(selectedChartPeriodProvider);
    final selectedIdx = ref.watch(selectedChartBarIndexProvider);
    final dataAsync = ref.watch(chartDataProvider(period));
    final formatter = ref.watch(formatterProvider);

    return dataAsync.when(
      loading: () => _DetailsSkeleton(),
      error: (e, _) => const SizedBox.shrink(),
      data: (buckets) {
        if (buckets.isEmpty || selectedIdx == null) {
          return Center(
            child: Text('Tap a bar to see details',
                style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
          );
        }
        final bucket = buckets[selectedIdx.clamp(0, buckets.length - 1)];
        final net = bucket.income - bucket.expense;
        final range = (from: bucket.startDate, to: bucket.endDate);
        final catAsync = ref.watch(chartCategoryStatsProvider(range));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(KuberSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period label
              Text(
                _periodLabel(bucket, period),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: KuberSpacing.md),
              // Summary row
              Row(
                children: [
                  _SummaryTile(
                    label: 'INCOME',
                    value: formatter.formatCurrency(bucket.income),
                    color: cs.tertiary,
                  ),
                  const SizedBox(width: KuberSpacing.sm),
                  _SummaryTile(
                    label: 'EXPENSE',
                    value: formatter.formatCurrency(bucket.expense),
                    color: cs.error,
                  ),
                  const SizedBox(width: KuberSpacing.sm),
                  _SummaryTile(
                    label: 'NET',
                    value: formatter.formatCurrency(net.abs()),
                    color: net >= 0 ? cs.tertiary : cs.error,
                    prefix: net < 0 ? '−' : '+',
                  ),
                ],
              ),
              const SizedBox(height: KuberSpacing.lg),
              // Category breakdown
              catAsync.when(
                loading: () => _DetailsSkeleton(),
                error: (_, __) => const SizedBox.shrink(),
                data: (stats) {
                  if (stats.isEmpty) {
                    return Text('No expense breakdown available.',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: cs.onSurfaceVariant));
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BY CATEGORY',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurfaceVariant,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: KuberSpacing.sm),
                      ...stats.take(5).map((s) {
                        final color =
                            harmonizeCategory(context, Color(s.category.colorValue));
                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    color: color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  s.category.name,
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: cs.onSurface),
                                ),
                              ),
                              Text(
                                formatter.formatCurrency(s.total),
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 36,
                                child: Text(
                                  '${s.percentage.toStringAsFixed(0)}%',
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: cs.onSurfaceVariant),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _periodLabel(ChartBarBucket b, ChartPeriod period) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return switch (period) {
      ChartPeriod.oneDay =>
        '${b.startDate.hour == 0 ? '12' : b.startDate.hour <= 12 ? '${b.startDate.hour}' : '${b.startDate.hour - 12}'}:00 ${b.startDate.hour < 12 ? 'AM' : 'PM'}',
      ChartPeriod.oneWeek ||
      ChartPeriod.oneMonth =>
        '${b.startDate.day} ${months[b.startDate.month - 1]} ${b.startDate.year}',
      ChartPeriod.oneQuarter =>
        'Week of ${b.startDate.day} ${months[b.startDate.month - 1]}',
      ChartPeriod.oneYear =>
        '${months[b.startDate.month - 1]} ${b.startDate.year}',
    };
  }
}

class _DetailsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(KuberSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary row skeleton
          Row(
            children: List.generate(
              3,
              (i) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                  height: 56,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: KuberSpacing.lg),
          // Category rows skeleton
          ...List.generate(
            4,
            (i) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              height: 18,
              width: double.infinity,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(KuberRadius.sm),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String prefix;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
    this.prefix = '',
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: KuberSpacing.md, vertical: KuberSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '$prefix$value',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
