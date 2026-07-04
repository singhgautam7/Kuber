import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/locale_font.dart';
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

/// One reminder card in the landing list (screen 2a). Overdue cards get a
/// red-tinted border and red due-label.
class ReminderRow extends ConsumerWidget {
  final Reminder reminder;
  final VoidCallback onTap;

  const ReminderRow({super.key, required this.reminder, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final overdue = reminder.isOverdue;
    final completed = reminder.isCompleted;
    final fmt = ref.watch(formatterProvider);
    final isPrivate = ref.watch(privacyModeProvider);

    final amount = reminder.amount;
    final isIncome = reminder.transactionType == 'income';

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: completed ? 0.6 : 1,
        child: Container(
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            // Overdue is signalled by the red section title + red due label,
            // not a red card border.
            border: Border.all(color: cs.outline),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: localeFont(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        decoration:
                            completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      completed
                          ? 'Completed ${reminder.completedAt == null ? '' : DateFormat('d MMM').format(reminder.completedAt!)}'
                          : reminderDueLabel(reminder),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: localeFont(
                        fontSize: 11.5,
                        color: overdue ? cs.error : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (amount != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      maskAmount(
                        '${isIncome ? '+' : '−'}${fmt.formatCurrency(amount)}',
                        isPrivate,
                      ),
                      style: localeFont(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isIncome ? cs.tertiary : cs.error,
                      ),
                    ),
                    if (reminder.repeat != null) ...[
                      const SizedBox(height: 3),
                      _RepeatPill(label: reminder.repeat!.toUpperCase()),
                    ],
                  ],
                )
              else if (reminder.repeat != null)
                _RepeatPill(label: reminder.repeat!.toUpperCase())
              else
                Icon(Icons.chevron_right_rounded,
                    size: 17, color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RepeatPill extends StatelessWidget {
  final String label;

  const _RepeatPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(KuberRadius.sm),
        border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: localeFont(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: cs.primary,
        ),
      ),
    );
  }
}
