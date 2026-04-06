import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/services/attachment_service.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/loan.dart';
import '../data/loan_repository.dart';
import '../utils/loan_calculations.dart' as calc;

final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  return LoanRepository(ref.watch(isarProvider));
});

final loanListProvider =
    AsyncNotifierProvider<LoanListNotifier, List<Loan>>(
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
    final txnName = 'EMI — ${loan.name}';
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
    final txnName = 'Extra Payment — ${loan.name}';
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
    final txnName = 'Loan Closure — ${loan.name}';
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

/// Summary: total outstanding and total paid.
final loanSummaryProvider =
    FutureProvider<({double outstanding, double totalPaid})>((ref) async {
  final loans = await ref.watch(loanListProvider.future);
  final txns = await ref.watch(transactionListProvider.future);
  return (
    outstanding: calc.totalOutstanding(loans, txns),
    totalPaid: calc.totalPaidAllLoans(loans, txns),
  );
});
