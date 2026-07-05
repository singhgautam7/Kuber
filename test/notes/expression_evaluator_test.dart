import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/notes/engine/expression_evaluator.dart';

void main() {
  const e = ExpressionEvaluator();

  group('ExpressionEvaluator', () {
    test('addition and multiplication precedence (BODMAS)', () {
      expect(e.evaluate('7 * 10'), 70);
      expect(e.evaluate('100 + 200 + 50'), 350);
      expect(e.evaluate('2 + 3 * 4'), 14);
    });

    test('subtraction and division', () {
      expect(e.evaluate('500 - 50'), 450);
      expect(e.evaluate('1000 / 4'), 250);
    });

    test('parentheses', () {
      expect(e.evaluate('(100 + 50) * 2'), 300);
      expect(e.evaluate('10 * (5 + 3) - 4'), 76);
    });

    test('decimals', () {
      expect(e.evaluate('1000 / 3')!, closeTo(333.333, 0.01));
      expect(e.evaluate('1.5 + 2.5'), 4);
    });

    test('negative and unary signs', () {
      expect(e.evaluate('-5 + 10'), 5);
      expect(e.evaluate('10 * -2'), -20);
    });

    test('commas and rupee prefix', () {
      expect(e.evaluate('1,000 + 500'), 1500);
      expect(e.evaluate('₹500 - 50'), 450);
    });

    test('division by zero returns null', () {
      expect(e.evaluate('10 / 0'), isNull);
    });

    test('invalid expressions return null', () {
      expect(e.evaluate('100 +'), isNull);
      expect(e.evaluate('(100 + 50'), isNull);
      expect(e.evaluate(''), isNull);
      expect(e.evaluate('abc'), isNull);
      expect(e.evaluate('5 5'), isNull);
    });
  });
}
