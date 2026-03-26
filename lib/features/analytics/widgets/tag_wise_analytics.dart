import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../transactions/data/transaction.dart';
import '../../tags/providers/tag_providers.dart';
import '../../tags/data/tag.dart';
import '../../settings/providers/settings_provider.dart';

class TagWiseAnalytics extends ConsumerWidget {
  final List<Transaction> transactions;

  const TagWiseAnalytics({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagListProvider);
    final txTagsMapAsync = ref.watch(transactionTagsMapProvider);
    final cs = Theme.of(context).colorScheme;

    return tagsAsync.when(
      data: (allTags) {
        return txTagsMapAsync.when(
          data: (txTagsMap) {
            final tagStats = _calculateTagStats(allTags, txTagsMap);
            if (tagStats.isEmpty) {
              return _buildEmptyState(cs);
            }

            final totalExpense = tagStats.values.fold<double>(0, (sum, val) => sum + val);
            final sortedTags = tagStats.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            
            final top3 = sortedTags.take(3).toList();

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
                              'Tag-wise Analytics',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Spending by Tag',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.local_offer_rounded,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: KuberSpacing.xl),
                    
                    // Spending by Tag List
                    ...sortedTags.map((entry) {
                      final tag = allTags.firstWhere((t) => t.id == entry.key);
                      final amount = entry.value;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: KuberSpacing.lg),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(KuberRadius.md),
                                  ),
                                  child: Text(
                                    '#${tag.name}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: KuberSpacing.sm),
                                Text(
                                  ref.watch(formatterProvider).formatPercentage(amount / totalExpense * 100),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: cs.primary,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  ref.watch(formatterProvider).formatCurrency(amount),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: KuberSpacing.sm),
                            Row(
                              children: [
                                Expanded(
                                  flex: (amount / totalExpense * 100).round().clamp(1, 100),
                                  child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: cs.primary,
                                      borderRadius: BorderRadius.circular(KuberRadius.full),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  flex: (100 - (amount / totalExpense * 100)).round().clamp(1, 100),
                                  child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(KuberRadius.full),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                    
                    const SizedBox(height: KuberSpacing.md),
                    const Divider(),
                    const SizedBox(height: KuberSpacing.lg),
                    
                    Text(
                      'TOP TAGS CONTRIBUTION',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    
                    // Top 3 Tags Contribution Grid
                    Row(
                      children: List.generate(3, (index) {
                        if (index >= top3.length) return const Expanded(child: SizedBox());
                        
                        final entry = top3[index];
                        final tag = allTags.firstWhere((t) => t.id == entry.key);
                        

                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: index < 2 ? KuberSpacing.sm : 0),
                            padding: const EdgeInsets.symmetric(vertical: KuberSpacing.lg),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(KuberRadius.md),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '#${tag.name}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ref.watch(formatterProvider).formatPercentage(entry.value / totalExpense * 100),
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => _buildSkeleton(),
          error: (e, s) => Center(child: Text('Error loading tags: $e')),
        );
      },
      loading: () => _buildSkeleton(),
      error: (e, s) => Center(child: Text('Error loading tags: $e')),
    );
  }

  Map<int, double> _calculateTagStats(List<Tag> allTags, Map<int, Set<int>> txTagsMap) {
    final expenses = transactions.where((t) => t.type == 'expense').toList();
    final Map<int, double> tagStats = {};

    for (final tx in expenses) {
      final tagIds = txTagsMap[tx.id];
      if (tagIds != null) {
        for (final tagId in tagIds) {
          tagStats[tagId] = (tagStats[tagId] ?? 0) + tx.amount;
        }
      }
    }

    return tagStats;
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(KuberSpacing.xxl),
        child: Column(
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 48,
              color: cs.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: KuberSpacing.lg),
            Text(
              'There are no tags related transaction in in your selected date range',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
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
            Container(width: 100, height: 14, color: Colors.white10),
            const SizedBox(height: KuberSpacing.xl),
            ...List.generate(3, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 80, height: 24, color: Colors.white10),
                      Container(width: 60, height: 20, color: Colors.white10),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(width: double.infinity, height: 4, color: Colors.white10),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
