import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

import '../../transactions/data/transaction.dart';
import '../../settings/providers/settings_provider.dart';

class TransactionSizeDistribution extends ConsumerWidget {
  final List<Transaction> transactions;
  final bool isLoading;

  const TransactionSizeDistribution({
    super.key,
    required this.transactions,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return _buildSkeleton();
    }

    final distribution = _calculateDistribution();
    final total = distribution.values.fold<int>(0, (sum, val) => sum + val);
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(KuberSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Size Distribution',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Frequency by ticket size',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: KuberSpacing.xl),
            
            // Segmented Bar
            Row(
              children: [
                _buildBarSegment(cs.primary.withValues(alpha: 0.9), distribution['small'] ?? 0, total),
                const SizedBox(width: 4),
                _buildBarSegment(cs.primary.withValues(alpha: 0.5), distribution['medium'] ?? 0, total),
                const SizedBox(width: 4),
                _buildBarSegment(cs.primary.withValues(alpha: 0.1), distribution['large'] ?? 0, total),
              ],
            ),
            
            const SizedBox(height: KuberSpacing.xl),
            
            // Legend
            _buildLegendItem(cs.primary.withValues(alpha: 0.9), 'Small (<${formatter.formatCurrency(500)})', distribution['small'] ?? 0, total, cs),
            const SizedBox(height: KuberSpacing.md),
            _buildLegendItem(cs.primary.withValues(alpha: 0.5), 'Medium (${formatter.formatCurrency(500)} - ${formatter.formatCurrency(2000)})', distribution['medium'] ?? 0, total, cs),
            const SizedBox(height: KuberSpacing.md),
            _buildLegendItem(cs.primary.withValues(alpha: 0.1), 'Large (>${formatter.formatCurrency(2000)})', distribution['large'] ?? 0, total, cs),
          ],
        ),
      ),
    );
  }

  Widget _buildBarSegment(Color color, int count, int total) {
    final flex = (total > 0 ? (count / total * 100).round() : 1).clamp(1, 100);
    return Expanded(
      flex: flex,
      child: Container(
        height: 24,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(KuberRadius.sm),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, int count, int total, ColorScheme cs) {
    final percentage = total > 0 ? (count / total * 100).round() : 0;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: KuberSpacing.md),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: cs.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          '$percentage%',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }

  Map<String, int> _calculateDistribution() {
    final (s, m, l) = transactions.fold<(int, int, int)>(
      (0, 0, 0),
      (acc, tx) {
        if (tx.type != 'expense') return acc;
        return tx.amount < 500
            ? (acc.$1 + 1, acc.$2, acc.$3)
            : tx.amount <= 2000
                ? (acc.$1, acc.$2 + 1, acc.$3)
                : (acc.$1, acc.$2, acc.$3 + 1);
      },
    );

    return {'small': s, 'medium': m, 'large': l};
  }

  Widget _buildSkeleton() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(KuberSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 200, height: 20, color: Colors.white10),
            const SizedBox(height: 8),
            Container(width: 150, height: 14, color: Colors.white10),
            const SizedBox(height: KuberSpacing.xl),
            Container(width: double.infinity, height: 24, color: Colors.white10),
            const SizedBox(height: KuberSpacing.xl),
            ...List.generate(3, (index) => Padding(
              padding: const EdgeInsets.only(bottom: KuberSpacing.md),
              child: Row(
                children: [
                  Container(width: 8, height: 8, color: Colors.white10),
                  const SizedBox(width: 12),
                  Container(width: 120, height: 14, color: Colors.white10),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
