import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../budgets/data/budget.dart';
import '../../settings/providers/settings_provider.dart' show privacyModeProvider;
import '../../budgets/providers/budget_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/color_harmonizer.dart';

class BudgetVsActualCard extends ConsumerWidget {
  const BudgetVsActualCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetVsActualProvider);
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
            padding: const EdgeInsets.all(KuberSpacing.lg),
            child: Text(
              'Budget vs Actual',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const Divider(height: 1),
          budgetsAsync.when(
            loading: () => _buildLoading(context),
            error: (e, _) => const Padding(
              padding: EdgeInsets.all(KuberSpacing.lg),
              child: _EmptyState(message: 'Error loading budgets'),
            ),
            data: (results) {
              // Filter: show top 5 OR budgets >= 60% usage
              final filtered = results.where((r) => r.progress.percentage >= 60).toList();
              final displayList = filtered.length >= 3 ? filtered : results.take(5).toList();

              if (displayList.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(KuberSpacing.lg),
                  child: _EmptyState(message: 'No active budgets'),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(KuberSpacing.lg),
                child: Column(
                  children: displayList.map((r) => _BudgetVsActualRow(result: r)).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: cs.surfaceContainerHigh,
      highlightColor: cs.surfaceContainerLowest,
      child: Container(
        height: 200,
        margin: const EdgeInsets.all(KuberSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
      ),
    );
  }
}

class _BudgetVsActualRow extends ConsumerWidget {
  final ({Budget budget, BudgetProgress progress}) result;
  const _BudgetVsActualRow({required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final budget = result.budget;
    final progress = result.progress;
    final isPrivate = ref.watch(privacyModeProvider);

    final categoryMap = ref.watch(categoryMapProvider).valueOrNull ?? {};
    final category = categoryMap[int.tryParse(budget.categoryId)];

    final Color catColor = category != null
        ? harmonizeCategory(context, Color(category.colorValue))
        : cs.primary;

    Color badgeColor;
    String statusLabel;
    if (progress.percentage >= 100) {
      badgeColor = cs.error;
      statusLabel = 'Exceeded';
    } else if (progress.percentage >= 80) {
      badgeColor = cs.error;
      statusLabel = 'High usage';
    } else if (progress.percentage >= 50) {
      badgeColor = Colors.orange.shade600;
      statusLabel = 'Near limit';
    } else {
      badgeColor = Colors.green.shade600;
      statusLabel = 'On track';
    }

    final remaining = (progress.limit - progress.spent).clamp(0.0, double.infinity);

    return InkWell(
      onTap: () => context.go('/history?categoryId=${budget.categoryId}'),
      borderRadius: BorderRadius.circular(KuberRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                // Category Icon
                Container(
                  padding: const EdgeInsets.all(KuberSpacing.sm),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(KuberRadius.sm),
                  ),
                  child: Icon(
                    category != null ? IconMapper.fromString(category.icon) : Icons.category_outlined,
                    color: catColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: KuberSpacing.md),

                // Main Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category?.name ?? 'Category',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${maskAmount(CurrencyFormatter.format(progress.spent), isPrivate)} ',
                              style: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                            ),
                            TextSpan(
                              text: '/ ${maskAmount(CurrencyFormatter.format(progress.limit), isPrivate)}',
                              style: textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${maskAmount(CurrencyFormatter.format(remaining), isPrivate)} remaining',
                        style: textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Percentage Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    '${progress.percentage.toInt()}%',
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: (progress.percentage / 100).clamp(0.0, 1.0),
                backgroundColor: cs.outline.withValues(alpha: 0.2),
                color: cs.primary, // Static primary color as requested
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                statusLabel,
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
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
      padding: const EdgeInsets.symmetric(vertical: KuberSpacing.xl),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
        ),
      ),
    );
  }
}
