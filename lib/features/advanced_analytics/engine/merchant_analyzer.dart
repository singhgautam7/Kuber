part of 'analytics_engine_adapter.dart';

class MerchantAnalysisResult {
  final int merchantCount;
  final double totalSpend;
  final List<MerchantRow> topMerchants;
  final List<MerchantRow> newMerchants;
  final List<MerchantRow> risingMerchants;

  const MerchantAnalysisResult({
    required this.merchantCount,
    required this.totalSpend,
    required this.topMerchants,
    required this.newMerchants,
    required this.risingMerchants,
  });
}

class MerchantRow {
  final String name;
  final double total;
  final int count;
  final DateTime lastVisit;
  final Set<String> categoryIds;
  final double trendPercent;

  const MerchantRow({
    required this.name,
    required this.total,
    required this.count,
    required this.lastVisit,
    required this.categoryIds,
    required this.trendPercent,
  });

  double get average => count == 0 ? 0 : total / count;
}

MerchantAnalysisResult computeMerchantAnalysis(AnalyticsInput input) {
  final current = _expensesInRange(input.transactions, input.range);
  final previousRange = AnalyticsRange(
    input.range.from.subtract(Duration(days: input.range.inclusiveDays)),
    input.range.from.subtract(const Duration(days: 1)),
  );
  final previous = _expensesInRange(input.transactions, previousRange);
  final previousTotals = <String, double>{};
  for (final t in previous) {
    previousTotals[t.name] = (previousTotals[t.name] ?? 0) + t.amount;
  }

  final rows = _merchantRows(current, previousTotals);
  final firstSeen = <String, DateTime>{};
  for (final t
      in input.transactions
          .map(_Txn.new)
          .where((t) => t.type == 'expense' && !_skip(t))) {
    final currentFirst = firstSeen[t.name];
    if (currentFirst == null || t.date.isBefore(currentFirst)) {
      firstSeen[t.name] = t.date;
    }
  }
  final newCutoff = input.now.subtract(const Duration(days: 92));
  final newRows = rows
      .where((r) => !(firstSeen[r.name]?.isBefore(newCutoff) ?? true))
      .toList();
  final rising = rows.where((r) => r.trendPercent > 40).toList();

  return MerchantAnalysisResult(
    merchantCount: rows.length,
    totalSpend: current.fold<double>(0, (sum, t) => sum + t.amount),
    topMerchants: rows,
    newMerchants: newRows.take(5).toList(),
    risingMerchants: rising.take(5).toList(),
  );
}

List<MerchantRow> _merchantRows(
  List<_Txn> txns,
  Map<String, double> previousTotals,
) {
  final mutable = <String, _MerchantMutable>{};
  for (final t in txns) {
    final m = mutable.putIfAbsent(t.name, () => _MerchantMutable(t.name));
    m.total += t.amount;
    m.count++;
    m.categoryIds.add(t.categoryId);
    if (m.lastVisit == null || t.date.isAfter(m.lastVisit!)) {
      m.lastVisit = t.date;
    }
  }
  final rows = mutable.values.map((m) {
    final prev = previousTotals[m.name] ?? 0;
    return MerchantRow(
      name: m.name,
      total: m.total,
      count: m.count,
      lastVisit: m.lastVisit ?? DateTime.fromMillisecondsSinceEpoch(0),
      categoryIds: Set.unmodifiable(m.categoryIds),
      trendPercent: prev <= 0 ? 0 : ((m.total - prev) / prev) * 100,
    );
  }).toList()..sort((a, b) => b.total.compareTo(a.total));
  return rows;
}

class _MerchantMutable {
  final String name;
  var total = 0.0;
  var count = 0;
  DateTime? lastVisit;
  final categoryIds = <String>{};

  _MerchantMutable(this.name);
}
