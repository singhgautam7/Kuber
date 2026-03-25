enum InsightType {
  weekdayPattern,
  topCategory,
  categoryTrend,
  monthComparison,
  weekendVsWeekday,
  biggestExpense,
  savingsTrend,
  recurringBurden,
  spendingFreeStreak,
  fallbackTotal,
  fallbackTip,
}

class KuberInsight {
  final InsightType type;
  final String message;
  final String emoji;
  final double confidence;
  final bool isPositive;

  const KuberInsight({
    required this.type,
    required this.message,
    required this.emoji,
    required this.confidence,
    required this.isPositive,
  });
}
