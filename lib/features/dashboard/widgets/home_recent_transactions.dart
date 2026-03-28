import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/transaction_detail_sheet.dart';
import '../../../shared/widgets/transaction_list_item.dart';
import '../../categories/providers/category_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';

class HomeRecentTransactionsCard extends ConsumerWidget {
  const HomeRecentTransactionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentTransactionsProvider);
    final categoryMapAsync = ref.watch(categoryMapProvider);
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = cs;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('RECENT TRANSACTIONS',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  )),
              GestureDetector(
                onTap: () => context.go('/history'),
                child: Text('VIEW ALL',
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: colorScheme.primary,
                    )),
              ),
            ],
          ),
        ),
        const SizedBox(height: KuberSpacing.md),
        recentAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (transactions) {
            if (transactions.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(KuberSpacing.xl),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
                ),
                child: Center(
                  child: Text(
                    'No transactions yet',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: KuberSpacing.lg,
                vertical: KuberSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
              ),
              child: categoryMapAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (e, _) => const SizedBox.shrink(),
                data: (categories) => Column(
                  children: transactions.map((t) {
                    final catId = int.tryParse(t.categoryId);
                    final cat = catId != null ? categories[catId] : null;
                    return DashboardTransactionItem(
                      transaction: t,
                      category: cat,
                      onTap: () => showTransactionDetailSheet(
                        context,
                        ref,
                        t,
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
