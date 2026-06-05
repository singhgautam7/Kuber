import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/prefs_keys.dart';
import '../../accounts/data/account.dart';
import '../../accounts/data/account_repository.dart';
import '../../categories/data/category.dart';
import '../../categories/data/category_group_repository.dart';
import '../../categories/data/category_repository.dart';

class AdvancedSetupRepository {
  final Isar isar;

  AdvancedSetupRepository(this.isar);

  Future<void> saveDefaults({
    required List<Account> accounts,
    required List<Category> categories,
  }) async {
    final accountRepository = AccountRepository(isar);
    final categoryRepository = CategoryRepository(isar);
    final groupRepository = CategoryGroupRepository(isar);

    await isar.writeTxn(() async {
      await accountRepository.putAll(accounts);

      final ungroupedId = await groupRepository.getOrCreateIdByName(
        'Ungrouped',
      );
      for (final category in categories) {
        category.groupId = ungroupedId;
      }
      await categoryRepository.putAll(categories);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.advancedSetupCompleted, true);
  }
}
