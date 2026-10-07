import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/kuber_skeleton.dart';
import '../../../shared/widgets/kuber_progress.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../settings/providers/settings_provider.dart';
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

    return snapshotAsync.when(
      loading: () => _buildLoading(context),
      error: (e, _) => const SizedBox.shrink(),
      data: (snapshots) {
        if (snapshots.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: KuberSpace.sectionGap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KuberHomeWidgetTitle(title: context.l10n.budgetSnapshot),
              // Budgets as a grouped list (board 3.2a).
              KuberGroup(
                children: [for (final s in snapshots) _BudgetRow(snapshot: s)],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpace.sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KuberHomeWidgetTitle(title: context.l10n.budgetSnapshot),
          const KuberSkeleton(
            height: 180,
            borderRadius: KuberShape.largeIncreased,
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final budget = snapshot.budget;
    final progress = snapshot.progress;
    final isPrivate = ref.watch(privacyModeProvider);
    final fmt = ref.watch(formatterProvider);

    final categoryMap = ref.watch(categoryMapProvider).valueOrNull ?? {};
    final category = categoryMap[int.tryParse(budget.categoryId)];

    // Thresholds and labels unchanged; colours from the progress tokens.
    // High usage (80-99) moves from red to the near-limit style (open
    // decision 7); only 100%+ uses the over-limit style.
    final KuberProgressState state;
    String statusLabel;
    if (progress.percentage >= 100) {
      state = KuberProgressState.overLimit;
      statusLabel = context.l10n.budgetExceeded;
    } else if (progress.percentage >= 80) {
      state = KuberProgressState.nearLimit;
      statusLabel = context.l10n.budgetHighUsage;
    } else if (progress.percentage >= 50) {
      state = KuberProgressState.nearLimit;
      statusLabel = context.l10n.budgetNearLimit;
    } else {
      state = KuberProgressState.normal;
      statusLabel = context.l10n.budgetOnTrack;
    }
    final (pillBg, pillFg) = kuberProgressChipColors(context, state);

    final remaining = (progress.limit - progress.spent).clamp(
      0.0,
      double.infinity,
    );

    return InkWell(
      onTap: category == null
          ? null
          : () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,
                backgroundColor: Colors.transparent,
                builder: (context) =>
                    BudgetDetailsSheet(budgetId: budget.id, category: category),
              );
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                category != null
                    ? CategoryIcon.square(
                        icon: IconMapper.fromString(category.icon),
                        rawColor: Color(category.colorValue),
                      )
                    : const KuberIconTile(
                        icon: Icons.category_outlined,
                        tone: KuberTone.neutral,
                      ),
                const SizedBox(width: KuberSpace.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category?.name ?? context.l10n.categoryLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        '${maskAmount(fmt.formatCurrency(progress.spent), isPrivate)} / '
                        '${maskAmount(fmt.formatCurrency(progress.limit), isPrivate)} · '
                        '${context.l10n.budgetRemaining(maskAmount(fmt.formatCurrency(remaining), isPrivate))}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: KuberSpace.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: pillBg,
                    borderRadius: KuberShape.fullR,
                  ),
                  child: Text(
                    '${progress.percentage.toInt()}% · $statusLabel',
                    style: textTheme.labelMedium?.copyWith(color: pillFg),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            KuberLinearProgress(
              value: (progress.percentage / 100).clamp(0.0, 1.0),
              state: state,
            ),
          ],
        ),
      ),
    );
  }
}
