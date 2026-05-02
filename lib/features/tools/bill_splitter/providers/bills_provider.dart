import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../../../core/database/isar_service.dart';
import '../data/bill.dart';

final billsListProvider = AsyncNotifierProvider<BillsListNotifier, List<Bill>>(
  BillsListNotifier.new,
);

class BillsListNotifier extends AsyncNotifier<List<Bill>> {
  Isar get _isar => ref.read(isarProvider);

  @override
  FutureOr<List<Bill>> build() async {
    return _isar.bills.where().sortByCreatedAtDesc().findAll();
  }

  Future<int> save(Bill bill) async {
    final id = await _isar.writeTxn(() => _isar.bills.put(bill));
    ref.invalidateSelf();
    return id;
  }

  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.bills.delete(id));
    ref.invalidateSelf();
  }

  Future<void> setArchived(int id, bool archived) async {
    final bill = await _isar.bills.get(id);
    if (bill == null) return;
    bill
      ..isArchived = archived
      ..archivedAt = archived ? DateTime.now() : null;
    await _isar.writeTxn(() => _isar.bills.put(bill));
    ref.invalidateSelf();
  }
}
