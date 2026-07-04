import 'package:isar_community/isar.dart';

import '../../../core/services/notification_service.dart';
import '../../notifications/data/app_notification.dart';
import '../../notifications/data/notification_repository.dart';
import 'reminder.dart';

/// All reads/writes and lifecycle logic for [Reminder]s: persistence, system
/// notification scheduling, inbox mirroring, repeat advancement and the
/// 7-day completed cleanup.
class RemindersRepository {
  final Isar isar;
  final NotificationService notifications;

  RemindersRepository(this.isar, {NotificationService? notificationService})
      : notifications = notificationService ?? NotificationService();

  Stream<List<Reminder>> watchAll() =>
      isar.reminders.where().watch(fireImmediately: true);

  Future<List<Reminder>> getAll() => isar.reminders.where().findAll();

  Future<Reminder?> getById(int id) => isar.reminders.get(id);

  /// Creates or updates a reminder and (re)schedules its notification.
  Future<Reminder> save(Reminder reminder) async {
    reminder.updatedAt = DateTime.now();
    await isar.writeTxn(() async {
      reminder.id = await isar.reminders.put(reminder);
    });
    await _reschedule(reminder);
    return reminder;
  }

  Future<void> delete(int id) async {
    await notifications.cancel(id);
    await isar.writeTxn(() => isar.reminders.delete(id));
  }

  /// Mark done. Repeating reminders roll to the next occurrence and stay
  /// pending; non-repeating go to completed (7-day retention).
  Future<void> markDone(int id) async {
    final reminder = await isar.reminders.get(id);
    if (reminder == null) return;
    if (reminder.repeat != null) {
      reminder
        ..dueAt = nextOccurrence(reminder.dueAt, reminder.repeat!)
        ..status = ReminderStatus.pending
        ..updatedAt = DateTime.now();
    } else {
      reminder
        ..status = ReminderStatus.completed
        ..completedAt = DateTime.now()
        ..updatedAt = DateTime.now();
    }
    await isar.writeTxn(() => isar.reminders.put(reminder));
    await _reschedule(reminder);
  }

  /// Reopen a completed reminder (status back to pending, due time kept).
  Future<void> reopen(int id) async {
    final reminder = await isar.reminders.get(id);
    if (reminder == null) return;
    reminder
      ..status = ReminderStatus.pending
      ..completedAt = null
      ..updatedAt = DateTime.now();
    await isar.writeTxn(() => isar.reminders.put(reminder));
    await _reschedule(reminder);
  }

  /// Snooze to [until]: moves dueAt, marks snoozed, reschedules.
  Future<void> snooze(int id, DateTime until) async {
    final reminder = await isar.reminders.get(id);
    if (reminder == null) return;
    reminder
      ..dueAt = until
      ..status = ReminderStatus.snoozed
      ..updatedAt = DateTime.now();
    await isar.writeTxn(() => isar.reminders.put(reminder));
    await _reschedule(reminder);
  }

  /// Next occurrence for a repeat schedule, always in the future.
  static DateTime nextOccurrence(DateTime from, String repeat) {
    var next = from;
    final now = DateTime.now();
    do {
      next = switch (repeat) {
        ReminderRepeat.daily => next.add(const Duration(days: 1)),
        ReminderRepeat.weekly => next.add(const Duration(days: 7)),
        ReminderRepeat.monthly =>
          DateTime(next.year, next.month + 1, next.day, next.hour, next.minute),
        ReminderRepeat.yearly =>
          DateTime(next.year + 1, next.month, next.day, next.hour, next.minute),
        _ => next.add(const Duration(days: 1)),
      };
    } while (!next.isAfter(now));
    return next;
  }

  Future<void> _reschedule(Reminder reminder) async {
    await notifications.cancel(reminder.id);
    if (reminder.isCompleted) return;
    if (!reminder.dueAt.isAfter(DateTime.now())) return;
    await notifications.scheduleReminderNotification(
      id: reminder.id,
      title: reminder.title,
      body: _notificationBody(reminder),
      when: reminder.dueAt,
      payload: 'reminder:${reminder.id}',
    );
  }

  String _notificationBody(Reminder reminder) {
    final parts = <String>[];
    if (reminder.amount != null) {
      parts.add('₹${_plain(reminder.amount!)} due now');
    }
    final notes = reminder.notes?.trim() ?? '';
    if (notes.isNotEmpty) {
      parts.add(notes.length > 80 ? '${notes.substring(0, 80)}…' : notes);
    }
    return parts.isEmpty ? 'Reminder due now' : parts.join(' · ');
  }

  String _plain(double v) => v == v.truncateToDouble()
      ? v.toInt().toString()
      : v.toStringAsFixed(2);

  /// On-open maintenance (post-first-frame, best effort):
  ///  1. Deletes completed reminders older than 7 days.
  ///  2. Mirrors due reminders into the in-app notification inbox (deduped
  ///     per reminder per day by the inbox repository).
  ///  3. Re-registers system notifications for upcoming reminders (alarms
  ///     are cheap to re-register and this heals missed reboots).
  Future<void> onAppOpenMaintenance() async {
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(days: 7));
    final all = await getAll();

    final expiredIds = all
        .where((r) =>
            r.isCompleted &&
            r.completedAt != null &&
            r.completedAt!.isBefore(cutoff))
        .map((r) => r.id)
        .toList();
    if (expiredIds.isNotEmpty) {
      await isar.writeTxn(() => isar.reminders.deleteAll(expiredIds));
    }

    final inbox = NotificationRepository(isar);
    for (final r in all) {
      if (expiredIds.contains(r.id) || r.isCompleted) continue;
      if (r.dueAt.isAfter(now)) {
        await _reschedule(r);
      } else {
        await inbox.add(
          type: NotificationType.reminderTrigger,
          title: 'Reminder due',
          body: r.amount != null
              ? '${r.title} · ₹${_plain(r.amount!)} · tap to open'
              : '${r.title} · tap to open',
          payload: 'reminder:${r.id}',
        );
      }
    }
  }
}
