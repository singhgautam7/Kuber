import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/insight_helpers.dart';
import '../../../core/utils/formatters.dart';
import '../../categories/data/category.dart';
import '../../insights/models/insight.dart';
import '../../investments/data/investment.dart';
import '../../ledger/data/ledger.dart';
import '../../loans/data/loan.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/helpers/transaction_filters.dart';
import '../../../core/utils/locale_font.dart';
import '../../../l10n/app_localizations.dart';

class InsightEngine {
  final List<Transaction> allTransactions;
  final List<Category> categories;
  final List<Loan> loans;
  final List<Ledger> ledgers;
  final List<Investment> investments;
  final String currencySymbol;
  final AppFormatter formatter;

  InsightEngine({
    required this.allTransactions,
    required this.categories,
    this.loans = const [],
    this.ledgers = const [],
    this.investments = const [],
    required this.currencySymbol,
    required this.formatter,
  });

  // ── Icon / color / label mapping ────────────────────────────────────

  static (IconData, Color, String) _iconForType(
    InsightType type,
    bool isPositive,
  ) {
    final l10n = lookupAppLocalizations(AppLocale.current);
    return switch (type) {
      InsightType.weekdayPattern => (
        Icons.bolt_rounded,
        const Color(0xFFF59E0B),
        l10n.insightLabelWeekdayPattern,
      ),
      InsightType.topCategory => (
        Icons.lightbulb_outline_rounded,
        KuberColors.primary,
        l10n.insightLabelTopCategory,
      ),
      InsightType.categoryTrend =>
        isPositive
            ? (
                Icons.trending_down_rounded,
                KuberColors.income,
                l10n.insightLabelCategoryTrend,
              )
            : (
                Icons.trending_up_rounded,
                KuberColors.expense,
                l10n.insightLabelCategoryTrend,
              ),
      InsightType.monthComparison => (
        Icons.bar_chart_rounded,
        KuberColors.primary,
        l10n.insightLabelMonthTrend,
      ),
      InsightType.weekendVsWeekday => (
        Icons.shopping_bag_outlined,
        const Color(0xFF8B5CF6),
        l10n.insightLabelWeekendPattern,
      ),
      InsightType.biggestExpense => (
        Icons.payments_outlined,
        KuberColors.expense,
        l10n.insightLabelBigExpense,
      ),
      InsightType.savingsTrend =>
        isPositive
            ? (Icons.savings_outlined, KuberColors.income, l10n.insightLabelSavings)
            : (Icons.warning_amber_rounded, const Color(0xFFF59E0B), l10n.insightLabelSavings),
      InsightType.recurringBurden => (
        Icons.sync_rounded,
        KuberColors.primary,
        l10n.insightLabelRecurring,
      ),
      InsightType.spendingFreeStreak => (
        Icons.local_fire_department_rounded,
        KuberColors.income,
        l10n.insightLabelStreak,
      ),
      InsightType.spendingHighToday => (
        Icons.notification_important_outlined,
        KuberColors.expense,
        l10n.insightLabelToday,
      ),
      InsightType.spendingFasterThisWeek => (
        Icons.speed_rounded,
        const Color(0xFFF59E0B),
        l10n.insightLabelThisWeek,
      ),
      InsightType.categoryConcentration => (
        Icons.pie_chart_outline_rounded,
        KuberColors.primary,
        l10n.insightLabelDidYouKnow,
      ),
      InsightType.loanEmiTotal => (
        Icons.account_balance_rounded,
        KuberColors.primary,
        l10n.insightLabelLoans,
      ),
      InsightType.loanPayoffCountdown => (
        Icons.event_available_rounded,
        KuberColors.income,
        l10n.insightLabelLoans,
      ),
      InsightType.loanInterestPaid => (
        Icons.percent_rounded,
        const Color(0xFFF59E0B),
        l10n.insightLabelLoanInterest,
      ),
      InsightType.ledgerOutstanding => (
        Icons.receipt_long_rounded,
        KuberColors.primary,
        l10n.insightLabelLendBorrow,
      ),
      InsightType.ledgerOldestOpen => (
        Icons.schedule_rounded,
        const Color(0xFFF59E0B),
        l10n.insightLabelLendBorrow,
      ),
      InsightType.investmentPortfolioChange => (
        Icons.show_chart_rounded,
        KuberColors.income,
        l10n.insightLabelInvestments,
      ),
      InsightType.investmentTopPerformer => (
        Icons.trending_up_rounded,
        KuberColors.income,
        l10n.insightLabelTopInvestment,
      ),
      InsightType.investmentPeriodInvested => (
        Icons.savings_rounded,
        KuberColors.primary,
        l10n.insightLabelInvestments,
      ),
      InsightType.fallbackTotal => (
        Icons.account_balance_wallet_rounded,
        KuberColors.primary,
        l10n.insightLabelSummary,
      ),
      InsightType.fallbackTip => (
        Icons.lightbulb_outline_rounded,
        KuberColors.income,
        l10n.insightLabelTip,
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
      ..._loanInsights(),
      ..._ledgerInsights(),
      ..._investmentInsights(),
    ];

    // Deduplicate by type, keep highest confidence.
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

    final l10n = lookupAppLocalizations(AppLocale.current);
    final days = [
      l10n.weekdayMonday,
      l10n.weekdayTuesday,
      l10n.weekdayWednesday,
      l10n.weekdayThursday,
      l10n.weekdayFriday,
      l10n.weekdaySaturday,
      l10n.weekdaySunday,
    ];
    final dayName = days[peakDay - 1];
    final cs = currencySymbol;
    final highest = peakMedian.toStringAsFixed(0);

    final (icon, color, label) = _iconForType(
      InsightType.weekdayPattern,
      false,
    );

    return [
      KuberInsight(
        type: InsightType.weekdayPattern,
        message: l10n.weekdayPatternInsight(
          '$cs$highest',
          dayName,
          '$cs${otherMedian.toStringAsFixed(0)}',
        ),
        emoji: '⚡',
        confidence: (pctAbove / 100).clamp(0.3, 0.95),
        isPositive: false,
        iconData: icon,
        iconColor: color,
        typeLabel: label,
        highlights: ['$cs$highest', dayName],
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
        message: lookupAppLocalizations(AppLocale.current).topCategoryInsight(
          pct.toInt().toString(),
          catName,
          '$cs$amount',
        ),
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

      final (icon, color, label) = _iconForType(
        InsightType.categoryTrend,
        !isUp,
      );

      final insight = KuberInsight(
        type: InsightType.categoryTrend,
        message: lookupAppLocalizations(AppLocale.current).categoryTrendInsight(
          catName,
          formatDelta(pctChange),
        ),
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
    final lastMonthEnd = DateTime(
      now.year,
      now.month - 1,
      lastMonthSameDay.day + dayOfMonth - 1,
    );

    final currentSpend = allTransactions
        .computeSummary(
          start: currentMonthStart,
          end: now.add(const Duration(days: 1)),
          excludeLinkedRules: true,
        )
        .expense;
    final lastSpend = allTransactions
        .computeSummary(
          start: lastMonthSameDay,
          end: lastMonthEnd.add(const Duration(days: 1)),
          excludeLinkedRules: true,
        )
        .expense;

    if (lastSpend == 0) return [];
    final pctChange = ((currentSpend - lastSpend) / lastSpend) * 100;
    if (pctChange.abs() < 5) return [];

    final isUp = pctChange > 0;

    final (icon, color, label) = _iconForType(
      InsightType.monthComparison,
      !isUp,
    );

    return [
      KuberInsight(
        type: InsightType.monthComparison,
        message: lookupAppLocalizations(AppLocale.current).monthComparisonInsight(
          formatDelta(pctChange),
        ),
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

    final (icon, color, label) = _iconForType(
      InsightType.weekendVsWeekday,
      pctDiff <= 0,
    );

    return [
      KuberInsight(
        type: InsightType.weekendVsWeekday,
        message: lookupAppLocalizations(AppLocale.current).weekendVsWeekdayInsight(
          '$cs${weekendMedian.toStringAsFixed(0)}',
          '$cs${weekdayMedian.toStringAsFixed(0)}',
        ),
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

    final (icon, color, label) = _iconForType(
      InsightType.biggestExpense,
      false,
    );

    return [
      KuberInsight(
        type: InsightType.biggestExpense,
        message: lookupAppLocalizations(AppLocale.current).biggestExpenseInsight(
          biggest.name,
          _moneyWhole(biggest.amount),
          ratio.toStringAsFixed(1),
        ),
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

    final currentMonthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final thisSummary = allTransactions.computeSummary(
      start: currentMonthStart,
      end: now.add(const Duration(days: 1)),
      excludeLinkedRules: true,
    );
    final lastSummary = allTransactions.computeSummary(
      start: lastMonthStart,
      end: currentMonthStart,
      excludeLinkedRules: true,
    );

    final thisSavings = thisSummary.net;
    final lastSavings = lastSummary.net;

    if (lastSavings == 0 && thisSavings == 0) return [];

    if (thisSavings > 0 && lastSavings <= 0) {
      final (icon, color, label) = _iconForType(InsightType.savingsTrend, true);
      return [
        KuberInsight(
          type: InsightType.savingsTrend,
          message: lookupAppLocalizations(AppLocale.current).savingsTrendPositive,
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

      final (icon, color, label) = _iconForType(InsightType.savingsTrend, isUp);

      return [
        KuberInsight(
          type: InsightType.savingsTrend,
          message: isUp
              ? lookupAppLocalizations(AppLocale.current).savingsTrendInsight(formatDelta(pctChange))
              : lookupAppLocalizations(AppLocale.current).savingsTrendDipInsight(formatDelta(pctChange)),
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
      if (t.linkedRuleType == 'recurring') {
        recurringTotal += t.amount;
      }
    }

    if (total == 0) return [];
    final pct = (recurringTotal / total) * 100;
    if (pct < 20) return [];

    final (icon, color, label) = _iconForType(
      InsightType.recurringBurden,
      false,
    );

    return [
      KuberInsight(
        type: InsightType.recurringBurden,
        message: lookupAppLocalizations(AppLocale.current).recurringBurdenInsight(
          formatter.formatPercentage(pct),
        ),
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
        final td = DateTime(
          t.createdAt.year,
          t.createdAt.month,
          t.createdAt.day,
        );
        return td == day;
      });
      if (hasExpense) break;
      streak++;
    }

    if (streak < 2) return [];

    final (icon, color, label) = _iconForType(
      InsightType.spendingFreeStreak,
      true,
    );

    return [
      KuberInsight(
        type: InsightType.spendingFreeStreak,
        message: lookupAppLocalizations(AppLocale.current).streakInsight(
          streak.toString(),
        ),
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

    final todayTotal = allTransactions
        .computeSummary(
          start: todayStart,
          end: now.add(const Duration(days: 1)),
          excludeLinkedRules: true,
        )
        .expense;
    if (todayTotal == 0) return [];

    // Get 30-day daily totals excluding today
    final dailyTotals = <double>[];
    for (int i = 1; i <= 30; i++) {
      final dayStart = todayStart.subtract(Duration(days: i));
      final dayEnd = dayStart.add(const Duration(days: 1));
      dailyTotals.add(
        allTransactions
            .computeSummary(
              start: dayStart,
              end: dayEnd,
              excludeLinkedRules: true,
            )
            .expense,
      );
    }

    // Need 7+ days of history
    final nonZeroDays = dailyTotals.where((d) => d > 0).toList();
    if (nonZeroDays.length < 7) return [];

    final cleaned = removeOutliers(nonZeroDays);
    final dailyMedian = median(cleaned);
    if (dailyMedian == 0) return [];

    if (todayTotal < dailyMedian * 2) return [];

    final amountStr = _moneyWhole(todayTotal);
    final diff = todayTotal - dailyMedian;
    final diffStr = _moneyWhole(diff);
    final medStr = _moneyWhole(dailyMedian);

    final (icon, color, label) = _iconForType(
      InsightType.spendingHighToday,
      false,
    );

    return [
      KuberInsight(
        type: InsightType.spendingHighToday,
        message: lookupAppLocalizations(AppLocale.current).spentTodayInsight(
          amountStr,
          diffStr,
          medStr,
        ),
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

    final thisWeekTotal = allTransactions
        .computeSummary(
          start: mondayStart,
          end: now.add(const Duration(days: 1)),
          excludeLinkedRules: true,
        )
        .expense;

    final thisWeekDaily = thisWeekTotal / daysThisWeek;
    if (thisWeekDaily == 0) return [];

    // Get 90-day daily totals
    final dailyTotals = <double>[];
    for (int i = 1; i <= 90; i++) {
      final dayStart = todayStart.subtract(Duration(days: i));
      final dayEnd = dayStart.add(const Duration(days: 1));
      dailyTotals.add(
        allTransactions
            .computeSummary(
              start: dayStart,
              end: dayEnd,
              excludeLinkedRules: true,
            )
            .expense,
      );
    }

    final nonZeroDays = dailyTotals.where((d) => d > 0).toList();
    if (nonZeroDays.length < 14) return [];

    final cleaned = removeOutliers(nonZeroDays);
    final baselineDaily = median(cleaned);
    if (baselineDaily == 0) return [];

    if (thisWeekDaily < baselineDaily * 1.3) return [];

    final weekStr = _moneyWhole(thisWeekDaily);
    final diff = thisWeekDaily - baselineDaily;
    final diffStr = _moneyWhole(diff);
    final baseStr = _moneyWhole(baselineDaily);

    final (icon, color, label) = _iconForType(
      InsightType.spendingFasterThisWeek,
      false,
    );

    return [
      KuberInsight(
        type: InsightType.spendingFasterThisWeek,
        message: lookupAppLocalizations(AppLocale.current).spendingFasterInsight(
          weekStr,
          diffStr,
          baseStr,
        ),
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
    final amtStr = _moneyWhole(top3Total);

    final (icon, color, label) = _iconForType(
      InsightType.categoryConcentration,
      false,
    );

    return [
      KuberInsight(
        type: InsightType.categoryConcentration,
        message: lookupAppLocalizations(AppLocale.current).categoryConcentrationInsight(
          pctStr,
          amtStr,
        ),
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

  List<KuberInsight> _loanInsights() {
    final activeLoans = loans.where((l) => !l.isCompleted).toList();
    if (activeLoans.isEmpty) return [];

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final monthEnd = DateTime(now.year, now.month + 1);
    final linkedLoanPayments = allTransactions
        .computeSummary(
          start: monthStart,
          end: monthEnd,
          excludeLinkedRules: false,
          categoryIds: activeLoans.map((l) => l.categoryId).toSet(),
        )
        .expense;
    final emiTotal = linkedLoanPayments > 0
        ? linkedLoanPayments
        : activeLoans.fold<double>(0, (sum, l) => sum + l.emiAmount);

    final insights = <KuberInsight>[];
    if (emiTotal > 0) {
      final (icon, color, label) = _iconForType(
        InsightType.loanEmiTotal,
        false,
      );
      final amount = _moneyWhole(emiTotal);
      insights.add(
        KuberInsight(
          type: InsightType.loanEmiTotal,
          message: lookupAppLocalizations(AppLocale.current).loanEmiTotalInsight(amount),
          confidence: (activeLoans.length / 5).clamp(0.35, 0.85),
          isPositive: false,
          iconData: icon,
          iconColor: color,
          typeLabel: label,
          highlights: [amount],
          highlightIsWarning: true,
        ),
      );
    }

    final withEnd = activeLoans.where((l) => l.endDate != null).toList()
      ..sort((a, b) => a.endDate!.compareTo(b.endDate!));
    if (withEnd.isNotEmpty) {
      final loan = withEnd.first;
      final days = loan.endDate!.difference(now).inDays.clamp(0, 99999);
      final months = (days / 30).ceil();
      final (icon, color, label) = _iconForType(
        InsightType.loanPayoffCountdown,
        true,
      );
      insights.add(
        KuberInsight(
          type: InsightType.loanPayoffCountdown,
          message: lookupAppLocalizations(AppLocale.current).loanPayoffCountdownInsight(
            loan.name,
            months.toString(),
            months == 1 ? '' : 's',
          ),
          confidence: 0.55,
          isPositive: true,
          iconData: icon,
          iconColor: color,
          typeLabel: label,
          highlights: [loan.name, '$months month${months == 1 ? '' : 's'}'],
        ),
      );
    }

    double estimatedInterest = 0;
    for (final loan in loans) {
      final paid = allTransactions
          .where(
            (t) => t.linkedRuleType == 'loan' && t.linkedRuleId == loan.uid,
          )
          .fold<double>(0, (sum, t) => sum + t.amount);
      if (paid > loan.principalAmount) {
        estimatedInterest += paid - loan.principalAmount;
      }
    }
    if (estimatedInterest > 0) {
      final (icon, color, label) = _iconForType(
        InsightType.loanInterestPaid,
        false,
      );
      final amount = _moneyWhole(estimatedInterest);
      insights.add(
        KuberInsight(
          type: InsightType.loanInterestPaid,
          message: lookupAppLocalizations(AppLocale.current).loanInterestPaidInsight(amount),
          confidence: 0.5,
          isPositive: false,
          iconData: icon,
          iconColor: color,
          typeLabel: label,
          highlights: [amount],
          highlightIsWarning: true,
        ),
      );
    }

    return insights;
  }

  List<KuberInsight> _ledgerInsights() {
    final open = ledgers.where((l) => !l.isSettled).toList();
    if (open.isEmpty) return [];

    final owedToUser = open
        .where((l) => l.type == 'lent')
        .fold<double>(0, (sum, l) => sum + l.originalAmount);
    final owedByUser = open
        .where((l) => l.type == 'borrowed')
        .fold<double>(0, (sum, l) => sum + l.originalAmount);

    final insights = <KuberInsight>[];
    if (owedToUser > 0 || owedByUser > 0) {
      final (icon, color, label) = _iconForType(
        InsightType.ledgerOutstanding,
        owedToUser >= owedByUser,
      );
      final receive = _moneyWhole(owedToUser);
      final owe = _moneyWhole(owedByUser);
      insights.add(
        KuberInsight(
          type: InsightType.ledgerOutstanding,
          message: lookupAppLocalizations(AppLocale.current).ledgerOutstandingInsight(receive, owe),
          confidence: 0.65,
          isPositive: owedToUser >= owedByUser,
          iconData: icon,
          iconColor: color,
          typeLabel: label,
          highlights: [receive, owe],
          highlightIsWarning: owedByUser > owedToUser,
        ),
      );
    }

    open.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final oldest = open.first;
    final ageDays = DateTime.now().difference(oldest.createdAt).inDays;
    if (ageDays >= 7) {
      final (icon, color, label) = _iconForType(
        InsightType.ledgerOldestOpen,
        false,
      );
      insights.add(
        KuberInsight(
          type: InsightType.ledgerOldestOpen,
          message: lookupAppLocalizations(AppLocale.current).ledgerOldestOpenInsight(oldest.personName, ageDays.toString()),
          confidence: (ageDays / 60).clamp(0.35, 0.85),
          isPositive: false,
          iconData: icon,
          iconColor: color,
          typeLabel: label,
          highlights: [oldest.personName, '$ageDays days'],
          highlightIsWarning: true,
        ),
      );
    }

    return insights;
  }

  List<KuberInsight> _investmentInsights() {
    if (investments.isEmpty) return [];
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final monthEnd = DateTime(now.year, now.month + 1);
    final insights = <KuberInsight>[];

    final invested = investments.fold<double>(
      0,
      (sum, i) => sum + (i.investedAmount ?? 0),
    );
    final current = investments.fold<double>(
      0,
      (sum, i) => sum + (i.currentValue ?? i.investedAmount ?? 0),
    );
    final change = current - invested;
    if (invested > 0 && change != 0) {
      final isPositive = change >= 0;
      final (icon, color, label) = _iconForType(
        InsightType.investmentPortfolioChange,
        isPositive,
      );
      final amount = '${isPositive ? '+' : '-'}${_moneyWhole(change.abs())}';
      insights.add(
        KuberInsight(
          type: InsightType.investmentPortfolioChange,
          message: lookupAppLocalizations(AppLocale.current).investmentPortfolioChangeInsight(amount),
          confidence: (change.abs() / invested).clamp(0.35, 0.9),
          isPositive: isPositive,
          iconData: icon,
          iconColor: color,
          typeLabel: label,
          highlights: [amount],
          highlightIsWarning: !isPositive,
        ),
      );
    }

    final performers =
        investments
            .where((i) => (i.investedAmount ?? 0) > 0 && i.currentValue != null)
            .map(
              (i) => (
                investment: i,
                gain: (i.currentValue! - i.investedAmount!) / i.investedAmount!,
              ),
            )
            .toList()
          ..sort((a, b) => b.gain.compareTo(a.gain));
    if (performers.isNotEmpty && performers.first.gain > 0) {
      final top = performers.first;
      final pct = formatter.formatPercentage(top.gain * 100);
      final (icon, color, label) = _iconForType(
        InsightType.investmentTopPerformer,
        true,
      );
      insights.add(
        KuberInsight(
          type: InsightType.investmentTopPerformer,
          message: lookupAppLocalizations(AppLocale.current).investmentTopPerformerInsight(top.investment.name, pct),
          confidence: top.gain.clamp(0.35, 0.9),
          isPositive: true,
          iconData: icon,
          iconColor: color,
          typeLabel: label,
          highlights: [top.investment.name, pct],
        ),
      );
    }

    final periodInvested = allTransactions
        .computeSummary(
          start: monthStart,
          end: monthEnd,
          excludeLinkedRules: false,
          categoryIds: investments.map((i) => i.categoryId).toSet(),
        )
        .expense;
    if (periodInvested > 0) {
      final (icon, color, label) = _iconForType(
        InsightType.investmentPeriodInvested,
        true,
      );
      final amount = _moneyWhole(periodInvested);
      insights.add(
        KuberInsight(
          type: InsightType.investmentPeriodInvested,
          message: lookupAppLocalizations(AppLocale.current).investmentPeriodInvestedInsight(amount),
          confidence: 0.55,
          isPositive: true,
          iconData: icon,
          iconColor: color,
          typeLabel: label,
          highlights: [amount],
        ),
      );
    }

    return insights;
  }

  // ── Fallback ────────────────────────────────────────────────────────

  List<KuberInsight> _fallback() {
    final recent = window(allTransactions, days: 30);
    if (recent.isEmpty) {
      final (icon, color, label) = _iconForType(InsightType.fallbackTip, true);
      return [
        KuberInsight(
          type: InsightType.fallbackTip,
          message: lookupAppLocalizations(AppLocale.current).fallbackTipInsight,
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

    final (icon, color, label) = _iconForType(InsightType.fallbackTotal, false);

    return [
      KuberInsight(
        type: InsightType.fallbackTotal,
        message: lookupAppLocalizations(AppLocale.current).fallbackTotalInsight(_moneyWhole(total)),
        emoji: '💰',
        confidence: 0.15,
        isPositive: false,
        iconData: icon,
        iconColor: color,
        typeLabel: label,
        highlights: [_moneyWhole(total)],
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
      if (t.type != 'expense') return false;
      final summary = [
        t,
      ].computeSummary(start: start, end: end, excludeLinkedRules: true);
      return summary.expense > 0;
    }).toList();
  }

  Map<String, double> _groupByCategory(List<Transaction> txns) {
    final map = <String, double>{};
    for (final t in txns) {
      map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    }
    return map;
  }

  String _moneyWhole(double amount) =>
      formatter.formatCurrency(amount.roundToDouble());
}
