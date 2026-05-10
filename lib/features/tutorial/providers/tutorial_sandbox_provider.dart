import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/database/isar_service.dart';
import '../../../features/accounts/data/account.dart';
import '../../../features/budgets/data/budget.dart';
import '../../../features/categories/data/category.dart';
import '../../../features/categories/data/category_group.dart';
import '../../../features/investments/data/investment.dart';
import '../../../features/ledger/data/ledger.dart';
import '../../../features/loans/data/loan.dart';
import '../../../features/recurring/data/recurring_rule.dart';
import '../../../features/tags/data/tag.dart';
import '../../../features/tags/data/transaction_tag.dart';
import '../../../features/tools/bill_splitter/data/bill.dart';
import '../../../features/tools/bill_splitter/data/person.dart';
import '../../../features/transactions/data/transaction.dart';
import '../../../features/transactions/data/transaction_suggestion.dart';

/// Holds the live sandbox Isar instance (null when not in tutorial).
final tutorialSandboxIsarProvider = StateProvider<Isar?>((ref) => null);

/// Resolves to sandbox if active, else falls back to main Isar.
final tutorialAwareIsarProvider = Provider<Isar>((ref) {
  return ref.watch(tutorialSandboxIsarProvider) ?? ref.watch(isarProvider);
});

Future<Isar> openSandboxIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [
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
    ],
    name: 'tutorial_sandbox',
    directory: dir.path,
  );
}

Future<void> closeSandboxIsar(Isar sandbox) async {
  await sandbox.close(deleteFromDisk: true);
}
