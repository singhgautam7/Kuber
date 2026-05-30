import '../data/transaction.dart';

extension TransactionFilterX on Iterable<Transaction> {
  /// Returns an Iterable of transactions valid for gross calculations
  /// (Income, Expense, Net summaries).
  /// Excludes:
  /// - All legs of Transfers
  /// - Balance Adjustments
  ///
  /// Note: This returns a lazy Iterable map, meaning no extra passes are made
  /// over the data until iterated (e.g. via .toList() or in a for loop).
  Iterable<Transaction> get validForCalculations {
    return where((t) => !t.isTransfer && !t.isBalanceAdjustment);
  }

  /// Returns an Iterable of transactions valid for displaying in a
  /// timeline/history feed.
  /// Excludes:
  /// - The 'income' leg of a Transfer to avoid duplicates (the expense
  ///   leg represents the transfer event in the UI)
  /// - Balance Adjustments
  Iterable<Transaction> get validForFeed {
    return where(
      (t) => !(t.isTransfer && t.type == 'income') && !t.isBalanceAdjustment,
    );
  }
}

/// Maps each transfer leg's transaction id to the *other* leg's `accountId`.
///
/// Built once per list so a transfer row can render "FROM → TO" with an O(1)
/// lookup instead of scanning the whole transaction list on every build.
Map<int, String> buildTransferPairAccountIds(Iterable<Transaction> txns) {
  final byTransferId = <String, List<Transaction>>{};
  for (final t in txns) {
    if (t.isTransfer && t.transferId != null) {
      byTransferId.putIfAbsent(t.transferId!, () => []).add(t);
    }
  }

  final result = <int, String>{};
  for (final legs in byTransferId.values) {
    if (legs.length < 2) continue;
    for (final leg in legs) {
      final other = legs.firstWhere((l) => l.id != leg.id, orElse: () => leg);
      if (other.id != leg.id) result[leg.id] = other.accountId;
    }
  }
  return result;
}

/// Shared filter shape for aggregating transactions into a period summary.
/// Used by Home's monthly hero, the Categories hero, and any future screen
/// that needs income/expense/net for a date window — pass the same filter
/// instead of re-implementing the loop.
class TxnPeriodFilter {
  /// Inclusive lower bound on `createdAt`. `null` = no lower bound.
  final DateTime? from;

  /// Exclusive upper bound on `createdAt`. `null` = no upper bound.
  final DateTime? to;

  /// If set, only include transactions whose `categoryId` matches. Pass the
  /// stringified category id (transactions store categoryId as a String).
  final String? categoryId;

  /// When `true`, drop transactions linked to a recurring / loan / lend /
  /// borrow / investment rule. Defaults to `false` so behaviour matches the
  /// Home monthly summary — EMI, SIP, and recurring charges count as real
  /// cashflow there.
  final bool excludeLinkedRule;

  const TxnPeriodFilter({
    this.from,
    this.to,
    this.categoryId,
    this.excludeLinkedRule = false,
  });
}

/// Aggregate of a transaction set over a period — what Home's balance hero
/// and the Categories hero both render.
class TxnPeriodAggregate {
  /// Sum of `type == 'income'` amounts.
  final double income;

  /// Sum of `type == 'expense'` amounts.
  final double expense;

  /// Per-category expense totals, keyed by `categoryId` (String, as stored).
  final Map<String, double> spendingByCategory;

  /// Per-category transaction counts (income + expense), keyed by `categoryId`.
  final Map<String, int> txnCountByCategory;

  /// `income - expense`.
  double get net => income - expense;

  const TxnPeriodAggregate({
    required this.income,
    required this.expense,
    required this.spendingByCategory,
    required this.txnCountByCategory,
  });
}

extension TransactionAggregateX on Iterable<Transaction> {
  /// Sum income, expense, and per-category spend for a given period/filter.
  ///
  /// Always drops transfers and balance adjustments (same baseline as
  /// `validForCalculations`). Extra inclusion rules come from `filter`.
  ///
  /// Single pass over the source iterable.
  TxnPeriodAggregate aggregate(TxnPeriodFilter filter) {
    double income = 0;
    double expense = 0;
    final spendingByCategory = <String, double>{};
    final txnCountByCategory = <String, int>{};

    for (final t in this) {
      if (t.isTransfer || t.isBalanceAdjustment) continue;
      if (filter.excludeLinkedRule && t.linkedRuleType != null) continue;
      if (filter.categoryId != null && t.categoryId != filter.categoryId) {
        continue;
      }
      final date = t.createdAt;
      if (filter.from != null && date.isBefore(filter.from!)) continue;
      if (filter.to != null && !date.isBefore(filter.to!)) continue;

      txnCountByCategory[t.categoryId] =
          (txnCountByCategory[t.categoryId] ?? 0) + 1;

      if (t.type == 'income') {
        income += t.amount;
      } else if (t.type == 'expense') {
        expense += t.amount;
        spendingByCategory[t.categoryId] =
            (spendingByCategory[t.categoryId] ?? 0) + t.amount;
      }
    }

    return TxnPeriodAggregate(
      income: income,
      expense: expense,
      spendingByCategory: spendingByCategory,
      txnCountByCategory: txnCountByCategory,
    );
  }
}
