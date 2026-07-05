import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/notes/engine/number_parser.dart';

void main() {
  const parser = NumberParser();

  group('NumberParser', () {
    test('parses plain integers', () {
      final tokens = parser.parse('Milk 60 and bread 45');
      expect(tokens.map((t) => t.value), [60, 45]);
    });

    test('parses decimals', () {
      final tokens = parser.parse('Paid 450.50 today');
      expect(tokens.single.value, 450.50);
    });

    test('parses signed values', () {
      final tokens = parser.parse('-500 and +1200');
      expect(tokens[0].value, -500);
      expect(tokens[0].isSigned, isTrue);
      expect(tokens[1].value, 1200);
    });

    test('parses currency prefix', () {
      final tokens = parser.parse('Fee ₹500 and ₹1,200');
      expect(tokens[0].value, 500);
      expect(tokens[0].hasCurrency, isTrue);
      expect(tokens[1].value, 1200);
    });

    test('parses Indian comma grouping', () {
      final tokens = parser.parse('Corpus 1,00,000 done');
      expect(tokens.single.value, 100000);
    });

    test('rejects tokens glued to words', () {
      expect(parser.parse('v2 build and 3rd item'), isEmpty);
    });

    test('respects excluded ranges', () {
      const text = 'total ₹385';
      final excluded = [const PlainTextRange(6, 10)];
      expect(parser.parse(text, excluded: excluded), isEmpty);
    });

    test('offsets are exact', () {
      final tokens = parser.parse('Eggs 90');
      expect(tokens.single.startOffset, 5);
      expect(tokens.single.endOffset, 7);
    });
  });
}
