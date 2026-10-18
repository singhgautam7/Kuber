import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/features/budgets/data/budget.dart';
import 'package:kuber/features/categories/data/category.dart';
import 'package:kuber/features/notifications/data/app_notification.dart';
import 'package:kuber/features/notifications/utils/deep_link_handler.dart';
import 'package:kuber/features/notifications/utils/notification_routes.dart';
import 'package:kuber/features/recurring/data/recurring_rule.dart';

import '../../helpers/isar_test_helper.dart';
import '../../helpers/test_factories.dart';

void main() {
  group('resolveNotificationRoute', () {
    test('every payload kind the app writes', () {
      const cases = <String, NotificationRoute>{
        'budget:3': NotificationRoute('/more/budgets', kind: 'budget', id: '3'),
        'loan:abc': NotificationRoute('/more/loans', kind: 'loan', id: 'abc'),
        'recurring:42':
            NotificationRoute('/more/recurring', kind: 'recurring', id: '42'),
        'investment:inv_1': NotificationRoute('/more/investments',
            kind: 'investment', id: 'inv_1'),
        'ledger:l_1': NotificationRoute('/more/ledger', kind: 'ledger', id: 'l_1'),
        'reminder:7':
            NotificationRoute('/more/reminders', kind: 'reminder', id: '7'),
        'account:2':
            NotificationRoute('/more/accounts', kind: 'account', id: '2'),
        'backup:diskFull': NotificationRoute('/more/data/automatic-backups'),
        '/storage/emulated/0/Download/kuber.csv':
            NotificationRoute('/more/data'),
      };
      cases.forEach((payload, expected) {
        expect(resolveNotificationRoute(payload), expected, reason: payload);
      });
    });

    test('ids containing ":" stay intact', () {
      expect(resolveNotificationRoute('loan:a:b').id, 'a:b');
    });

    test('missing id (old rows) opens the type page only', () {
      for (final type in NotificationType.values) {
        final r = resolveNotificationRoute(null, type: type);
        expect(r.hasItem, isFalse);
        expect(r.page, kNotificationTypePages[type], reason: type.name);
      }
      expect(resolveNotificationRoute('recurring:', type: NotificationType.recurringTransaction),
          const NotificationRoute('/more/recurring'));
    });

    test('every notification type has a page', () {
      expect(kNotificationTypePages.keys.toSet(),
          NotificationType.values.toSet());
    });

    test('unknown payload falls back to the type page, else Home', () {
      expect(resolveNotificationRoute('weird', type: NotificationType.loanEmi).page,
          '/more/loans');
      expect(resolveNotificationRoute('nope:1').page, '/');
    });
  });

  group('notificationItemSheet', () {
    late Isar isar;
    setUpAll(() async => initialiseIsarForTests());
    setUp(() async => isar = await openTestIsar());
    tearDown(() async => closeAndCleanIsar(isar));

    test('existing items resolve to a sheet, deleted ones to null', () async {
      final ruleId = await isar.writeTxn(
          () => isar.recurringRules.put(makeRecurringRule()));
      final cat = Category()
        ..name = 'Food'
        ..icon = 'restaurant'
        ..colorValue = 0xFF000000
        ..type = 'expense';
      final catId = await isar.writeTxn(() => isar.categorys.put(cat));
      final budgetId = await isar.writeTxn(() => isar.budgets.put(Budget()
        ..categoryId = '$catId'
        ..amount = 1000
        ..periodType = BudgetPeriodType.monthly
        ..startDate = DateTime(2026, 10, 1)
        ..isRecurring = true));

      final rule = resolveNotificationRoute('recurring:$ruleId');
      final budget = resolveNotificationRoute('budget:$budgetId');
      expect(await notificationItemSheet(isar, rule), isNotNull);
      expect(await notificationItemSheet(isar, budget), isNotNull);

      await isar.writeTxn(() async {
        await isar.recurringRules.delete(ruleId);
        await isar.budgets.delete(budgetId);
      });
      expect(await notificationItemSheet(isar, rule), isNull);
      expect(await notificationItemSheet(isar, budget), isNull);
      for (final p in ['loan:x', 'ledger:x', 'investment:x', 'reminder:9',
          'account:9', 'recurring:not-a-number']) {
        expect(await notificationItemSheet(isar, resolveNotificationRoute(p)),
            isNull, reason: p);
      }
    });
  });
}
