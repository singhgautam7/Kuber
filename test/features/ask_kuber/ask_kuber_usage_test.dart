import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/ask_kuber/data/ask_kuber_usage.dart';

void main() {
  group('AskKuberUsage.weekKey', () {
    test('keys share the ISO week for days in the same Mon-Sun window', () {
      // 2026-07-06 is a Monday; 2026-07-12 is the following Sunday.
      final monday = AskKuberUsage.weekKey(DateTime(2026, 7, 6));
      final wednesday = AskKuberUsage.weekKey(DateTime(2026, 7, 8));
      final sunday = AskKuberUsage.weekKey(DateTime(2026, 7, 12));
      expect(monday, wednesday);
      expect(monday, sunday);
    });

    test('rolls over to a new key on the next Monday', () {
      final thisWeek = AskKuberUsage.weekKey(DateTime(2026, 7, 12)); // Sunday
      final nextWeek = AskKuberUsage.weekKey(DateTime(2026, 7, 13)); // Monday
      expect(thisWeek, isNot(nextWeek));
    });

    test('uses the prefixed YYYY-Www format', () {
      final key = AskKuberUsage.weekKey(DateTime(2026, 7, 8));
      expect(key, startsWith('ask_kuber_messages_week_'));
      expect(key, matches(RegExp(r'_\d{4}-W\d{2}$')));
    });

    test('week-year follows the Thursday across the Jan boundary', () {
      // 2025-12-31 is a Wednesday; its ISO week belongs to 2026 (Thursday is
      // 2026-01-01), so the key must read 2026, not 2025.
      final key = AskKuberUsage.weekKey(DateTime(2025, 12, 31));
      expect(key, contains('2026-W01'));
    });
  });
}
