import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/notes/engine/arithmetic_engine.dart';
import 'package:kuber/features/notes/engine/number_parser.dart';

void main() {
  const engine = ArithmeticEngine();

  group('ArithmeticEngine', () {
    test('demo note sums signed numbers above the trigger', () {
      const text = 'Milk 60\nBread 45\nEggs 90\nVegetables 220\n'
          '-30 (discount)\ntotal';
      final res = engine.resolve(text);
      expect(res.single.value, 385);
      expect(res.single.trigger.word, 'total');
    });

    test('all four scoped trigger words fire', () {
      for (final word in ['total', 'sum', 'difference', '=']) {
        final res = engine.resolve('10\n20\n$word');
        expect(res, hasLength(1), reason: word);
      }
    });

    test('difference subtracts subsequent numbers from the first', () {
      final res = engine.resolve('100\n30\n20\ndifference');
      expect(res.single.value, 50);
    });

    test('scoped trigger only sums since the previous trigger', () {
      const text = '10\n20\ntotal\n5\n7\nsum';
      final res = engine.resolve(text);
      expect(res, hasLength(2));
      expect(res[0].value, 30);
      expect(res[1].value, 12);
    });

    test('global triggers sum the whole document', () {
      for (final phrase in ['all sum', 'total of all', 'all total']) {
        const numbers = '10\n20\ntotal\n5\n7\n';
        final res = engine.resolve('$numbers$phrase');
        final global =
            res.singleWhere((r) => r.trigger.isGlobal);
        expect(global.value, 42, reason: phrase);
      }
    });

    test('trigger must be alone on its line', () {
      expect(engine.resolve('10\nthe total was big'), isEmpty);
    });

    test('no numbers in scope produces no resolution', () {
      expect(engine.resolve('hello\ntotal'), isEmpty);
    });

    test('result chips are excluded from sums and trigger matching', () {
      // "total ₹30" where "₹30" is an existing result chip: line still
      // matches, chip value not double counted.
      const text = '10\n20\ntotal ₹30';
      final spans = [const PlainTextRange(12, 15)];
      final res = engine.resolve(text, resultSpans: spans);
      expect(res.single.value, 30);
    });

    test('is case-insensitive', () {
      final res = engine.resolve('10\nTOTAL');
      expect(res.single.value, 10);
    });
  });
}
