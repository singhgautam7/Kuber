import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/prefs_keys.dart';

/// Tracks the free tier's weekly Ask Kuber message allowance. Pro and trial
/// users are unlimited and never touch this — the caller checks entitlement
/// first and only consults this for free users.
///
/// The count lives under a per-ISO-week SharedPreferences key
/// (`ask_kuber_messages_week_YYYY-Www`), so it resets automatically each week
/// with no cleanup job: a new week simply reads a fresh, absent key as zero.
class AskKuberUsage {
  const AskKuberUsage._();

  /// Free accounts get this many Ask Kuber messages per week.
  static const freeWeeklyLimit = 5;

  /// How many messages the free user has sent in the current ISO week.
  static Future<int> messagesThisWeek() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(weekKey(DateTime.now())) ?? 0;
  }

  /// True when the free user has already used their weekly allowance and the
  /// next send should be gated.
  static Future<bool> atWeeklyLimit() async =>
      await messagesThisWeek() >= freeWeeklyLimit;

  /// Records one sent message against the current ISO week.
  static Future<void> increment() async {
    final prefs = await SharedPreferences.getInstance();
    final key = weekKey(DateTime.now());
    await prefs.setInt(key, (prefs.getInt(key) ?? 0) + 1);
  }

  /// The SharedPreferences key for [date]'s ISO week. Exposed for tests.
  static String weekKey(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    // The ISO week-year and week number are decided by this week's Thursday
    // (weekday: Mon=1 .. Sun=7), which keeps the year correct across the
    // Dec/Jan boundary.
    final thursday = day.add(Duration(days: 4 - day.weekday));
    final dayOfYear =
        thursday.difference(DateTime(thursday.year, 1, 1)).inDays + 1;
    final week = ((dayOfYear - 1) ~/ 7) + 1;
    final label = week.toString().padLeft(2, '0');
    return '${PrefsKeys.askKuberWeekPrefix}${thursday.year}-W$label';
  }
}
