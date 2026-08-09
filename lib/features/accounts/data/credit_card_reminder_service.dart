import 'package:isar_community/isar.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/utils/monthly_recurrence.dart';
import 'account.dart';

/// Owns OS notification scheduling for credit-card billing reminders (bill
/// generated + payment due), mirroring [RemindersRepository]'s responsibility
/// for reminders. Keeps notification logic out of widgets and providers.
///
/// Recurrence follows the app's "schedule the next occurrence, heal on open"
/// pattern: only the next bill/due date is armed; [onAppOpenMaintenance]
/// re-arms the following month after one fires and heals reboots.
class CreditCardReminderService {
  final Isar isar;
  final NotificationService notifications;

  CreditCardReminderService(this.isar,
      {NotificationService? notificationService})
      : notifications = notificationService ?? NotificationService();

  // Notification id bands, offset high to avoid colliding with reminder ids
  // (raw Isar ids) and budget ids (budget.id * 10 + i). Both stay < 2^31 for
  // realistic account ids (Android notification id is a 32-bit int).
  static const int _billBase = 800000000;
  static const int _dueBase = 810000000;

  /// Local hour of day the reminder fires on its resolved date.
  static const int _notifyHour = 9;

  int billNotifId(int accountId) => _billBase + accountId;
  int dueNotifId(int accountId) => _dueBase + accountId;

  /// Cancels both notifications for [accountId]. Safe no-op if none scheduled.
  Future<void> cancelFor(int accountId) async {
    await notifications.cancel(billNotifId(accountId));
    await notifications.cancel(dueNotifId(accountId));
  }

  /// Cancels then re-schedules both notifications from the account's current
  /// state. A side is left cancelled when its day is unset, its reminder is
  /// off, or the account is not an active credit card.
  Future<void> reschedule(Account a) async {
    await cancelFor(a.id);
    if (!a.isCreditCard || a.isDisabled) return;

    final billDay = a.billGenerationDay;
    if (billDay != null && a.billGenerationReminderEnabled) {
      await notifications.scheduleCreditCardNotification(
        id: billNotifId(a.id),
        title: 'Credit card bill generated',
        body: 'Your ${a.name} statement is generated today.',
        when: _whenFor(billDay),
        payload: 'account:${a.id}',
      );
    }

    final dueDay = a.paymentDueDay;
    if (dueDay != null && a.paymentDueReminderEnabled) {
      await notifications.scheduleCreditCardNotification(
        id: dueNotifId(a.id),
        title: 'Credit card payment due',
        body: 'Your ${a.name} payment is due today.',
        when: _whenFor(dueDay),
        payload: 'account:${a.id}',
      );
    }
  }

  DateTime _whenFor(int day) {
    final d = nextMonthlyOccurrence(day);
    return DateTime(d.year, d.month, d.day, _notifyHour);
  }

  /// On-open maintenance: re-arm reminders for every credit card. Best-effort;
  /// alarms are cheap to re-register.
  Future<void> onAppOpenMaintenance() async {
    final accounts = await isar.accounts.where().findAll();
    for (final a in accounts) {
      if (!a.isCreditCard) continue;
      await reschedule(a);
    }
  }
}
