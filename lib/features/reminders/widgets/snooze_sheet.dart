import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
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
      BuildContext context, WidgetRef ref, DateTime until) async {
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

    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Snooze reminder',
                    style: localeFont(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reminder.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: localeFont(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
              child: Column(
                children: [
                  _SnoozeOption(
                    icon: Icons.schedule_rounded,
                    label: '15 minutes',
                    onTap: () => _apply(context, ref,
                        now.add(const Duration(minutes: 15))),
                  ),
                  _SnoozeOption(
                    icon: Icons.schedule_rounded,
                    label: '1 hour',
                    onTap: () =>
                        _apply(context, ref, now.add(const Duration(hours: 1))),
                  ),
                  _SnoozeOption(
                    icon: Icons.update_rounded,
                    label: 'Tomorrow',
                    trailing: '9:00 AM',
                    onTap: () => _apply(context, ref, tomorrow9),
                  ),
                  _SnoozeOption(
                    icon: Icons.calendar_month_rounded,
                    label: 'Pick a time',
                    chevron: true,
                    onTap: () => _pickTime(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SnoozeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final bool chevron;
  final VoidCallback onTap;

  const _SnoozeOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.chevron = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cs.outline),
          ),
          child: Row(
            children: [
              Icon(icon, size: 19, color: cs.primary),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  label,
                  style: localeFont(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: localeFont(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              if (chevron)
                Icon(Icons.chevron_right_rounded,
                    size: 16,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}
