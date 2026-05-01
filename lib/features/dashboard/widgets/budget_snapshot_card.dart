import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../budgets/data/budget.dart';
import '../../budgets/providers/budget_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../budgets/widgets/budget_details_sheet.dart';
import '../../../shared/widgets/kuber_home_widget_title.dart';

class BudgetSnapshotCard extends ConsumerWidget {
  const BudgetSnapshotCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(budgetSnapshotProvider);
    final cs = Theme.of(context).colorScheme;

    return snapshotAsync.when(
      loading: () => _buildLoading(context),
      error: (e, _) => const SizedBox.shrink(),
      data: (snapshots) {
        if (snapshots.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: KuberSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const KuberHomeWidgetTitle(title: 'BUDGET SNAPSHOT'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(KuberSpacing.md),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: snapshots.map((s) => _BudgetRow(snapshot: s)).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KuberHomeWidgetTitle(title: 'BUDGET SNAPSHOT'),
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
      ),
    );
  }
}

class _BudgetRow extends ConsumerWidget {
  final ({Budget budget, BudgetProgress progress}) snapshot;

  const _BudgetRow({required this.snapshot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final budget = snapshot.budget;
    final progress = snapshot.progress;
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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: category == null ? null : () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          backgroundColor: Colors.transparent,
          builder: (context) => BudgetDetailsSheet(
            budgetId: budget.id,
            category: category,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            Row(
            children: [
              // Category Icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(KuberRadius.sm),
                ),
                child: Icon(
                  category != null ? IconMapper.fromString(category.icon) : Icons.category_outlined,
                  color: catColor,
                  size: 16,
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
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 1),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${maskAmount(CurrencyFormatter.format(progress.spent), isPrivate)} ',
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                              fontSize: 11,
                            ),
                          ),
                          TextSpan(
                            text: '/ ${maskAmount(CurrencyFormatter.format(progress.limit), isPrivate)}',
                            style: textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${maskAmount(CurrencyFormatter.format(remaining), isPrivate)} remaining',
                      style: textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Percentage Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
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
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: (progress.percentage / 100).clamp(0.0, 1.0),
              backgroundColor: cs.outline.withValues(alpha: 0.2),
              color: cs.primary, 
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              statusLabel,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
                fontSize: 9,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
