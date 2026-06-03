/// Deterministic story keys. The bubble `type` (recap_day, recap_week, ...) is
/// stored separately on the row; these keys drive dedup:
///   - recaps/pace: rollover/period-stable keys (dedup by exact key)
///   - entity bubbles: stable per-entity keys gated by a cadence window
class StoryKeys {
  /// First-launch Welcome story. Single key, never regenerated for a user.
  static const welcome = 'welcome_v1';

  // ── Recaps (rollover-keyed) ──────────────────────────────────────────
  static String dailyRecap(DateTime date) =>
      'recap_day_${_yyyy(date)}_${_mm(date)}_${_dd(date)}';

  static String weeklyRecap(DateTime date) =>
      'recap_week_${_yyyy(date)}_W${_isoWeek(date).toString().padLeft(2, '0')}';

  static String monthlyRecap(DateTime date) =>
      'recap_month_${_yyyy(date)}_${_mm(date)}';

  /// Recap of a completed year, one key per year.
  static String yearlyRecap(DateTime date) => 'recap_year_${_yyyy(date)}';

  // ── Entity bubbles (cadence-gated, stable per-entity keys) ────────────
  static String loanEntity(String loanId) => 'loans_$loanId';

  static String ledger(String eventId) => 'ledger_$eventId';

  static String investments(DateTime date) =>
      'investments_${_yyyy(date)}_W${_isoWeek(date).toString().padLeft(2, '0')}';

  /// Single consolidated Insights story (multiple slides), cadence-gated.
  static const insights = 'insights';

  static int _isoWeek(DateTime date) {
    final normalized = DateTime.utc(date.year, date.month, date.day);
    final thursday = normalized.add(Duration(days: 4 - normalized.weekday));
    final firstThursday = DateTime.utc(thursday.year, 1, 4);
    final weekOne = firstThursday.add(
      Duration(days: 4 - firstThursday.weekday),
    );
    return 1 + thursday.difference(weekOne).inDays ~/ 7;
  }

  static String _yyyy(DateTime date) => date.year.toString().padLeft(4, '0');
  static String _mm(DateTime date) => date.month.toString().padLeft(2, '0');
  static String _dd(DateTime date) => date.day.toString().padLeft(2, '0');
}
