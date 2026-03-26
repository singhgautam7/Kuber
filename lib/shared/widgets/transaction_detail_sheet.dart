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

/// Shows the transaction detail bottom sheet with edit/delete actions.
void showTransactionDetailSheet(
  BuildContext context,
  WidgetRef ref,
  Transaction t,
) {
  final cs = Theme.of(context).colorScheme;
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: cs.surfaceContainer,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
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
  showKuberSnackBar(
    context,
    label,
    actionLabel: 'Undo',
    onAction: () {
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
    final categoryName = category?.name ?? 'Unknown';
    final displayName = isTransfer
        ? '${fromAccountName ?? "Unknown"} → ${toAccountName ?? "Unknown"}'
        : transaction.name;

    // Account display with last4Digits
    String accountDisplay = account?.name ?? 'Unknown';
    if (account?.last4Digits != null && account!.last4Digits!.isNotEmpty) {
      accountDisplay += ' •••• ${account.last4Digits}';
    }

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
                color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: KuberSpacing.xl),

            // Header row: icon + name + close
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
                GestureDetector(
                  onTap: () => Navigator.of(context, rootNavigator: true).pop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KuberSpacing.xl),

            // Amount label
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'AMOUNT',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: KuberSpacing.xs),

            // Amount value
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                amountText,
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: amountColor,
                ),
              ),
            ),
            const SizedBox(height: KuberSpacing.xl),

            // 2×2 detail grid
            if (isTransfer) ...[
              Row(
                children: [
                  Expanded(
                    child: _DetailCell(
                      label: 'FROM ACCOUNT',
                      value: fromAccountName ?? 'Unknown',
                    ),
                  ),
                  const SizedBox(width: KuberSpacing.sm),
                  Expanded(
                    child: _DetailCell(
                      label: 'TO ACCOUNT',
                      value: toAccountName ?? 'Unknown',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: KuberSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: _DetailCell(
                  label: 'DATE & TIME',
                  value: dateLabel,
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: _DetailCell(
                      label: 'CATEGORY',
                      value: categoryName,
                    ),
                  ),
                  const SizedBox(width: KuberSpacing.sm),
                  Expanded(
                    child: _DetailCell(
                      label: 'ACCOUNT',
                      value: accountDisplay,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: KuberSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: _DetailCell(
                  label: 'DATE & TIME',
                  value: dateLabel,
                ),
              ),
            ],

            // Tags (full-width row)
            ref.watch(transactionTagsProvider(transaction.id)).when(
                  data: (tags) {
                    if (tags.isEmpty) return const SizedBox.shrink();
                    return Column(
                      children: [
                        const SizedBox(height: KuberSpacing.sm),
                        SizedBox(
                          width: double.infinity,
                          child: Container(
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
                                  'TAGS',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurfaceVariant,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: KuberSpacing.sm),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: tags.map((tag) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: cs.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: cs.primary.withValues(alpha: 0.2),
                                        ),
                                      ),
                                      child: Text(
                                        '#${tag.name}',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: cs.primary,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

            // Notes (full-width row)
            if (transaction.notes != null &&
                transaction.notes!.isNotEmpty) ...[
              const SizedBox(height: KuberSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: _DetailCell(
                  label: 'NOTES',
                  value: transaction.notes!,
                ),
              ),
            ],

            const SizedBox(height: KuberSpacing.xl),

            // Edit button (muted/outlined)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(
                  'Edit Transaction',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.onSurface,
                  side: BorderSide(color: cs.outline),
                  padding:
                      const EdgeInsets.symmetric(vertical: KuberSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(KuberRadius.md),
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
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: cs.error,
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class _DetailCell extends StatelessWidget {
  final String label;
  final String value;

  const _DetailCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
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
              color: cs.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
