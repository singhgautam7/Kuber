import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../categories/providers/category_provider.dart';
import '../data/transaction.dart';

class TransactionListItem extends ConsumerWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDismissed;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final categoryMap = ref.watch(categoryMapProvider);
    final isIncome = transaction.type == 'income';

    return categoryMap.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
      data: (categories) {
        final categoryId = int.tryParse(transaction.categoryId);
        final category = categoryId != null ? categories[categoryId] : null;
        final rawColor =
            category != null ? Color(category.colorValue) : colorScheme.outline;
        final harmonized = harmonizeCategory(context, rawColor);
        final icon = category != null
            ? IconMapper.fromString(category.icon)
            : Icons.category;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KuberSpacing.lg,
            vertical: KuberSpacing.xs,
          ),
          child: Dismissible(
            key: ValueKey(transaction.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => onDismissed?.call(),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: KuberSpacing.xl),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.delete, color: colorScheme.onErrorContainer),
            ),
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(KuberSpacing.lg),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                children: [
                  // Category icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: harmonized.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: harmonized),
                  ),
                  const SizedBox(width: KuberSpacing.md),
                  // Name + metadata
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(transaction.name, style: textTheme.bodyLarge),
                        Text(
                          [
                            category?.name ?? 'Unknown',
                            DateFormatter.time(transaction.createdAt),
                          ].join(' · '),
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Amount
                  Text(
                    '${isIncome ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
                    style: textTheme.titleMedium?.copyWith(
                      color:
                          isIncome ? colorScheme.tertiary : colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
        );
      },
    );
  }
}
