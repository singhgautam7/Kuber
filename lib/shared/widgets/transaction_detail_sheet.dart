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
import '../../features/transactions/providers/transaction_provider.dart';
import 'category_icon.dart';
import 'timed_snackbar.dart';

/// Shows the transaction detail bottom sheet with edit/delete actions.
void showTransactionDetailSheet(
  BuildContext context,
  WidgetRef ref,
  Transaction t,
) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: KuberColors.surfaceCard,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
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
  ref.read(transactionListProvider.notifier).delete(t.id);
  final label = t.type == 'transfer' ? 'Deleted transfer' : 'Deleted "${t.name}"';
  showTimedSnackBar(
    context,
    message: label,
    duration: const Duration(seconds: 5),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        final restored = Transaction()
          ..name = t.name
          ..amount = t.amount
          ..type = t.type
          ..categoryId = t.categoryId
          ..accountId = t.accountId
          ..fromAccountId = t.fromAccountId
          ..toAccountId = t.toAccountId
          ..notes = t.notes
          ..createdAt = t.createdAt
          ..updatedAt = t.updatedAt
          ..nameLower = t.nameLower;
        ref.read(transactionListProvider.notifier).restore(restored);
      },
    ),
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
    final categoriesAsync = ref.watch(categoryListProvider);
    final accountsAsync = ref.watch(accountListProvider);
    final isTransfer = transaction.type == 'transfer';

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
      fromAccountName = accs
          .where((a) => a.id.toString() == transaction.fromAccountId)
          .firstOrNull
          ?.name;
      toAccountName = accs
          .where((a) => a.id.toString() == transaction.toAccountId)
          .firstOrNull
          ?.name;
    }

    final isIncome = transaction.type == 'income';
    final amountColor = isTransfer
        ? KuberColors.textPrimary
        : (isIncome ? KuberColors.income : KuberColors.expense);
    final amountPrefix = isTransfer ? '₹' : (isIncome ? '+₹' : '−₹');
    final iconData = isTransfer
        ? Icons.swap_horiz_rounded
        : (category != null
            ? IconMapper.fromString(category.icon)
            : Icons.category);
    final iconColor = isTransfer
        ? const Color(0xFF78909C)
        : (category != null ? Color(category.colorValue) : KuberColors.primary);
    final categoryName = category?.name ?? 'Unknown';
    final accountName = account?.name ?? 'Unknown';
    final displayName = isTransfer
        ? '${fromAccountName ?? "Unknown"} → ${toAccountName ?? "Unknown"}'
        : transaction.name;

    final dateLabel =
        '${DateFormatter.groupHeader(transaction.createdAt)}, ${DateFormat('d MMM').format(transaction.createdAt)} • ${DateFormatter.time(transaction.createdAt)}';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(KuberSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: KuberColors.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: KuberSpacing.xl),

            // Icon
            if (isTransfer)
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, size: 30, color: iconColor),
              )
            else
              CategoryIcon.circle(
                icon: iconData,
                rawColor: iconColor,
                size: 64,
              ),
            const SizedBox(height: KuberSpacing.lg),

            // Transaction name
            Text(
              displayName,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: KuberColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: KuberSpacing.sm),

            // Amount
            Text(
              '$amountPrefix${transaction.amount.toStringAsFixed(2)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: amountColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: KuberSpacing.xs),

            // Date & time
            Text(
              dateLabel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: KuberColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: KuberSpacing.xl),

            // Detail rows
            if (isTransfer) ...[
              // From Account
              DetailRow(
                icon: Icons.arrow_upward_rounded,
                label: 'From Account',
                trailing: Text(
                  fromAccountName ?? 'Unknown',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: KuberColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: KuberSpacing.sm),
              // To Account
              DetailRow(
                icon: Icons.arrow_downward_rounded,
                label: 'To Account',
                trailing: Text(
                  toAccountName ?? 'Unknown',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: KuberColors.textPrimary,
                  ),
                ),
              ),
            ] else ...[
              // Category
              DetailRow(
                icon: Icons.category_rounded,
                label: 'Category',
                trailing: Text(
                  categoryName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: KuberColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: KuberSpacing.sm),
              // Account
              DetailRow(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Account',
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      accountName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: KuberColors.textPrimary,
                      ),
                    ),
                    if (account?.last4Digits != null &&
                        account!.last4Digits!.isNotEmpty)
                      Text(
                        'ENDING IN ${account.last4Digits}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: KuberColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ],

            // Notes
            if (transaction.notes != null &&
                transaction.notes!.isNotEmpty) ...[
              const SizedBox(height: KuberSpacing.sm),
              DetailRow(
                icon: Icons.notes_rounded,
                label: 'Notes',
                trailing: const SizedBox.shrink(),
                subtitle: Text(
                  transaction.notes!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: KuberColors.textSecondary,
                  ),
                ),
              ),
            ],

            const SizedBox(height: KuberSpacing.xl),

            // Edit button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(
                  'Edit Transaction',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: KuberColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: KuberSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: KuberSpacing.sm),

            // Delete button
            TextButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: Text(
                'Delete Transaction',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: KuberColors.expense,
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final Widget? subtitle;

  const DetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.trailing,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KuberSpacing.lg,
        vertical: KuberSpacing.md,
      ),
      decoration: BoxDecoration(
        color: KuberColors.surfaceElement,
        borderRadius: BorderRadius.circular(16),
      ),
      child: subtitle != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: KuberColors.textSecondary),
                    const SizedBox(width: KuberSpacing.sm),
                    Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: KuberColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.sm),
                subtitle!,
              ],
            )
          : Row(
              children: [
                Icon(icon, size: 18, color: KuberColors.textSecondary),
                const SizedBox(width: KuberSpacing.sm),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: KuberColors.textSecondary,
                  ),
                ),
                const Spacer(),
                trailing,
              ],
            ),
    );
  }
}
