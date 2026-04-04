import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/isar_service.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/ledger.dart';
import '../data/ledger_repository.dart';
import '../utils/ledger_calculations.dart' as calc;

final ledgerRepositoryProvider = Provider<LedgerRepository>((ref) {
  return LedgerRepository(ref.watch(isarProvider));
});

final ledgerListProvider =
    AsyncNotifierProvider<LedgerListNotifier, List<Ledger>>(
  LedgerListNotifier.new,
);

class LedgerListNotifier extends AsyncNotifier<List<Ledger>> {
  @override
  FutureOr<List<Ledger>> build() {
    return ref.watch(ledgerRepositoryProvider).getAll();
  }

  Future<int> addLedger({
    required String personName,
    required String type,
    required double amount,
    required String accountId,
    required String categoryId,
    String? notes,
    DateTime? expectedDate,
    DateTime? createdAt,
  }) async {
    final uid = const Uuid().v4();
    final now = createdAt ?? DateTime.now();

    final ledger = Ledger()
      ..uid = uid
      ..personName = personName.trim()
      ..personNameLower = personName.trim().toLowerCase()
      ..type = type
      ..originalAmount = amount
      ..accountId = accountId
      ..categoryId = categoryId
      ..notes = notes
      ..expectedDate = expectedDate
      ..createdAt = now
      ..updatedAt = DateTime.now();

    final id = await ref.read(ledgerRepositoryProvider).save(ledger);

    // Create the initial transaction
    final txnName = type == 'lent'
        ? 'Lent to ${personName.trim()}'
        : 'Borrowed from ${personName.trim()}';
    final txnType = type == 'lent' ? 'expense' : 'income';

    final txn = Transaction()
      ..name = txnName
      ..nameLower = txnName.toLowerCase()
      ..amount = amount
      ..type = txnType
      ..accountId = accountId
      ..categoryId = categoryId
      ..linkedRuleId = uid
      ..linkedRuleType = type
      ..createdAt = now
      ..updatedAt = DateTime.now();

    await ref.read(transactionListProvider.notifier).add(txn);
    ref.invalidateSelf();
    return id;
  }

  Future<void> updateLedger({
    required Ledger ledger,
    required String personName,
    required double amount,
    required String accountId,
    required String categoryId,
    String? notes,
    DateTime? expectedDate,
  }) async {
    ledger
      ..personName = personName.trim()
      ..personNameLower = personName.trim().toLowerCase()
      ..originalAmount = amount
      ..accountId = accountId
      ..categoryId = categoryId
      ..notes = notes
      ..expectedDate = expectedDate
      ..updatedAt = DateTime.now();

    await ref.read(ledgerRepositoryProvider).save(ledger);

    // Update the initial transaction
    final allTxns = await ref.read(transactionListProvider.future);
    final initialTxn = allTxns.firstWhere(
      (t) =>
          t.linkedRuleId == ledger.uid &&
          (t.name.toLowerCase().startsWith('lent to') ||
              t.name.toLowerCase().startsWith('borrowed from')),
      orElse: () => allTxns.firstWhere((t) => t.linkedRuleId == ledger.uid),
    );

    final txnName = ledger.type == 'lent'
        ? 'Lent to ${personName.trim()}'
        : 'Borrowed from ${personName.trim()}';

    initialTxn
      ..name = txnName
      ..nameLower = txnName.toLowerCase()
      ..amount = amount
      ..accountId = accountId
      ..categoryId = categoryId
      ..updatedAt = DateTime.now();

    await ref.read(transactionListProvider.notifier).updateTransaction(initialTxn);
    ref.invalidateSelf();
  }

  Future<void> deleteLedger(Ledger ledger) async {
    final isar = ref.read(isarProvider);

    // Delete all linked transactions
    final linkedTxns = await isar.transactions
        .filter()
        .linkedRuleIdEqualTo(ledger.uid)
        .findAll();

    await isar.writeTxn(() async {
      await isar.transactions
          .deleteAll(linkedTxns.map((t) => t.id).toList());
      await isar.ledgers.delete(ledger.id);
    });

    ref.invalidate(transactionListProvider);
    ref.invalidateSelf();
  }

  Future<void> addPayment({
    required Ledger ledger,
    required double amount,
    required String accountId,
    DateTime? date,
  }) async {
    final txnName = 'Payment — ${ledger.personName}';
    // Lent: money coming back = income. Borrowed: money going out = expense.
    final txnType = ledger.type == 'lent' ? 'income' : 'expense';

    final txn = Transaction()
      ..name = txnName
      ..nameLower = txnName.toLowerCase()
      ..amount = amount
      ..type = txnType
      ..accountId = accountId
      ..categoryId = ledger.categoryId
      ..linkedRuleId = ledger.uid
      ..linkedRuleType = ledger.type
      ..createdAt = date ?? DateTime.now()
      ..updatedAt = DateTime.now();

    await ref.read(transactionListProvider.notifier).add(txn);
    ref.invalidateSelf();
  }

  Future<void> markSettled({
    required Ledger ledger,
    required String accountId,
  }) async {
    final allTxns = await ref.read(transactionListProvider.future);
    final remaining = calc.computeRemaining(ledger, allTxns);

    if (remaining > 0) {
      await addPayment(
        ledger: ledger,
        amount: remaining,
        accountId: accountId,
      );
    }

    ledger
      ..isSettled = true
      ..updatedAt = DateTime.now();
    await ref.read(ledgerRepositoryProvider).save(ledger);
    ref.invalidateSelf();
  }
}

/// All transactions linked to a specific ledger, sorted newest-first.
final ledgerTransactionsProvider =
    FutureProvider.family<List<Transaction>, String>((ref, ledgerUid) async {
  final all = await ref.watch(transactionListProvider.future);
  return all
      .where((t) => t.linkedRuleId == ledgerUid)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

/// Payment transactions only (excluding initial) for a ledger.
final ledgerPaymentsProvider =
    FutureProvider.family<List<Transaction>, String>((ref, ledgerUid) async {
  final all = await ref.watch(transactionListProvider.future);
  return all.where((t) {
    if (t.linkedRuleId != ledgerUid) return false;
    final lower = t.name.toLowerCase();
    return !lower.startsWith('lent to') && !lower.startsWith('borrowed from');
  }).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

/// Distinct person names for autocomplete.
final ledgerPersonNamesProvider = FutureProvider<List<String>>((ref) async {
  ref.watch(ledgerListProvider);
  return ref.read(ledgerRepositoryProvider).getDistinctPersonNames();
});

/// Summary: total to receive and total owed.
final ledgerSummaryProvider = FutureProvider<({double toReceive, double owed})>((ref) async {
  final ledgers = await ref.watch(ledgerListProvider.future);
  final txns = await ref.watch(transactionListProvider.future);
  return (
    toReceive: calc.totalToReceive(ledgers, txns),
    owed: calc.totalOwed(ledgers, txns),
  );
});
