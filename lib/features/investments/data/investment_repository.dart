import 'package:isar_community/isar.dart';

import '../../../core/database/base_repository.dart';
import 'investment.dart';

class InvestmentRepository extends BaseRepository<Investment> {
  InvestmentRepository(super.isar);

  Future<List<Investment>> getAll() async {
    return isar.investments.where().sortByCreatedAtDesc().findAll();
  }

  Future<Investment?> getById(Id id) async {
    return isar.investments.get(id);
  }

  Future<Investment?> getByUid(String uid) async {
    return isar.investments.filter().uidEqualTo(uid).findFirst();
  }

  Future<int> save(Investment investment) async {
    investment.updatedAt = DateTime.now();
    if (investment.id == Isar.autoIncrement) {
      investment.createdAt = DateTime.now();
    }
    return isar.writeTxn(() => isar.investments.put(investment));
  }

  Future<void> delete(Id id) async {
    await isar.writeTxn(() => isar.investments.delete(id));
  }
}
