import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../accounts/data/account.dart';
import '../../categories/data/category.dart';
import '../../settings/providers/settings_provider.dart';
import '../data/transaction.dart';

class DateGroupHeader extends ConsumerWidget {
  final String label;
  final double dayTotal;

  const DateGroupHeader({
    super.key,
    required this.label,
    required this.dayTotal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final isPositive = dayTotal >= 0;
    final totalText = isPositive
        ? '+${formatter.formatCurrency(dayTotal)}'
        : '−${formatter.formatCurrency(dayTotal.abs())}';
    final totalColor = isPositive ? cs.tertiary : cs.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(
        top: KuberSpacing.lg,
        bottom: KuberSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
          ),
          const SizedBox(width: KuberSpacing.sm),
          Expanded(
            child: Container(
              height: 0.5,
              color: cs.outline,
            ),
          ),
          const SizedBox(width: KuberSpacing.sm),
          Text(
            totalText,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: totalColor,
                ),
          ),
        ],
      ),
    );
  }
}

class TransactionDayCard extends StatelessWidget {
  final List<Transaction> transactions;
  final void Function(Transaction) onDelete;
  final void Function(Transaction) onTap;
  final void Function(Transaction) onEdit;

  final dynamic formatter;
  final Map<int, Category> categoryMap;
  final Map<int, Account> accountMap;
  final List<Transaction> transactionList;

  const TransactionDayCard({
    super.key,
    required this.transactions,
    required this.onDelete,
    required this.onTap,
    required this.onEdit,
    required this.formatter,
    required this.categoryMap,
    required this.accountMap,
    required this.transactionList,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < transactions.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          TransactionRow(
            transaction: transactions[i],
            onDelete: () => onDelete(transactions[i]),
            onTap: () => onTap(transactions[i]),
            onEdit: () => onEdit(transactions[i]),
            formatter: formatter,
            category: categoryMap[int.tryParse(transactions[i].categoryId)],
            account: accountMap[int.tryParse(transactions[i].accountId)],
            accountMap: accountMap,
            transactionList: transactionList,
          ),
        ],
      ],
    );
  }
}

class TransactionRow extends ConsumerWidget {
  final Transaction transaction;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final dynamic formatter;
  final Category? category;
  final Account? account;
  final Map<int, Account> accountMap;
  final List<Transaction> transactionList;

  const TransactionRow({
    super.key,
    required this.transaction,
    required this.onDelete,
    required this.onTap,
    required this.onEdit,
    required this.formatter,
    this.category,
    this.account,
    required this.accountMap,
    required this.transactionList,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isTransfer = transaction.isTransfer;
    final isAdjustment = transaction.isBalanceAdjustment;

    // Transfer-specific: look up FROM and TO accounts
    String? fromName;
    String? toName;
    if (isTransfer) {
      // This is the expense (FROM) leg. Find the income (TO) leg by transferId.
      final pairAccountId = transactionList
          .firstWhereOrNull((t) =>
              t.transferId == transaction.transferId && t.id != transaction.id)
          ?.accountId;

      fromName = accountMap[int.tryParse(transaction.accountId)]?.name;
      toName = pairAccountId != null
          ? accountMap[int.tryParse(pairAccountId)]?.name
          : null;
    }

    final isIncome = transaction.type == 'income';

    // Adjustment-specific styling
    final IconData iconData;
    final Color iconColor;
    final String displayName;
    final String subtitle;
    final Color amountColor;
    final String amountPrefix;

    if (isAdjustment) {
      iconData = Icons.account_balance_rounded;
      iconColor = cs.onSurfaceVariant;
      displayName = transaction.name;
      subtitle = 'Account correction · excluded from analytics';
      amountColor = cs.onSurface;
      amountPrefix = isIncome ? '+' : '-';
    } else if (isTransfer) {
      iconData = Icons.swap_horiz_rounded;
      iconColor = const Color(0xFF78909C);
      displayName = '${fromName ?? "Unknown"} → ${toName ?? "Unknown"}';
      subtitle = 'Transfer · ${toName ?? "Unknown"}';
      amountColor = cs.onSurface;
      amountPrefix = '';
    } else {
      iconData = category != null
          ? IconMapper.fromString(category!.icon)
          : Icons.category;
      iconColor = category != null ? Color(category!.colorValue) : cs.primary;
      displayName = transaction.name;
      subtitle =
          '${category?.name ?? "Unknown"} · ${account?.name ?? "Unknown"}';
      amountColor = isIncome ? cs.tertiary : cs.onSurface;
      amountPrefix = isIncome ? '+' : '-';
    }

    final swipeMode = ref.watch(settingsProvider.select(
      (async) => async.valueOrNull?.swipeMode ?? SwipeMode.changeTabs,
    ));

    final content = Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KuberSpacing.lg,
            vertical: KuberSpacing.md,
          ),
          child: Row(
            children: [
              CategoryIcon.square(
                icon: iconData,
                rawColor: iconColor,
                size: 42,
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            subtitle,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: cs.onSurfaceVariant,
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isAdjustment) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHigh,
                              borderRadius:
                                  BorderRadius.circular(KuberRadius.sm),
                              border: Border.all(
                                color: cs.outline.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              'ADJUSTMENT',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurfaceVariant,
                                    letterSpacing: 0.5,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: KuberSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$amountPrefix${formatter.formatCurrency(transaction.amount)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: amountColor,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormatter.time(transaction.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (swipeMode == SwipeMode.performActions) {
      return Dismissible(
        key: ValueKey(transaction.id),
        direction: DismissDirection.horizontal,
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: KuberSpacing.xl),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
          child: Icon(Icons.edit_outlined, color: cs.primary),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: KuberSpacing.xl),
          decoration: BoxDecoration(
            color: cs.error.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
          child: Icon(Icons.delete_outline, color: cs.error),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            onDelete();
            return true;
          } else {
            onEdit();
            return false;
          }
        },
        child: content,
      );
    }

    return content;
  }
}
