import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/quick_add/services/quick_add_parser.dart';

void main() {
  group('parseQuickAddMulti', () {
    test('single expense: amount + category', () {
      final r = parseQuickAddMulti('250 in groceries');
      expect(r, hasLength(1));
      expect(r.first.amount, 250);
      expect(r.first.type, 'expense');
      expect(r.first.categoryHint, 'groceries');
    });

    test('splits on "and", ",", "+", "&"', () {
      expect(parseQuickAddMulti('250 groceries and 300 movies'), hasLength(2));
      expect(parseQuickAddMulti('250 groceries, 300 movies'), hasLength(2));
      expect(parseQuickAddMulti('250 groceries + 300 movies'), hasLength(2));
      expect(parseQuickAddMulti('250 groceries & 300 movies'), hasLength(2));
    });

    test('splits on newlines (one transaction per line)', () {
      final r = parseQuickAddMulti('250 groceries\n46 newcat');
      expect(r, hasLength(2));
      expect(r[0].amount, 250);
      expect(r[0].categoryHint, 'groceries');
      expect(r[1].amount, 46);
      expect(r[1].categoryHint, 'newcat');
    });

    test('does not split "and" inside a word', () {
      final r = parseQuickAddMulti('120 sandwich');
      expect(r, hasLength(1));
      expect(r.first.categoryHint, 'sandwich');
    });

    test('multi keeps per-segment amounts and hints', () {
      final r = parseQuickAddMulti('250 groceries and 300 movies');
      expect(r[0].amount, 250);
      expect(r[0].categoryHint, 'groceries');
      expect(r[1].amount, 300);
      expect(r[1].categoryHint, 'movies');
    });

    test('income keywords flip type to income', () {
      expect(parseQuickAddMulti('1200 salary income').first.type, 'income');
      expect(parseQuickAddMulti('5000 received from client').first.type,
          'income');
      expect(parseQuickAddMulti('800 refund').first.type, 'income');
      expect(parseQuickAddMulti('250 groceries').first.type, 'expense');
    });

    test('parses Indian grouped amounts and strips currency symbols', () {
      expect(parseQuickAddMulti('1,200 salary').first.amount, 1200);
      expect(parseQuickAddMulti('₹250 groceries').first.amount, 250);
      expect(parseQuickAddMulti('rs 99 tea').first.amount, 99);
    });

    test('resolves account hint via "from"', () {
      final r = parseQuickAddMulti('300 movies from hdfc').first;
      expect(r.amount, 300);
      expect(r.categoryHint, 'movies');
      expect(r.accountHint, 'hdfc');
    });

    test('line with no number is unparsed', () {
      final r = parseQuickAddMulti('groceries').first;
      expect(r.isParsed, isFalse);
      expect(r.amount, isNull);
    });

    test('empty input yields no segments', () {
      expect(parseQuickAddMulti('   '), isEmpty);
    });
  });
}
