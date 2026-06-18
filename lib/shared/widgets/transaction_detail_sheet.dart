import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/attachment_service.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/icon_mapper.dart';
import '../../features/accounts/providers/account_provider.dart';
import '../../features/categories/providers/category_provider.dart';
import '../../features/transactions/data/transaction.dart';
import '../../features/settings/providers/settings_provider.dart' show formatterProvider;
import '../../features/transactions/providers/transaction_provider.dart';
import '../../features/recurring/providers/recurring_provider.dart';
import 'category_icon.dart';
import 'timed_snackbar.dart'; // showKuberSnackBar
import '../../features/tags/providers/tag_providers.dart';
import 'info_table.dart';
import 'kuber_bottom_sheet.dart';
import 'sheet_button_section.dart';

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
    t.isTransfer ? context.l10n.transferDeleted : context.l10n.transactionDeleted,
    actionLabel: context.l10n.undoLabel,
    onAction: () {
      ref.read(transactionListProvider.notifier).restore(t);
      if (pair != null) {
        ref.read(transactionListProvider.notifier).restore(pair);
      }
    },
  );
}

class TransactionDetailSheet extends ConsumerStatefulWidget {
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
  ConsumerState<TransactionDetailSheet> createState() =>
      _TransactionDetailSheetState();
}

class _TransactionDetailSheetState
    extends ConsumerState<TransactionDetailSheet> {
  Transaction get transaction => widget.transaction;

  String _formatDetailDatetime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);
    final timeStr = DateFormatter.time(dt);
    if (d == today) return 'Today • $timeStr';
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday • $timeStr';
    if (dt.year != now.year) return '${DateFormat('d MMM yyyy').format(dt)} • $timeStr';
    return '${DateFormat('EEE, d MMM').format(dt)} • $timeStr';
  }

  /// Derives the human Source label + icon from the transaction's provenance.
  ///
  /// The source is one of six values, decided from stored fields:
  ///  * `importSource == 'sms'` → SMS
  ///  * `linkedRuleType == 'recurring'` → Recurring
  ///  * `linkedRuleType == 'loan'` → Loan
  ///  * `linkedRuleType == 'investment'` → Investment / SIP
  ///  * `linkedRuleType == 'lent' | 'borrowed'` → Lent or Borrowed
  ///  * everything else → Entered by you
  ///
  /// Older auto-created rows may carry a `linkedRuleId` but a null
  /// `linkedRuleType` (the type field was added later). For those we resolve
  /// the id against the recurring rules so they still read as "Recurring".
  ({String label, IconData icon}) _source(BuildContext context) {
    final t = transaction;
    if (t.importSource == 'sms') {
      return (label: context.l10n.sourceSms, icon: Icons.sms_outlined);
    }

    var type = t.linkedRuleType;
    if (type == null && t.linkedRuleId != null) {
      final rules = ref.read(recurringListProvider).valueOrNull ?? const [];
      if (rules.any((r) => r.id.toString() == t.linkedRuleId)) {
        type = 'recurring';
      }
    }

    switch (type) {
      case 'recurring':
        return (label: context.l10n.sourceRecurring, icon: Icons.repeat_rounded);
      case 'loan':
        return (label: context.l10n.sourceLoan, icon: Icons.account_balance_rounded);
      case 'investment':
        return (label: context.l10n.sourceInvestment, icon: Icons.trending_up_rounded);
      case 'lent':
      case 'borrowed':
        return (label: context.l10n.sourceLentBorrowed, icon: Icons.swap_horiz_rounded);
    }
    return (label: context.l10n.sourceManual, icon: Icons.edit_outlined);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isTransfer = transaction.isTransfer;

    final category = ref.watch(categoryListProvider.select(
      (async) => async.whenOrNull(
        data: (cats) => cats.firstWhereOrNull(
          (c) => c.id.toString() == transaction.categoryId,
        ),
      ),
    ));

    final account = ref.watch(allAccountsProvider.select(
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
      final pairAccountId = ref.watch(transactionListProvider.select(
        (async) => async.whenOrNull(
          data: (txns) => txns
              .firstWhereOrNull(
                  (t) => t.transferId == transaction.transferId && t.id != transaction.id)
              ?.accountId,
        ),
      ));
      toAccountName = pairAccountId != null
          ? ref.watch(allAccountsProvider.select(
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
        ? '${fromAccountName ?? context.l10n.unknownLabel} → ${toAccountName ?? context.l10n.unknownLabel}'
        : transaction.name;

    // Account display
    String accountDisplay = account?.name ?? context.l10n.unknownLabel;
    if (account?.last4Digits != null && account!.last4Digits!.isNotEmpty) {
      accountDisplay += ' •••• ${account.last4Digits}';
    }
    final accountIcon = account?.icon != null
        ? IconMapper.fromString(account!.icon!)
        : Icons.account_balance_wallet_rounded;
    final accountColor = account?.colorValue != null
        ? Color(account!.colorValue!)
        : cs.primary;

    final dateLabel = _formatDetailDatetime(transaction.createdAt);
    final source = _source(context);
    final hasSms = transaction.importSource == 'sms' &&
        transaction.importedFromSms != null &&
        transaction.importedFromSms!.isNotEmpty;

    final tags = ref.watch(transactionTagsProvider(transaction.id)).valueOrNull ?? [];

    // ── InfoTable rows ──────────────────────────────────────────────────────
    final rows = <InfoTableRow>[
      InfoTableDataRow(label: context.l10n.dateTimeTitle, value: dateLabel),
      InfoTableDataRow(
        label: context.l10n.accountLabel,
        value: accountDisplay,
        valueLeadingIcon: accountIcon,
        valueIconColor: accountColor,
      ),
      InfoTableDataRow(
        label: context.l10n.categoryLabel,
        value: isTransfer
            ? context.l10n.transferLabel
            : (category?.name ??
                (isIncome ? context.l10n.incomeLabel : context.l10n.noneLabel)),
        valueLeadingIcon: iconData,
        valueIconColor: iconColor,
      ),
      InfoTableDataRow(
        label: context.l10n.sourceLabel,
        value: source.label,
        valueLeadingIcon: source.icon,
        valueIconColor: cs.onSurfaceVariant,
      ),
    ];

    return KuberBottomSheet(
      title: displayName,
      subtitle: (isTransfer
              ? context.l10n.transferLabel
              : (transaction.type == 'income'
                    ? context.l10n.incomeLabel
                    : context.l10n.expenseLabel))
          .toUpperCase(),
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
      actions: SheetButtonSection(
        padding: EdgeInsets.zero,
        actions: [
          SheetAction(
            label: context.l10n.editLabel,
            icon: Icons.edit_outlined,
            onPressed: widget.onEdit,
          ),
          SheetAction(
            label: context.l10n.deleteLabel,
            icon: Icons.delete_outline_rounded,
            destructive: true,
            onPressed: widget.onDelete,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetAmountHero(
            caption: context.l10n.transactionAmount,
            amount: amountText,
            amountColor: amountColor,
          ),
          const SizedBox(height: 18),
          InfoTable(rows: rows),

          // ── Notes ────────────────────────────────────────────────────────
          if (transaction.notes != null && transaction.notes!.isNotEmpty)
            _LabeledBlock(
              label: context.l10n.notesUpper,
              child: Text(
                transaction.notes!,
                style: localeFont(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                  height: 1.5,
                ),
              ),
            ),

          if (transaction.quickAddNote != null &&
              transaction.quickAddNote!.isNotEmpty)
            _LabeledBlock(
              label: context.l10n.addedUsingPrompt,
              child: Text(
                transaction.quickAddNote!,
                style: localeFont(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                  height: 1.5,
                ),
              ),
            ),

          // ── Tags ─────────────────────────────────────────────────────────
          if (tags.isNotEmpty)
            _LabeledBlock(
              label: context.l10n.attachedTags,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in tags)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(KuberRadius.sm),
                        border: Border.all(
                            color: cs.primary.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        '#${tag.name}',
                        style: localeFont(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: cs.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // ── Original SMS ───────────────────────────────────────────────
          if (hasSms)
            _LabeledBlock(
              label: context.l10n.originalSmsLabel,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(KuberSpacing.md),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  border: Border.all(color: cs.outline),
                ),
                child: Text(
                  transaction.importedFromSms!,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    height: 1.55,
                    color: cs.onSurfaceVariant,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ),

          // ── Attachments ────────────────────────────────────────────────
          if (transaction.attachmentPaths.isNotEmpty)
            _LabeledBlock(
              label: context.l10n.attachmentsLabel,
              child: SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: transaction.attachmentPaths.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: KuberSpacing.sm),
                  itemBuilder: (context, index) {
                    final path = transaction.attachmentPaths[index];
                    final isImage =
                        AttachmentService.getFileType(path) == 'image';
                    return GestureDetector(
                      onTap: () => OpenFilex.open(path),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(KuberRadius.md),
                          border: Border.all(color: cs.outline),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: isImage
                            ? Image.file(
                                File(path),
                                fit: BoxFit.cover,
                                width: 64,
                                height: 64,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.broken_image_outlined,
                                  color: cs.onSurfaceVariant,
                                ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.picture_as_pdf,
                                  color: cs.error,
                                  size: 28,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Small uppercase-label block used for Notes / Attachments sections below the
/// info table.
class _LabeledBlock extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledBlock({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: localeFont(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
