import 'package:isar_community/isar.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/utils/formatters.dart';
import '../../accounts/data/account.dart';
import '../../budgets/data/budget.dart';
import '../../investments/data/investment.dart';
import '../../ledger/data/ledger.dart';
import '../../loans/data/loan.dart';
import '../../notifications/data/app_notification.dart';
import '../../recurring/data/recurring_rule.dart';
import '../../reminders/data/reminder.dart';

/// Dev tools: one inbox notification of every type, pointing at the first
/// existing item of each kind (load demo data first), plus an old-style row
/// with no payload and one whose item id does not exist. Returns rows added.
Future<int> seedTestNotifications(Isar isar) async {
  final now = DateTime.now();
  final rows = <AppNotification>[];
  void add(NotificationType type, String title, String body, String? payload) {
    rows.add(AppNotification()
      ..type = type
      ..title = '[Test] $title'
      ..body = body
      ..payload = payload
      ..createdAt = now.subtract(Duration(minutes: rows.length)));
  }

  final budget = await isar.budgets.where().findFirst();
  if (budget != null) {
    add(NotificationType.budgetAlert, 'Budget alert',
        'You have spent ${AppFormatter.amountToken(budget.amount)}.',
        'budget:${budget.id}');
  }
  final loan = await isar.loans.where().findFirst();
  if (loan != null) {
    add(NotificationType.loanEmi, 'Loan EMI', '${loan.name} EMI added.',
        'loan:${loan.uid}');
  }
  final rule = await isar.recurringRules.where().findFirst();
  if (rule != null) {
    add(NotificationType.recurringTransaction, 'Recurring',
        '${rule.name} added.', 'recurring:${rule.id}');
  }
  final inv = await isar.investments.where().findFirst();
  if (inv != null) {
    add(NotificationType.recurringTransaction, 'Investment SIP',
        'Contribution - ${inv.name}', 'investment:${inv.uid}');
  }
  final ledger = await isar.ledgers.where().findFirst();
  if (ledger != null) {
    add(NotificationType.ledgerReminder, 'Lend / Borrow',
        '${ledger.personName} is due.', 'ledger:${ledger.uid}');
  }
  final reminder = await isar.reminders.where().findFirst();
  if (reminder != null) {
    add(NotificationType.reminderTrigger, 'Reminder', reminder.title,
        'reminder:${reminder.id}');
  }
  final card =
      await isar.accounts.filter().isCreditCardEqualTo(true).findFirst();
  if (card != null) {
    add(NotificationType.general, 'Credit card due',
        'Your ${card.name} payment is due today.', 'account:${card.id}');
  }
  add(NotificationType.backup, 'Backup failed', 'Folder access was revoked.',
      'backup:folderRevoked');
  add(NotificationType.budgetAlert, 'Old-style (no id)',
      'Opens the Budgets page only.', null);
  add(NotificationType.recurringTransaction, 'Deleted item',
      'Points at a rule that does not exist.', 'recurring:987654321');

  await isar.writeTxn(() => isar.appNotifications.putAll(rows));
  return rows.length;
}

/// Dev tools: posts a system notification for the first loan (or a budget
/// when there is no loan), to test background and cold-start taps.
Future<bool> postTestSystemNotification(Isar isar) async {
  final loan = await isar.loans.where().findFirst();
  final budget = await isar.budgets.where().findFirst();
  final payload = loan != null
      ? 'loan:${loan.uid}'
      : budget != null
      ? 'budget:${budget.id}'
      : null;
  if (payload == null) return false;
  await NotificationService().showAppNotification(
    type: loan != null ? NotificationType.loanEmi : NotificationType.budgetAlert,
    id: 424242,
    title: '[Test] Tap to open',
    body: loan != null ? '${loan.name} EMI' : 'Budget alert',
    payload: payload,
  );
  return true;
}
