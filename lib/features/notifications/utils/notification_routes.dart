import '../data/app_notification.dart';

/// Where a notification tap goes: a [page] (GoRouter location) and, when the
/// notification names an item, that item's [kind] + [id] so its view sheet
/// opens on top.
class NotificationRoute {
  final String page;
  final String? kind;
  final String? id;

  const NotificationRoute(this.page, {this.kind, this.id});

  bool get hasItem => kind != null && id != null && id!.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      other is NotificationRoute &&
      other.page == page &&
      other.kind == kind &&
      other.id == id;

  @override
  int get hashCode => Object.hash(page, kind, id);

  @override
  String toString() => 'NotificationRoute($page, $kind, $id)';
}

/// Payload kind (`"<kind>:<id>"`) -> page. Every payload the app writes, in
/// the inbox (AppNotification.payload) or on an OS notification.
const kNotificationKindPages = <String, String>{
  'budget': '/more/budgets',
  'loan': '/more/loans',
  'recurring': '/more/recurring',
  'investment': '/more/investments',
  'ledger': '/more/ledger',
  'reminder': '/more/reminders',
  'account': '/more/accounts', // credit-card bill / payment-due reminders
  'backup': '/more/data/automatic-backups', // id is a failure reason
};

/// Kinds whose id is not an item (no sheet to open).
const _pageOnlyKinds = {'backup'};

/// Page for notifications without a usable payload (older rows), by type.
const kNotificationTypePages = <NotificationType, String>{
  NotificationType.general: '/',
  NotificationType.budgetAlert: '/more/budgets',
  NotificationType.recurringTransaction: '/more/recurring',
  NotificationType.loanEmi: '/more/loans',
  NotificationType.ledgerReminder: '/more/ledger',
  NotificationType.backup: '/more/data/automatic-backups',
  NotificationType.reminderTrigger: '/more/reminders',
};

/// The single routing map for in-app and system notification taps.
NotificationRoute resolveNotificationRoute(
  String? payload, {
  NotificationType? type,
}) {
  final fallback = NotificationRoute(kNotificationTypePages[type] ?? '/');
  if (payload == null || payload.isEmpty) return fallback;
  // Export notifications carry the saved file's path.
  if (payload.startsWith('/')) return const NotificationRoute('/more/data');
  // Background tasks notification: the queue's page (no item sheet).
  if (payload == 'background:backup') {
    return const NotificationRoute('/more/data/automatic-backups');
  }
  if (payload.startsWith('background:')) {
    return const NotificationRoute('/more/recurring');
  }

  final sep = payload.indexOf(':');
  if (sep <= 0) return fallback;
  final kind = payload.substring(0, sep);
  final id = payload.substring(sep + 1);
  final page = kNotificationKindPages[kind];
  if (page == null) return fallback;
  if (_pageOnlyKinds.contains(kind) || id.isEmpty) {
    return NotificationRoute(page);
  }
  return NotificationRoute(page, kind: kind, id: id);
}
