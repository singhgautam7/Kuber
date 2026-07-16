part of 'analytics_engine_adapter.dart';

class AnomalyResult {
  final List<AnomalyItem> items;

  const AnomalyResult({required this.items});
}

class AnomalyItem {
  final String title;
  final String description;
  final String tone;
  final double significance;

  const AnomalyItem({
    required this.title,
    required this.description,
    required this.tone,
    required this.significance,
  });
}

final _anomalyInr =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

AnomalyResult computeAnomalies(AnalyticsInput input) {
  final now = input.now;
  final currentStart = DateTime(now.year, now.month, 1);
  final prevStart = DateTime(now.year, now.month - 1, 1);
  final current = _summary(
    input.transactions,
    currentStart,
    _endInclusive(now),
  );
  final previous = _summary(input.transactions, prevStart, currentStart);

  // Resolve real category names (transactions store a stringified category id).
  final nameById = <String, String>{
    for (final c in input.categories)
      '${c['id']}': (c['name'] as String?) ?? 'A category',
  };
  String catName(String id) => nameById[id] ?? 'A category';

  final items = <AnomalyItem>[];
  for (final id in {
    ...current.categorySpend.keys,
    ...previous.categorySpend.keys,
  }) {
    final curr = current.categorySpend[id] ?? 0;
    final prev = previous.categorySpend[id] ?? 0;
    final delta = curr - prev;
    if (prev > 0 && curr > prev * 2 && delta > 500) {
      items.add(
        AnomalyItem(
          title: '${catName(id)} spending is up',
          description:
              'You spent ${_anomalyInr.format(curr)} on ${catName(id)} this '
              'month vs ${_anomalyInr.format(prev)} last month.',
          tone: 'warning',
          significance: delta,
        ),
      );
    } else if (prev > 500 && curr < prev * 0.5) {
      items.add(
        AnomalyItem(
          title: '${catName(id)} spending is down',
          description:
              'You spent ${_anomalyInr.format(curr)} on ${catName(id)} this '
              'month vs ${_anomalyInr.format(prev)} last month.',
          tone: 'positive',
          significance: prev - curr,
        ),
      );
    }
  }
  final catAmounts = <String, List<double>>{};
  for (final t
      in input.transactions
          .map(_Txn.new)
          .where((t) => t.type == 'expense' && !_skip(t))) {
    (catAmounts[t.categoryId] ??= []).add(t.amount);
  }
  for (final t
      in input.transactions
          .map(_Txn.new)
          .where(
            (t) =>
                t.type == 'expense' &&
                !_skip(t) &&
                !t.date.isBefore(currentStart),
          )) {
    final amounts = catAmounts[t.categoryId] ?? const [];
    if (amounts.length < 4) continue;
    final avg = amounts.fold<double>(0, (a, b) => a + b) / amounts.length;
    if (avg > 0 && t.amount >= avg * 5) {
      items.add(
        AnomalyItem(
          title: 'Unusually large transaction',
          description:
              '${_anomalyInr.format(t.amount)} at ${t.name} is much larger '
              'than your usual ${catName(t.categoryId)} spend.',
          tone: 'warning',
          significance: t.amount - avg,
        ),
      );
    }
  }
  items.sort((a, b) => b.significance.compareTo(a.significance));
  return AnomalyResult(items: items.take(5).toList());
}
