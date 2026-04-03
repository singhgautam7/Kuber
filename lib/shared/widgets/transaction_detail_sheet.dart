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
    final categoriesAsync = ref.watch(categoryListProvider);
    final accountsAsync = ref.watch(accountListProvider);
    final isTransfer = transaction.isTransfer;

    final category = categoriesAsync.whenOrNull(
      data: (cats) {
        try {
          return cats.firstWhere(
            (c) => c.id.toString() == transaction.categoryId,
          );
        } catch (_) {
          return null;
        }
      },
    );

    final account = accountsAsync.whenOrNull(
      data: (accs) {
        try {
          return accs.firstWhere(
            (a) => a.id.toString() == transaction.accountId,
          );
        } catch (_) {
          return null;
        }
      },
    );

    // Transfer-specific lookups
    String? fromAccountName;
    String? toAccountName;
    if (isTransfer) {
      final accs = accountsAsync.valueOrNull ?? [];
      fromAccountName = account?.name;
      // Find TO leg by transferId
      final allTxns = ref.watch(transactionListProvider).valueOrNull ?? [];
      final pair = allTxns.firstWhereOrNull(
          (t) => t.transferId == transaction.transferId && t.id != transaction.id);
      toAccountName = pair != null
          ? accs.firstWhereOrNull((a) => a.id.toString() == pair.accountId)?.name
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
      subtitle: 'TRANSACTION DETAIL',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isTransfer)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, size: 24, color: iconColor),
                )
              else
                CategoryIcon.square(
                  icon: iconData,
                  rawColor: iconColor,
                  size: 48,
                ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'TRANSACTION DETAIL',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpacing.xl),

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
          Row(
            children: [
              Expanded(
                child: _DetailCell(
                  label: 'DATE & TIME',
                  value: dateLabel.toUpperCase(),
                ),
              ),
              const SizedBox(width: KuberSpacing.sm),
              Expanded(
                child: _DetailCell(
                  label: 'ACCOUNT',
                  value: accountDisplay.toUpperCase(),
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _DetailCell(
                  label: 'TYPE',
                  value: isTransfer ? 'TRANSFER' : transaction.type.toUpperCase(),
                  valueColor: amountColor,
                ),
              ),
              const SizedBox(width: KuberSpacing.sm),
              Expanded(
                child: _DetailCell(
                  label: 'CATEGORY',
                  value: transaction.type == 'income' ? 'INCOME' : (category?.name.toUpperCase() ?? 'NONE'),
                ),
              ),
            ],
          ),

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
  final Color? valueColor;
  final bool fullWidth;

  const _DetailCell({
    required this.label,
    required this.value,
    this.valueColor,
    this.fullWidth = false,
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
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? cs.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: fullWidth ? 3 : 1,
          ),
        ],
      ),
    );
  }
}
