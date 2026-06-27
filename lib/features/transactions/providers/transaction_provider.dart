import 'dart:async';

import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tutorial/providers/tutorial_sandbox_provider.dart';
import '../../../core/services/attachment_service.dart';
import '../data/transaction.dart';
import '../data/transaction_repository.dart';
import '../../budgets/services/budget_service.dart';
import '../../budgets/providers/budget_provider.dart';
import '../../categories/providers/category_provider.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(tutorialAwareIsarProvider));
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
      ref
          .read(budgetServiceProvider)
          .checkAlerts(t.categoryId)
          .catchError((_) {});
    }
    return id;
  }

  /// Creates a balance-adjustment transaction for a changed account balance or
  /// credit-card limit spent. Moved verbatim from the old EditBalanceSheet so
  /// the behavior (name, sign, type) is identical — do not change it.
  ///
  /// [diff] is signed: positive raises the balance (income), negative lowers it
  /// (expense). [isCredit] selects the adjustment name used for credit cards.
  Future<void> addBalanceAdjustment({
    required int accountId,
    required double diff,
    required bool isCredit,
  }) async {
    final isPositive = diff > 0;
    final adjustment = Transaction()
      ..name = isCredit ? 'Limit Spent Adjustment' : 'Balance Adjustment'
      ..amount = diff.abs()
      ..type = isPositive ? 'income' : 'expense'
      ..accountId = accountId.toString()
      ..categoryId = ''
      ..isBalanceAdjustment = true
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now()
      ..nameLower =
          isCredit ? 'limit spent adjustment' : 'balance adjustment';
    await add(adjustment);
  }

  Future<int> updateTransaction(Transaction t) async {
    final id = await ref.read(transactionRepositoryProvider).save(t);
    ref.invalidateSelf();
    _invalidateDependencies();
    if (t.type == 'expense') {
      ref
          .read(budgetServiceProvider)
          .checkAlerts(t.categoryId)
          .catchError((_) {});
    }
    return id;
  }

  Future<void> delete(int id) async {
    final repo = ref.read(transactionRepositoryProvider);
    final attachments = ref.read(attachmentServiceProvider);
    final t = await repo.getById(id);
    if (t != null && t.isTransfer && t.transferId != null) {
      // Delete attachments for both legs of the transfer
      await attachments.deleteAllForTransaction(t.id);
      final pair = await repo.findTransferPair(t.transferId!, t.id);
      if (pair != null) await attachments.deleteAllForTransaction(pair.id);
      await repo.deleteTransferPair(t.transferId!);
    } else {
      if (t != null) await attachments.deleteAllForTransaction(t.id);
      await repo.delete(id);
    }
    ref.invalidateSelf();
    _invalidateDependencies();
    if (t != null && t.type == 'expense' && !t.isTransfer) {
      ref
          .read(budgetServiceProvider)
          .checkAlerts(t.categoryId)
          .catchError((_) {});
    }
  }

  /// Deletes many transactions at once. Expands transfer pairs, clears
  /// attachments, deletes everything in a single transaction, and invalidates
  /// dependent providers exactly once — instead of N reloads for N rows.
  Future<void> deleteMany(Iterable<int> ids) async {
    final repo = ref.read(transactionRepositoryProvider);
    final attachments = ref.read(attachmentServiceProvider);

    final toDelete = <int>{};
    final affectedExpenseCategories = <String>{};

    for (final id in ids) {
      final t = await repo.getById(id);
      if (t == null) continue;
      toDelete.add(t.id);
      if (t.type == 'expense' && !t.isTransfer) {
        affectedExpenseCategories.add(t.categoryId);
      }
      if (t.isTransfer && t.transferId != null) {
        final pair = await repo.findTransferPair(t.transferId!, t.id);
        if (pair != null) toDelete.add(pair.id);
      }
    }

    if (toDelete.isEmpty) return;

    for (final id in toDelete) {
      await attachments.deleteAllForTransaction(id);
    }
    await repo.deleteByIds(toDelete.toList());

    ref.invalidateSelf();
    _invalidateDependencies();

    final budgetService = ref.read(budgetServiceProvider);
    for (final cat in affectedExpenseCategories) {
      budgetService.checkAlerts(cat).catchError((_) {});
    }
  }

  Future<void> restore(Transaction t) async {
    await ref.read(transactionRepositoryProvider).restore(t);
    ref.invalidateSelf();
    _invalidateDependencies();
    if (t.type == 'expense') {
      ref
          .read(budgetServiceProvider)
          .checkAlerts(t.categoryId)
          .catchError((_) {});
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

/// Pre-computed spending stats for the dashboard card.
final spendingStatsProvider =
    Provider<
      ({double avgDaily, double monthTotal, double projected, int daysElapsed})
    >((ref) {
      final txns = ref.watch(transactionListProvider).valueOrNull;
      if (txns == null || txns.isEmpty) {
        return (avgDaily: 0, monthTotal: 0, projected: 0, daysElapsed: 0);
      }

      final now = DateTime.now();
      final cutoff90 = now.subtract(const Duration(days: 90));
      final monthStart = DateTime(now.year, now.month, 1);
      final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

      final expenses = txns.where(
        (t) => t.type == 'expense' && !t.isTransfer && !t.isBalanceAdjustment,
      );

      final monthTotal = expenses
          .where((t) => !t.createdAt.isBefore(monthStart))
          .fold<double>(0.0, (s, t) => s + t.amount);

      final last90 = expenses
          .where((t) => !t.createdAt.isBefore(cutoff90))
          .toList();
      final last90Total = last90.fold<double>(0.0, (s, t) => s + t.amount);

      double avgDaily = 0;
      if (last90.isNotEmpty) {
        final firstDate = last90
            .map((e) => e.createdAt)
            .reduce((min, e) => e.isBefore(min) ? e : min);
        final diff = now.difference(firstDate).inDays + 1;
        final daysActive = diff.clamp(1, 90);
        avgDaily = last90Total / daysActive;
      }

      return (
        avgDaily: avgDaily,
        monthTotal: monthTotal,
        projected: avgDaily * daysInMonth,
        daysElapsed: now.day,
      );
    });
