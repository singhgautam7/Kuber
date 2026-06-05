import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/stories/services/story_keys.dart';

void main() {
  group('StoryKeys', () {
    test('generates deterministic recap keys', () {
      final date = DateTime(2026, 5, 28);

      expect(StoryKeys.dailyRecap(date), 'recap_day_2026_05_28');
      expect(StoryKeys.monthlyRecap(date), 'recap_month_2026_05');
      expect(StoryKeys.yearlyRecap(date), 'recap_year_2026');
    });

    test('generates stable per-entity keys', () {
      expect(StoryKeys.loans, 'loans');
      expect(StoryKeys.ledger, 'ledger');
      expect(StoryKeys.insights, 'insights');
      expect(StoryKeys.welcome, 'welcome_v1');
    });

    test('uses ISO week numbering', () {
      expect(
        StoryKeys.weeklyRecap(DateTime(2026, 5, 28)),
        'recap_week_2026_W22',
      );
      expect(
        StoryKeys.investments(DateTime(2026, 5, 28)),
        'investments_2026_W22',
      );
      expect(
        StoryKeys.weeklyRecap(DateTime(2026, 1, 1)),
        'recap_week_2026_W01',
      );
    });
  });
}
