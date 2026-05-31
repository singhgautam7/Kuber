import 'package:flutter/material.dart';

const Map<String, IconData> kStoryIconRegistry = {
  'trending_up': Icons.trending_up,
  'trending_down': Icons.trending_down,
  'savings': Icons.savings,
  'wallet': Icons.account_balance_wallet,
  'loan': Icons.account_balance,
  'investment': Icons.show_chart,
  'ledger': Icons.receipt_long,
  'calendar': Icons.calendar_month,
  'fire': Icons.local_fire_department,
  'warning': Icons.warning_amber_rounded,
  'target': Icons.crisis_alert,
  'chart': Icons.bar_chart,
  'category': Icons.category,
  'food': Icons.restaurant,
  'shopping': Icons.shopping_bag,
  'transport': Icons.directions_car,
  'trophy': Icons.emoji_events,
  'sparkle': Icons.auto_awesome,
};

IconData storyIcon(String key) => kStoryIconRegistry[key] ?? Icons.category;
