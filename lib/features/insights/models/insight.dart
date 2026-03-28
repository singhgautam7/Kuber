import 'package:flutter/material.dart';

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
  spendingHighToday,
  spendingFasterThisWeek,
  categoryConcentration,
  fallbackTotal,
  fallbackTip,
}

class KuberInsight {
  final InsightType type;
  final String message;
  final String emoji;
  final double confidence;
  final bool isPositive;
  final IconData? iconData;
  final Color? iconColor;
  final String typeLabel;
  final List<String> highlights;
  final bool highlightIsWarning;

  const KuberInsight({
    required this.type,
    required this.message,
    this.emoji = '',
    required this.confidence,
    required this.isPositive,
    this.iconData,
    this.iconColor,
    this.typeLabel = '',
    this.highlights = const [],
    this.highlightIsWarning = false,
  });
}
