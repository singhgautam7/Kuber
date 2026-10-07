import 'package:flutter/material.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../core/utils/l10n_ext.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';

import '../../transactions/data/transaction.dart';
import '../../settings/providers/settings_provider.dart';
import 'threshold_settings_sheet.dart';

class TransactionSizeDistribution extends ConsumerWidget {
  final List<Transaction> transactions;
  final Map<String, int>? precomputedDistribution;
  final bool isLoading;

  const TransactionSizeDistribution({
    super.key,
    required this.transactions,
    this.precomputedDistribution,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return _buildSkeleton(context);
    }

    final floor = ref.watch(thresholdFloorProvider);
    final ceiling = ref.watch(thresholdCeilingProvider);
    final distribution = _calculateDistribution(floor, ceiling);
    final total = distribution.values.fold<int>(0, (sum, val) => sum + val);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final formatter = ref.watch(formatterProvider);
    // Stacked distribution (tokens.md §6): ramp steps 4 / 2 / 1, 12 high,
    // 4 gap, full radius.
    final ramp = context.kuberChart.ramp;
    final cSmall = ramp[4], cMedium = ramp[2], cLarge = ramp[1];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(KuberSpace.lg),
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
                        context.l10n.transactionSizeDistribution,
                        style: tt.titleMedium?.copyWith(color: cs.onSurface),
                      ),
                      Text(
                        context.l10n.frequencyByTicketSize,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(4, -4),
                  child: AppIconButton(
                    icon: Icons.tune_rounded,
                    semanticLabel: 'Thresholds',
                    onPressed: () => _openThresholdSheet(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KuberSpace.md),

            // Segmented Bar
            Row(
              children: [
                _buildBarSegment(cSmall, distribution['small'] ?? 0, total),
                const SizedBox(width: 4),
                _buildBarSegment(cMedium, distribution['medium'] ?? 0, total),
                const SizedBox(width: 4),
                _buildBarSegment(cLarge, distribution['large'] ?? 0, total),
              ],
            ),

            const SizedBox(height: KuberSpace.lg),

            // Legend
            _buildLegendItem(
              cSmall,
              'Small (<${formatter.formatCurrency(floor)})',
              distribution['small'] ?? 0,
              total,
              cs,
              tt,
            ),
            const SizedBox(height: KuberSpace.md),
            _buildLegendItem(
              cMedium,
              'Medium (${formatter.formatCurrency(floor)} - ${formatter.formatCurrency(ceiling)})',
              distribution['medium'] ?? 0,
              total,
              cs,
              tt,
            ),
            const SizedBox(height: KuberSpace.md),
            _buildLegendItem(
              cLarge,
              'Large (>${formatter.formatCurrency(ceiling)})',
              distribution['large'] ?? 0,
              total,
              cs,
              tt,
            ),
          ],
        ),
      ),
    );
  }

  void _openThresholdSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ThresholdSettingsSheet(),
    );
  }

  Widget _buildBarSegment(Color color, int count, int total) {
    final flex = (total > 0 ? (count / total * 100).round() : 1).clamp(1, 100);
    return Expanded(
      flex: flex,
      child: Container(
        height: 12,
        decoration: BoxDecoration(color: color, borderRadius: KuberShape.fullR),
      ),
    );
  }

  Widget _buildLegendItem(
    Color color,
    String label,
    int count,
    int total,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final percentage = total > 0 ? (count / total * 100).round() : 0;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: KuberSpace.md),
        Expanded(
          child: Text(
            label,
            style: tt.bodyMedium?.copyWith(color: cs.onSurface),
          ),
        ),
        Text(
          '$percentage%',
          style: tt.titleSmall?.copyWith(color: cs.onSurface),
        ),
      ],
    );
  }

  Map<String, int> _calculateDistribution(double floor, double ceiling) {
    final (s, m, l) = transactions.fold<(int, int, int)>((0, 0, 0), (acc, tx) {
      if (tx.type != 'expense') return acc;
      return tx.amount < floor
          ? (acc.$1 + 1, acc.$2, acc.$3)
          : tx.amount <= ceiling
          ? (acc.$1, acc.$2 + 1, acc.$3)
          : (acc.$1, acc.$2, acc.$3 + 1);
    });

    return {'small': s, 'medium': m, 'large': l};
  }

  Widget _buildSkeleton(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(KuberSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 200,
              height: 20,
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
            ),
            const SizedBox(height: 8),
            Container(
              width: 150,
              height: 14,
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
            ),
            const SizedBox(height: KuberSpace.xl),
            Container(
              width: double.infinity,
              height: 24,
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
            ),
            const SizedBox(height: KuberSpace.xl),
            ...List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: KuberSpace.md),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 120,
                      height: 14,
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
