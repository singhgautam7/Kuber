import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../budgets/providers/budget_provider.dart';
import '../../categories/providers/category_provider.dart';

class BudgetSnapshotCard extends ConsumerWidget {
  const BudgetSnapshotCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(budgetSnapshotProvider);
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return snapshotAsync.when(
      loading: () => _buildLoading(context),
      error: (e, _) => const SizedBox.shrink(),
      data: (snapshots) {
        if (snapshots.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget Snapshot',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: KuberSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(KuberSpacing.lg),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: snapshots.asMap().entries.map((entry) {
                  final isLast = entry.key == snapshots.length - 1;
                  return _BudgetRow(snapshot: entry.value, isLast: isLast);
                }).toList(),
              ),
            ),
            const SizedBox(height: KuberSpacing.md),
          ],
        );
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Snapshot',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: cs.onSurface.withValues(alpha: 0.1),
          ),
        ),
        const SizedBox(height: KuberSpacing.sm),
        Shimmer.fromColors(
          baseColor: cs.surfaceContainerHigh,
          highlightColor: cs.surfaceContainerLowest,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(KuberRadius.md),
            ),
          ),
        ),
      ],
    );
  }
}

class _BudgetRow extends ConsumerWidget {
  final ({dynamic budget, dynamic progress}) snapshot;
  final bool isLast;

  const _BudgetRow({required this.snapshot, required this.isLast});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final budget = snapshot.budget;
    final progress = snapshot.progress;

    final categoryMap = ref.watch(categoryMapProvider).valueOrNull ?? {};
    final category = categoryMap[int.tryParse(budget.categoryId)];

    final catColor = category != null
        ? harmonizeCategory(context, Color(category.colorValue))
        : cs.primary;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : KuberSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  category != null ? IconMapper.fromString(category.icon) : Icons.category_outlined,
                  color: catColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: Text(
                  category?.name ?? 'Category',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Text(
                '${progress.percentage.toInt()}% used',
                style: textTheme.labelSmall?.copyWith(
                  color: progress.percentage >= 100 ? cs.error : cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${CurrencyFormatter.format(progress.spent)} / ${CurrencyFormatter.format(progress.limit)}',
                style: textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: (progress.percentage / 100).clamp(0, 1),
              backgroundColor: cs.outline.withValues(alpha: 0.2),
              color: cs.primary, // Static accent color
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}
