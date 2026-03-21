import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_service.dart';
import '../data/transaction.dart';
import '../data/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(isarProvider));
});

final transactionListProvider =
    AsyncNotifierProvider<TransactionListNotifier, List<Transaction>>(
  TransactionListNotifier.new,
);

class TransactionListNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  FutureOr<List<Transaction>> build() {
    return ref.watch(transactionRepositoryProvider).getAll();
  }

  Future<void> add(Transaction t) async {
    await ref.read(transactionRepositoryProvider).save(t);
    ref.invalidateSelf();
  }

  Future<void> updateTransaction(Transaction t) async {
    await ref.read(transactionRepositoryProvider).save(t);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    await ref.read(transactionRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }
}

final monthlyTransactionsProvider =
    FutureProvider.family<List<Transaction>, ({int year, int month})>(
  (ref, params) {
    // Re-fetch when transactions are added/edited/deleted
    ref.watch(transactionListProvider);
    final repo = ref.watch(transactionRepositoryProvider);
    return repo.getByMonth(params.year, params.month);
  },
);
