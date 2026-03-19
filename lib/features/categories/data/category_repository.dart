import 'package:isar/isar.dart';

import '../../../core/database/base_repository.dart';
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

  Future<void> seedDefaults() async {
    final count = await isar.categorys.count();
    if (count > 0) return;

    final defaults = [
      _cat('Food & Dining', 'restaurant', 0xFFE57373),
      _cat('Transport', 'directions_car', 0xFF64B5F6),
      _cat('Shopping', 'shopping_bag', 0xFFBA68C8),
      _cat('Bills & Utilities', 'receipt_long', 0xFFFFB74D),
      _cat('Health', 'favorite', 0xFF81C784),
      _cat('Entertainment', 'movie', 0xFFF06292),
      _cat('Income', 'trending_up', 0xFF4DB6AC),
      _cat('Savings', 'savings', 0xFF4DD0E1),
      _cat('Other', 'category', 0xFF90A4AE),
    ];

    await isar.writeTxn(() => isar.categorys.putAll(defaults));
  }

  Category _cat(String name, String icon, int colorValue) {
    return Category()
      ..name = name
      ..icon = icon
      ..colorValue = colorValue
      ..isDefault = true;
  }
}
