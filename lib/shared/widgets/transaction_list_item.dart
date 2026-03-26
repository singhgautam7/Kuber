import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/icon_mapper.dart';
import '../../features/categories/data/category.dart';
import '../../features/transactions/data/transaction.dart';
import 'category_icon.dart';

/// Simplified transaction list item for dashboard use.
/// Takes resolved Transaction + Category directly (no Consumer/Dismissible).
class DashboardTransactionItem extends ConsumerWidget {
  final Transaction transaction;
  final Category? category;
  final String? accountName;
  final VoidCallback? onTap;

  const DashboardTransactionItem({
    super.key,
    required this.transaction,
    this.category,
    this.accountName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isIncome = transaction.type == 'income';

    final rawColor =
        category != null ? Color(category!.colorValue) : colorScheme.outline;
    final icon = category != null
        ? IconMapper.fromString(category!.icon)
        : Icons.category;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
      padding: const EdgeInsets.symmetric(
        vertical: KuberSpacing.sm,
      ),
      child: Row(
        children: [
          CategoryIcon.square(
            icon: icon,
            rawColor: rawColor,
            size: 44,
          ),
          const SizedBox(width: KuberSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.name,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    category?.name ?? 'Unknown',
                    if (accountName != null) accountName,
                    DateFormatter.relativeTime(transaction.createdAt),
                  ].join(' · '),
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : ''}${ref.watch(formatterProvider).formatCurrency(transaction.amount)}',
            style: textTheme.titleMedium?.copyWith(
              color: isIncome ? colorScheme.tertiary : colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
    );
  }
}
