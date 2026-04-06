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
    return where((t) => !(t.isTransfer && t.type == 'income') && !t.isBalanceAdjustment);
  }
}
