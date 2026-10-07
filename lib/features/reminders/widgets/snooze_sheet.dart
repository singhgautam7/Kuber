import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../data/reminder.dart';
import '../providers/reminders_provider.dart';

/// Snooze options sheet (screen 2e): 15 minutes / 1 hour / Tomorrow 9:00 AM
/// / Pick a time. Selecting an option applies immediately and dismisses.
class SnoozeSheet extends ConsumerWidget {
  final Reminder reminder;

  const SnoozeSheet({super.key, required this.reminder});

  static void show(BuildContext context, Reminder reminder) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SnoozeSheet(reminder: reminder),
    );
  }

  Future<void> _apply(
    BuildContext context,
    WidgetRef ref,
    DateTime until,
  ) async {
    await ref.read(remindersRepositoryProvider).snooze(reminder.id, until);
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      showKuberSnackBar(
        context,
        'Snoozed until ${DateFormat('d MMM, h:mm a').format(until)}',
      );
    }
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );
    if (time == null || !context.mounted) return;
    await _apply(
      context,
      ref,
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final tomorrow9 = DateTime(now.year, now.month, now.day + 1, 9);

    Widget option(
      IconData icon,
      String label,
      VoidCallback onTap, {
      String? note,
      bool chevron = false,
    }) => KuberListRow(
      leading: KuberIconTile(icon: icon),
      title: label,
      onTap: onTap,
      trailing: chevron
          ? const KuberChevron()
          : note == null
          ? null
          : Text(
              note,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
            ),
    );

    return KuberBottomSheet(
      title: 'Snooze reminder',
      description: reminder.title,
      child: KuberGroup(
        children: [
          option(
            Icons.schedule_rounded,
            '15 minutes',
            () => _apply(context, ref, now.add(const Duration(minutes: 15))),
          ),
          option(
            Icons.schedule_rounded,
            '1 hour',
            () => _apply(context, ref, now.add(const Duration(hours: 1))),
          ),
          option(
            Icons.update_rounded,
            'Tomorrow',
            () => _apply(context, ref, tomorrow9),
            note: '9:00 AM',
          ),
          option(
            Icons.calendar_month_rounded,
            'Pick a time',
            () => _pickTime(context, ref),
            chevron: true,
          ),
        ],
      ),
    );
  }
}
