import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/accounts/data/account.dart';
import '../../features/categories/data/category.dart';
import '../../features/categories/data/category_group.dart';
import '../../features/recurring/data/recurring_rule.dart';
import '../../features/transactions/data/transaction.dart';
import '../../features/categories/data/category_repository.dart';
import '../../features/accounts/data/account_repository.dart';
import '../../features/tags/data/tag.dart';
import '../../features/tags/data/transaction_tag.dart';

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
      ],
      directory: dir.path,
    );
  }

  static Future<void> seedIfNeeded(Isar isar) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('kuber_seeded') == true) return;

    await CategoryRepository(isar).seedDefaults();
    await AccountRepository(isar).seedDefaults();

    await prefs.setBool('kuber_seeded', true);
  }
}
