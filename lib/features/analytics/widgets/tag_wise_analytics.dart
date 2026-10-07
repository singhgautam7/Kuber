import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_progress.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../transactions/data/transaction.dart';
import '../../tags/providers/tag_providers.dart';
import '../../tags/data/tag.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../settings/providers/settings_provider.dart';

class TagWiseAnalytics extends ConsumerWidget {
  final List<Transaction> transactions;

  const TagWiseAnalytics({super.key, required this.transactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagListProvider);
    final txTagsMapAsync = ref.watch(transactionTagsMapProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return tagsAsync.when(
      data: (allTags) {
        return txTagsMapAsync.when(
          data: (txTagsMap) {
            final tagStats = _calculateTagStats(allTags, txTagsMap);
            if (tagStats.isEmpty) {
              return _buildEmptyState(context, cs, tt);
            }

            final totalExpense = tagStats.values.fold<double>(
              0,
              (sum, val) => sum + val['amount']!,
            );
            final sortedTags = tagStats.entries.toList()
              ..sort(
                (a, b) => b.value['amount']!.compareTo(a.value['amount']!),
              );

            // Top 3 sorted by transaction count
            final top3ByCount = tagStats.entries.toList()
              ..sort(
                (a, b) => b.value['count']!.toInt().compareTo(
                  a.value['count']!.toInt(),
                ),
              );
            final top3 = top3ByCount.take(3).toList();

            return KuberCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.tagWiseAnalytics,
                    style: tt.titleMedium?.copyWith(color: cs.onSurface),
                  ),
                  Text(
                    context.l10n.spendingByTag,
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: KuberSpace.lg),

                  // Spending by Tag List
                  ...sortedTags.map((entry) {
                    final tag = allTags.firstWhere((t) => t.id == entry.key);
                    final amount = entry.value['amount']!;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: KuberSpace.lg),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        '#${tag.name}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: tt.bodyMedium?.copyWith(
                                          color: cs.onSurface,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: KuberSpace.sm),
                                    Text(
                                      ref
                                          .watch(formatterProvider)
                                          .formatPercentage(
                                            amount / totalExpense * 100,
                                          ),
                                      style: tt.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                maskAmount(
                                  ref
                                      .watch(formatterProvider)
                                      .formatCurrency(amount),
                                  ref.watch(privacyModeProvider),
                                ),
                                style: tt.titleSmall?.copyWith(
                                  color: cs.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: KuberSpace.sm),
                          KuberLinearProgress(value: amount / totalExpense),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: KuberSpace.sm),
                  KuberSectionHeader(title: context.l10n.topTagsContribution),

                  // Top 3 Tags by Transaction Count
                  Row(
                    children: List.generate(3, (index) {
                      if (index >= top3.length) {
                        return const Expanded(child: SizedBox());
                      }

                      final entry = top3[index];
                      final tag = allTags.firstWhere((t) => t.id == entry.key);
                      final count = entry.value['count']!.toInt();

                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                            right: index < 2 ? KuberSpace.sm : 0,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: KuberSpace.md,
                            horizontal: KuberSpace.sm,
                          ),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHigh,
                            borderRadius: KuberShape.mediumR,
                          ),
                          child: Column(
                            children: [
                              Text(
                                '#${tag.name}',
                                style: tt.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$count',
                                style: tt.titleLarge?.copyWith(
                                  color: cs.onSurface,
                                ),
                              ),
                              Text(
                                count == 1 ? 'txn' : 'txns',
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
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
            );
          },
          loading: () => _buildSkeleton(context),
          error: (e, s) => Center(child: Text('Error loading tags: $e')),
        );
      },
      loading: () => _buildSkeleton(context),
      error: (e, s) => Center(child: Text('Error loading tags: $e')),
    );
  }

  /// Returns a map of tagId → {'amount': double, 'count': double}
  Map<int, Map<String, double>> _calculateTagStats(
    List<Tag> allTags,
    Map<int, Set<int>> txTagsMap,
  ) {
    final expenses = transactions.where((t) => t.type == 'expense').toList();
    final Map<int, Map<String, double>> tagStats = {};

    for (final tx in expenses) {
      final tagIds = txTagsMap[tx.id];
      if (tagIds != null) {
        for (final tagId in tagIds) {
          final existing = tagStats[tagId] ?? {'amount': 0.0, 'count': 0.0};
          tagStats[tagId] = {
            'amount': existing['amount']! + tx.amount,
            'count': existing['count']! + 1,
          };
        }
      }
    }

    return tagStats;
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme cs, TextTheme tt) {
    return KuberCard(
      padding: const EdgeInsets.all(KuberSpace.xxl),
      child: Column(
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 48,
            color: cs.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: KuberSpace.lg),
          Text(
            context.l10n.noTagsInRange,
            textAlign: TextAlign.center,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return KuberCard(
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
            width: 100,
            height: 14,
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
          ),
          const SizedBox(height: KuberSpace.xl),
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 80,
                        height: 24,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHigh,
                      ),
                      Container(
                        width: 60,
                        height: 20,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHigh,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 4,
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
