import 'dart:io';
import 'package:isar/isar.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/features/categories/data/category.dart';
import 'package:kuber/features/categories/data/category_group.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/features/recurring/data/recurring_rule.dart';
import 'package:kuber/features/tags/data/tag.dart';
import 'package:kuber/features/tags/data/transaction_tag.dart';
import 'package:kuber/features/budgets/data/budget.dart';
import 'package:kuber/features/ledger/data/ledger.dart';

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
  await isar.close(deleteFromDisk: true);
}
