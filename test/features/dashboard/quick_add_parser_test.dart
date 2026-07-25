import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/categories/data/category.dart';
import 'package:kuber/features/dashboard/utils/quick_add_parser.dart';

void main() {
  final catGroceries = Category()
    ..id = 1
    ..name = 'Groceries';
  final catDinner = Category()
    ..id = 2
    ..name = 'Dinner';

  final categories = [catGroceries, catDinner];

  group('Multi Quick Add Parser', () {
    test('splits input on "and", newlines, and commas', () {
      final segments = splitQuickAddInput('300 movies and 500 dinner, 1200 rent\n250 in groceries');
      expect(segments.length, equals(4));
      expect(segments[0], equals('300 movies'));
      expect(segments[1], equals('500 dinner'));
      expect(segments[2], equals('1200 rent'));
      expect(segments[3], equals('250 in groceries'));
    });

    test('parses individual segment into amount, category, and account hint', () {
      final item = parseQuickAddSegment('500 in dinner from HDFC', categories);
      expect(item.amount, equals(500.0));
      expect(item.categoryCandidate, equals('dinner'));
      expect(item.accountHint, equals('HDFC'));
    });

    test('parseMultiQuickAdd returns candidate items', () {
      final items = parseMultiQuickAdd('250 in groceries and 500 dinner from HDFC', categories);
      expect(items.length, equals(2));
      expect(items[0].amount, equals(250.0));
      expect(items[1].amount, equals(500.0));
      expect(items[1].accountHint, equals('HDFC'));
    });
  });
}
