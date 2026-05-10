import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/database/isar_service.dart';
import '../../accounts/data/account.dart';
import '../../budgets/data/budget.dart';
import '../../categories/data/category.dart';
import '../../categories/data/category_group.dart';
import '../../investments/data/investment.dart';
import '../../ledger/data/ledger.dart';
import '../../loans/data/loan.dart';
import '../../recurring/data/recurring_rule.dart';
import '../../tags/data/tag.dart';
import '../../tags/data/transaction_tag.dart';
import '../../tools/bill_splitter/data/bill.dart';
import '../../tools/bill_splitter/data/person.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/data/transaction_suggestion.dart';

final tutorialSandboxIsarProvider = StateProvider<Isar?>((ref) => null);

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
