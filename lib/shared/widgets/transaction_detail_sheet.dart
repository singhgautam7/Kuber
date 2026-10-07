import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../../core/utils/color_harmonizer.dart';
import 'app_button.dart';
import 'kuber_chips.dart';
import 'kuber_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import '../../features/notes/providers/notes_provider.dart';
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
    if (t.sourceNoteId != null) {
      return (
        label: 'Added from Kuber Notes',
        icon: Icons.sticky_note_2_outlined,
      );
    }
    if (t.importSource == 'sms') {
      return (label: context.l10n.sourceSms, icon: Icons.sms_outlined);
    }
    // Quick Add / Ask Kuber provenance. English literals, matching the
    // Kuber Notes label above (these are English-only features). The original
    // typed / spoken text is stored in `quickAddNote` and renders in the
    // "ADDED USING PROMPT" block below, mirroring how the SMS body is shown.
    if (t.importSource == 'quick_add') {
      return (label: 'Quick Add', icon: Icons.flash_on_rounded);
    }
    if (t.importSource == 'ask_kuber') {
      return (label: 'Ask Kuber', icon: Icons.auto_awesome_rounded);
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

  /// Opens the source note in the editor, or falls back to a snackbar when
  /// the note has been deleted.
  Future<void> _openSourceNote() async {
    final id = int.tryParse(transaction.sourceNoteId ?? '');
    final note = id == null
        ? null
        : await ref.read(notesRepositoryProvider).getById(id);
    if (!mounted) return;
    if (note == null) {
      showKuberSnackBar(context, 'This note was deleted.');
      return;
    }
    Navigator.of(context, rootNavigator: true).pop();
    context.push('/notes/editor?id=${note.id}');
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
        : (isIncome ? context.kuberMoney.income : context.kuberMoney.expense);

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
        ? cs.onSurfaceVariant
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
        valueIconColor: harmonizeCategory(context, accountColor),
      ),
      InfoTableDataRow(
        label: context.l10n.categoryLabel,
        value: isTransfer
            ? context.l10n.transferLabel
            : (category?.name ??
                (isIncome ? context.l10n.incomeLabel : context.l10n.noneLabel)),
        valueLeadingIcon: iconData,
        valueIconColor: isTransfer
            ? cs.onSurfaceVariant
            : harmonizeCategory(context, iconColor),
      ),
      if (transaction.sourceNoteId != null)
        InfoTableDataRow(
          label: context.l10n.sourceLabel,
          value: source.label,
          valueLeadingIcon: source.icon,
          valueIconColor: cs.primary,
          valueColor: cs.primary,
          tappable: true,
          onTap: _openSourceNote,
        )
      else
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
                color: cs.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, size: 24, color: cs.onSurfaceVariant),
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
          const SizedBox(height: KuberSpace.xl - 4),
          InfoTable(rows: rows),

          // ── "View note" (Kuber Notes provenance, per 1m) ─────────────────
          if (transaction.sourceNoteId != null) ...[
            const SizedBox(height: KuberSpace.xl - 4),
            _ViewSourceNoteButton(
              sourceNoteId: transaction.sourceNoteId!,
              onTap: _openSourceNote,
            ),
          ],

          // ── Notes ────────────────────────────────────────────────────────
          if (transaction.notes != null && transaction.notes!.isNotEmpty)
            _LabeledBlock(
              label: context.l10n.notesUpper,
              child: Text(
                transaction.notes!,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: cs.onSurface),
              ),
            ),

          if (transaction.quickAddNote != null &&
              transaction.quickAddNote!.isNotEmpty)
            _LabeledBlock(
              label: context.l10n.addedUsingPrompt,
              child: Text(
                transaction.quickAddNote!,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: cs.onSurface),
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
                    KuberChip(label: '#${tag.name}', icon: Icons.sell_outlined),
                ],
              ),
            ),

          // ── Original SMS ───────────────────────────────────────────────
          if (hasSms)
            _LabeledBlock(
              label: context.l10n.originalSmsLabel,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: KuberSpace.lg, vertical: KuberSpace.md),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: KuberShape.mediumR,
                ),
                child: Text(
                  transaction.importedFromSms!,
                  style: monoFont(
                    fontSize: 12,
                    height: 19 / 12,
                    color: cs.onSurfaceVariant,
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
                      const SizedBox(width: KuberSpace.sm),
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
                          borderRadius: KuberShape.mediumR,
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

/// Bordered full-width "View note: "title"" button below the info table for
/// transactions created from Kuber Notes (per 1m).
class _ViewSourceNoteButton extends ConsumerWidget {
  final String sourceNoteId;
  final VoidCallback onTap;

  const _ViewSourceNoteButton({
    required this.sourceNoteId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = int.tryParse(sourceNoteId);
    return FutureBuilder(
      future: id == null
          ? Future.value(null)
          : ref.read(notesRepositoryProvider).getById(id),
      builder: (context, snapshot) {
        final note = snapshot.data;
        final label = note == null
            ? 'View note'
            : 'View note: "${note.title.isEmpty ? 'Untitled note' : note.title}"';
        return AppButton(
          label: label,
          icon: Icons.sticky_note_2_outlined,
          type: AppButtonType.outline,
          height: 40,
          fullWidth: true,
          onPressed: onTap,
        );
      },
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
    return Padding(
      padding: const EdgeInsets.only(top: KuberSpace.xl - 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KuberSectionHeader(title: label),
          child,
        ],
      ),
    );
  }
}
