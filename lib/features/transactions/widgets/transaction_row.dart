import 'package:flutter/material.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
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
    final isPrivate = ref.watch(privacyModeProvider);
    final isPositive = dayTotal >= 0;
    final totalText = maskAmount(
      isPositive
          ? '+${formatter.formatCurrency(dayTotal)}'
          : '−${formatter.formatCurrency(dayTotal.abs())}',
      isPrivate,
    );
    final totalColor = isPositive ? cs.tertiary : cs.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(
        top: KuberSpacing.sm,
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
            transferPairAccountId: transferPairAccountId,
            tagNames: tagNamesMap[transactions[i].id] ?? const [],
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

  /// Builds a styled TextSpan with tags in accent color and attachment/notes chips.
  InlineSpan _buildIndicatorSpan(BuildContext context, ColorScheme cs) {
    final hasAttachments = transaction.attachmentPaths.isNotEmpty;
    final hasNotes = transaction.notes?.isNotEmpty == true;
    final hasTags = tagNames.isNotEmpty;
    const goldColor = Color(0xFFD4A017);
    final blueColor = cs.primary;
    final baseStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: cs.onSurfaceVariant,
    );
    final tagStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: cs.primary,
    );

    final spans = <InlineSpan>[];

    if (hasAttachments) {
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Container(
          height: 16,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: goldColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: goldColor.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.attach_file_rounded, size: 11, color: goldColor),
              const SizedBox(width: 2),
              Text(
                '${transaction.attachmentPaths.length}',
                style: const TextStyle(
                  fontSize: 10,
                  height: 1.0,
                  fontWeight: FontWeight.w600,
                  color: goldColor,
                ),
              ),
            ],
          ),
        ),
      ));
    }

    if (hasAttachments && hasNotes) {
      spans.add(const WidgetSpan(child: SizedBox(width: 4)));
    }

    if (hasNotes) {
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Container(
          height: 16,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: blueColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: blueColor.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.notes_rounded, size: 11, color: blueColor),
            ],
          ),
        ),
      ));
    }

    if ((hasAttachments || hasNotes) && hasTags) {
      spans.add(TextSpan(text: '  \u00B7  ', style: baseStyle));
    }

    if (hasTags) {
      final visible = tagNames.take(2).map((t) => '#$t').join(' ');
      spans.add(TextSpan(text: visible, style: tagStyle));
      final remaining = tagNames.length - 2;
      if (remaining > 0) {
        spans.add(TextSpan(
            text: ' ${context.l10n.tagsMoreCount('$remaining')}',
            style: baseStyle));
      }
    }

    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
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
      amountColor = cs.onSurface;
      amountPrefix = isIncome ? '+' : '-';
    } else if (isTransfer) {
      iconData = Icons.swap_horiz_rounded;
      iconColor = const Color(0xFF78909C);
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
      amountColor = isIncome ? cs.tertiary : cs.onSurface;
      amountPrefix = isIncome ? '+' : '-';
    }

    final swipeMode = ref.watch(settingsProvider.select(
      (async) => async.valueOrNull?.swipeMode ?? SwipeMode.changeTabs,
    ));

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? cs.primary.withValues(alpha: 0.2) : cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(
          color: isSelected ? cs.primary.withValues(alpha: 0.4) : cs.outline,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (isSelectionMode) {
            ref.read(transactionSelectionProvider.notifier).toggle(transaction.id);
          } else {
            onTap();
          }
        },
        onLongPress: () {
          ref.read(transactionSelectionProvider.notifier).toggle(transaction.id);
        },
        borderRadius: BorderRadius.circular(KuberRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KuberSpacing.lg,
            vertical: KuberSpacing.md,
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isSelectionMode
                    ? Container(
                        key: const ValueKey('checkbox'),
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? cs.primary.withValues(alpha: 0.15) 
                              : cs.onSurfaceVariant.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(KuberRadius.md),
                        ),
                        child: isSelected 
                            ? Icon(
                                Icons.check_rounded,
                                color: cs.primary,
                                size: 24,
                              )
                            : null,
                      )
                    : CategoryIcon.square(
                        key: const ValueKey('icon'),
                        icon: iconData,
                        rawColor: iconColor,
                        size: 42,
                      ),
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
                              context.l10n.adjustmentLabel,
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
                    if (_hasIndicator()) ...[
                      const SizedBox(height: 2),
                      Text.rich(
                        _buildIndicatorSpan(context, cs),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: KuberSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    maskAmount('$amountPrefix${formatter.formatCurrency(transaction.amount)}', ref.watch(privacyModeProvider)),
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
