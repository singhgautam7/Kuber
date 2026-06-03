import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/stories/services/story_date_label.dart';

void main() {
  group('formatBubblePeriod', () {
    test('matches the design table for each bubble kind', () {
      expect(
        formatBubblePeriod(BubblePeriodKind.daily, start: DateTime(2026, 5, 24)),
        '24 May 2026',
      );
      expect(
        formatBubblePeriod(
          BubblePeriodKind.weekly,
          start: DateTime(2026, 5, 18),
          end: DateTime(2026, 5, 24),
        ),
        '18 May to 24 May 2026',
      );
      expect(
        formatBubblePeriod(BubblePeriodKind.monthly, start: DateTime(2026, 5, 1)),
        'May 2026',
      );
      expect(
        formatBubblePeriod(
          BubblePeriodKind.yearlyYtd,
          start: DateTime(2026, 5, 31),
        ),
        'Through May 2026',
      );
      expect(
        formatBubblePeriod(
          BubblePeriodKind.yearlyFull,
          start: DateTime(2025, 1, 1),
        ),
        '2025',
      );
      expect(
        formatBubblePeriod(
          BubblePeriodKind.loan,
          start: DateTime(2026, 5, 24),
          entityName: 'Bike Loan',
        ),
        'Bike Loan · 24 May',
      );
      expect(
        formatBubblePeriod(
          BubblePeriodKind.ledger,
          start: DateTime(2026, 5, 24),
          entityName: 'Rahul',
        ),
        'Rahul · 24 May',
      );
      expect(
        formatBubblePeriod(
          BubblePeriodKind.investments,
          sourcePeriod: 'This week',
        ),
        'This week',
      );
    });

    test('returns null when inputs are insufficient', () {
      expect(formatBubblePeriod(BubblePeriodKind.daily), isNull);
      expect(
        formatBubblePeriod(BubblePeriodKind.weekly, start: DateTime(2026, 5, 1)),
        isNull,
      );
      expect(formatBubblePeriod(BubblePeriodKind.loan, start: DateTime(2026, 5, 1)), isNull);
    });
  });
}
