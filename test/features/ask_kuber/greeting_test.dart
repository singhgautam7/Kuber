import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/ask_kuber/screen/greeting.dart';

void main() {
  group('composeCompactGreeting', () {
    test('includes the name with a comma and trailing period', () {
      expect(composeCompactGreeting('Hello', 'Gautam'), 'Hello, Gautam.');
      expect(composeCompactGreeting('Welcome back', 'G'), 'Welcome back, G.');
    });

    test('empty name drops the comma and name but keeps the period', () {
      expect(composeCompactGreeting('Hi', ''), 'Hi.');
      expect(composeCompactGreeting('Namaste', '   '), 'Namaste.');
    });
  });

  group('selectGreetingWord', () {
    const all = {'Hi', 'Hello', 'Hey', 'Namaste', 'Welcome back', 'Ssup'};

    test('always returns a word from the list', () {
      for (var i = 0; i < 100; i++) {
        expect(all.contains(selectGreetingWord(20, null)), isTrue);
      }
    });

    test('"Ssup" only appears from 17:00 onward', () {
      for (var i = 0; i < 300; i++) {
        expect(selectGreetingWord(10, null), isNot('Ssup'));
        expect(selectGreetingWord(16, null), isNot('Ssup'));
      }
      // From the evening it becomes eligible (statistically certain over 500 draws).
      final evening = {for (var i = 0; i < 500; i++) selectGreetingWord(20, null)};
      expect(evening.contains('Ssup'), isTrue);
    });

    test('never repeats the immediately previous greeting when avoidable', () {
      for (var i = 0; i < 300; i++) {
        expect(selectGreetingWord(20, 'Hi'), isNot('Hi'));
      }
    });
  });
}
