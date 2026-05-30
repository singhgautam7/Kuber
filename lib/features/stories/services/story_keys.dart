class StoryKeys {
  static String dailyRecap(DateTime date) =>
      'recap_day_${_yyyy(date)}_${_mm(date)}_${_dd(date)}';

  static String weeklyRecap(DateTime date) =>
      'recap_week_${_yyyy(date)}_W${_isoWeek(date).toString().padLeft(2, '0')}';

  static String monthlyRecap(DateTime date) =>
      'recap_month_${_yyyy(date)}_${_mm(date)}';

  static String yearlyRecap(DateTime date) => 'recap_year_${_yyyy(date)}';

  static String insight(String type, DateTime date) =>
      'insight_${type}_${_yyyy(date)}_${_mm(date)}_${_dd(date)}';

  static String insights(DateTime date) =>
      'insights_${_yyyy(date)}_${_mm(date)}';

  static String loans(DateTime date) =>
      'loans_${_yyyy(date)}_${_mm(date)}_${_dd(date)}';

  static String investments(DateTime date) =>
      'investments_${_yyyy(date)}_W${_isoWeek(date).toString().padLeft(2, '0')}';

  static String ledger(String eventId) => 'ledger_$eventId';

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
