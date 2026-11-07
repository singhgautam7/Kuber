// The Notifications page switches: what each covers, on until switched off.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/services/notification_service.dart';
import 'package:kuber/features/notifications/data/app_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('each switch covers its notifications; reminders stay always on', () {
    expect(NotificationKind.of(NotificationType.recurringTransaction), NotificationKind.payments);
    expect(NotificationKind.of(NotificationType.loanEmi), NotificationKind.payments);
    expect(NotificationKind.of(NotificationType.budgetAlert), NotificationKind.budgets);
    expect(NotificationKind.of(NotificationType.backup), NotificationKind.backups);
    expect(NotificationKind.of(NotificationType.reminderTrigger), isNull);
    expect(NotificationKind.of(NotificationType.ledgerReminder), isNull);
    expect(NotificationKind.of(NotificationType.general), isNull);
  });

  test('on by default, and a change is stored', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(notificationKindsProvider), NotificationKind.values.toSet());
    await c.read(notificationKindsProvider.notifier).set(NotificationKind.budgets, false);
    expect(c.read(notificationKindsProvider).contains(NotificationKind.budgets), isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(NotificationKind.budgets.key), isFalse);

    final fresh = ProviderContainer();
    addTearDown(fresh.dispose);
    fresh.read(notificationKindsProvider);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(fresh.read(notificationKindsProvider).contains(NotificationKind.budgets), isFalse);
  });
}
