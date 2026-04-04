import 'package:isar_community/isar.dart';

import '../../../core/database/base_repository.dart';
import 'loan.dart';

class LoanRepository extends BaseRepository<Loan> {
  LoanRepository(super.isar);

  Future<List<Loan>> getAll() async {
    return isar.loans.where().sortByCreatedAtDesc().findAll();
  }

  Future<Loan?> getById(Id id) async {
    return isar.loans.get(id);
  }

  Future<Loan?> getByUid(String uid) async {
    return isar.loans.filter().uidEqualTo(uid).findFirst();
  }

  Future<int> save(Loan loan) async {
    loan.updatedAt = DateTime.now();
    if (loan.id == Isar.autoIncrement) {
      loan.createdAt = DateTime.now();
    }
    return isar.writeTxn(() => isar.loans.put(loan));
  }

  Future<void> delete(Id id) async {
    await isar.writeTxn(() => isar.loans.delete(id));
  }
}
