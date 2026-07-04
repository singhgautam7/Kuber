import 'package:isar_community/isar.dart';

import 'reminders_repository.dart';

/// Processes a reminder notification action ("Mark done" / "Snooze 1 hour").
/// Wired from `main.dart` for both live taps and cold-start action launches.
Future<void> handleReminderNotificationAction(
  Isar isar,
  String actionId,
  String payload,
) async {
  if (!payload.startsWith('reminder:')) return;
  final id = int.tryParse(payload.substring('reminder:'.length));
  if (id == null) return;

  final repo = RemindersRepository(isar);
  switch (actionId) {
    case 'reminder_mark_done':
      await repo.markDone(id);
      break;
    case 'reminder_snooze_1h':
      await repo.snooze(id, DateTime.now().add(const Duration(hours: 1)));
      break;
  }
}
