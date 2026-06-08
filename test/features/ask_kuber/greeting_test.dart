import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/ask_kuber/screen/greeting.dart';

void main() {
  group('composeAskGreeting', () {
    test('time-of-day buckets with a name', () {
      expect(composeAskGreeting('Gautam', 8), 'Good morning, Gautam.');
      expect(composeAskGreeting('Gautam', 14), 'Good afternoon, Gautam.');
      expect(composeAskGreeting('Gautam', 19), 'Good evening, Gautam.');
      expect(composeAskGreeting('Gautam', 23), 'Hi, Gautam.');
      expect(composeAskGreeting('Gautam', 2), 'Hi, Gautam.');
    });

    test('bucket boundaries', () {
      expect(composeAskGreeting('A', 5), startsWith('Good morning'));
      expect(composeAskGreeting('A', 11), startsWith('Good morning'));
      expect(composeAskGreeting('A', 12), startsWith('Good afternoon'));
      expect(composeAskGreeting('A', 16), startsWith('Good afternoon'));
      expect(composeAskGreeting('A', 17), startsWith('Good evening'));
      expect(composeAskGreeting('A', 21), startsWith('Good evening'));
      expect(composeAskGreeting('A', 22), startsWith('Hi'));
      expect(composeAskGreeting('A', 4), startsWith('Hi'));
    });

    test('empty name drops the comma and name but keeps the period', () {
      expect(composeAskGreeting('', 8), 'Good morning.');
      expect(composeAskGreeting('   ', 14), 'Good afternoon.');
      expect(composeAskGreeting('', 19), 'Good evening.');
      expect(composeAskGreeting('', 23), 'Hi.');
    });
  });
}
