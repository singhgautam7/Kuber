import 'package:collection/collection.dart';
import '../../../core/utils/insight_helpers.dart';
import '../../categories/data/category.dart';
import '../../insights/models/insight.dart';
import '../../transactions/data/transaction.dart';

class InsightEngine {
  final List<Transaction> allTransactions;
  final List<Category> categories;
  final String currencySymbol;

  InsightEngine({
    required this.allTransactions,
    required this.categories,
    required this.currencySymbol,
  });

  List<KuberInsight> generate() {
    final insights = <KuberInsight>[
      ..._weekdayPattern(),
      ..._topCategory(),
      ..._categoryTrend(),
      ..._monthComparison(),
      ..._weekendVsWeekday(),
      ..._biggestExpense(),
      ..._savingsTrend(),
      ..._recurringBurden(),
      ..._spendingFreeStreak(),
    ];

    // Deduplicate by type — keep highest confidence
    final byType = <InsightType, KuberInsight>{};
    for (final i in insights) {
      final existing = byType[i.type];
      if (existing == null || i.confidence > existing.confidence) {
        byType[i.type] = i;
      }
    }

    final result = byType.values.toList()
      ..sort((a, b) => b.confidence.compareTo(a.confidence));

    if (result.isEmpty) return _fallback();
    return result;
  }

  // ── 1. Weekday pattern ──────────────────────────────────────────────

  List<KuberInsight> _weekdayPattern() {
    final recent = window(allTransactions, days: 60);
    if (recent.length < 7) return [];

    final totals = <int, double>{};
    final counts = <int, int>{};
    for (final t in recent) {
      final wd = t.createdAt.weekday;
      totals[wd] = (totals[wd] ?? 0) + t.amount;
      counts[wd] = (counts[wd] ?? 0) + 1;
    }

    final avgPerDay = <int, double>{};
    for (final wd in totals.keys) {
      avgPerDay[wd] = totals[wd]! / (counts[wd] ?? 1);
    }

    final overallAvg = totals.values.fold<double>(0, (a, b) => a + b) / 7;
    if (overallAvg == 0) return [];

    int peakDay = 1;
    double peakAvg = 0;
    for (final e in avgPerDay.entries) {
      if (e.value > peakAvg) {
        peakAvg = e.value;
        peakDay = e.key;
      }
    }

    final pctAbove = ((peakAvg - overallAvg) / overallAvg) * 100;
    if (pctAbove < 15) return [];

    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    final dayName = days[peakDay - 1];

    return [
      KuberInsight(
        type: InsightType.weekdayPattern,
        message: 'You spend ${formatDelta(pctAbove)} on ${dayName}s',
        emoji: '⚡',
        confidence: (pctAbove / 100).clamp(0.3, 0.95),
        isPositive: false,
      ),
    ];
  }

  // ── 2. Top category ─────────────────────────────────────────────────

  List<KuberInsight> _topCategory() {
    final recent = window(allTransactions, days: 30);
    if (recent.length < 3) return [];

    final catTotals = <String, double>{};
    for (final t in recent) {
      catTotals[t.categoryId] = (catTotals[t.categoryId] ?? 0) + t.amount;
    }
    if (catTotals.isEmpty) return [];

    final sorted = catTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEntry = sorted.first;
    final total = catTotals.values.fold<double>(0, (a, b) => a + b);
    final pct = (topEntry.value / total) * 100;

    final catId = int.tryParse(topEntry.key);
    final cat = categories.firstWhereOrNull((c) => c.id == catId);
    final catName = cat?.name ?? 'Unknown';

    return [
      KuberInsight(
        type: InsightType.topCategory,
        message: '${pct.toInt()}% of spending goes to $catName',
        emoji: '🏷️',
        confidence: (pct / 100).clamp(0.3, 0.9),
        isPositive: false,
      ),
    ];
  }

  // ── 3. Category trend ───────────────────────────────────────────────

  List<KuberInsight> _categoryTrend() {
    final thisMonth = window(allTransactions, days: 30);
    final lastMonth = _windowRange(days: 60, excludeLastDays: 30);
    if (thisMonth.length < 3 || lastMonth.length < 3) return [];

    final thisMonthCat = _groupByCategory(thisMonth);
    final lastMonthCat = _groupByCategory(lastMonth);

    KuberInsight? best;
    for (final catId in thisMonthCat.keys) {
      final curr = thisMonthCat[catId]!;
      final prev = lastMonthCat[catId];
      if (prev == null || prev == 0) continue;
      final pctChange = ((curr - prev) / prev) * 100;
      if (pctChange.abs() < 20) continue;

      final cId = int.tryParse(catId);
      final cat = categories.firstWhereOrNull((c) => c.id == cId);
      final catName = cat?.name ?? 'Unknown';
      final isUp = pctChange > 0;

      final insight = KuberInsight(
        type: InsightType.categoryTrend,
        message: '$catName spending is ${formatDelta(pctChange)} vs last month',
        emoji: isUp ? '📈' : '📉',
        confidence: (pctChange.abs() / 200).clamp(0.3, 0.9),
        isPositive: !isUp,
      );

      if (best == null || insight.confidence > best.confidence) {
        best = insight;
      }
    }

    return best != null ? [best] : [];
  }

  // ── 4. Month comparison ─────────────────────────────────────────────

  List<KuberInsight> _monthComparison() {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final dayOfMonth = now.day;
    final lastMonthSameDay = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month - 1,
        lastMonthSameDay.day + dayOfMonth - 1);

    double currentSpend = 0;
    double lastSpend = 0;

    for (final t in allTransactions) {
      if (t.type != 'expense' || t.type == 'transfer') continue;
      if (!t.createdAt.isBefore(currentMonthStart) &&
          t.createdAt.day <= dayOfMonth) {
        currentSpend += t.amount;
      } else if (!t.createdAt.isBefore(lastMonthSameDay) &&
          t.createdAt.isBefore(lastMonthEnd.add(const Duration(days: 1)))) {
        lastSpend += t.amount;
      }
    }

    if (lastSpend == 0) return [];
    final pctChange = ((currentSpend - lastSpend) / lastSpend) * 100;
    if (pctChange.abs() < 5) return [];

    final isUp = pctChange > 0;

    return [
      KuberInsight(
        type: InsightType.monthComparison,
        message: isUp
            ? 'Spending is ${formatDelta(pctChange)} vs this point last month'
            : 'Spending is ${formatDelta(pctChange)} vs this point last month',
        emoji: isUp ? '📈' : '📉',
        confidence: (pctChange.abs() / 100).clamp(0.3, 0.9),
        isPositive: !isUp,
      ),
    ];
  }

  // ── 5. Weekend vs weekday ───────────────────────────────────────────

  List<KuberInsight> _weekendVsWeekday() {
    final recent = window(allTransactions, days: 30);
    if (recent.length < 10) return [];

    double weekendTotal = 0;
    int weekendDays = 0;
    double weekdayTotal = 0;
    int weekdayDays = 0;

    // Count actual weekend/weekday days in last 30 days
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final d = now.subtract(Duration(days: i));
      if (d.weekday >= 6) {
        weekendDays++;
      } else {
        weekdayDays++;
      }
    }

    for (final t in recent) {
      if (t.createdAt.weekday >= 6) {
        weekendTotal += t.amount;
      } else {
        weekdayTotal += t.amount;
      }
    }

    if (weekendDays == 0 || weekdayDays == 0) return [];
    final weekendAvg = weekendTotal / weekendDays;
    final weekdayAvg = weekdayTotal / weekdayDays;
    if (weekdayAvg == 0) return [];

    final pctDiff = ((weekendAvg - weekdayAvg) / weekdayAvg) * 100;
    if (pctDiff.abs() < 20) return [];

    final moreOnWeekend = pctDiff > 0;

    return [
      KuberInsight(
        type: InsightType.weekendVsWeekday,
        message: moreOnWeekend
            ? 'Weekend spending is ${formatDelta(pctDiff)} than weekdays'
            : 'Weekday spending is ${formatDelta(-pctDiff)} than weekends',
        emoji: moreOnWeekend ? '🎉' : '💼',
        confidence: (pctDiff.abs() / 100).clamp(0.3, 0.85),
        isPositive: !moreOnWeekend,
      ),
    ];
  }

  // ── 6. Biggest expense ──────────────────────────────────────────────

  List<KuberInsight> _biggestExpense() {
    final recent = window(allTransactions, days: 30);
    if (recent.length < 3) return [];

    final amounts = recent.map((t) => t.amount).toList();
    final cleaned = removeOutliers(amounts);
    final med = median(cleaned);
    if (med == 0) return [];

    final biggest = recent.reduce((a, b) => a.amount > b.amount ? a : b);
    final ratio = biggest.amount / med;
    if (ratio < 2) return [];

    return [
      KuberInsight(
        type: InsightType.biggestExpense,
        message:
            '${biggest.name} ($currencySymbol${biggest.amount.toStringAsFixed(0)}) was ${ratio.toStringAsFixed(1)}× your typical spend',
        emoji: '💸',
        confidence: (ratio / 10).clamp(0.4, 0.9),
        isPositive: false,
      ),
    ];
  }

  // ── 7. Savings trend ────────────────────────────────────────────────

  List<KuberInsight> _savingsTrend() {
    final now = DateTime.now();
    if (allTransactions.length < 10) return [];

    double thisIncome = 0, thisExpense = 0;
    double lastIncome = 0, lastExpense = 0;
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);

    for (final t in allTransactions) {
      if (t.type == 'transfer') continue;
      if (!t.createdAt.isBefore(currentMonthStart)) {
        if (t.type == 'income') thisIncome += t.amount;
        if (t.type == 'expense') thisExpense += t.amount;
      } else if (!t.createdAt.isBefore(lastMonthStart) &&
          t.createdAt.isBefore(currentMonthStart)) {
        if (t.type == 'income') lastIncome += t.amount;
        if (t.type == 'expense') lastExpense += t.amount;
      }
    }

    final thisSavings = thisIncome - thisExpense;
    final lastSavings = lastIncome - lastExpense;

    if (lastSavings == 0 && thisSavings == 0) return [];

    if (thisSavings > 0 && lastSavings <= 0) {
      return [
        KuberInsight(
          type: InsightType.savingsTrend,
          message: 'You\'re saving money this month — keep it up!',
          emoji: '🎯',
          confidence: 0.7,
          isPositive: true,
        ),
      ];
    }

    if (lastSavings > 0) {
      final pctChange = ((thisSavings - lastSavings) / lastSavings) * 100;
      if (pctChange.abs() < 10) return [];
      final isUp = pctChange > 0;

      return [
        KuberInsight(
          type: InsightType.savingsTrend,
          message: isUp
              ? 'Savings are ${formatDelta(pctChange)} vs last month'
              : 'Savings dipped ${formatDelta(pctChange)} vs last month',
          emoji: isUp ? '🎯' : '⚠️',
          confidence: (pctChange.abs() / 100).clamp(0.3, 0.85),
          isPositive: isUp,
        ),
      ];
    }

    return [];
  }

  // ── 8. Recurring burden ─────────────────────────────────────────────

  List<KuberInsight> _recurringBurden() {
    final recent = window(allTransactions, days: 30);
    if (recent.length < 5) return [];

    double recurringTotal = 0;
    double total = 0;
    for (final t in recent) {
      total += t.amount;
      if (t.recurringRuleId != null) {
        recurringTotal += t.amount;
      }
    }

    if (total == 0) return [];
    final pct = (recurringTotal / total) * 100;
    if (pct < 20) return [];

    return [
      KuberInsight(
        type: InsightType.recurringBurden,
        message: '${pct.toInt()}% of spending is from recurring transactions',
        emoji: '🔄',
        confidence: (pct / 100).clamp(0.4, 0.85),
        isPositive: false,
      ),
    ];
  }

  // ── 9. Spending-free streak ─────────────────────────────────────────

  List<KuberInsight> _spendingFreeStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int streak = 0;
    for (int i = 1; i <= 30; i++) {
      final day = today.subtract(Duration(days: i));
      final hasExpense = allTransactions.any((t) {
        if (t.type != 'expense') return false;
        final td = DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day);
        return td == day;
      });
      if (hasExpense) break;
      streak++;
    }

    if (streak < 2) return [];

    return [
      KuberInsight(
        type: InsightType.spendingFreeStreak,
        message: '$streak-day spending-free streak before today!',
        emoji: '🔥',
        confidence: (streak / 14).clamp(0.4, 0.9),
        isPositive: true,
      ),
    ];
  }

  // ── Fallback ────────────────────────────────────────────────────────

  List<KuberInsight> _fallback() {
    final recent = window(allTransactions, days: 30);
    if (recent.isEmpty) {
      return [
        const KuberInsight(
          type: InsightType.fallbackTip,
          message: 'Start adding transactions to unlock smart insights',
          emoji: '💡',
          confidence: 0.1,
          isPositive: true,
        ),
      ];
    }

    final total = recent.fold<double>(0, (sum, t) => sum + t.amount);
    return [
      KuberInsight(
        type: InsightType.fallbackTotal,
        message: 'You\'ve spent $currencySymbol${total.toStringAsFixed(0)} in the last 30 days',
        emoji: '💰',
        confidence: 0.15,
        isPositive: false,
      ),
    ];
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  List<Transaction> _windowRange({
    required int days,
    required int excludeLastDays,
  }) {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));
    final end = now.subtract(Duration(days: excludeLastDays));
    return allTransactions.where((t) {
      if (t.type == 'transfer') return false;
      if (t.type != 'expense') return false;
      return t.createdAt.isAfter(start) && t.createdAt.isBefore(end);
    }).toList();
  }

  Map<String, double> _groupByCategory(List<Transaction> txns) {
    final map = <String, double>{};
    for (final t in txns) {
      map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    }
    return map;
  }
}
