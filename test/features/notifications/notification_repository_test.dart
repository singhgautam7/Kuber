import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/features/notifications/data/app_notification.dart';
import 'package:kuber/features/notifications/data/notification_repository.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late NotificationRepository repo;

  setUpAll(initialiseIsarForTests);

  setUp(() async {
    isar = await openTestIsar();
    repo = NotificationRepository(isar);
  });

  tearDown(() async {
    await closeAndCleanIsar(isar);
  });

  group('NotificationRepository.add — dedup', () {
    test('inserts on first add', () async {
      final ok = await repo.add(
        type: NotificationType.budgetAlert,
        title: 'Budget',
        body: 'Crossed',
        payload: 'budget:42',
      );
      expect(ok, isTrue);
      expect(await isar.appNotifications.count(), 1);
    });

    test('skips duplicate same calendar day', () async {
      final now = DateTime(2026, 5, 17, 9, 0);
      await repo.add(
        type: NotificationType.budgetAlert,
        title: 'Budget',
        body: 'Crossed',
        payload: 'budget:42',
        createdAt: now,
      );

      final second = await repo.add(
        type: NotificationType.budgetAlert,
        title: 'Budget',
        body: 'Crossed again',
        payload: 'budget:42',
        createdAt: now.add(const Duration(hours: 6)),
      );
      expect(second, isFalse);
      expect(await isar.appNotifications.count(), 1);
    });

    test('allows duplicate on next calendar day', () async {
      final day1 = DateTime(2026, 5, 17, 23, 0);
      await repo.add(
        type: NotificationType.budgetAlert,
        title: 'Budget',
        body: 'Crossed',
        payload: 'budget:42',
        createdAt: day1,
      );

      final day2 = DateTime(2026, 5, 18, 1, 0);
      final ok = await repo.add(
        type: NotificationType.budgetAlert,
        title: 'Budget',
        body: 'Crossed again',
        payload: 'budget:42',
        createdAt: day2,
      );
      expect(ok, isTrue);
      expect(await isar.appNotifications.count(), 2);
    });

    test('different type with same payload is not deduped', () async {
      final at = DateTime(2026, 5, 17, 9, 0);
      await repo.add(
        type: NotificationType.budgetAlert,
        title: 'A',
        body: 'B',
        payload: 'x:1',
        createdAt: at,
      );
      final ok = await repo.add(
        type: NotificationType.recurringTransaction,
        title: 'A',
        body: 'B',
        payload: 'x:1',
        createdAt: at,
      );
      expect(ok, isTrue);
      expect(await isar.appNotifications.count(), 2);
    });

    test('different payload with same type is not deduped', () async {
      final at = DateTime(2026, 5, 17, 9, 0);
      await repo.add(
        type: NotificationType.loanEmi,
        title: 'A',
        body: 'B',
        payload: 'loan:1',
        createdAt: at,
      );
      final ok = await repo.add(
        type: NotificationType.loanEmi,
        title: 'A',
        body: 'B',
        payload: 'loan:2',
        createdAt: at,
      );
      expect(ok, isTrue);
      expect(await isar.appNotifications.count(), 2);
    });

    test('null payload deduplicates against null payload only', () async {
      final at = DateTime(2026, 5, 17, 9, 0);
      await repo.add(
        type: NotificationType.general,
        title: 'A',
        body: 'B',
        createdAt: at,
      );
      final dupe = await repo.add(
        type: NotificationType.general,
        title: 'Different',
        body: 'Body',
        createdAt: at,
      );
      expect(dupe, isFalse);
    });

    test('backup failures deduplicate by payload on same day', () async {
      final at = DateTime(2026, 5, 17, 9, 0);
      await repo.add(
        type: NotificationType.backup,
        title: 'Automatic backup failed',
        body: 'Folder revoked',
        payload: 'backup:folder_revoked',
        createdAt: at,
      );

      final dupe = await repo.add(
        type: NotificationType.backup,
        title: 'Automatic backup failed',
        body: 'Folder revoked again',
        payload: 'backup:folder_revoked',
        createdAt: at.add(const Duration(hours: 2)),
      );
      final differentReason = await repo.add(
        type: NotificationType.backup,
        title: 'Automatic backup failed',
        body: 'Disk full',
        payload: 'backup:disk_full',
        createdAt: at.add(const Duration(hours: 3)),
      );

      expect(dupe, isFalse);
      expect(differentReason, isTrue);
      expect(await isar.appNotifications.count(), 2);
    });
  });

  group('NotificationRepository — read/write helpers', () {
    test('unreadCount + markAllRead', () async {
      await repo.add(type: NotificationType.general, title: 'A', body: 'B');
      await repo.add(
        type: NotificationType.budgetAlert,
        title: 'C',
        body: 'D',
        payload: 'budget:1',
      );
      expect(await repo.unreadCount(), 2);

      await repo.markAllRead();
      expect(await repo.unreadCount(), 0);
    });

    test('clearAll empties the collection', () async {
      await repo.add(type: NotificationType.general, title: 'A', body: 'B');
      await repo.clearAll();
      expect(await isar.appNotifications.count(), 0);
    });

    test('list returns newest-first', () async {
      final older = DateTime(2026, 5, 16, 9);
      final newer = DateTime(2026, 5, 17, 9);
      await repo.add(
        type: NotificationType.general,
        title: 'old',
        body: 'b',
        createdAt: older,
      );
      await repo.add(
        type: NotificationType.general,
        title: 'new',
        body: 'b',
        payload: 'x:1',
        createdAt: newer,
      );
      final list = await repo.list();
      expect(list.first.title, 'new');
      expect(list.last.title, 'old');
    });
  });
}
