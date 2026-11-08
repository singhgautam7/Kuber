// Notification categories: each notification type lands in the category the
// Notifications page shows, with its name in every language and no old ids.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/services/notification_service.dart';
import 'package:kuber/features/notifications/data/app_notification.dart';
import 'package:kuber/l10n/app_localizations.dart';

void main() {
  test('each type has its category', () {
    expect(KuberChannel.of(NotificationType.recurringTransaction), KuberChannel.payments);
    expect(KuberChannel.of(NotificationType.loanEmi), KuberChannel.payments);
    expect(KuberChannel.of(NotificationType.budgetAlert), KuberChannel.budgets);
    expect(KuberChannel.of(NotificationType.reminderTrigger), KuberChannel.reminders);
    expect(KuberChannel.of(NotificationType.ledgerReminder), KuberChannel.ledger);
    expect(KuberChannel.of(NotificationType.backup), KuberChannel.backups);
    expect(KuberChannel.of(NotificationType.general), isNull);
  });

  test('ids are unique and the merged ones are gone', () {
    final ids = KuberChannel.values.map((c) => c.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(ids, isNot(contains('kuber_recurring')));
    expect(ids, isNot(contains('kuber_loan_emi')));
  });

  test('every category has a name and a description in all 9 languages', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final l = lookupAppLocalizations(Locale(locale.languageCode));
      for (final c in KuberChannel.values) {
        final (name, description) = c.text(l);
        expect(name.trim(), isNotEmpty, reason: '${locale.languageCode} ${c.name}');
        expect(description.trim(), isNotEmpty, reason: '${locale.languageCode} ${c.name}');
        expect('$name$description'.contains('—') || '$name$description'.contains('–'), isFalse);
      }
    }
    final en = lookupAppLocalizations(const Locale('en'));
    expect(KuberChannel.payments.text(en).$1, 'EMI, SIP or Subscriptions');
    expect(KuberChannel.reminders.text(en).$2, 'A heads-up before any payment');
  });
}
