import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar_community/isar.dart';

import '../../../core/database/isar_service.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../budgets/data/budget.dart';
import '../../budgets/widgets/budget_details_sheet.dart';
import '../../categories/data/category.dart';
import '../../ledger/data/ledger.dart';
import '../../ledger/widgets/ledger_detail_sheet.dart';
import '../../loans/data/loan.dart';
import '../../loans/widgets/loan_detail_sheet.dart';
import '../../recurring/data/recurring_rule.dart';
import '../../recurring/widgets/recurring_detail_sheet.dart';
import '../../reminders/data/reminder.dart';
import '../../reminders/widgets/reminder_view_sheet.dart';
import '../data/app_notification.dart';

/// Resolves a notification payload (e.g. `"loan:abc-uid"`) to a route +
/// follow-up bottom-sheet open. Missing entities snackbar + go to home.
///
/// The caller is responsible for closing the notifications sheet *before*
/// calling this — that lets the deep-link routing happen on a clean stack.
Future<void> handleNotificationTap(
  BuildContext context,
  WidgetRef ref,
  AppNotification n,
) async {
  final payload = n.payload;
  if (payload == null || !payload.contains(':')) {
    context.go('/');
    return;
  }

  final parts = payload.split(':');
  if (parts.length != 2) {
    context.go('/');
    return;
  }
  final kind = parts[0];
  final id = parts[1];

  final isar = ref.read(isarProvider);

  switch (kind) {
    case 'recurring':
      final ruleId = int.tryParse(id);
      final rule = ruleId == null
          ? null
          : await isar.collection<RecurringRule>().get(ruleId);
      if (!context.mounted) return;
      if (rule == null) {
        _missing(context);
        return;
      }
      context.go('/more/recurring');
      if (!context.mounted) return;
      showRecurringDetailSheet(context, ref, rule);
      break;

    case 'loan':
      final loan = await isar
          .collection<Loan>()
          .filter()
          .uidEqualTo(id)
          .findFirst();
      if (!context.mounted) return;
      if (loan == null) {
        _missing(context);
        return;
      }
      context.go('/more/loans');
      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => LoanDetailSheet(loan: loan),
      );
      break;

    case 'budget':
      final budgetId = int.tryParse(id);
      final budget = budgetId == null
          ? null
          : await isar.collection<Budget>().get(budgetId);
      if (!context.mounted) return;
      if (budget == null) {
        _missing(context);
        return;
      }
      final catId = int.tryParse(budget.categoryId);
      final category = catId == null
          ? null
          : await isar.collection<Category>().get(catId);
      if (!context.mounted) return;
      if (category == null) {
        _missing(context);
        return;
      }
      context.go('/more/budgets');
      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => BudgetDetailsSheet(
          budgetId: budget.id,
          category: category,
        ),
      );
      break;

    case 'ledger':
      final ledger = await isar
          .collection<Ledger>()
          .filter()
          .uidEqualTo(id)
          .findFirst();
      if (!context.mounted) return;
      if (ledger == null) {
        _missing(context);
        return;
      }
      context.go('/more/ledger');
      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => LedgerDetailSheet(ledger: ledger),
      );
      break;

    case 'investment':
      // Investment notifications route to the investments page (no detail
      // sheet open — the SIP transaction itself is what was added).
      context.go('/more/investments');
      break;

    case 'reminder':
      final reminderId = int.tryParse(id);
      final reminder = reminderId == null
          ? null
          : await isar.collection<Reminder>().get(reminderId);
      if (!context.mounted) return;
      if (reminder == null) {
        _missing(context);
        return;
      }
      context.go('/');
      if (!context.mounted) return;
      context.push('/more/reminders');
      if (!context.mounted) return;
      showReminderViewSheet(context, reminder);
      break;

    default:
      context.go('/');
  }
}

void _missing(BuildContext context) {
  context.go('/');
  if (!context.mounted) return;
  showKuberSnackBar(
    context,
    'That item no longer exists',
    isError: true,
  );
}
