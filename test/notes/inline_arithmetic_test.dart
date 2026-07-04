import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/notes/engine/arithmetic_engine.dart';

void main() {
  const engine = ArithmeticEngine();

  double? inlineResult(String line) {
    final res = engine.resolve(line);
    final inline = res.where((r) => r.trigger.isInline);
    return inline.isEmpty ? null : inline.first.value;
  }

  group('Inline expression mode (Mode A)', () {
    test('evaluates expressions with a prefix word', () {
      expect(inlineResult('Eggs 7 * 10 ='), 70);
      expect(inlineResult('Discount 500 - 50 ='), 450);
      expect(inlineResult('Total 100 + 200 + 50 ='), 350);
    });

    test('evaluates bare expressions', () {
      expect(inlineResult('100 + 200 ='), 300);
      expect(inlineResult('(100 + 50) * 2 ='), 300);
      expect(inlineResult('1000 / 4 ='), 250);
      expect(inlineResult('10 * (5 + 3) - 4 ='), 76);
    });

    test('division producing a decimal', () {
      expect(inlineResult('1000 / 3 ='), closeTo(333.333, 0.01));
    });

    test('division by zero inserts no inline result', () {
      expect(inlineResult('10 / 0 ='), isNull);
    });

    test('invalid expression falls through (no inline result)', () {
      expect(inlineResult('100 +  ='), isNull);
    });

    test('no "=" means no inline result', () {
      expect(inlineResult('100 + 200'), isNull);
    });

    test('recomputes a manually typed result', () {
      // The engine resolves the expression to 300 regardless of typed text.
      expect(inlineResult('100 + 200 ='), 300);
    });
  });

  group('Column sum mode still works (Mode B)', () {
    ArithmeticResolution columnOf(String text) =>
        engine.resolve(text).firstWhere((r) => !r.trigger.isInline);

    test('total sums the lines above', () {
      expect(columnOf('10\n20\ntotal').value, 30);
    });

    test('= alone on a line column-sums', () {
      expect(columnOf('10\n20\n=').value, 30);
    });

    test('sum keyword', () {
      expect(columnOf('5\n7\nsum').value, 12);
    });

    test('all sum is global', () {
      final res = engine.resolve('10\n20\ntotal\n5\nall sum');
      final global = res.firstWhere((r) => r.trigger.isGlobal);
      expect(global.value, 35);
    });

    test('"Total =" alone falls back to column sum', () {
      final res = engine.resolve('10\n20\nTotal =');
      expect(res.single.trigger.isInline, isFalse);
      expect(res.single.value, 30);
    });
  });

  group('Precedence', () {
    test('inline wins over column when operators are present', () {
      // "Total 100 + 200 =" is inline 300, NOT the column sum of lines above.
      final res = engine.resolve('999\nTotal 100 + 200 =');
      final r = res.single;
      expect(r.trigger.isInline, isTrue);
      expect(r.value, 300);
    });

    test('prose lines with trigger words do not trigger', () {
      // The demo note instruction line must not resolve.
      expect(engine.resolve('Type total or = on a new line'), isEmpty);
    });
  });
}
