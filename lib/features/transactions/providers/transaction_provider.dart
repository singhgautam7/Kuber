import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_service.dart';
import '../data/transaction.dart';
import '../data/transaction_repository.dart';
import '../../budgets/services/budget_service.dart';
import '../../budgets/providers/budget_provider.dart';
import '../../categories/providers/category_provider.dart';

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

  void _invalidateDependencies() {
    ref.invalidate(categoryListProvider);
    ref.invalidate(budgetListProvider);
  }

  Future<int> add(Transaction t) async {
    final id = await ref.read(transactionRepositoryProvider).save(t);
    ref.invalidateSelf();
    _invalidateDependencies();
    if (t.type == 'expense') {
      await ref.read(budgetServiceProvider).checkAlerts(t.categoryId);
    }
    return id;
  }

  Future<int> updateTransaction(Transaction t) async {
    final id = await ref.read(transactionRepositoryProvider).save(t);
    ref.invalidateSelf();
    _invalidateDependencies();
    if (t.type == 'expense') {
      await ref.read(budgetServiceProvider).checkAlerts(t.categoryId);
    }
    return id;
  }

  Future<void> delete(int id) async {
    final t = await ref.read(transactionRepositoryProvider).getById(id);
    if (t != null && t.isTransfer && t.transferId != null) {
      await ref
          .read(transactionRepositoryProvider)
          .deleteTransferPair(t.transferId!);
    } else {
      await ref.read(transactionRepositoryProvider).delete(id);
    }
    ref.invalidateSelf();
    _invalidateDependencies();
    if (t != null && t.type == 'expense' && !t.isTransfer) {
      await ref.read(budgetServiceProvider).checkAlerts(t.categoryId);
    }
  }

  Future<void> restore(Transaction t) async {
    await ref.read(transactionRepositoryProvider).restore(t);
    ref.invalidateSelf();
    _invalidateDependencies();
    if (t.type == 'expense') {
      await ref.read(budgetServiceProvider).checkAlerts(t.categoryId);
    }
  }

  Future<List<int>> saveTransfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required DateTime createdAt,
    String? notes,
  }) async {
    final ids = await ref
        .read(transactionRepositoryProvider)
        .saveTransfer(
          fromAccountId: fromAccountId,
          toAccountId: toAccountId,
          amount: amount,
          createdAt: createdAt,
          notes: notes,
        );
    ref.invalidateSelf();
    _invalidateDependencies();
    return ids;
  }

  Future<List<int>> updateTransfer({
    required int id,
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required DateTime createdAt,
    String? notes,
  }) async {
    final ids = await ref
        .read(transactionRepositoryProvider)
        .updateTransfer(
          id: id,
          fromAccountId: fromAccountId,
          toAccountId: toAccountId,
          amount: amount,
          createdAt: createdAt,
          notes: notes,
        );
    ref.invalidateSelf();
    _invalidateDependencies();
    return ids;
  }
}

final monthlyTransactionsProvider =
    FutureProvider.family<List<Transaction>, ({int year, int month})>((
      ref,
      params,
    ) {
      // Re-fetch when transactions are added/edited/deleted
      ref.watch(transactionListProvider);
      final repo = ref.watch(transactionRepositoryProvider);
      return repo.getByMonth(params.year, params.month);
    });
