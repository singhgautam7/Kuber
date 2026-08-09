import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/utils/fuzzy_category_matcher.dart';
import 'package:kuber/features/categories/data/category.dart';

Category _cat(String name, {String type = 'expense', int id = 0}) => Category()
  ..id = id == 0 ? Isar.autoIncrement : id
  ..name = name
  ..icon = 'category'
  ..colorValue = 0xFF888888
  ..type = type;

void main() {
  group('normalizeText', () {
    test('lowercases, trims, collapses whitespace', () {
      expect(normalizeText('  Groceries   Store '), 'groceries store');
    });
    test('strips one leading filler word', () {
      expect(normalizeText('on groceries'), 'groceries');
      expect(normalizeText('for movies'), 'movies');
    });
  });

  group('matchScore', () {
    test('exact beats plural beats prefix beats contains', () {
      expect(matchScore('food', 'Food'), 0);
      expect(matchScore('groceries', 'Grocery'), 1);
      expect(matchScore('trans', 'Transport'), 2);
      expect(matchScore('borrow', 'Lend/Borrow'), 3);
    });
    test('no match returns null', () {
      expect(matchScore('xyz', 'Food'), isNull);
    });
  });

  group('matchCategory', () {
    final cats = [
      _cat('Food', id: 1),
      _cat('Groceries', id: 2),
      _cat('Transport', id: 3),
      _cat('Salary', type: 'income', id: 4),
    ];

    test('exact and plural resolve to the existing category (no duplicate)', () {
      expect(matchCategory('food', cats)!.id, 1);
      expect(matchCategory('grocery', cats)!.id, 2); // singular of Groceries
      expect(matchCategory('on transport', cats)!.id, 3); // filler stripped
    });

    test('honors type filter', () {
      expect(matchCategory('salary', cats, type: 'expense'), isNull);
      expect(matchCategory('salary', cats, type: 'income')!.id, 4);
    });

    test('returns null when nothing matches', () {
      expect(matchCategory('spaceship', cats), isNull);
    });
  });
}
