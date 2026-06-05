import 'package:isar_community/isar.dart';
import 'category.dart';
import 'category_group.dart';

class CategoryGroupRepository {
  final Isar isar;

  CategoryGroupRepository(this.isar);

  Future<List<CategoryGroup>> getAll() async {
    return isar.categoryGroups.where().sortByName().findAll();
  }

  Future<Id> save(CategoryGroup group) async {
    return isar.writeTxn(() => isar.categoryGroups.put(group));
  }

  Future<CategoryGroup?> getByName(String name) async {
    return isar.categoryGroups
        .filter()
        .nameEqualTo(name, caseSensitive: false)
        .findFirst();
  }

  Future<Id> getOrCreateIdByName(String name) async {
    final existing = await getByName(name);
    if (existing != null) return existing.id;
    return isar.categoryGroups.put(CategoryGroup()..name = name);
  }

  Future<void> delete(int id) async {
    await isar.writeTxn(() async {
      // 1. Nullify groupId for all categories in this group
      final categories = await isar.categorys
          .filter()
          .groupIdEqualTo(id)
          .findAll();
      for (final cat in categories) {
        cat.groupId = null;
      }
      await isar.categorys.putAll(categories);

      // 2. Delete the group
      await isar.categoryGroups.delete(id);
    });
  }
}
