import 'package:isar/isar.dart';

import '../../features/accounts/data/account.dart';
import '../../features/categories/data/category.dart';
import '../../features/categories/data/category_group.dart';
import '../../features/tags/data/tag.dart';

class SeedService {
  Future<void> seedInitialData(Isar isar) async {
    final hasAccounts = await isar.accounts.count() > 0;
    final hasCategories = await isar.categorys.count() > 0;
    final hasTags = await isar.tags.count() > 0;

    if (hasAccounts || hasCategories || hasTags) return;

    await isar.writeTxn(() async {
      // 1. Seed Accounts
      final accounts = [
        Account()
          ..name = 'Cash'
          ..type = 'cash'
          ..icon = 'payments_outlined'
          ..colorValue = 0xFF9E9E9E
          ..initialBalance = 0,
        Account()
          ..name = 'Bank'
          ..type = 'bank'
          ..icon = 'account_balance_outlined'
          ..colorValue = 0xFF2196F3
          ..initialBalance = 0,
        Account()
          ..name = 'Credit Card'
          ..type = 'card'
          ..icon = 'credit_card_outlined'
          ..colorValue = 0xFF9C27B0
          ..initialBalance = 0
          ..creditLimit = 50000,
      ];
      await isar.accounts.putAll(accounts);

      // 2. Seed Category Groups & Categories
      final categoryData = {
        'FOOD': [
          _cat('Dining', 'restaurant', 0xFFFF5722, 'expense'),
          _cat('Fast Food', 'fastfood', 0xFFFFC107, 'expense'),
          _cat('Groceries', 'shopping_basket', 0xFF4CAF50, 'expense'),
          _cat('Coffee', 'local_cafe', 0xFF795548, 'expense'),
          _cat('Drinks', 'local_bar', 0xFF673AB7, 'expense'),
        ],
        'ENTERTAINMENT': [
          _cat('Movies', 'movie', 0xFFE91E63, 'expense'),
          _cat('Streaming', 'live_tv', 0xFFF44336, 'expense'),
          _cat('Gaming', 'sports_esports', 0xFF3F51B5, 'expense'),
          _cat('Events', 'event', 0xFF00BCD4, 'expense'),
        ],
        'TRAVEL': [
          _cat('Fuel', 'local_gas_station', 0xFF607D8B, 'expense'),
          _cat('Flight', 'flight', 0xFF03A9F4, 'expense'),
          _cat('Train', 'train', 0xFF009688, 'expense'),
          _cat('Bus', 'directions_bus', 0xFFFF9800, 'expense'),
          _cat('Cab', 'local_taxi', 0xFFFFEB3B, 'expense'),
        ],
        'HOUSEHOLD': [
          _cat('Rent', 'house', 0xFF8BC34A, 'expense'),
          _cat('Utilities', 'power', 0xFFFF5252, 'expense'),
          _cat('Internet', 'wifi', 0xFF448AFF, 'expense'),
          _cat('Maintenance', 'build', 0xFF757575, 'expense'),
        ],
        'BILLS': [
          _cat('Electricity', 'electrical_services', 0xFFFFC107, 'expense'),
          _cat('Mobile', 'phone_android', 0xFF536DFE, 'expense'),
          _cat('Subscriptions', 'subscriptions', 0xFFE040FB, 'expense'),
        ],
        'HEALTH': [
          _cat('Medicines', 'medication', 0xFF18FFFF, 'expense'),
          _cat('Doctor', 'medical_services', 0xFF00E676, 'expense'),
          _cat('Fitness', 'fitness_center', 0xFFFF4081, 'expense'),
        ],
        'SHOPPING': [
          _cat('Clothing', 'checkroom', 0xFFE91E63, 'expense'),
          _cat('Electronics', 'devices', 0xFF607D8B, 'expense'),
          _cat('General', 'shopping_bag', 0xFF8D6E63, 'expense'),
        ],
        'PERSONAL': [
          _cat('Personal', 'person', 0xFF00BCD4, 'both'),
          _cat('Gifts', 'card_giftcard', 0xFFFF5252, 'both'),
        ],
        'INCOME': [
          _cat('Salary', 'account_balance_wallet', 0xFF4CAF50, 'income'),
          _cat('Freelance', 'work', 0xFF8BC34A, 'income'),
          _cat('Bonus', 'monetization_on', 0xFFFFD740, 'income'),
          _cat('Interest', 'trending_up', 0xFF69F0AE, 'income'),
          _cat('Refund', 'assignment_return', 0xFF40C4FF, 'income'),
        ],
        'OTHER': [
          _cat('Transfer', 'swap_horiz', 0xFF9E9E9E, 'both'),
          _cat('Adjustment', 'tune', 0xFFBDBDBD, 'both'),
        ],
      };

      for (final entry in categoryData.entries) {
        final groupName = entry.key;
        final cats = entry.value;

        // Create and insert group
        final group = CategoryGroup()..name = groupName;
        final groupId = await isar.categoryGroups.put(group);

        // Assign groupId to categories and insert
        for (final cat in cats) {
          cat.groupId = groupId;
        }
        await isar.categorys.putAll(cats);
      }

      // 3. Seed Tags
      final tagNames = ['personal', 'trip', 'work', 'family'];
      final now = DateTime.now();
      final tags = tagNames.map((name) => Tag()..name = name..createdAt = now).toList();
      await isar.tags.putAll(tags);
    });
  }

  Category _cat(String name, String icon, int color, String type) {
    return Category()
      ..name = name
      ..icon = icon
      ..colorValue = color
      ..type = type
      ..isDefault = true;
  }
}
