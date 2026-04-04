import 'package:isar_community/isar.dart';

import '../../../core/database/base_repository.dart';
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
}
