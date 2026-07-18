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
  loanEmiTotal,
  loanPayoffCountdown,
  loanInterestPaid,
  ledgerOutstanding,
  ledgerOldestOpen,
  investmentPortfolioChange,
  investmentTopPerformer,
  investmentPeriodInvested,
  fallbackTotal,
  fallbackTip,
}

/// Semantic accent for an insight's icon. Insights are generated inside a
/// provider (no BuildContext), so they carry a role instead of a resolved
/// [Color]; the widget resolves the role against the active theme. This keeps
/// insight colors correct across theme family/mode changes without
/// regenerating insights.
enum InsightAccent { primary, income, expense, warning, purple }

class KuberInsight {
  final InsightType type;
  final String message;
  final String emoji;
  final double confidence;
  final bool isPositive;
  final IconData? iconData;
  final InsightAccent? iconAccent;
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
    this.iconAccent,
    this.typeLabel = '',
    this.highlights = const [],
    this.highlightIsWarning = false,
  });
}
