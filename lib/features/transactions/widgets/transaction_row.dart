import 'package:flutter/material.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../accounts/data/account.dart';
import '../../categories/data/category.dart';
import '../../history/providers/selection_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../sms_import/widgets/sms_badge.dart';
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final formatter = ref.watch(formatterProvider);
    final isPrivate = ref.watch(privacyModeProvider);
    final isPositive = dayTotal >= 0;
    final totalText = maskAmount(
      isPositive
          ? '+${formatter.formatCurrency(dayTotal)}'
          : '−${formatter.formatCurrency(dayTotal.abs())}',
      isPrivate,
    );
    // Day header = section header (board 3.5): caps label, total trailing.
    return Padding(
      padding: const EdgeInsets.only(
        top: KuberSpace.sm,
        bottom: KuberSpace.sectionHeaderGap,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelMedium?.copyWith(
                letterSpacing: 0.8,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: KuberSpace.sm),
          Text(
            totalText,
            style: textTheme.labelLarge?.copyWith(color: cs.onSurfaceVariant),
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

  final AppFormatter formatter;
  final Map<int, Category> categoryMap;
  final Map<int, Account> accountMap;

  /// Transaction id → the paired transfer leg's accountId. Built once by the
  /// caller (see `buildTransferPairAccountIds`) so rows don't scan the list.
  final Map<int, String> transferPairAccountId;
  final Map<int, List<String>> tagNamesMap;

  const TransactionDayCard({
    super.key,
    required this.transactions,
    required this.onDelete,
    required this.onTap,
    required this.onEdit,
    required this.formatter,
    required this.categoryMap,
    required this.accountMap,
    this.transferPairAccountId = const {},
    this.tagNamesMap = const {},
  });

  @override
  Widget build(BuildContext context) {
    // One grouped list per day, rows divided by 1dp outlineVariant (grouping
    // over boxing, density-audit #1).
    return KuberGroup(
      children: [
        for (int i = 0; i < transactions.length; i++)
          TransactionRow(
            transaction: transactions[i],
            onDelete: () => onDelete(transactions[i]),
            onTap: () => onTap(transactions[i]),
            onEdit: () => onEdit(transactions[i]),
            formatter: formatter,
            category: categoryMap[int.tryParse(transactions[i].categoryId)],
            account: accountMap[int.tryParse(transactions[i].accountId)],
            accountMap: accountMap,
            transferPairAccountId: transferPairAccountId,
            tagNames: tagNamesMap[transactions[i].id] ?? const [],
          ),
      ],
    );
  }
}

class TransactionRow extends ConsumerWidget {
  final Transaction transaction;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final AppFormatter formatter;
  final Category? category;
  final Account? account;
  final Map<int, Account> accountMap;

  /// Transaction id → the paired transfer leg's accountId (O(1) lookup).
  final Map<int, String> transferPairAccountId;
  final List<String> tagNames;

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
    this.transferPairAccountId = const {},
    this.tagNames = const [],
  });

  /// Builds the secondary indicator text showing attachment count and/or tags.
  /// Returns null when there's nothing to show.
  bool _hasIndicator() {
    final hasAttachments = transaction.attachmentPaths.isNotEmpty;
    final hasNotes = transaction.notes?.isNotEmpty == true;
    final hasTags = tagNames.isNotEmpty;
    return hasAttachments || hasNotes || hasTags;
  }

  /// Tags (labelMedium primary) and 20-high badge pills (attachments count,
  /// note), per components/transaction-item.md.
  Widget _buildIndicatorRow(BuildContext context, ThemeData theme) {
    final cs = theme.colorScheme;
    final hasAttachments = transaction.attachmentPaths.isNotEmpty;
    final hasNotes = transaction.notes?.isNotEmpty == true;
    final hasTags = tagNames.isNotEmpty;
    final pillText = theme.textTheme.labelSmall!.copyWith(
      color: cs.onSurfaceVariant,
      height: 1.0,
    );

    Widget pill(IconData icon, [String? count]) => Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: KuberShape.fullR,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: cs.onSurfaceVariant),
          if (count != null) ...[
            const SizedBox(width: 2),
            Text(count, style: pillText),
          ],
        ],
      ),
    );

    final tagText = hasTags
        ? [
            tagNames.take(2).map((t) => '#$t').join(' '),
            if (tagNames.length > 2)
              context.l10n.tagsMoreCount('${tagNames.length - 2}'),
          ].join(' ')
        : null;

    return Row(
      children: [
        if (hasAttachments) ...[
          pill(
            Icons.attach_file_rounded,
            '${transaction.attachmentPaths.length}',
          ),
          const SizedBox(width: 4),
        ],
        if (hasNotes) ...[pill(Icons.notes_rounded), const SizedBox(width: 4)],
        if (tagText != null)
          Flexible(
            child: Text(
              tagText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium!.copyWith(color: cs.primary),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Cache theme lookups — this widget renders per-row in the History list,
    // so five separate Theme.of(context).textTheme walks per row adds up.
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isSelectionMode = ref.watch(isSelectionModeProvider);
    // Watch only this row's membership so toggling one selection rebuilds only
    // the affected row, not every visible row.
    final isSelected = ref.watch(
      transactionSelectionProvider.select((s) => s.contains(transaction.id)),
    );
    final isTransfer = transaction.isTransfer;
    final isAdjustment = transaction.isBalanceAdjustment;

    // Transfer-specific: look up FROM and TO accounts via the precomputed map.
    String? fromName;
    String? toName;
    if (isTransfer) {
      // This is the expense (FROM) leg; the map gives the income (TO) leg's id.
      final pairAccountId = transferPairAccountId[transaction.id];

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
      subtitle = context.l10n.accountCorrectionSubtitle;
      // Income (+) adjustments read green like any other inflow; expense stays
      // neutral.
      amountColor = isIncome ? context.kuberMoney.income : cs.onSurface;
      amountPrefix = isIncome ? '+' : '-';
    } else if (isTransfer) {
      iconData = Icons.swap_horiz_rounded;
      iconColor = cs.onSurfaceVariant;
      displayName =
          '${fromName ?? context.l10n.unknownLabel} → ${toName ?? context.l10n.unknownLabel}';
      subtitle =
          '${context.l10n.transferLabel} · ${toName ?? context.l10n.unknownLabel}';
      amountColor = cs.onSurface;
      amountPrefix = '';
    } else {
      iconData = category != null
          ? IconMapper.fromString(category!.icon)
          : Icons.category;
      iconColor = category != null
          ? harmonizeCategory(context, Color(category!.colorValue))
          : cs.primary;
      displayName = transaction.name;
      subtitle =
          '${category?.name ?? context.l10n.unknownLabel} · ${account?.name ?? context.l10n.unknownLabel}';
      amountColor = isIncome
          ? context.kuberMoney.income
          : context.kuberMoney.expense;
      amountPrefix = isIncome ? '+' : '-';
    }

    final swipeMode = ref.watch(
      settingsProvider.select(
        (async) => async.valueOrNull?.swipeMode ?? SwipeMode.changeTabs,
      ),
    );

    final hasIndicator = _hasIndicator();
    final Widget lead = isSelectionMode && isSelected
        ? Container(
            key: const ValueKey('check'),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: cs.onPrimary, size: 22),
          )
        : (isTransfer || isAdjustment)
        ? Container(
            key: const ValueKey('neutral'),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: cs.onSurfaceVariant, size: 22),
          )
        : CategoryIcon.square(
            key: const ValueKey('icon'),
            icon: iconData,
            rawColor: iconColor,
          );

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: isSelected ? cs.secondaryContainer : Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isSelectionMode) {
            ref
                .read(transactionSelectionProvider.notifier)
                .toggle(transaction.id);
          } else {
            onTap();
          }
        },
        onLongPress: () {
          ref
              .read(transactionSelectionProvider.notifier)
              .toggle(transaction.id);
        },
        child: Container(
          constraints: BoxConstraints(
            minHeight: hasIndicator
                ? KuberSpace.listItem3
                : KuberSpace.listItem2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: KuberSpace.listRowPadH,
            vertical: KuberSpace.listRowPadV,
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: lead,
              ),
              const SizedBox(width: KuberSpace.lg),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: textTheme.titleMedium?.copyWith(
                              color: isSelected
                                  ? cs.onSecondaryContainer
                                  : cs.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (transaction.importSource == 'sms') ...[
                          const SizedBox(width: 6),
                          SmsBadge(
                            onTap: transaction.importedFromSms == null
                                ? null
                                : () => showRawSmsSheet(
                                    context,
                                    rawSms: transaction.importedFromSms!,
                                  ),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            subtitle,
                            style: textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? cs.onSecondaryContainer
                                  : cs.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isAdjustment) ...[
                          const SizedBox(width: 6),
                          Container(
                            height: 20,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: KuberShape.fullR,
                              border: Border.all(color: cs.outlineVariant),
                            ),
                            child: Text(
                              context.l10n.adjustmentLabel,
                              style: textTheme.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (hasIndicator) ...[
                      const SizedBox(height: 2),
                      _buildIndicatorRow(context, theme),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: KuberSpace.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    maskAmount(
                      '$amountPrefix${formatter.formatCurrency(transaction.amount)}',
                      ref.watch(privacyModeProvider),
                    ),
                    style: textTheme.titleMedium?.copyWith(color: amountColor),
                  ),
                  Text(
                    DateFormatter.time(transaction.createdAt),
                    style: textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? cs.onSecondaryContainer
                          : cs.onSurfaceVariant,
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
          padding: const EdgeInsets.only(left: KuberSpace.xl),
          color: cs.secondaryContainer,
          child: Icon(Icons.edit_outlined, color: cs.onSecondaryContainer),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: KuberSpace.xl),
          color: cs.errorContainer,
          child: Icon(Icons.delete_outline, color: cs.onErrorContainer),
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
