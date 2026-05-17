import 'package:isar_community/isar.dart';

import '../../notifications/data/app_notification.dart';
import '../../notifications/data/notification_repository.dart';
import 'ledger.dart';

/// Surfaces lend/borrow reminders for ledgers whose `expectedDate` has
/// arrived (or already passed) and which haven't been marked settled.
///
/// Writes one [AppNotification] per ledger per calendar day (deduped). The
/// batched on-open run is in-app only; per the plan the OS notification
/// fires only on the day the reminder is genuinely "new" — which is exactly
/// what the dedupe in the repo gives us, so we fire OS in [checkAll] only
/// when the insert returns true.
class LedgerReminderProcessor {
  final Isar isar;
  final NotificationRepository notificationRepo;

  /// Optional OS notification callback. Pass-through to avoid coupling this
  /// processor to NotificationService — `main.dart` wires it.
  final Future<void> Function({
    required NotificationType type,
    required int id,
    required String title,
    required String body,
    String? payload,
  })? showOs;

  LedgerReminderProcessor({
    required this.isar,
    required this.notificationRepo,
    this.showOs,
  });

  Future<int> checkAll() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final dueLedgers = await isar.ledgers
        .filter()
        .isSettledEqualTo(false)
        .expectedDateIsNotNull()
        .findAll();

    int fired = 0;

    for (final l in dueLedgers) {
      final expected = l.expectedDate!;
      final expectedDay = DateTime(expected.year, expected.month, expected.day);
      if (expectedDay.isAfter(today)) continue;

      final isLent = l.type == 'lent';
      final title = isLent ? 'Money to collect' : 'Money to repay';
      final daysOverdue = today.difference(expectedDay).inDays;
      final body = daysOverdue == 0
          ? '${l.personName} — due today'
          : daysOverdue == 1
              ? '${l.personName} — 1 day overdue'
              : '${l.personName} — $daysOverdue days overdue';

      final payload = 'ledger:${l.uid}';
      final inserted = await notificationRepo.add(
        type: NotificationType.ledgerReminder,
        title: title,
        body: body,
        payload: payload,
      );

      if (inserted) {
        fired++;
        if (showOs != null) {
          await showOs!(
            type: NotificationType.ledgerReminder,
            id: l.id,
            title: title,
            body: body,
            payload: payload,
          );
        }
      }
    }

    return fired;
  }
}
