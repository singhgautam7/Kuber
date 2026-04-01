import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/accounts/data/account.dart';
import '../../features/categories/data/category.dart';
import '../../features/categories/data/category_group.dart';
import '../../features/recurring/data/recurring_rule.dart';
import '../../features/transactions/data/transaction.dart';
import '../../features/tags/data/tag.dart';
import '../../features/tags/data/transaction_tag.dart';
import '../../features/budgets/data/budget.dart';

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

class IsarService {
  static Future<Isar> open() async {
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
      ],
      directory: dir.path,
    );
  }
}
