import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar_community/isar.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/router/app_router.dart' show rootNavigatorKey;
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../accounts/data/account.dart';
import '../../accounts/widgets/account_detail_sheet.dart';
import '../../budgets/data/budget.dart';
import '../../budgets/widgets/budget_details_sheet.dart';
import '../../categories/data/category.dart';
import '../../investments/data/investment.dart';
import '../../investments/widgets/holding_sheet.dart';
import '../../ledger/data/ledger.dart';
import '../../ledger/widgets/ledger_detail_sheet.dart';
import '../../loans/data/loan.dart';
import '../../loans/widgets/loan_sheet.dart';
import '../../recurring/data/recurring_rule.dart';
import '../../recurring/widgets/rule_sheet.dart';
import '../../reminders/data/reminder.dart';
import '../../reminders/widgets/reminder_view_sheet.dart';
import '../data/app_notification.dart';
import 'notification_routes.dart';

/// Opens what a notification is about: its page (via the routing map in
/// `notification_routes.dart`), then that item's view sheet. Used for in-app
/// sheet taps and for system notification taps (warm and cold start).
///
/// No item id (older rows) opens the page only. A deleted item opens the page
/// and shows the "no longer exists" snackbar. Navigation runs on the root
/// navigator, so the caller's own context may already be gone.
Future<void> handleNotificationTap(
  WidgetRef ref, {
  String? payload,
  NotificationType? type,
}) async {
  final route = resolveNotificationRoute(payload, type: type);
  final sheet = route.hasItem
      ? await notificationItemSheet(ref.read(isarProvider), route)
      : null;

  final context = rootNavigatorKey.currentContext;
  if (context == null || !context.mounted) return;
  GoRouter.of(context).go(route.page);
  // Let the router swap pages first: a sheet pushed before that would be
  // attached to the outgoing page and dropped with it.
  await WidgetsBinding.instance.endOfFrame;

  final nav = rootNavigatorKey.currentState;
  final ctx = rootNavigatorKey.currentContext;
  if (nav == null || ctx == null || !ctx.mounted) return;
  if (route.hasItem && sheet == null) {
    showKuberSnackBar(ctx, ctx.l10n.notifItemMissing, overlay: nav.overlay);
    return;
  }
  if (sheet == null) return;
  showModalBottomSheet(
    context: ctx,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => sheet,
  );
}

/// The view sheet for [route]'s item, or null when the item no longer exists.
Future<Widget?> notificationItemSheet(Isar isar, NotificationRoute route) async {
  final id = route.id!;
  final intId = int.tryParse(id);
  switch (route.kind) {
    case 'recurring':
      final rule =
          intId == null ? null : await isar.collection<RecurringRule>().get(intId);
      return rule == null ? null : RuleSheet(rule: rule);
    case 'loan':
      final loan =
          await isar.collection<Loan>().filter().uidEqualTo(id).findFirst();
      return loan == null ? null : LoanSheet(loan: loan);
    case 'budget':
      final budget =
          intId == null ? null : await isar.collection<Budget>().get(intId);
      final catId = int.tryParse(budget?.categoryId ?? '');
      final category =
          catId == null ? null : await isar.collection<Category>().get(catId);
      if (budget == null || category == null) return null;
      return BudgetDetailsSheet(budgetId: budget.id, category: category);
    case 'ledger':
      final ledger =
          await isar.collection<Ledger>().filter().uidEqualTo(id).findFirst();
      return ledger == null ? null : LedgerDetailSheet(ledger: ledger);
    case 'investment':
      final inv = await isar
          .collection<Investment>()
          .filter()
          .uidEqualTo(id)
          .findFirst();
      return inv == null ? null : HoldingSheet(investment: inv);
    case 'reminder':
      final reminder =
          intId == null ? null : await isar.collection<Reminder>().get(intId);
      return reminder == null ? null : ReminderViewSheet(reminderId: reminder.id);
    case 'account':
      final account =
          intId == null ? null : await isar.collection<Account>().get(intId);
      return account == null ? null : AccountDetailSheet(account: account);
  }
  return null;
}
