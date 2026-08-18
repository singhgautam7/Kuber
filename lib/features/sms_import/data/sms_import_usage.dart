import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/prefs_keys.dart';

/// Free accounts get this many SMS imports per rolling week.
const smsImportFreeWeeklyLimit = 5;

/// Tracks the free tier's weekly SMS-import allowance. Pro and trial users are
/// unlimited and never touch this — the caller checks entitlement first and only
/// consults this for free users.
///
/// Modelled on [AskKuberUsage] but with an **anchored 7-day window** instead of
/// ISO-week keys: the first counted import stamps [PrefsKeys.smsImportWindowStart]
/// and [PrefsKeys.smsImportWindowCount] accumulates until the window lapses
/// (`now - windowStart >= 7d`). A lapsed window reads as zero, so it self-resets
/// with no cleanup job and re-anchors on the next import.
///
/// Only the actual "import to transaction" action is counted. Inbox scanning /
/// staging and the paste-a-SMS flow are free and never call [increment].
class SmsImportUsage {
  const SmsImportUsage._();

  static const _window = Duration(days: 7);

  /// The live window's start, or null if no window is active (never imported, or
  /// the last window has lapsed).
  static Future<DateTime?> _activeWindowStart(SharedPreferences prefs) async {
    final iso = prefs.getString(PrefsKeys.smsImportWindowStart);
    if (iso == null) return null;
    final start = DateTime.tryParse(iso);
    if (start == null) return null;
    if (DateTime.now().difference(start) >= _window) return null; // lapsed
    return start;
  }

  /// How many imports the free user has made in the current window (0 if the
  /// window has lapsed or none has ever run).
  static Future<int> importsThisWeek() async {
    final prefs = await SharedPreferences.getInstance();
    final start = await _activeWindowStart(prefs);
    if (start == null) return 0;
    return prefs.getInt(PrefsKeys.smsImportWindowCount) ?? 0;
  }

  /// Imports still available in the current window, clamped to [0, limit].
  static Future<int> remainingThisWeek() async {
    final used = await importsThisWeek();
    final left = smsImportFreeWeeklyLimit - used;
    return left < 0 ? 0 : (left > smsImportFreeWeeklyLimit ? smsImportFreeWeeklyLimit : left);
  }

  /// True when the free user has used their weekly allowance.
  static Future<bool> atWeeklyLimit() async =>
      await importsThisWeek() >= smsImportFreeWeeklyLimit;

  /// When the current window resets (`windowStart + 7d`), or null when no window
  /// is active. Used for the limit-reached sheet copy.
  static Future<DateTime?> resetDate() async {
    final prefs = await SharedPreferences.getInstance();
    final start = await _activeWindowStart(prefs);
    return start?.add(_window);
  }

  /// Records [n] imported transactions against the current window. Starts a fresh
  /// window (re-anchored to now) if none is active; otherwise accumulates.
  static Future<void> increment(int n) async {
    if (n <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    final start = await _activeWindowStart(prefs);
    if (start == null) {
      await prefs.setString(
        PrefsKeys.smsImportWindowStart,
        DateTime.now().toIso8601String(),
      );
      await prefs.setInt(PrefsKeys.smsImportWindowCount, n);
    } else {
      final current = prefs.getInt(PrefsKeys.smsImportWindowCount) ?? 0;
      await prefs.setInt(PrefsKeys.smsImportWindowCount, current + n);
    }
  }
}
