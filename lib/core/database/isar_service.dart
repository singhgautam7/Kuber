import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/accounts/data/account.dart';
import '../../features/categories/data/category.dart';
import '../../features/categories/data/category_group.dart';
import '../../features/recurring/data/recurring_rule.dart';
import '../../features/transactions/data/transaction.dart';
import '../../features/tags/data/tag.dart';
import '../../features/tags/data/transaction_tag.dart';
import '../../features/budgets/data/budget.dart';
import '../../features/ledger/data/ledger.dart';
import '../../features/loans/data/loan.dart';
import '../../features/investments/data/investment.dart';
import '../../features/transactions/data/transaction_suggestion.dart';
import '../../features/tools/bill_splitter/data/person.dart';
import '../../features/tools/bill_splitter/data/bill.dart';
import '../../features/notifications/data/app_notification.dart';
import '../../features/widget_editor/data/widget_preference.dart';
import '../../features/stories/data/insight_story.dart';
import '../../features/backups/data/backup_config.dart';
import '../../features/ask_kuber/data/ask_kuber_message.dart';
import '../../features/sms_import/data/sms_transaction.dart';
import '../../features/sms_import/data/sms_account_mapping.dart';
import '../../features/tools/saved/data/saved_calculation.dart';
import '../../features/tools/saved/data/calculator_recent_use.dart';
import '../../features/notes/data/kuber_note.dart';
import '../../features/reminders/data/reminder.dart';
import '../../features/pro/data/pinned_shortcut_pref.dart';
import '../../features/pro/data/user_entitlement.dart';

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

class IsarService {
  static Future<Isar> open() async {
    // Reuse the process-global instance if it's already open. The widget
    // configuration activities boot a second Flutter engine that re-runs
    // main(); without this, a second Isar.open() in the same process would
    // fail and crash the config screen.
    final existing = Isar.getInstance();
    if (existing != null && existing.isOpen) return existing;
    final dir = await getApplicationDocumentsDirectory();
    return Isar.open([
      TransactionSchema,
      CategorySchema,
      CategoryGroupSchema,
      AccountSchema,
      RecurringRuleSchema,
      TagSchema,
      TransactionTagSchema,
      BudgetSchema,
      LedgerSchema,
      LoanSchema,
      InvestmentSchema,
      TransactionSuggestionSchema,
      PersonSchema,
      BillSchema,
      AppNotificationSchema,
      WidgetPreferenceSchema,
      InsightStorySchema,
      BackupConfigSchema,
      AskKuberMessageSchema,
      SmsTransactionSchema,
      SmsAccountMappingSchema,
      SavedCalculationSchema,
      CalculatorRecentUseSchema,
      KuberNoteSchema,
      ReminderSchema,
      UserEntitlementSchema,
      PinnedShortcutPrefSchema,
    ], directory: dir.path);
  }
}
