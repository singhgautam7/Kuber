import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/info_table.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/sheet_button_section.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart' show formatterProvider;
import '../data/reminder.dart';
import '../providers/reminders_provider.dart';
import 'reminder_row.dart' show reminderCreatedLabel, reminderDueDateTime;
import 'snooze_sheet.dart';

/// Opens the reminder view bottom sheet (screen 2d).
void showReminderViewSheet(BuildContext context, Reminder reminder) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => ReminderViewSheet(reminderId: reminder.id),
  );
}

class ReminderViewSheet extends ConsumerWidget {
  final int reminderId;

  const ReminderViewSheet({super.key, required this.reminderId});

  void _close(BuildContext context) =>
      Navigator.of(context, rootNavigator: true).pop();

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Reminder reminder,
  ) async {
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete reminder?'),
        content: Text('"${reminder.title}" will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(remindersRepositoryProvider).delete(reminder.id);
    if (context.mounted) {
      _close(context);
      showKuberSnackBar(context, 'Reminder deleted');
    }
  }

  void _addAsTransaction(BuildContext context, Reminder reminder) {
    _close(context);
    final params = <String>[
      if (reminder.amount != null)
        'amount=${reminder.amount == reminder.amount!.truncateToDouble() ? reminder.amount!.toInt() : reminder.amount}',
      'name=${Uri.encodeComponent(reminder.title)}',
      if (reminder.categoryId != null) 'categoryId=${reminder.categoryId}',
      'type=${reminder.transactionType ?? 'expense'}',
      'reminderId=${reminder.id}',
    ].join('&');
    context.push('/add-transaction?$params');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final warning = context.kuberMoney.warning;

    // Watch the stream so Mark done / Snooze refresh the open sheet.
    final reminder = ref
        .watch(remindersStreamProvider)
        .valueOrNull
        ?.firstWhereOrNull((r) => r.id == reminderId);
    if (reminder == null) return const SizedBox.shrink();

    final fmt = ref.watch(formatterProvider);
    final category = ref.watch(
      categoryListProvider.select(
        (async) => async.valueOrNull?.firstWhereOrNull(
          (c) => c.id.toString() == reminder.categoryId,
        ),
      ),
    );

    final overdue = reminder.isOverdue;
    final completed = reminder.isCompleted;
    final statusLabel = completed
        ? 'Completed'
        : overdue
        ? 'Overdue'
        : reminder.status == ReminderStatus.snoozed
        ? 'Snoozed'
        : 'Pending';
    final statusColor = completed
        ? context.kuberMoney.income
        : overdue
        ? context.kuberMoney.expense
        : warning;

    final isIncome = reminder.transactionType == 'income';

    return KuberBottomSheet(
      title: reminder.title,
      subtitle: overdue ? 'Reminder · Overdue' : 'Reminder',
      leadingIcon: KuberIconTile(
        icon: Icons.notifications_active_outlined,
        tone: overdue ? KuberTone.error : KuberTone.secondary,
        size: 48,
      ),
      actions: SheetButtonSection(
        padding: EdgeInsets.zero,
        primary: reminder.amount == null
            ? null
            : SheetAction(
                label: 'Add as transaction',
                icon: Icons.add_rounded,
                onPressed: () => _addAsTransaction(context, reminder),
              ),
        actions: [
          SheetAction(
            label: 'Edit',
            icon: Icons.edit_outlined,
            onPressed: () {
              _close(context);
              context.push('/reminders/edit', extra: reminder);
            },
          ),
          SheetAction(
            label: completed ? 'Reopen' : 'Mark done',
            icon: completed ? Icons.replay_rounded : Icons.check_rounded,
            onPressed: () async {
              final repo = ref.read(remindersRepositoryProvider);
              if (completed) {
                await repo.reopen(reminder.id);
              } else {
                await repo.markDone(reminder.id);
              }
            },
          ),
          SheetAction(
            label: 'Snooze',
            icon: Icons.schedule_rounded,
            onPressed: () => SnoozeSheet.show(context, reminder),
          ),
          SheetAction(
            label: 'Delete',
            icon: Icons.delete_outline_rounded,
            destructive: true,
            onPressed: () => _delete(context, ref, reminder),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reminder.amount != null) ...[
            SheetAmountHero(
              caption: 'Amount',
              amount:
                  '${isIncome ? '+' : '−'}${fmt.formatCurrency(reminder.amount!)}',
              amountColor: isIncome
                  ? context.kuberMoney.income
                  : context.kuberMoney.expense,
            ),
            const SizedBox(height: 16),
          ],
          InfoTable(
            rows: [
              // Always a plain "Due date" row (short format). Overdue is
              // signalled by the red Status row below, not here.
              InfoTableDataRow(
                label: 'Due date',
                value: reminderDueDateTime(reminder),
              ),
              InfoTableDataRow(
                label: 'Created on',
                value: reminderCreatedLabel(reminder),
              ),
              if (reminder.repeat != null)
                InfoTableDataRow(
                  label: 'Repeat',
                  value:
                      reminder.repeat![0].toUpperCase() +
                      reminder.repeat!.substring(1),
                  valueLeadingIcon: Icons.repeat_rounded,
                  valueIconColor: cs.primary,
                ),
              if (category != null)
                InfoTableDataRow(label: 'Category', value: category.name),
              InfoTableHighlightRow(
                label: 'Status',
                value: statusLabel,
                valueColor: statusColor,
              ),
            ],
          ),
          if ((reminder.notes ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 18),
            const KuberSectionHeader(title: 'Notes'),
            Text(
              reminder.notes!.trim(),
              style: localeFont(
                fontSize: 14,
                color: cs.onSurface,
                height: 1.55,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
