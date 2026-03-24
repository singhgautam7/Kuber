import 'package:isar/isar.dart';

import '../../../core/database/base_repository.dart';
import '../../../core/utils/color_palette.dart';
import '../../transactions/data/transaction.dart';
import 'category.dart';

class CategoryRepository extends BaseRepository<Category> {
  CategoryRepository(super.isar);

  Future<List<Category>> getAll() async {
    return isar.categorys.where().findAll();
  }

  Future<Category?> getById(Id id) async {
    return isar.categorys.get(id);
  }

  Future<void> save(Category c) async {
    await isar.writeTxn(() => isar.categorys.put(c));
  }

  Future<void> delete(Id id) async {
    await isar.writeTxn(() => isar.categorys.delete(id));
  }

  Future<bool> hasTransactions(Id categoryId) async {
    final count = await isar.transactions
        .filter()
        .categoryIdEqualTo(categoryId.toString())
        .count();
    return count > 0;
  }

  Future<void> seedDefaults() async {
    final count = await isar.categorys.count();
    if (count > 0) return;

    final defaults = [
      _cat('Food & Dining', 'restaurant', AppColorPalette.colors[4], 'expense'), // red
      _cat('Transport', 'directions_car', AppColorPalette.colors[0], 'expense'), // blue
      _cat('Shopping', 'shopping_bag', AppColorPalette.colors[3], 'expense'), // pink
      _cat('Bills & Utilities', 'receipt_long', AppColorPalette.colors[5], 'expense'), // orange
      _cat('Health', 'favorite', AppColorPalette.colors[7], 'expense'), // emerald
      _cat('Entertainment', 'movie', AppColorPalette.colors[2], 'expense'), // violet
      _cat('Income', 'trending_up', AppColorPalette.colors[8], 'income'), // teal
      _cat('Savings', 'savings', AppColorPalette.colors[9], 'both'), // cyan
      _cat('Other', 'category', AppColorPalette.colors[10], 'both'), // slate
    ];

    await isar.writeTxn(() => isar.categorys.putAll(defaults));
  }

  Category _cat(String name, String icon, int colorValue, String type) {
    return Category()
      ..name = name
      ..icon = icon
      ..colorValue = colorValue
      ..isDefault = true
      ..type = type;
  }
}
