import 'package:isar_community/isar.dart';

import 'app_notification.dart';

/// All reads and writes for [AppNotification]. Construct via the provider in
/// `notification_provider.dart`.
class NotificationRepository {
  final Isar isar;
  NotificationRepository(this.isar);

  /// Insert a notification.
  ///
  /// Dedup rule: skip if an entry already exists with the same
  /// `(type, payload, calendar day of createdAt)`. Returns `true` if a row
  /// was inserted, `false` if it was deduped.
  Future<bool> add({
    required NotificationType type,
    required String title,
    required String body,
    String? payload,
    String? iconHint,
    DateTime? createdAt,
  }) async {
    final at = createdAt ?? DateTime.now();
    final dayStart = DateTime(at.year, at.month, at.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final existing = await isar.appNotifications
        .filter()
        .typeEqualTo(type)
        .and()
        .group((q) {
          if (payload == null) {
            return q.payloadIsNull();
          }
          return q.payloadEqualTo(payload);
        })
        .and()
        .createdAtBetween(dayStart, dayEnd, includeUpper: false)
        .findFirst();

    if (existing != null) return false;

    final n = AppNotification()
      ..type = type
      ..title = title
      ..body = body
      ..payload = payload
      ..createdAt = at
      ..iconHint = iconHint;

    await isar.writeTxn(() async {
      await isar.appNotifications.put(n);
    });
    return true;
  }

  Future<int> unreadCount() =>
      isar.appNotifications.filter().readAtIsNull().count();

  /// Watch unread count. Emits the current count immediately and on every
  /// change to the collection.
  Stream<int> unreadCountStream() async* {
    yield await unreadCount();
    await for (final _ in isar.appNotifications.watchLazy(fireImmediately: false)) {
      yield await unreadCount();
    }
  }

  Future<void> markAllRead() async {
    final now = DateTime.now();
    await isar.writeTxn(() async {
      final unread = await isar.appNotifications
          .filter()
          .readAtIsNull()
          .findAll();
      for (final n in unread) {
        n.readAt = now;
      }
      await isar.appNotifications.putAll(unread);
    });
  }

  Future<void> clearAll() async {
    await isar.writeTxn(() async {
      await isar.appNotifications.clear();
    });
  }

  Future<List<AppNotification>> list() =>
      isar.appNotifications.where().sortByCreatedAtDesc().findAll();
}
