enum ExportType { transactions, analytics }

enum ExportFormat { csv, pdf }

// ---------------------------------------------------------------------------
// Transaction export data (isolate-safe)
// ---------------------------------------------------------------------------

class TransactionRow {
  final DateTime date;
  final String name;
  final double amount;
  final String type; // 'income' | 'expense'
  final String categoryName;
  final String accountName;
  final String? notes;
  final bool isTransfer;
  final String? fromAccountName;
  final String? toAccountName;

  const TransactionRow({
    required this.date,
    required this.name,
    required this.amount,
    required this.type,
    required this.categoryName,
    required this.accountName,
    this.notes,
    this.isTransfer = false,
    this.fromAccountName,
    this.toAccountName,
  });
}

class TransactionExportData {
  final List<TransactionRow> rows;
  final String userName;
  final String currencyCode;
  final String currencySymbol;
  final String periodLabel;
  final int totalCount;
  final String? accountFilter;
  final String? categoryFilter;
  final String? searchFilter;

  const TransactionExportData({
    required this.rows,
    required this.userName,
    required this.currencyCode,
    required this.currencySymbol,
    required this.periodLabel,
    required this.totalCount,
    this.accountFilter,
    this.categoryFilter,
    this.searchFilter,
  });
}

// ---------------------------------------------------------------------------
// Analytics export data (isolate-safe)
// ---------------------------------------------------------------------------

class CategoryBreakdownRow {
  final String name;
  final String type; // 'income' | 'expense'
  final double amount;
  final double percentage;
  final int txnCount;

  const CategoryBreakdownRow({
    required this.name,
    required this.type,
    required this.amount,
    required this.percentage,
    required this.txnCount,
  });
}

class DailyTotalRow {
  final DateTime date;
  final double income;
  final double expense;
  final double net;

  const DailyTotalRow({
    required this.date,
    required this.income,
    required this.expense,
    required this.net,
  });
}

class InsightRow {
  final String emoji;
  final String message;
  final String typeLabel;

  const InsightRow({
    required this.emoji,
    required this.message,
    required this.typeLabel,
  });
}

class BarBucketRow {
  final String label;
  final double income;
  final double expense;

  const BarBucketRow({
    required this.label,
    required this.income,
    required this.expense,
  });
}

class AnalyticsExportData {
  final String userName;
  final String currencyCode;
  final String currencySymbol;
  final String periodLabel;
  final double totalIncome;
  final double totalExpense;
  final double netAmount;
  final double savingsRate;
  final List<CategoryBreakdownRow> categoryBreakdown;
  final List<DailyTotalRow> dailyTotals;
  final List<InsightRow> insights;
  final List<BarBucketRow> barBuckets;

  const AnalyticsExportData({
    required this.userName,
    required this.currencyCode,
    required this.currencySymbol,
    required this.periodLabel,
    required this.totalIncome,
    required this.totalExpense,
    required this.netAmount,
    required this.savingsRate,
    required this.categoryBreakdown,
    required this.dailyTotals,
    required this.insights,
    required this.barBuckets,
  });
}
