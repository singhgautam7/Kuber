import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../features/accounts/providers/account_provider.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/icon_mapper.dart';
import '../../features/categories/data/category.dart';
import '../../features/transactions/data/transaction.dart';
import '../../features/transactions/providers/transaction_provider.dart';
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
    final isTransfer = transaction.isTransfer;

    // Transfer-specific: resolve FROM and TO account names
    IconData iconData;
    Color iconColor;
    String displayName;
    String subtitle;
    Color amountColor;
    String amountPrefix;

    if (isTransfer) {
      // Only extract the paired transaction's accountId — avoids rebuilding on every transaction change
      final pairAccountId = ref.watch(transactionListProvider.select(
        (async) => async.whenOrNull(
          data: (txns) => txns
              .firstWhereOrNull(
                  (t) => t.transferId == transaction.transferId && t.id != transaction.id)
              ?.accountId,
        ),
      ));
      final accs = ref.watch(accountListProvider).valueOrNull ?? [];
      final fromName = accs
          .where((a) => a.id.toString() == transaction.accountId)
          .firstOrNull
          ?.name;
      final toName = pairAccountId != null
          ? accs.where((a) => a.id.toString() == pairAccountId).firstOrNull?.name
          : null;

      iconData = Icons.swap_horiz_rounded;
      iconColor = const Color(0xFF78909C);
      displayName = '${fromName ?? "Unknown"} → ${toName ?? "Unknown"}';
      subtitle = 'Transfer · ${DateFormatter.relativeTime(transaction.createdAt)}';
      amountColor = colorScheme.onSurface;
      amountPrefix = '';
    } else {
      final rawColor =
          category != null ? Color(category!.colorValue) : colorScheme.outline;
      iconData = category != null
          ? IconMapper.fromString(category!.icon)
          : Icons.category;
      iconColor = rawColor;
      displayName = transaction.name;
      subtitle = [
        category?.name ?? 'Unknown',
        if (accountName != null) accountName,
        DateFormatter.relativeTime(transaction.createdAt),
      ].join(' · ');
      amountColor = isIncome ? colorScheme.tertiary : colorScheme.onSurface;
      amountPrefix = isIncome ? '+' : '';
    }

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
            icon: iconData,
            rawColor: iconColor,
            size: 44,
          ),
          const SizedBox(width: KuberSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$amountPrefix${ref.watch(formatterProvider).formatCurrency(transaction.amount)}',
            style: textTheme.titleMedium?.copyWith(
              color: amountColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
    );
  }
}
