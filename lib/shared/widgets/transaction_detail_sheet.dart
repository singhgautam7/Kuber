import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/icon_mapper.dart';
import '../../features/accounts/providers/account_provider.dart';
import '../../features/categories/providers/category_provider.dart';
import '../../features/transactions/data/transaction.dart';
import '../../features/settings/providers/settings_provider.dart' show formatterProvider;
import '../../features/transactions/providers/transaction_provider.dart';
import 'category_icon.dart';
import 'timed_snackbar.dart'; // showKuberSnackBar
import '../../features/tags/providers/tag_providers.dart';
import 'kuber_bottom_sheet.dart';
import 'app_button.dart';

/// Shows the transaction detail bottom sheet with edit/delete actions.
void showTransactionDetailSheet(
  BuildContext context,
  WidgetRef ref,
  Transaction t,
) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => TransactionDetailSheet(
      transaction: t,
      onEdit: () {
        Navigator.of(context, rootNavigator: true).pop();
        context.push('/add-transaction', extra: t);
      },
      onDelete: () {
        Navigator.of(context, rootNavigator: true).pop();
        deleteTransactionWithUndo(context, ref, t);
      },
    ),
  );
}

/// Deletes the transaction and shows an undo snackbar.
void deleteTransactionWithUndo(BuildContext context, WidgetRef ref, Transaction t) {
  // If transfer, find pair BEFORE deleting
  Transaction? pair;
  if (t.isTransfer && t.transferId != null) {
    final allTxns = ref.read(transactionListProvider).valueOrNull ?? [];
    pair = allTxns.firstWhereOrNull(
        (tx) => tx.transferId == t.transferId && tx.id != t.id);
  }

  ref.read(transactionListProvider.notifier).delete(t.id);
  showKuberSnackBar(
    context,
    t.isTransfer ? 'Transfer deleted' : 'Transaction deleted',
    actionLabel: 'UNDO',
    onAction: () {
      ref.read(transactionListProvider.notifier).restore(t);
      if (pair != null) {
        ref.read(transactionListProvider.notifier).restore(pair);
      }
    },
  );
}

class TransactionDetailSheet extends ConsumerWidget {
  final Transaction transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionDetailSheet({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isTransfer = transaction.isTransfer;

    // Only rebuild when THIS specific category/account changes
    final category = ref.watch(categoryListProvider.select(
      (async) => async.whenOrNull(
        data: (cats) => cats.firstWhereOrNull(
          (c) => c.id.toString() == transaction.categoryId,
        ),
      ),
    ));

    final account = ref.watch(accountListProvider.select(
      (async) => async.whenOrNull(
        data: (accs) => accs.firstWhereOrNull(
          (a) => a.id.toString() == transaction.accountId,
        ),
      ),
    ));

    // Transfer-specific lookups
    String? fromAccountName;
    String? toAccountName;
    if (isTransfer) {
      fromAccountName = account?.name;
      // Only extract the paired transaction's accountId
      final pairAccountId = ref.watch(transactionListProvider.select(
        (async) => async.whenOrNull(
          data: (txns) => txns
              .firstWhereOrNull(
                  (t) => t.transferId == transaction.transferId && t.id != transaction.id)
              ?.accountId,
        ),
      ));
      toAccountName = pairAccountId != null
          ? ref.watch(accountListProvider.select(
              (async) => async.whenOrNull(
                data: (accs) => accs.firstWhereOrNull(
                  (a) => a.id.toString() == pairAccountId,
                )?.name,
              ),
            ))
          : null;
    }

    final isIncome = transaction.type == 'income';
    final amountColor = isTransfer
        ? cs.onSurface
        : (isIncome ? cs.tertiary : cs.error);
    
    final formattedAmount = ref.watch(formatterProvider).formatCurrency(transaction.amount);
    final amountText = isTransfer 
        ? formattedAmount 
        : (isIncome ? '+$formattedAmount' : '−$formattedAmount');
    final iconData = isTransfer
        ? Icons.swap_horiz_rounded
        : (category != null
            ? IconMapper.fromString(category.icon)
            : Icons.category);
    final iconColor = isTransfer
        ? const Color(0xFF78909C)
        : (category != null ? Color(category.colorValue) : cs.primary);
    final displayName = isTransfer
        ? '${fromAccountName ?? "Unknown"} → ${toAccountName ?? "Unknown"}'
        : transaction.name;

    // Account display
    String accountDisplay = account?.name ?? 'Unknown';
    if (account?.last4Digits != null && account!.last4Digits!.isNotEmpty) {
      accountDisplay += ' •••• ${account.last4Digits}';
    }

    final dateLabel =
        '${DateFormatter.groupHeader(transaction.createdAt)}, ${DateFormat('d MMM').format(transaction.createdAt)} • ${DateFormatter.time(transaction.createdAt)}';

    return KuberBottomSheet(
      title: displayName,
      subtitle: (isTransfer ? 'TRANSFER' : transaction.type).toUpperCase(),
      leadingIcon: isTransfer
          ? Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, size: 24, color: iconColor),
            )
          : CategoryIcon.square(
              icon: iconData,
              rawColor: iconColor,
              size: 48,
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Amount ────────────────────────────────────────────────────
          Text(
            'TRANSACTION AMOUNT',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: KuberSpacing.xs),
          Text(
            amountText,
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: amountColor,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: KuberSpacing.xl),

          // ── Details Grid ─────────────────────────────────────────────
          _DetailCell(
            label: 'DATE & TIME',
            value: dateLabel.toUpperCase(),
            fullWidth: true,
          ),
          const SizedBox(height: KuberSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DetailCell(
                  label: 'ACCOUNT',
                  value: accountDisplay.toUpperCase(),
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: cs.primary,
                ),
              ),
              const SizedBox(width: KuberSpacing.sm),
              Expanded(
                child: _DetailCell(
                  label: 'CATEGORY',
                  value: transaction.type == 'income' ? 'INCOME' : (category?.name.toUpperCase() ?? 'NONE'),
                  icon: isTransfer ? Icons.swap_horiz_rounded : (category != null ? IconMapper.fromString(category.icon) : Icons.category_rounded),
                  iconColor: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpacing.sm),

          if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
            const SizedBox(height: KuberSpacing.sm),
            _DetailCell(
              label: 'NOTES',
              value: transaction.notes!,
              fullWidth: true,
            ),
          ],

          const SizedBox(height: KuberSpacing.xl),

          // ── Tags ─────────────────────────────────────────────────────
          Consumer(
            builder: (context, ref, _) {
              final tagsAsync = ref.watch(transactionTagsProvider(transaction.id));
              return tagsAsync.when(
                data: (tags) {
                  if (tags.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ATTACHED TAGS',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tags.map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            '#${tag.name}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: cs.primary,
                            ),
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: KuberSpacing.xl),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),

          // ── Actions ──────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Edit',
                  icon: Icons.edit_outlined,
                  type: AppButtonType.normal,
                  onPressed: onEdit,
                ),
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: AppButton(
                  label: 'Delete',
                  icon: Icons.delete_outline_rounded,
                  type: AppButtonType.danger,
                  onPressed: onDelete,
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpacing.xl),
        ],
      ),
    );
  }
}

class _DetailCell extends StatelessWidget {
  final String label;
  final String value;
  final bool fullWidth;
  final IconData? icon;
  final Color? iconColor;

  const _DetailCell({
    required this.label,
    required this.value,
    this.fullWidth = false,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(
        horizontal: KuberSpacing.lg,
        vertical: KuberSpacing.md,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: KuberSpacing.xs),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: iconColor ?? cs.onSurfaceVariant),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                  overflow: fullWidth ? TextOverflow.visible : TextOverflow.ellipsis,
                  maxLines: fullWidth ? null : 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
