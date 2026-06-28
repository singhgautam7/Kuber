import 'dart:io';
import 'package:isar_community/isar.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/features/categories/data/category.dart';
import 'package:kuber/features/categories/data/category_group.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/features/recurring/data/recurring_rule.dart';
import 'package:kuber/features/tags/data/tag.dart';
import 'package:kuber/features/tags/data/transaction_tag.dart';
import 'package:kuber/features/budgets/data/budget.dart';
import 'package:kuber/features/ledger/data/ledger.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/investments/data/investment.dart';
import 'package:kuber/features/notifications/data/app_notification.dart';
import 'package:kuber/features/widget_editor/data/widget_preference.dart';
import 'package:kuber/features/transactions/data/transaction_suggestion.dart';
import 'package:kuber/features/tools/bill_splitter/data/person.dart';
import 'package:kuber/features/tools/bill_splitter/data/bill.dart';
import 'package:kuber/features/stories/data/insight_story.dart';
import 'package:kuber/features/backups/data/backup_config.dart';
import 'package:kuber/features/ask_kuber/data/ask_kuber_message.dart';
import 'package:kuber/features/sms_import/data/sms_transaction.dart';
import 'package:kuber/features/sms_import/data/sms_account_mapping.dart';

const _allSchemas = [
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
  AppNotificationSchema,
  WidgetPreferenceSchema,
  TransactionSuggestionSchema,
  PersonSchema,
  BillSchema,
  InsightStorySchema,
  BackupConfigSchema,
  AskKuberMessageSchema,
  SmsTransactionSchema,
  SmsAccountMappingSchema,
];

bool _isarInitialized = false;

Future<void> initialiseIsarForTests() async {
  if (_isarInitialized) return;
  await Isar.initializeIsarCore(download: true);
  _isarInitialized = true;
}

Future<Isar> openTestIsar() async {
  final dir = Directory.systemTemp.createTempSync('isar_test_');
  return Isar.open(
    _allSchemas,
    directory: dir.path,
    name: 'test_${DateTime.now().microsecondsSinceEpoch}',
  );
}

Future<void> closeAndCleanIsar(Isar isar) async {
  final path = isar.directory;
  await isar.close(deleteFromDisk: false);
  if (path != null) {
    try {
      final dir = Directory(path);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    } catch (_) {}
  }
}
