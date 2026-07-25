import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/categories/data/category.dart';
import 'package:kuber/shared/utils/category_fuzzy_matcher.dart';

void main() {
  final catGroceries = Category()
    ..id = 1
    ..name = 'Groceries';
  final catMovies = Category()
    ..id = 2
    ..name = 'Movies';
  final catRent = Category()
    ..id = 3
    ..name = 'Rent';

  final categories = [catGroceries, catMovies, catRent];

  group('CategoryFuzzyMatcher', () {
    test('matches exact name case-insensitively', () {
      final res = CategoryFuzzyMatcher.match('groceries', categories);
      expect(res.kind, equals(CategoryMatchKind.exact));
      expect(res.category?.name, equals('Groceries'));
    });

    test('matches singular / plural forms', () {
      final res = CategoryFuzzyMatcher.match('grocery', categories);
      expect(res.kind, equals(CategoryMatchKind.fuzzy));
      expect(res.category?.name, equals('Groceries'));
    });

    test('matches close Levenshtein distance (e.g. "movis" -> "Movies")', () {
      final res = CategoryFuzzyMatcher.match('movis', categories);
      expect(res.kind, equals(CategoryMatchKind.fuzzy));
      expect(res.category?.name, equals('Movies'));
    });

    test('returns noMatch for unmatched categories (does not auto-create silently)', () {
      final res = CategoryFuzzyMatcher.match('skydiving', categories);
      expect(res.kind, equals(CategoryMatchKind.noMatch));
      expect(res.candidateName, equals('skydiving'));
      expect(res.category, isNull);
    });
  });
}
