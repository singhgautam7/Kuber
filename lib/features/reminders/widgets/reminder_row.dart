import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, privacyModeProvider;
import '../data/reminder.dart';

/// Plain due date/time, no overdue phrasing: "Today • 7:00 PM",
/// "Tomorrow • 9:00 AM", "Sat, 5 Jul • 11:00 AM", "5 Jul 2026 • 11:00 AM".
String reminderDueDateTime(Reminder r) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dueDay = DateTime(r.dueAt.year, r.dueAt.month, r.dueAt.day);
  final time = DateFormat('h:mm a').format(r.dueAt);
  if (dueDay == today) return 'Today • $time';
  if (dueDay == today.add(const Duration(days: 1))) return 'Tomorrow • $time';
  if (dueDay == today.subtract(const Duration(days: 1))) {
    return 'Yesterday • $time';
  }
  if (r.dueAt.year == now.year) {
    return '${DateFormat('EEE, d MMM').format(r.dueAt)} • $time';
  }
  return '${DateFormat('d MMM yyyy').format(r.dueAt)} • $time';
}

/// Absolute created timestamp: "5 Jul 2026 • 9:24 AM".
String reminderCreatedLabel(Reminder r) {
  final now = DateTime.now();
  final fmt = r.createdAt.year == now.year
      ? DateFormat('d MMM • h:mm a')
      : DateFormat('d MMM yyyy • h:mm a');
  return fmt.format(r.createdAt);
}

/// Formats a reminder's due time contextually: "Today, 7:00 PM",
/// "Was due 1 Jul, 6:00 PM · 2 days ago", "Sat, 5 Jul · 11:00 AM".
String reminderDueLabel(Reminder r) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dueDay = DateTime(r.dueAt.year, r.dueAt.month, r.dueAt.day);
  final time = DateFormat('h:mm a').format(r.dueAt);

  if (!r.isCompleted && r.dueAt.isBefore(now)) {
    final days = today.difference(dueDay).inDays;
    final when = DateFormat('d MMM').format(r.dueAt);
    final ago = days <= 0
        ? 'earlier today'
        : days == 1
        ? 'yesterday'
        : '$days days ago';
    return 'Was due $when, $time · $ago';
  }
  if (dueDay == today) return 'Today, $time';
  if (dueDay == today.add(const Duration(days: 1))) {
    return 'Tomorrow, $time';
  }
  if (r.dueAt.difference(today).inDays < 7) {
    return '${DateFormat('EEE, d MMM').format(r.dueAt)} · $time';
  }
  return '${DateFormat('d MMM yyyy').format(r.dueAt)} · $time';
}

/// One reminder row (board 3.25): status ring (error for overdue, check
/// when done), title, due line, amount + repeat glyph. Lives inside a
/// [KuberGroup]; completed rows are struck through at 55%.
class ReminderRow extends ConsumerWidget {
  final Reminder reminder;
  final VoidCallback onTap;

  const ReminderRow({super.key, required this.reminder, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final overdue = reminder.isOverdue;
    final completed = reminder.isCompleted;
    final fmt = ref.watch(formatterProvider);
    final isPrivate = ref.watch(privacyModeProvider);

    final amount = reminder.amount;
    final isIncome = reminder.transactionType == 'income';

    final row = KuberListRow(
      onTap: onTap,
      leading: Icon(
        completed
            ? Icons.check_circle_rounded
            : Icons.radio_button_unchecked_rounded,
        size: 24,
        color: completed
            ? cs.primary
            : overdue
            ? cs.error
            : cs.onSurfaceVariant,
      ),
      title: reminder.title,
      titleDecoration: completed ? TextDecoration.lineThrough : null,
      subtitle: completed
          ? 'Completed ${reminder.completedAt == null ? '' : DateFormat('d MMM').format(reminder.completedAt!)}'
          : reminderDueLabel(reminder),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (amount != null)
            Text(
              maskAmount(
                '${isIncome ? '+' : '−'}${fmt.formatCurrency(amount)}',
                isPrivate,
              ),
              style: tt.titleMedium!.copyWith(
                color: isIncome
                    ? context.kuberMoney.income
                    : context.kuberMoney.expense,
              ),
            ),
          if (reminder.repeat != null) ...[
            const SizedBox(width: 6),
            Icon(Icons.repeat_rounded, size: 16, color: cs.onSurfaceVariant),
          ],
        ],
      ),
    );
    return completed ? Opacity(opacity: 0.55, child: row) : row;
  }
}
