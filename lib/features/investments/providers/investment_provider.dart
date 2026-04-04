import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/isar_service.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/investment.dart';
import '../data/investment_repository.dart';
import '../utils/investment_calculations.dart' as calc;

final investmentRepositoryProvider = Provider<InvestmentRepository>((ref) {
  return InvestmentRepository(ref.watch(isarProvider));
});

final investmentListProvider =
    AsyncNotifierProvider<InvestmentListNotifier, List<Investment>>(
  InvestmentListNotifier.new,
);

class InvestmentListNotifier extends AsyncNotifier<List<Investment>> {
  @override
  FutureOr<List<Investment>> build() {
    return ref.watch(investmentRepositoryProvider).getAll();
  }

  Future<int> addInvestment({
    required String name,
    required String investmentType,
    double? currentValue,
    bool autoDebit = false,
    double? sipAmount,
    int? sipDate,
    String? accountId,
    required String categoryId,
    String? notes,
    double initialAmount = 0,
  }) async {
    final uid = const Uuid().v4();
    final now = DateTime.now();

    final investment = Investment()
      ..uid = uid
      ..name = name.trim()
      ..investmentType = investmentType
      ..currentValue = currentValue
      ..autoDebit = autoDebit
      ..sipAmount = sipAmount
      ..sipDate = sipDate
      ..accountId = accountId
      ..categoryId = categoryId
      ..notes = notes
      ..createdAt = now
      ..updatedAt = now;

    final id = await ref.read(investmentRepositoryProvider).save(investment);

    // Create initial contribution if amount > 0
    if (initialAmount > 0 && accountId != null) {
      final txnName = 'Contribution — ${name.trim()}';
      final txn = Transaction()
        ..name = txnName
        ..nameLower = txnName.toLowerCase()
        ..amount = initialAmount
        ..type = 'expense'
        ..accountId = accountId
        ..categoryId = categoryId
        ..linkedRuleId = uid
        ..linkedRuleType = 'investment'
        ..createdAt = now
        ..updatedAt = now;

      await ref.read(transactionListProvider.notifier).add(txn);
    }

    ref.invalidateSelf();
    return id;
  }

  Future<void> updateInvestment(Investment investment) async {
    investment.updatedAt = DateTime.now();
    await ref.read(investmentRepositoryProvider).save(investment);
    ref.invalidateSelf();
  }

  Future<void> updateCurrentValue(Investment investment, double? newValue) async {
    investment
      ..currentValue = newValue
      ..updatedAt = DateTime.now();
    await ref.read(investmentRepositoryProvider).save(investment);
    ref.invalidateSelf();
  }

  Future<void> deleteInvestment(Investment investment) async {
    final isar = ref.read(isarProvider);

    final linkedTxns = await isar.transactions
        .filter()
        .linkedRuleIdEqualTo(investment.uid)
        .linkedRuleTypeEqualTo('investment')
        .findAll();

    await isar.writeTxn(() async {
      await isar.transactions.deleteAll(linkedTxns.map((t) => t.id).toList());
      await isar.investments.delete(investment.id);
    });

    ref.invalidate(transactionListProvider);
    ref.invalidateSelf();
  }

  Future<void> addContribution({
    required Investment investment,
    required double amount,
    required DateTime date,
    required String accountId,
    String? note,
  }) async {
    final txnName = 'Contribution — ${investment.name}';
    final txn = Transaction()
      ..name = txnName
      ..nameLower = txnName.toLowerCase()
      ..amount = amount
      ..type = 'expense'
      ..accountId = accountId
      ..categoryId = investment.categoryId
      ..linkedRuleId = investment.uid
      ..linkedRuleType = 'investment'
      ..notes = note
      ..createdAt = date
      ..updatedAt = DateTime.now();

    await ref.read(transactionListProvider.notifier).add(txn);
    ref.invalidateSelf();
  }
}

/// All transactions linked to a specific investment, sorted newest-first.
final investmentTransactionsProvider =
    FutureProvider.family<List<Transaction>, String>((ref, investmentUid) async {
  final all = await ref.watch(transactionListProvider.future);
  return all
      .where((t) =>
          t.linkedRuleId == investmentUid && t.linkedRuleType == 'investment')
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

/// Summary: total invested, current value, gain/loss.
final investmentSummaryProvider = FutureProvider<
    ({double totalInvested, double currentValue, double gainLoss, int assetCount})>(
    (ref) async {
  final investments = await ref.watch(investmentListProvider.future);
  final txns = await ref.watch(transactionListProvider.future);
  return (
    totalInvested: calc.totalInvestedAll(investments, txns),
    currentValue: calc.totalCurrentValueAll(investments),
    gainLoss: calc.totalGainLossAll(investments, txns),
    assetCount: calc.totalAssetCount(investments),
  );
});
