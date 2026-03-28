import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/insight_helpers.dart';
import '../../../core/utils/formatters.dart';
import '../../categories/data/category.dart';
import '../../insights/models/insight.dart';
import '../../transactions/data/transaction.dart';

class InsightEngine {
  final List<Transaction> allTransactions;
  final List<Category> categories;
  final String currencySymbol;
  final AppFormatter formatter;

  InsightEngine({
    required this.allTransactions,
    required this.categories,
    required this.currencySymbol,
    required this.formatter,
  });

  // ── Icon / color / label mapping ────────────────────────────────────

  static (IconData, Color, String) _iconForType(
    InsightType type,
    bool isPositive,
  ) {
    return switch (type) {
      InsightType.weekdayPattern => (
          Icons.bolt_rounded,
          const Color(0xFFF59E0B),
          'WEEKDAY PATTERN',
        ),
      InsightType.topCategory => (
          Icons.lightbulb_outline_rounded,
          KuberColors.primary,
          'TOP CATEGORY',
        ),
      InsightType.categoryTrend => isPositive
          ? (Icons.trending_down_rounded, KuberColors.income, 'CATEGORY TREND')
          : (Icons.trending_up_rounded, KuberColors.expense, 'CATEGORY TREND'),
      InsightType.monthComparison => (
          Icons.bar_chart_rounded,
          KuberColors.primary,
          'MONTH TREND',
        ),
      InsightType.weekendVsWeekday => (
          Icons.shopping_bag_outlined,
          const Color(0xFF8B5CF6),
          'WEEKEND PATTERN',
        ),
      InsightType.biggestExpense => (
          Icons.payments_outlined,
          KuberColors.expense,
          'BIG EXPENSE',
        ),
      InsightType.savingsTrend => isPositive
          ? (Icons.savings_outlined, KuberColors.income, 'SAVINGS')
          : (Icons.warning_amber_rounded, const Color(0xFFF59E0B), 'SAVINGS'),
      InsightType.recurringBurden => (
          Icons.sync_rounded,
          KuberColors.primary,
          'RECURRING',
        ),
      InsightType.spendingFreeStreak => (
          Icons.local_fire_department_rounded,
          KuberColors.income,
          'STREAK',
        ),
      InsightType.spendingHighToday => (
          Icons.notification_important_outlined,
          KuberColors.expense,
          'TODAY',
        ),
      InsightType.spendingFasterThisWeek => (
          Icons.speed_rounded,
          const Color(0xFFF59E0B),
          'THIS WEEK',
        ),
      InsightType.categoryConcentration => (
          Icons.pie_chart_outline_rounded,
          KuberColors.primary,
          'DID YOU KNOW',
        ),
      InsightType.fallbackTotal => (
          Icons.account_balance_wallet_rounded,
          KuberColors.primary,
          'SUMMARY',
        ),
      InsightType.fallbackTip => (
          Icons.lightbulb_outline_rounded,
          KuberColors.income,
          'TIP',
        ),
    };
  }

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
      ..._spendingHighToday(),
      ..._spendingFasterThisWeek(),
      ..._categoryConcentration(),
    ];

    // Deduplicate by type — keep highest confidence
    final byType = <InsightType, KuberInsight>{};
    for (final i in insights) {
      final existing = byType[i.type];
      if (existing == null || i.confidence > existing.confidence) {
        byType[i.type] = i;
      }
    }

    // Semantic conflict: keep only one of spendingHighToday / spendingFasterThisWeek
    final hasToday = byType.containsKey(InsightType.spendingHighToday);
    final hasFaster = byType.containsKey(InsightType.spendingFasterThisWeek);
    if (hasToday && hasFaster) {
      final today = byType[InsightType.spendingHighToday]!;
      final faster = byType[InsightType.spendingFasterThisWeek]!;
      if (today.confidence >= faster.confidence) {
        byType.remove(InsightType.spendingFasterThisWeek);
      } else {
        byType.remove(InsightType.spendingHighToday);
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
    final amountsByDay = <int, List<double>>{};
    for (final t in recent) {
      final wd = t.createdAt.weekday;
      totals[wd] = (totals[wd] ?? 0) + t.amount;
      counts[wd] = (counts[wd] ?? 0) + 1;
      (amountsByDay[wd] ??= []).add(t.amount);
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

    final peakMedian = median(amountsByDay[peakDay] ?? []);
    final otherAmounts = <double>[];
    for (final e in amountsByDay.entries) {
      if (e.key != peakDay) otherAmounts.addAll(e.value);
    }
    final otherMedian = median(otherAmounts);

    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    final dayName = days[peakDay - 1];
    final cs = currencySymbol;
    final highest = peakMedian.toStringAsFixed(0);

    final (icon, color, label) = _iconForType(InsightType.weekdayPattern, false);

    return [
      KuberInsight(
        type: InsightType.weekdayPattern,
        message:
            'You typically spend $cs$highest on ${dayName}s vs $cs${otherMedian.toStringAsFixed(0)} on other days',
        emoji: '⚡',
        confidence: (pctAbove / 100).clamp(0.3, 0.95),
        isPositive: false,
        iconData: icon,
        iconColor: color,
        typeLabel: label,
        highlights: ['$cs$highest', '${dayName}s'],
        highlightIsWarning: true,
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

    final cs = currencySymbol;
    final amount = topEntry.value.toStringAsFixed(0);

    final (icon, color, label) = _iconForType(InsightType.topCategory, false);

    return [
      KuberInsight(
        type: InsightType.topCategory,
        message: '${pct.toInt()}% of spending goes to $catName ($cs$amount)',
        emoji: '🏷️',
        confidence: (pct / 100).clamp(0.3, 0.9),
        isPositive: false,
        iconData: icon,
        iconColor: color,
        typeLabel: label,
        highlights: ['$cs$amount', '${pct.toInt()}%'],
        highlightIsWarning: false,
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

      final (icon, color, label) =
          _iconForType(InsightType.categoryTrend, !isUp);

      final insight = KuberInsight(
        type: InsightType.categoryTrend,
        message: '$catName spending is ${formatDelta(pctChange)} vs last month',
        emoji: isUp ? '📈' : '📉',
        confidence: (pctChange.abs() / 200).clamp(0.3, 0.9),
        isPositive: !isUp,
        iconData: icon,
        iconColor: color,
        typeLabel: label,
        highlights: [catName, formatDelta(pctChange)],
        highlightIsWarning: isUp,
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
      if (t.type != 'expense' || t.type == 'transfer' || t.isBalanceAdjustment) continue;
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

    final (icon, color, label) =
        _iconForType(InsightType.monthComparison, !isUp);

    return [
      KuberInsight(
        type: InsightType.monthComparison,
        message:
            'Spending is ${formatDelta(pctChange)} vs this point last month',
        emoji: isUp ? '📈' : '📉',
        confidence: (pctChange.abs() / 100).clamp(0.3, 0.9),
        isPositive: !isUp,
        iconData: icon,
        iconColor: color,
        typeLabel: label,
        highlights: [formatDelta(pctChange)],
        highlightIsWarning: isUp,
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

    final weekendAmounts = <double>[];
    final weekdayAmounts = <double>[];
    for (final t in recent) {
      if (t.createdAt.weekday >= 6) {
        weekendAmounts.add(t.amount);
      } else {
        weekdayAmounts.add(t.amount);
      }
    }
    final weekendMedian = median(weekendAmounts);
    final weekdayMedian = median(weekdayAmounts);

    final cs = currencySymbol;

    final (icon, color, label) =
        _iconForType(InsightType.weekendVsWeekday, pctDiff <= 0);

    return [
      KuberInsight(
        type: InsightType.weekendVsWeekday,
        message:
            'Weekend transactions average $cs${weekendMedian.toStringAsFixed(0)} vs $cs${weekdayMedian.toStringAsFixed(0)} on weekdays',
        emoji: pctDiff > 0 ? '🎉' : '💼',
        confidence: (pctDiff.abs() / 100).clamp(0.3, 0.85),
        isPositive: pctDiff <= 0,
        iconData: icon,
        iconColor: color,
        typeLabel: label,
        highlights: [
          '$cs${weekendMedian.toStringAsFixed(0)}',
          '$cs${weekdayMedian.toStringAsFixed(0)}',
        ],
        highlightIsWarning: pctDiff > 0,
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

    final (icon, color, label) =
        _iconForType(InsightType.biggestExpense, false);

    return [
      KuberInsight(
        type: InsightType.biggestExpense,
        message:
            '${biggest.name} (${formatter.formatCurrency(biggest.amount)}) was ${ratio.toStringAsFixed(1)}× your typical spend',
        emoji: '💸',
        confidence: (ratio / 10).clamp(0.4, 0.9),
        isPositive: false,
        iconData: icon,
        iconColor: color,
        typeLabel: label,
        highlights: [biggest.name, '${ratio.toStringAsFixed(1)}×'],
        highlightIsWarning: true,
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
      if (t.type == 'transfer' || t.isBalanceAdjustment) continue;
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
      final (icon, color, label) =
          _iconForType(InsightType.savingsTrend, true);
      return [
        KuberInsight(
          type: InsightType.savingsTrend,
          message: 'You\'re saving money this month — keep it up!',
          emoji: '🎯',
          confidence: 0.7,
          isPositive: true,
          iconData: icon,
          iconColor: color,
          typeLabel: label,
          highlights: ['saving money'],
          highlightIsWarning: false,
        ),
      ];
    }

    if (lastSavings > 0) {
      final pctChange = ((thisSavings - lastSavings) / lastSavings) * 100;
      if (pctChange.abs() < 10) return [];
      final isUp = pctChange > 0;

      final (icon, color, label) =
          _iconForType(InsightType.savingsTrend, isUp);

      return [
        KuberInsight(
          type: InsightType.savingsTrend,
          message: isUp
              ? 'Savings are ${formatDelta(pctChange)} vs last month'
              : 'Savings dipped ${formatDelta(pctChange)} vs last month',
          emoji: isUp ? '🎯' : '⚠️',
          confidence: (pctChange.abs() / 100).clamp(0.3, 0.85),
          isPositive: isUp,
          iconData: icon,
          iconColor: color,
          typeLabel: label,
          highlights: [formatDelta(pctChange)],
          highlightIsWarning: !isUp,
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

    final (icon, color, label) =
        _iconForType(InsightType.recurringBurden, false);

    return [
      KuberInsight(
        type: InsightType.recurringBurden,
        message:
            '${formatter.formatPercentage(pct)} of spending is from recurring transactions',
        emoji: '🔄',
        confidence: (pct / 100).clamp(0.4, 0.85),
        isPositive: false,
        iconData: icon,
        iconColor: color,
        typeLabel: label,
        highlights: [formatter.formatPercentage(pct)],
        highlightIsWarning: true,
      ),
    ];
  }

  // ── 9. Spending-free streak ─────────────────────────────────────────

  List<KuberInsight> _spendingFreeStreak() {
    if (allTransactions.where((t) => t.type == 'expense').length < 10) {
      return [];
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int streak = 0;
    for (int i = 1; i <= 30; i++) {
      final day = today.subtract(Duration(days: i));
      final hasExpense = allTransactions.any((t) {
        if (t.type != 'expense') return false;
        final td =
            DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day);
        return td == day;
      });
      if (hasExpense) break;
      streak++;
    }

    if (streak < 2) return [];

    final (icon, color, label) =
        _iconForType(InsightType.spendingFreeStreak, true);

    return [
      KuberInsight(
        type: InsightType.spendingFreeStreak,
        message: '$streak-day spending-free streak before today!',
        emoji: '🔥',
        confidence: (streak / 14).clamp(0.4, 0.9),
        isPositive: true,
        iconData: icon,
        iconColor: color,
        typeLabel: label,
        highlights: ['$streak-day streak'],
        highlightIsWarning: false,
      ),
    ];
  }

  // ── 10. Spending high today ─────────────────────────────────────────

  List<KuberInsight> _spendingHighToday() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    double todayTotal = 0;
    for (final t in allTransactions) {
      if (t.type != 'expense' || t.type == 'transfer' || t.isBalanceAdjustment) continue;
      if (!t.createdAt.isBefore(todayStart)) {
        todayTotal += t.amount;
      }
    }
    if (todayTotal == 0) return [];

    // Get 30-day daily totals excluding today
    final dailyTotals = <double>[];
    for (int i = 1; i <= 30; i++) {
      final dayStart = todayStart.subtract(Duration(days: i));
      final dayEnd = dayStart.add(const Duration(days: 1));
      double dayTotal = 0;
      for (final t in allTransactions) {
        if (t.type != 'expense' || t.type == 'transfer' || t.isBalanceAdjustment) continue;
        if (!t.createdAt.isBefore(dayStart) && t.createdAt.isBefore(dayEnd)) {
          dayTotal += t.amount;
        }
      }
      dailyTotals.add(dayTotal);
    }

    // Need 7+ days of history
    final nonZeroDays = dailyTotals.where((d) => d > 0).toList();
    if (nonZeroDays.length < 7) return [];

    final cleaned = removeOutliers(nonZeroDays);
    final dailyMedian = median(cleaned);
    if (dailyMedian == 0) return [];

    if (todayTotal < dailyMedian * 2) return [];

    final amountStr = formatter.formatCurrency(todayTotal);
    final diff = todayTotal - dailyMedian;
    final diffStr = formatter.formatCurrency(diff);
    final medStr = formatter.formatCurrency(dailyMedian);

    final (icon, color, label) =
        _iconForType(InsightType.spendingHighToday, false);

    return [
      KuberInsight(
        type: InsightType.spendingHighToday,
        message:
            "You've spent $amountStr today — $diffStr above your 30-day daily average of $medStr",
        confidence: (todayTotal / (dailyMedian * 2)).clamp(0.5, 1.0),
        isPositive: false,
        iconData: icon,
        iconColor: color,
        typeLabel: label,
        highlights: [amountStr, diffStr],
        highlightIsWarning: true,
      ),
    ];
  }

  // ── 11. Spending faster this week ───────────────────────────────────

  List<KuberInsight> _spendingFasterThisWeek() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    // Find Monday of this week
    final weekday = now.weekday; // 1=Mon
    final mondayStart = todayStart.subtract(Duration(days: weekday - 1));
    final daysThisWeek = weekday; // Mon=1 through today

    double thisWeekTotal = 0;
    for (final t in allTransactions) {
      if (t.type != 'expense' || t.type == 'transfer' || t.isBalanceAdjustment) continue;
      if (!t.createdAt.isBefore(mondayStart)) {
        thisWeekTotal += t.amount;
      }
    }

    final thisWeekDaily = thisWeekTotal / daysThisWeek;
    if (thisWeekDaily == 0) return [];

    // Get 90-day daily totals
    final dailyTotals = <double>[];
    for (int i = 1; i <= 90; i++) {
      final dayStart = todayStart.subtract(Duration(days: i));
      final dayEnd = dayStart.add(const Duration(days: 1));
      double dayTotal = 0;
      for (final t in allTransactions) {
        if (t.type != 'expense' || t.type == 'transfer' || t.isBalanceAdjustment) continue;
        if (!t.createdAt.isBefore(dayStart) && t.createdAt.isBefore(dayEnd)) {
          dayTotal += t.amount;
        }
      }
      dailyTotals.add(dayTotal);
    }

    final nonZeroDays = dailyTotals.where((d) => d > 0).toList();
    if (nonZeroDays.length < 14) return [];

    final cleaned = removeOutliers(nonZeroDays);
    final baselineDaily = median(cleaned);
    if (baselineDaily == 0) return [];

    if (thisWeekDaily < baselineDaily * 1.3) return [];

    final weekStr = formatter.formatCurrency(thisWeekDaily);
    final diff = thisWeekDaily - baselineDaily;
    final diffStr = formatter.formatCurrency(diff);
    final baseStr = formatter.formatCurrency(baselineDaily);

    final (icon, color, label) =
        _iconForType(InsightType.spendingFasterThisWeek, false);

    return [
      KuberInsight(
        type: InsightType.spendingFasterThisWeek,
        message:
            "You're spending $weekStr/day this week — $diffStr faster than your usual $baseStr/day",
        confidence: (thisWeekDaily / (baselineDaily * 1.3)).clamp(0.5, 0.9),
        isPositive: false,
        iconData: icon,
        iconColor: color,
        typeLabel: label,
        highlights: [weekStr, diffStr, 'faster'],
        highlightIsWarning: true,
      ),
    ];
  }

  // ── 12. Category concentration ──────────────────────────────────────

  List<KuberInsight> _categoryConcentration() {
    final recent = window(allTransactions, days: 90);
    if (recent.length < 5) return [];

    final catTotals = <String, double>{};
    for (final t in recent) {
      catTotals[t.categoryId] = (catTotals[t.categoryId] ?? 0) + t.amount;
    }
    if (catTotals.length < 3) return [];

    final total = catTotals.values.fold<double>(0, (a, b) => a + b);
    if (total == 0) return [];

    final sorted = catTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3Total = sorted.take(3).fold<double>(0, (a, b) => a + b.value);
    final pct = (top3Total / total) * 100;

    if (pct < 60) return [];

    final pctStr = '${pct.toInt()}%';
    final amtStr = formatter.formatCurrency(top3Total);

    final (icon, color, label) =
        _iconForType(InsightType.categoryConcentration, false);

    return [
      KuberInsight(
        type: InsightType.categoryConcentration,
        message: '$pctStr of your spending ($amtStr) goes to just 3 categories',
        confidence: (pct / 100) * 0.7,
        isPositive: false,
        iconData: icon,
        iconColor: color,
        typeLabel: label,
        highlights: [pctStr, '3 categories'],
        highlightIsWarning: false,
      ),
    ];
  }

  // ── Fallback ────────────────────────────────────────────────────────

  List<KuberInsight> _fallback() {
    final recent = window(allTransactions, days: 30);
    if (recent.isEmpty) {
      final (icon, color, label) =
          _iconForType(InsightType.fallbackTip, true);
      return [
        KuberInsight(
          type: InsightType.fallbackTip,
          message: 'Start adding transactions to unlock smart insights',
          emoji: '💡',
          confidence: 0.1,
          isPositive: true,
          iconData: icon,
          iconColor: color,
          typeLabel: label,
        ),
      ];
    }

    final total = recent.fold<double>(0, (sum, t) => sum + t.amount);

    final (icon, color, label) =
        _iconForType(InsightType.fallbackTotal, false);

    return [
      KuberInsight(
        type: InsightType.fallbackTotal,
        message:
            'You\'ve spent ${formatter.formatCurrency(total)} in the last 30 days',
        emoji: '💰',
        confidence: 0.15,
        isPositive: false,
        iconData: icon,
        iconColor: color,
        typeLabel: label,
        highlights: [formatter.formatCurrency(total)],
        highlightIsWarning: false,
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
      if (t.type == 'transfer' || t.isBalanceAdjustment) return false;
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
