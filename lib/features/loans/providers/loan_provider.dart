import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/schedule/processed_occurrence.dart';
import '../../../core/services/attachment_service.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/loan.dart';
import '../data/loan_repository.dart';
import '../domain/loan_engine.dart';

final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  return LoanRepository(ref.watch(isarProvider));
});

final loanListProvider = AsyncNotifierProvider<LoanListNotifier, List<Loan>>(
  LoanListNotifier.new,
);

class LoanListNotifier extends AsyncNotifier<List<Loan>> {
  @override
  FutureOr<List<Loan>> build() {
    return ref.watch(loanRepositoryProvider).getAll();
  }

  Future<int> addLoan({
    required String name,
    required String loanType,
    required String lenderName,
    String? referenceNumber,
    required double principalAmount,
    required double emiAmount,
    String? rateType,
    double? interestRate,
    DateTime? loanStartDate,
    required int billDate,
    required DateTime startDate,
    DateTime? endDate,
    bool autoAddTransaction = false,
    required String accountId,
    required String categoryId,
    String? notes,
  }) async {
    final uid = const Uuid().v4();
    final now = DateTime.now();

    final loan = Loan()
      ..uid = uid
      ..name = name.trim()
      ..loanType = loanType
      ..lenderName = lenderName.trim()
      ..referenceNumber = referenceNumber?.trim()
      ..principalAmount = principalAmount
      ..emiAmount = emiAmount
      ..rateType = rateType
      ..interestRate = interestRate
      ..loanStartDate = loanStartDate
      ..billDate = billDate
      ..startDate = startDate
      ..endDate = endDate
      ..autoAddTransaction = autoAddTransaction
      ..accountId = accountId
      ..categoryId = categoryId
      ..notes = notes
      ..createdAt = now
      ..updatedAt = now;

    final id = await ref.read(loanRepositoryProvider).save(loan);
    ref.invalidateSelf();
    return id;
  }

  Future<void> updateLoan(Loan loan) async {
    loan.updatedAt = DateTime.now();
    await ref.read(loanRepositoryProvider).save(loan);
    ref.invalidateSelf();
  }

  Future<void> deleteLoan(Loan loan) async {
    final isar = ref.read(isarProvider);
    final attachments = ref.read(attachmentServiceProvider);

    // Delete all linked transactions
    final linkedTxns = await isar.transactions
        .filter()
        .linkedRuleIdEqualTo(loan.uid)
        .linkedRuleTypeEqualTo('loan')
        .findAll();

    // Delete attachment files for linked transactions
    for (final txn in linkedTxns) {
      await attachments.deleteAllForTransaction(txn.id);
    }

    await isar.writeTxn(() async {
      await isar.transactions.deleteAll(linkedTxns.map((t) => t.id).toList());
      await isar.loans.delete(loan.id);
    });

    ref.invalidate(transactionListProvider);
    ref.invalidateSelf();
  }

  Future<void> payEmi({
    required Loan loan,
    required double amount,
    required DateTime date,
    String? accountId,
  }) async {
    final txnName = 'EMI - ${loan.name}';
    final txn = Transaction()
      ..name = txnName
      ..nameLower = txnName.toLowerCase()
      ..amount = amount
      ..type = 'expense'
      ..accountId = accountId ?? loan.accountId
      ..categoryId = loan.categoryId
      ..linkedRuleId = loan.uid
      ..linkedRuleType = 'loan'
      ..createdAt = date
      ..updatedAt = DateTime.now();

    await ref.read(transactionListProvider.notifier).add(txn);
    ref.invalidateSelf();
  }

  Future<void> payExtra({
    required Loan loan,
    required double amount,
    required DateTime date,
    String? accountId,
    String? note,
  }) async {
    final txnName = 'Extra Payment - ${loan.name}';
    final txn = Transaction()
      ..name = txnName
      ..nameLower = txnName.toLowerCase()
      ..amount = amount
      ..type = 'expense'
      ..accountId = accountId ?? loan.accountId
      ..categoryId = loan.categoryId
      ..linkedRuleId = loan.uid
      ..linkedRuleType = 'loan'
      ..notes = note
      ..createdAt = date
      ..updatedAt = DateTime.now();

    await ref.read(transactionListProvider.notifier).add(txn);
    ref.invalidateSelf();
  }

  Future<void> closeLoan({
    required Loan loan,
    required double closureAmount,
    required DateTime date,
    String? accountId,
  }) async {
    final txnName = 'Loan Closure - ${loan.name}';
    final txn = Transaction()
      ..name = txnName
      ..nameLower = txnName.toLowerCase()
      ..amount = closureAmount
      ..type = 'expense'
      ..accountId = accountId ?? loan.accountId
      ..categoryId = loan.categoryId
      ..linkedRuleId = loan.uid
      ..linkedRuleType = 'loan'
      ..createdAt = date
      ..updatedAt = DateTime.now();

    await ref.read(transactionListProvider.notifier).add(txn);

    loan
      ..isCompleted = true
      ..updatedAt = DateTime.now();
    await ref.read(loanRepositoryProvider).save(loan);
    ref.invalidateSelf();
  }
}

/// All transactions linked to a specific loan, sorted newest-first.
final loanTransactionsProvider =
    FutureProvider.family<List<Transaction>, String>((ref, loanUid) async {
      final all = await ref.watch(transactionListProvider.future);
      return all
          .where((t) => t.linkedRuleId == loanUid && t.linkedRuleType == 'loan')
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });

/// Deleted EMI days per loan uid (see [deletedEmiDays]). Refreshes with the
/// transaction list (a delete or a background run changes both).
final loanDeletedDaysProvider = FutureProvider<Map<String, Set<int>>>((ref) async {
  final txns = await ref.watch(transactionListProvider.future);
  final ledger = await ref
      .watch(isarProvider)
      .processedOccurrences
      .filter()
      .sourceTypeEqualTo('loan')
      .statusEqualTo('posted')
      .findAll();
  final ids = txns.map((t) => t.id).toSet();
  final out = <String, Set<int>>{};
  for (final p in ledger) {
    final d = deletedEmiDays([p], ids);
    if (d.isNotEmpty) (out[p.sourceId] ??= {}).addAll(d);
  }
  return out;
});

final loanRecordsProvider = Provider.family<LoanRecords, String>((ref, uid) {
  final linked = ref.watch(loanTransactionsProvider(uid)).valueOrNull ?? const <Transaction>[];
  final deleted = ref.watch(loanDeletedDaysProvider).valueOrNull?[uid] ?? const <int>{};
  return (linked: linked, deleted: deleted);
});

/// Summary: total outstanding and total paid.
final loanSummaryProvider =
    FutureProvider<({double outstanding, double totalPaid})>((ref) async {
      final loans = await ref.watch(loanListProvider.future);
      final txns = await ref.watch(transactionListProvider.future);
      final deleted = await ref.watch(loanDeletedDaysProvider.future);
      // vNext (approved fix L3): outstanding from each loan's schedule;
      // loans tracked by EMI only have no outstanding.
      var outstanding = 0.0, paid = 0.0;
      for (final l in loans) {
        final linked = txns
            .where((t) => t.linkedRuleType == 'loan' && t.linkedRuleId == l.uid)
            .toList();
        paid += linked.fold(0.0, (s, t) => s + t.amount);
        final st = loanStatus(l, linked, deletedDays: deleted[l.uid] ?? const {});
        if (!st.closed) outstanding += st.outstanding ?? 0;
      }
      return (outstanding: outstanding, totalPaid: paid);
    });
